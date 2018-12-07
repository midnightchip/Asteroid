#import "../asteroidicon/source/Asteroid.h"
#import <objc/message.h>
@interface SBHomeScreenView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end 

@interface SBHomeScreenView (Weather)
-(void)updateView;
@end 

static float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

%group LiveWeather
%hook SBHomeScreenView
%property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
%property (nonatomic, retain) AWeatherModel *weatherModel;

- (void)layoutSubviews {
    %orig;
    if(!self.referenceView){
        self.weatherModel = [%c(AWeatherModel) sharedInstance];
        [self.weatherModel updateWeatherDataWithCompletion:^{
            [self updateView];
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherTimer:) name:@"weatherTimerUpdate" object:nil];
    }
}
%new
- (void) weatherTimer: (NSNotification *)notification{
    [self updateView];
}

%new
-(void) updateView{
    [self.referenceView removeFromSuperview];
    
    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
    //EZ custom weather animation
    
    self.weatherModel.city.conditionCode = 16;
    [self.referenceView.background setCity:self.weatherModel.city];
    [self.referenceView.background setTag:123];
    
    [[self.referenceView.background condition] resume];
    
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self sendSubviewToBack:self.referenceView];
    
    NSLog(@"lock_TWEAK | %@", self.weatherModel.city);
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
