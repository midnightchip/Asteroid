#import "Asteroid.h"

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




static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;
static UIView* weatherAnimation = nil;
static bool Loaded = NO;

static void updateAnimation(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if(MSHookIvar<BOOL>([%c(SBLockScreenManager) sharedInstance], "_isScreenOn") && ![prefs boolForKey:@"freezeCondition"]){
        if(MSHookIvar<NSUInteger>([objc_getClass("SBLockStateAggregator") sharedInstance], "_lockState") == 3 || MSHookIvar<NSUInteger>([objc_getClass("SBLockStateAggregator") sharedInstance], "_lockState") == 1){
            [condition resume];
        } else{
            [condition pause];
        }
    } else {
        [condition pause];
    }
}

void loadWeatherAnimation(City *city){
    NSLog(@"lock_TWEAK | loading");
	if(!Loaded){
	    if(city){
            NSLog(@"lock_TWEAK | setup");
		    weatherAnimation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            [weatherAnimation setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
				weatherAnimation.clipsToBounds = YES;
			WUIWeatherConditionBackgroundView *referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            if([prefs intForKey:@"hideWeatherBackground"] == 1){
                referenceView.background.hidesBackground = YES;
                referenceView.background.condition.hidesConditionBackground = YES;
            } else if([prefs intForKey:@"hideWeatherBackground"] == 2){
                referenceView.hidesConditions = YES;
            }

			dynamicBG = [referenceView background];
			condition = [dynamicBG condition];
            if([prefs boolForKey:@"freezeCondition"]){
                [condition pause];
            } else {
                [condition resume];
            }
			[weatherAnimation addSubview:dynamicBG];
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
            NSLog(@"lock_TWEAK | set city");
            [dynamicBG setCity: city];
        }
    }
}

void loadCityForView(){
    AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
    if(weatherModel.isPopulated){
        City *backgroundCity = weatherModel.city;
        if([prefs boolForKey:@"customCondition"]){
            backgroundCity = [weatherModel.city cityCopy];
            backgroundCity.conditionCode = [prefs doubleForKey:@"weatherConditions"];
        }
        loadWeatherAnimation(backgroundCity);
    }
}

%hook SBLockScreenManager
-(id)init{
    if((self = %orig)){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherTimer:) name:@"weatherTimerUpdate" object:nil];
    }
    return self;
}
%new
-(void) weatherTimer:(NSNotification *)notification{
    loadCityForView();
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
    %orig;
	//thank you june
	dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
			loadCityForView();
		});
}
%end

%ctor{
    if([prefs boolForKey:@"lockScreenWeather"] && [prefs boolForKey:@"kLWPEnabled"]) {
        %init();
	}
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    updateAnimation,
                                    CFSTR("com.apple.springboard.screenchanged"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
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

