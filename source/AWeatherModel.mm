#include "AWeatherModel.h"

static NSDictionary *conditions = @{@"SevereThunderstorm" : @3,
@"Rain" : @12,
@"Thunderstorm" : @4,
@"Haze" : @21,
@"PartlyCloudyDay" :  @30,
@"MixedRainAndSnow" : @5,
@"SnowFlurries" : @13,
@"Smoky" : @22,
@"MixedRainAndSleet" : @6,
@"ClearNight" : @31,
@"SnowShowers" : @14,
@"MixedSnowAndSleet" : @7,
@"Breezy" : @23,
@"ScatteredSnowShowers" : @40,
@"FreezingDrizzle" : @8,
@"BlowingSnow" : @15,
@"Sunny" : @32,
@"Drizzle" : @9,
@"Windy" : @24,
@"MostlySunnyNight" : @33,
@"Snow" : @16,
@"HeavySnow" : @41,
@"Frigid" : @25,
@"ScatteredSnowShowers" : @42,
@"MostlySunnyDay" : @34,
@"Hail" : @17,
@"Blizzard" : @43,
@"Cloudy" : @26,
@"MixedRainFall" : @35,
@"Sleet" : @18,
@"PartlyCloudyDay" : @44,
@"MostlyCloudyNight" : @27,
@"Hot" : @36,
@"Dust" : @19,
@"HeavyRain" : @45,
@"MostlyCloudyDay" : @28,
@"IsolatedThunderstorms" : @37,
@"SnowShowers" : @46,
@"PartlyCloudyNight" : @29,
@"ScatteredShowers" : @38,
@"IsolatedThundershowers" : @47,
@"ScatteredThunderstorms" : @39,
@"Tornado" : @0,
@"FreezingRain" : @10,
@"TropicalStorm" : @1,
@"Showers1" : @11,
@"Hurricane" : @2,
@"Fog" : @20
};

@implementation AWeatherModel{
    // iVars if needed
}

- (instancetype) init{
    if(self = [super init]){
    }
    return self;
}

+ (instancetype)sharedInstance {
    static AWeatherModel *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AWeatherModel alloc] init];
    });
    return sharedInstance;
}

-(void)updateWeatherDataWithCompletion:(completion) compBlock{
    //if([[objc_getClass("WeatherPreferences") sharedPreferences] isLocalWeatherEnabled]){
        //self.localWeather = YES;
        //This sets up local weather, and anyone on github better appreciate this - the casle
        self.weatherPreferences = [objc_getClass("WeatherPreferences") sharedPreferences];
        self.locationProviderModel = [NSClassFromString(@"WATodayModel") autoupdatingLocationModelWithPreferences: self.weatherPreferences effectiveBundleIdentifier:@"com.apple.weather"];
        [self.locationProviderModel.locationManager forceLocationUpdate];
        [self.locationProviderModel _executeLocationUpdateForLocalWeatherCityWithCompletion:^{
            if(self.locationProviderModel.geocodeRequest.geocodedResult){
                self.geoLocation = self.locationProviderModel.geocodeRequest.geocodedResult;
                self.todayModel = [objc_getClass("WATodayModel") modelWithLocation:self.locationProviderModel.geocodeRequest.geocodedResult];
                [self.todayModel executeModelUpdateWithCompletion:^{
                    self.forecastModel = self.todayModel.forecastModel;
                    [self.locationProviderModel _willDeliverForecastModel:self.forecastModel];
                    self.locationProviderModel.forecastModel = self.forecastModel;
                    self.city = self.forecastModel.city;
                    self.localWeather = self.city.isLocalWeatherCity;
                    self.populated = YES;
                    
                    self.fakeCity = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
                    
                    [self postNotification];
                    [self setUpRefreshTimer];
                    compBlock();
                }];
                
            } else{
                NSLog(@"lock_TWEAK | didnt work");
                self.city = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
                self.localWeather = self.city.isLocalWeatherCity;
                self.populated = YES;
                [self postNotification];
                [self setUpRefreshTimer];
                compBlock();
            }
        }];
        
    /*} else {
        self.localWeather = NO;
        self.city = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
        if([prefs boolForKey:@"customCondition"]){
            self.city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditions"]] doubleValue];
        }
        
        compBlock();
    }*/
}

-(void)setUpRefreshTimer{
    // Creating a refresh timer
    if(!self.refreshTimer){
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:([prefs doubleForKey:@"refreshRate"] * 60)
                                                             target:self
                                                           selector:@selector(updateWeather:)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}
-(void) updateWeather: (NSTimer *) sender {
    [self updateWeatherDataWithCompletion:^{
        [self postNotification];
    }];
    
}
-(void) postNotification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"weatherTimerUpdate"
         object:nil];
    });
}
@end
