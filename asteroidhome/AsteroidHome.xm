#import "../asteroidicon/source/Asteroid.h"
#import <objc/message.h>
@interface SBHomeScreenView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end 

@interface SBHomeScreenView (Weather)
-(void)updateView;
@end 

/*static NSDictionary *conditions = @{@"SevereThunderstorm" : @3,
@"Rain" : @12,
@"Thunderstorm" : @4,
@"Haze" : @21,
@"PartlyCloudyDay" :  @30,
@"MixedRainAndSnow" : @5,
@"SnowFlurries" : @13,
@"Smoky" : @22,
@"MixedRainAndSleet" : @6,
@"ClearNight" : @31,
@"SnowShowers" : @14,
@"MixedSnowAndSleet" : @7,
@"Breezy" : @23,
@"ScatteredSnowShowers" : @40,
@"FreezingDrizzle" : @8,
@"BlowingSnow" : @15,
@"Sunny" : @32,
@"Drizzle" : @9,
@"Windy" : @24,
@"MostlySunnyNight" : @33,
@"Snow" : @16,
@"HeavySnow" : @41,
@"Frigid" : @25,
@"ScatteredSnowShowers" : @42,
@"MostlySunnyDay" : @34,
@"Hail" : @17,
@"Blizzard" : @43,
@"Cloudy" : @26,
@"MixedRainFall" : @35,
@"Sleet" : @18,
@"PartlyCloudyDay" : @44,
@"MostlyCloudyNight" : @27,
@"Hot" : @36,
@"Dust" : @19,
@"HeavyRain" : @45,
@"MostlyCloudyDay" : @28,
@"IsolatedThunderstorms" : @37,
@"SnowShowers" : @46,
@"PartlyCloudyNight" : @29,
@"ScatteredShowers" : @38,
@"IsolatedThundershowers" : @47,
@"ScatteredThunderstorms" : @39,
@"Tornado" : @0,
@"FreezingRain" : @10,
@"TropicalStorm" : @1,
@"Showers1" : @11,
@"Hurricane" : @2,
@"Fog" : @20
};*/

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
    
    //self.weatherModel.city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];//16;
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
