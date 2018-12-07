#import "../../source/LWPProvider.h"
#import "../../source/AWeatherModel.h"
#import <CoreLocation/CoreLocation.h>

/* weather background */
@interface WUIWeatherCondition : NSObject
-(void)pause;
-(void)resume;
@property (assign,nonatomic) long long condition;
@end;

@interface WUIDynamicWeatherBackground : UIView
-(void)setCity:(id)arg1 ;
-(void)setCondition:(long long)arg1 ;
-(WUIWeatherCondition *)condition;
@end

@interface WUIWeatherConditionBackgroundView : UIView
-(id)initWithFrame:(CGRect)arg1 ;
-(WUIDynamicWeatherBackground *)background;
-(void)prepareToSuspend;
-(void)prepareToResume;
@end

@interface WALockscreenWidgetViewController : UIViewController
@property (nonatomic,retain) WATodayModel * todayModel;
@end

