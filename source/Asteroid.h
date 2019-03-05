#import "LWPProvider.h"
#import "ConditionImageType.h"
#import "AWeatherModel.h"
#import <substrate.h>
#import <CoreLocation/CoreLocation.h>

/* weather background */
@interface WUIWeatherCondition : NSObject
@property (assign,nonatomic) long long condition;
@property (nonatomic, retain) NSString *loadedFileName;
@property (nonatomic) BOOL hidesConditionBackground;
-(void)pause;
-(void)resume;
-(City *)city;
-(void)setPlaying:(BOOL)arg1;
-(BOOL)playing;
-(double)alpha;
-(void)setAlpha:(double)arg1 ;
-(void)setCondition:(long long)arg1;
@end;

@interface WUIDynamicWeatherBackground : UIView
-(void)setCity:(id)arg1 ;
-(void)setCondition:(long long)arg1 ;
-(WUIWeatherCondition *)condition;
@property (nonatomic) BOOL hidesBackground;
@end

@interface WUIWeatherConditionBackgroundView : UIView
@property (nonatomic) BOOL hidesConditions;
-(id)initWithFrame:(CGRect)arg1 ;
-(WUIDynamicWeatherBackground *)background;
-(void)prepareToSuspend;
-(void)prepareToResume;
@end

@interface WALockscreenWidgetViewController : UIViewController
@property (nonatomic,retain) WATodayModel * todayModel;
@end

