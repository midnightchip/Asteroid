#import "Asteroid.h"
#import <objc/message.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>

@interface SBHomeScreenView : UIView
//@interface SBFWallpaperView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end 

@interface SBHomeScreenView (Weather)
//@interface SBFWallpaperView (Weather)
-(void)updateView;
@end 

static NSDictionary *conditions = @{@"SevereThunderstorm" : @3,
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
};

static float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
static WUIWeatherCondition* condition = nil;

%group LiveWeather
%hook SBHomeScreenView
//%hook SBFWallpaperView
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
    City *customWeather = self.weatherModel.city;
    if([prefs boolForKey:@"customCondition"]){
        customWeather.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];
        [self.referenceView.background setCity:customWeather];
    }else{
        [self.referenceView.background setCity:self.weatherModel.city];
    }
    //self.weatherModel.city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];//16;
    
    [self.referenceView.background setTag:123];
    
    [[self.referenceView.background condition] resume];
    condition = [self.referenceView.background condition];
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self sendSubviewToBack:self.referenceView];
    
    NSLog(@"lock_TWEAK | %@", self.weatherModel.city);
}

        
%end 
static BOOL isPlaying = NO;
void pauseHome(){
	[condition pause];
    isPlaying = NO;
}
void restartHome(){
    if(!isPlaying){
        [condition resume];
        isPlaying = YES;
    }
}


%hook SBLockScreenViewControllerBase
- (void)setInScreenOffMode:(_Bool)arg1 forAutoUnlock:(_Bool)arg2{
	%orig;
		if(arg1){
			pauseHome();
		}else{
			restartHome();
		}
}
%end

%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled{
    
		NSString *currentApp;
		SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
		SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
		currentApp = [frontApp valueForKey:@"_bundleIdentifier"];
		if([currentApp isEqualToString:@"com.apple.springboard"]){
            restartHome();
        }else{
           pauseHome(); 
        }
    return %orig;
}
%end
%end 

@interface SBIconBlurryBackgroundView : UIView
@end 

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end 

/*%hook SBFolderIconImageView 
// Thanks poomsmart
- (void)_updateAccessibilityBackgroundContrast
{
	%orig;
	SBFolderIconBackgroundView *backgroundView = MSHookIvar<SBFolderIconBackgroundView *>(self, "_backgroundView");
	UIView *accessibilityBackgroundView = MSHookIvar<UIView *>(self, "_accessibilityBackgroundView");
	backgroundView.hidden = YES;
	accessibilityBackgroundView.hidden = YES;

}
%end*/

%hook SBFolderIconBackgroundView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noFolders"]){
        self.hidden = TRUE;
    }
}
//Thanks iPad_Kid, for whatever reason, the substrate update changed us from being hidden after being displayed once.
- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
    if([prefs boolForKey:@"noFolderInBackground"]){
        %orig(CGRectNull, NULL, NULL);
    
        self.backgroundColor = [UIColor clearColor];
    }
    
}
%end 
//Figure this out at a later date
/*@interface SBFolderControllerBackgroundView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end 
%hook SBFolderControllerBackgroundView 
%property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
%property (nonatomic, retain) AWeatherModel *weatherModel;

-(void)layoutSubviews{
    %orig;

    [self.referenceView removeFromSuperview];
    
    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
    //EZ custom weather animation
    City *customWeather = self.weatherModel.city;
    if([prefs boolForKey:@"customCondition"]){
        customWeather.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];
        [self.referenceView.background setCity:customWeather];
    }else{
        [self.referenceView.background setCity:self.weatherModel.city];
    }
    
    [self.referenceView.background setTag:123];
    
    [[self.referenceView.background condition] resume];
    condition = [self.referenceView.background condition];
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self bringSubviewToFront:self.referenceView];
    
}
%end*/

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
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"] && [prefs boolForKey:@"kLWPEnabled"]) {
        if([prefs boolForKey:@"homeScreenWeather"]){
            %init(LiveWeather);
            }
        if([prefs boolForKey:@"hideWeatherBackground"]){
            %init(WeatherBackground);
            }
        %init(_ungrouped);
    }
    //Thank you june
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			NSString *processName = [executablePath lastPathComponent];
			BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
			BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			if (isSpringBoard || isApplication) {
				/* Weather */
				dlopen("System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
				/* WeatherUI */
    			dlopen("System/Library/PrivateFrameworks/WeatherUI.framework/WeatherUI", RTLD_NOW);
			}
		}
    }
}
