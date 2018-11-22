#import "../../source/LWPProvider.h"

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
@end

@interface WeatherPreferences
+ (id)sharedPreferences;
- (id)localWeatherCity;
-(int)loadActiveCity;
-(NSArray *)loadSavedCities;
@end

@interface City : NSObject
@end


@interface WAForecastModel
@property (nonatomic,retain) City * city;
@end

@interface WATodayAutoupdatingLocationModel
-(void)setPreferences:(WeatherPreferences *)arg1;
-(WAForecastModel *)forecastModel;
@end


