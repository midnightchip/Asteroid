#import "../source/LWPProvider.h"
#import "../source/ConditionOption.h"
#import <AudioToolbox/AudioToolbox.h>
#import <notify.h>
#import <substrate.h>
#import <CoreLocation/CoreLocation.h>
#import "../source/AWeatherModel.h"
#import "ASTViewController.h"
#import <SpringBoard/SpringBoard.h>


@interface UIView (tweak_cat)
-(id) _viewDelegate;
-(id) _gestureRecognizers;
@property (nonatomic, retain) NSArray *allSubviews;

@end


@interface MediaControlsPanelViewController
@property (nonatomic) BOOL isOnScreen;
+(id)panelViewControllerForCoverSheet;
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

@interface WADayForecast
@property (nonatomic, retain) WFTemperature *high;
@property (nonatomic, retain) WFTemperature *low;
@end

@interface WAWeatherCityView
@property(retain, nonatomic) UILabel *naturalLanguageDescriptionLabel;
@end

@interface SBDashBoardMainPageView : UIView
@property (nonatomic, retain) UIView *weather;
@property (nonatomic, retain) AWeatherModel *weatherModel;
@property (nonatomic, retain) ASTViewController *gestureViewController;

-(id) _viewControllerForAncestor;
-(void)updateImage:(NSNotification *) notification;
- (void)tc_animateFilter: (UIView *)view;
-(void) updateWeatherReveal;
-(void) updateLockView;
-(void) hideWeather;
@end

@interface UIBlurEffect (lockweather)
+(id)effectWithBlurRadius:(double)arg1 ;
@end

@interface SBDashBoardCombinedListViewController

@end

@interface SBDashBoardMainPageContentViewController
@property (nonatomic,readonly) SBDashBoardCombinedListViewController * combinedListViewController;
@property (assign,getter=isTransitioning,nonatomic) BOOL transitioning;
@end


@interface NCNotificationCombinedListViewController : UIViewController
-(BOOL) hasContent;
@end

@interface UILabel (lockTweak)
-(BOOL) checkForGesture;
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

@interface SBIdleTimerDefaults
-(double)minimumLockscreenIdleTime;
@end

@interface SBDashBoardIdleTimerProvider : NSObject
@property (getter=isIdleTimerEnabled,nonatomic,readonly) BOOL idleTimerEnabled;
- (void)addDisabledIdleTimerAssertionReason:(id)arg1;
- (void)removeDisabledIdleTimerAssertionReason:(id)arg1;
@end

@interface UIVisualEffectView (asteroid)
@property (nonatomic,copy) NSArray * contentEffects;
@end

@interface SBDashBoardWallpaperEffectView : UIView
@end

@interface SBMediaController
-(BOOL) isPlaying;
@end
