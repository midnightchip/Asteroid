#import <LWPProvider.h>
#import <CSWeather/CSWeatherInformationProvider.h>
#import <AudioToolbox/AudioToolbox.h>
#import <notify.h>

@interface UIView (tweak_cat)
-(id) _viewDelegate;
-(id) _gestureRecognizers;

@end

//help from the_casle on the blur
@interface SBUIBackgroundView : UIView
@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@property (nonatomic, retain) UIImageView *blurImgView;
-(void) recieveAdjustAlpha:(NSNotification*)notification;
@end

@interface SBDashBoardViewController : UIViewController 
@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@end 

@interface SBDashBoardView : UIView
@property (nonatomic, retain) SBUIBackgroundView *backgroundView;
@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@end

//Other Interfaces 
@interface WATodayPadView : UIView
- (id)initWithFrame:(CGRect)frame;
@property (nonatomic,retain) NSString * locationName;
@property (nonatomic,retain) UILabel * conditionsLabel;
@property (nonatomic,retain) UILabel * locationNCNotificationCombinedListViewControllerLabel;
@property (nonatomic,retain) NSString * conditionsLine;
@property (nonatomic,retain) NSString * temperature;
@end

@interface WFTemperature
-(CGFloat)temperatureForUnit:(int)arg1;
@end

@interface WADayForecast
@property (nonatomic, retain) WFTemperature *high;
@property (nonatomic, retain) WFTemperature *low;
@end

@interface WAForecastModel
@property (nonatomic, retain) NSArray *dailyForecasts;
@end

@interface WALockscreenWidgetViewController : UIViewController
+(id) sharedInstanceIfExists;
-(void) updateWeather;
@property (nonatomic, retain) WAForecastModel *currentForecastModel;
@property (nonatomic, retain) WATodayPadView *todayView;
@end

@interface WAWeatherCityView
@property(retain, nonatomic) UILabel *naturalLanguageDescriptionLabel;
@end

@interface WAWeatherPlatterViewController : UIViewController
@end


@interface SBDashBoardMainPageView : UIView
@property (nonatomic, retain) UIView *weather;
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *greetingLabel;
@property (nonatomic, retain) UILabel *wDescription;
@property (nonatomic, retain) UILabel *currentTemp;
@property (retain, nonatomic) UIVisualEffectView *blurView;
@property (retain, nonatomic) UIButton *dismissButton;
@property (retain, nonatomic) WALockscreenWidgetViewController *weatherCont;
@property (retain, nonatomic) NSTimer *refreshTimer;
@property (retain, nonatomic) NSTimer *inactiveTimer;
-(void)updateImage:(NSNotification *) notification;
@property (nonatomic, retain) NSDictionary *centerDict;
- (void)tc_animateFilter: (UIView *)view;
-(void) updateLockView;
@property (nonatomic, retain) UILabel *notifcationLabel;
@end

@interface UIBlurEffect (lockweather)
+(id)effectWithBlurRadius:(double)arg1 ;
@end

@interface SBDashBoardCombinedListViewController

@end

@interface SBDashBoardMainPageContentViewController
@property (nonatomic,readonly) SBDashBoardCombinedListViewController * combinedListViewController;
@end


@interface NCNotificationCombinedListViewController : UIViewController
-(BOOL) hasContent;
@end

@interface UILabel (lockTweak)
-(BOOL) checkForGesture;
@end

@interface UIFont (lock)
@property (nonatomic, readonly) double pointSizeForScaling;
@property (nonatomic, readonly) double pointSize;
- (double)_scaledValueForValue:(double)arg1;
-(id) _fontScaledByScaleFactor:(double)arg1;
@end


@interface SBLockScreenManager
+(id)sharedInstance;
@property (readonly) BOOL isLockScreenActive;
@property (readonly) BOOL isLockScreenVisible;
@property (readonly) BOOL isUILocked;
-(BOOL)isUIUnlocking;
-(BOOL)hasUIEverBeenLocked;
@end

@interface SBCoverSheetSlidingViewController
- (long long)dismissalSlidingMode;
//@property (nonatomic, retain) SBCoverSheetPanelBackgroundContainerView *panelBackgroundContainerView;
@end
