#import "../asteroidicon/source/Asteroid.h"
#import <objc/message.h>
@interface SBHomeScreenView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic,retain) NSTimer *refreshTimer;
@property (nonatomic, retain) WATodayAutoupdatingLocationModel *todayModel;
-(void) updateView: (City *) city;
@end 

@interface SBHomeScreenView (Weather)
-(void)updateView: (City *) city;
-(void) updateWeatherData;
@end 

static float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

%group LiveWeather
%hook SBHomeScreenView
%property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
%property (nonatomic,retain) NSTimer *refreshTimer;
%property (nonatomic, retain) WATodayAutoupdatingLocationModel *todayModel;

- (void)layoutSubviews {
    %orig;
    if(!self.referenceView){

        [self updateWeatherData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherTimer:) name:@"weatherTimerUpdate" object:nil];
    }
}
%new
- (void) weatherTimer: (NSNotification *)notification{
    [self updateWeatherData];
}

%new
-(void) updateView: (City *) city{
    
    [self.referenceView removeFromSuperview];
    
    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
    [self.referenceView.background setCity:city];
    [self.referenceView.background setTag:123];
    
    [[self.referenceView.background condition] resume];
    
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self sendSubviewToBack:self.referenceView];
    
    NSLog(@"lock_TWEAK | %@", city);
}

%new 
-(void)updateWeatherData{
    
    NSLog(@"lock_TWEAK | updateView");
    
    if([prefs boolForKey:@"isLocal"]){
        //This sets up local weather, and anyone on github better appreciate this - the casle
        WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
        self.todayModel = [NSClassFromString(@"WATodayModel") autoupdatingLocationModelWithPreferences: wPrefs effectiveBundleIdentifier:@"com.apple.weather"];
        [self.todayModel.locationManager forceLocationUpdate];
        [self.todayModel _executeLocationUpdateForLocalWeatherCityWithCompletion:^{
            if(self.todayModel.geocodeRequest.geocodedResult){
                WATodayModel *modelFromLocation = [%c(WATodayModel) modelWithLocation:self.todayModel.geocodeRequest.geocodedResult];
                [modelFromLocation executeModelUpdateWithCompletion:^{
                    [self.todayModel _willDeliverForecastModel:modelFromLocation.forecastModel];
                    self.todayModel.forecastModel = modelFromLocation.forecastModel;
                    [self updateView:modelFromLocation.forecastModel.city];
                }];
            } else NSLog(@"lock_TWEAK | didnt work");
        }];
        
    } else {
        [self updateView:[[%c(WeatherPreferences) sharedPreferences] cityFromPreferencesDictionary:[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]]];
    }
}
        
%end 
%end 

@interface SBIconBlurryBackgroundView : UIView
@end 

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end 

%hook SBFolderIconBackgroundView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noFolders"]){
        self.hidden = TRUE;
    }
}
%end 

//Dock 
@interface SBDockView : UIView 
@end 

@interface SBWallpaperEffectView : UIView
@end 

%hook SBDockView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noDock"]){
        MSHookIvar<SBWallpaperEffectView*>(self, "_backgroundView").hidden = YES;
        MSHookIvar<UIImageView*>(self, "_backgroundImageView").hidden = YES;
    }
}
%end 

@interface SBHighlightView : UIView
@end 

%hook SBHighlightView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noDock"]){
        self.hidden = YES;
    } 
}
%end 

//Hide background accross views
//Thanks June
%group WeatherBackground
%hook WUIDynamicWeatherBackground
	-(id)gradientLayer{
		return nil;
		return %orig;
	}
	-(void)setCurrentBackground:(CALayer *)arg1{

	}
	-(void)setBackgroundCache:(NSCache *)arg1{
	
	}
	/* 11.1.2 Still nees improving */ 
	-(void)addSublayer:(id)arg1{
		%orig;
			if(deviceVersion < 11.3){
				CALayer* layer = arg1;
				for(CALayer* firstLayers in layer.sublayers){
					if(firstLayers.backgroundColor){
						firstLayers.backgroundColor = [UIColor clearColor].CGColor;
					}
					for(CALayer* secLayers in firstLayers.sublayers){
						for(CALayer* thrLayers in secLayers.sublayers){
							if([thrLayers isKindOfClass:[CAGradientLayer class]]){
								thrLayers.hidden = YES;
							}
						}
					}
				}
			}
	}
%end
%end 

%ctor{
    if([prefs boolForKey:@"homeScreenWeather"]){
        %init(LiveWeather);
	}
    if([prefs boolForKey:@"hideWeatherBackground"]){
        %init(WeatherBackground);
    }
    %init(_ungrouped);
    
    dlopen("/System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
}
