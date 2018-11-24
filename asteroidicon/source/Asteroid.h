#import "../../source/LWPProvider.h"
#import <CoreLocation/CoreLocation.h>

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

@interface City : NSObject
-(NSMutableArray*)hourlyForecasts;
-(NSMutableArray*)dayForecasts;
-(unsigned long long)conditionCode;
-(NSString *)temperature;
-(unsigned long long)sunriseTime;
-(unsigned long long)sunsetTime;
-(BOOL)isDay;
-(NSDate*) updateTime;
@end

@interface WeatherLocationManager : NSObject
+(id)sharedWeatherLocationManager;
-(BOOL)locationTrackingIsReady;
-(void)setLocationTrackingReady:(BOOL)arg1 activelyTracking:(BOOL)arg2 watchKitExtension:(id)arg3;
-(void)setLocationTrackingActive:(BOOL)arg1;
-(CLLocation*)location;
-(void)setDelegate:(id)arg1;
@end

@interface WeatherPreferences
+ (id)sharedPreferences;
- (id)localWeatherCity;
-(int)loadActiveCity;
-(NSArray *)loadSavedCities;
+(id)userDefaultsPersistence;
-(NSDictionary*)userDefaults;
-(void)setLocalWeatherEnabled:(BOOL)arg1;
-(City*)cityFromPreferencesDictionary:(id)arg1;
-(BOOL)isCelsius;
@end


@interface WAForecastModel
@property (nonatomic,retain) City * city;
@end

@interface WATodayAutoupdatingLocationModel
-(void)setPreferences:(WeatherPreferences *)arg1;
-(WAForecastModel *)forecastModel;
@end


