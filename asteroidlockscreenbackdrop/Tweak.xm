#import "../asteroidicon/source/Asteroid.h"

@interface SBAlert : UIViewController
@end

@interface SBLockScreenViewControllerBase : SBAlert
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
@property (readonly) BOOL isUILocked;
@end


@interface SBLockScreenViewController : SBLockScreenViewControllerBase
-(id)lockScreenView;
@end

@interface SBLockScreenView : UIView
@end

@interface SBDashBoardView : UIView
@end
//TODO THIS REALLY NEEDS TO BE CENTRALIZED
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
@"Fog" : @20};


static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;
static UIView* weatherAnimation = nil;
static bool Loaded = NO;

void loadWeatherAnimation(City *city){
	if(!Loaded){
	    if(city){
		    weatherAnimation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
				weatherAnimation.clipsToBounds = YES;
			WUIWeatherConditionBackgroundView *referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
			//Covering all of my bases. This is redundant
			//referenceView.background.condition = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];
			dynamicBG = [referenceView background];
			condition = [dynamicBG condition];
			[condition resume];
			[weatherAnimation addSubview:dynamicBG];
			//Bases covered.
			city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];
			[dynamicBG setCity: city];
			SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];

			if([manager isUILocked]){
				if (manager != nil) {
					SBLockScreenViewController* lockViewController = MSHookIvar<SBLockScreenViewController*>([%c(SBLockScreenManager) sharedInstance], "_lockScreenViewController");
			     	UIView* lockView = MSHookIvar<SBLockScreenView*>(lockViewController, "_view");
			     	if([lockView isKindOfClass:[%c(SBDashBoardView) class]]){
			     		UIView *scrollView = MSHookIvar<SBDashBoardView*>(lockView, "_backgroundView");
			     		[scrollView addSubview:weatherAnimation];
						[scrollView sendSubviewToBack:weatherAnimation];
						Loaded = YES;
			     	}
				}
			}
		}
	}else{
		if(city){
			[dynamicBG setCity: city];
		}
		[condition resume];
	}
}

void loadCityForView(){
    if([prefs boolForKey:@"isLocal"]){
        AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
        [weatherModel updateWeatherDataWithCompletion:^{
            loadWeatherAnimation(weatherModel.city);
        }];
    } else {
        City *city = [[%c(WeatherPreferences) sharedPreferences] cityFromPreferencesDictionary:[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
        loadWeatherAnimation(city);
    }
}

/* remove view from screen */
void pauseAnimation(){
	[condition pause];
}


%hook SBLockScreenViewControllerBase
	- (void)setInScreenOffMode:(_Bool)arg1 forAutoUnlock:(_Bool)arg2{
		%orig;
		if(arg1){
			pauseAnimation();
		}else{
            loadCityForView();
		}
	}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
    %orig;
    loadCityForView();
}
%end

%ctor{
    if([prefs boolForKey:@"lockScreenWeather"]){
        %init();
	}
}
