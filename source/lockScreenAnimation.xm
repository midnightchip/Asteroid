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
			//city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];
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
        AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
        [weatherModel updateWeatherDataWithCompletion:^{
            loadWeatherAnimation(weatherModel.city);
        }];  
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
