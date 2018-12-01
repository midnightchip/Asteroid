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
-(void) update;
-(NSDate*) updateTime;
@end

@interface WeatherLocationManager : NSObject
+(id)sharedWeatherLocationManager;
-(BOOL)locationTrackingIsReady;
-(void)setLocationTrackingReady:(BOOL)arg1 activelyTracking:(BOOL)arg2 watchKitExtension:(id)arg3;
-(void)setLocationTrackingActive:(BOOL)arg1;
-(CLLocation*)location;
-(void)setDelegate:(id)arg1;
-(void)forceLocationUpdate;
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

@interface TWCLocationUpdater
+(id)sharedLocationUpdater;
-(void)updateWeatherForLocation:(id)arg1 city:(id)arg2 ;
@end

@interface WAForecastModel
@property (nonatomic,retain) City * city;
@end

@interface WATodayModel
+(id)autoupdatingLocationModelWithPreferences:(id)arg1 effectiveBundleIdentifier:(id)arg2 ;
-(void)_fireTodayModelWantsUpdate;
-(BOOL)executeModelUpdateWithCompletion:(/*^block*/id)arg1 ;
@property (nonatomic,retain) NSDate * lastUpdateDate;  

@end

@interface WFLocation

@end

@interface WFGeocodeRequest
@property (retain) WFLocation * geocodedResult;
@end

@interface WATodayAutoupdatingLocationModel : WATodayModel
-(BOOL)_reloadForecastData:(BOOL)arg1 ;
-(void)setPreferences:(WeatherPreferences *)arg1;
-(WAForecastModel *)forecastModel;
@property (assign,nonatomic) unsigned long long citySource;
@property (nonatomic,retain) WeatherLocationManager * locationManager;
@property (assign,nonatomic) BOOL isLocationTrackingEnabled;
-(void)_executeLocationUpdateForLocalWeatherCityWithCompletion:(/*^block*/id)arg1 ;
@property (nonatomic,retain) WFGeocodeRequest * geocodeRequest;
@end
@interface WALockscreenWidgetViewController : UIViewController
@property (nonatomic,retain) WATodayModel * todayModel;
@end

