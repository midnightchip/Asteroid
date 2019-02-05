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
			dynamicBG = [referenceView background];
			condition = [dynamicBG condition];
			[condition resume];
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
			[dynamicBG setCity: city];
		}
		[condition resume];
	}
}

void loadCityForView(){
        AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
			loadWeatherAnimation(weatherModel.city);
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
	//thank you june
	dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
			loadCityForView();
		});
	//Thought this was needed, its not.
	/*[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(isPlaying)
                                            name:@"isPlayingSong"
											object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(stoppedPlaying)
                                            name:@"stoppedPlaying"
											object:nil];*/
}
//Observe when the animation should stop
/*
%new 
-(void)isPlaying{
	pauseAnimation();
	//[weatherAnimation removeFromSuperview];
	//Loaded = NO;
	weatherAnimation.hidden = YES;
}

%new 
-(void)stoppedPlaying{
	weatherAnimation.hidden = NO;
    loadCityForView();
}*/
%end

//Hide animation on music playing
/*%hook SBDashBoardMainPageView
- (void)layoutSubviews {
    %orig;
	if([(SpringBoard*)[UIApplication sharedApplication] nowPlayingProcessPID] == 0){
			weatherAnimation.hidden = NO;
            loadCityForView();
        } else if([(SpringBoard*)[UIApplication sharedApplication] nowPlayingProcessPID] > 0){
            pauseAnimation();
			weatherAnimation.hidden = YES;
		}
	
}
%end */

%ctor{
    if([prefs boolForKey:@"lockScreenWeather"] && [prefs boolForKey:@"kLWPEnabled"]) {
        %init();
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

