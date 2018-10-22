#import <LWPProvider.h>
#import <CSWeather/CSWeatherInformationProvider.h>

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
@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *currentTemp;
@property (retain, nonatomic) UIVisualEffectView *blurView;
@property (retain, nonatomic) UIButton *dismissButton;
@property (retain, nonatomic) WALockscreenWidgetViewController *weatherCont;
@property (retain, nonatomic) NSTimer *refreshTimer;
@end

@interface UIBlurEffect (lockweather)
+(id)effectWithBlurRadius:(double)arg1 ;
@end


@interface NCNotificationCombinedListViewController : UIViewController
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
