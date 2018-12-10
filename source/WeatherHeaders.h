#import <CoreLocation/CoreLocation.h>

@interface City : NSObject
-(NSMutableArray*)hourlyForecasts;
-(NSMutableArray*)dayForecasts;
-(unsigned long long)conditionCode;
-(NSString *)temperature;
-(unsigned long long)sunriseTime;
-(unsigned long long)sunsetTime;
@property (assign,nonatomic) BOOL isLocalWeatherCity;
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

@interface WAForecastModel : NSObject
@property (nonatomic,retain) City * city;
-(BOOL)isPopulated;

@end

@interface WATodayModel
+(id)autoupdatingLocationModelWithPreferences:(id)arg1 effectiveBundleIdentifier:(id)arg2 ;
-(void)_fireTodayModelWantsUpdate;
-(BOOL)executeModelUpdateWithCompletion:(/*^block*/id)arg1 ;
@property (nonatomic,retain) NSDate * lastUpdateDate;
+(id)modelWithLocation:(id)arg1;
@property (nonatomic,retain) WAForecastModel * forecastModel;
-(id)location;
-(void)_executeForecastRetrievalForLocation:(id)arg1 completion:(/*^block*/id)arg2 ;
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
-(void)_executeLocationUpdateWithCompletion:(/*^block*/id)arg1;
@property (nonatomic,retain) WFGeocodeRequest * geocodeRequest;
-(void)_willDeliverForecastModel:(id)arg1 ;
@end

@interface WAWeatherPlatterViewController : UIViewController
-(id)initWithLocation:(id)arg1 ;
-(void)_buildModelForLocation:(id)arg1 ;
@property (nonatomic,retain) UIStackView * hourlyBeltView;
@property (nonatomic,retain) UIView * headerView;
-(void) _updateViewContent;
@property (nonatomic,retain) NSArray * hourlyForecastViews;
@property (nonatomic,retain) UIView * dividerLineView;
@property (nonatomic,retain) WATodayModel * model;   
@end

