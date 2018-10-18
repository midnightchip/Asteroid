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
@property (nonatomic,retain) UIView * locationLabel;   
//@property (nonatomic,retain) UIView * conditionsLabel;  
@property (nonatomic,retain) UILabel * conditionsLabel;
@end

@interface WALockscreenWidgetViewController : UIViewController
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
@end

@interface UIBlurEffect (lockweather)
+(id)effectWithBlurRadius:(double)arg1 ;
@end
