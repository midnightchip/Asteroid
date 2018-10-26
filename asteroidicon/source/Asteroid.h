#import <../../source/LWPProvider.h>

/* weather background */
@interface WUIWeatherCondition : NSObject
-(void)pause;
-(void)resume;
@end;

@interface WUIDynamicWeatherBackground : UIView
-(void)setCity:(id)arg1 ;
-(WUIWeatherCondition *)condition;
@end

@interface WUIWeatherConditionBackgroundView : UIView
  -(id)initWithFrame:(CGRect)arg1 ;
  -(WUIDynamicWeatherBackground *)background;
  -(void)prepareToSuspend;
-(void)prepareToResume;
@end;

@interface WeatherPreferences
+ (id)sharedPreferences;
- (id)localWeatherCity;
@end

@interface City : NSObject
@end
