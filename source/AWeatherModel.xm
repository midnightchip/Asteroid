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

typedef NSDictionary<NSString *, NSString *> *ConditionTable;
enum {
    ConditionImageTypeDefault = 0,
    ConditionImageTypeDay = 1,
    ConditionImageTypeNight = 2
};
typedef NSUInteger ConditionImageType;

@implementation AWeatherModel{
    NSBundle *_weatherBundle;
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

-(void) _kickStartWeatherFramework{
    self.weatherPreferences = [objc_getClass("WeatherPreferences") sharedPreferences];
    self.locationProviderModel = [NSClassFromString(@"WATodayModel") autoupdatingLocationModelWithPreferences: self.weatherPreferences effectiveBundleIdentifier:@"com.apple.weather"];
    [self.locationProviderModel setLocationServicesActive:YES];
    [self.locationProviderModel setIsLocationTrackingEnabled:YES];

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
                
                [self postNotification];
                [self setUpRefreshTimer];
            }];
            
        } else{
            NSLog(@"lock_TWEAK | didnt work");
            
            self.city = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
            self.localWeather = self.city.isLocalWeatherCity;
            self.todayModel = [objc_getClass("WATodayModel") modelWithLocation:self.city.wfLocation];
            [self.todayModel executeModelUpdateWithCompletion:^{nil;}];
            self.populated = YES;
            [self postNotification];
            [self setUpRefreshTimer];
        }
    }];
    [self.locationProviderModel setIsLocationTrackingEnabled:NO];
}

-(void)updateWeatherDataWithCompletion:(completion) compBlock{
    if(self.isPopulated){
        if(![self.todayModel isKindOfClass:objc_getClass("WATodayAutoupdatingLocationModel")]){
            self.todayModel = [objc_getClass("WATodayModel") autoupdatingLocationModelWithPreferences:self.weatherPreferences effectiveBundleIdentifier:@"com.apple.weather"];
        }
        [self.todayModel setLocationServicesActive:YES];
        [self.todayModel setIsLocationTrackingEnabled:YES];
        [self.todayModel executeModelUpdateWithCompletion:^(BOOL arg1, NSError *arg2) {
            self.forecastModel = self.todayModel.forecastModel;
            self.city = self.forecastModel.city;
            
            [self.todayModel setIsLocationTrackingEnabled:NO];
            [self postNotification];
            compBlock();
        }];
    }
}

-(void)setUpRefreshTimer{
    // Creating a refresh timer
    if(!self.refreshTimer){
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:([prefs doubleForKey:@"refreshRate"])
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

// Below methods from https://github.com/CreatureSurvive/CSWeather
- (UIImage *)imageForKey:(NSString *)key {
    return [UIImage imageNamed:key inBundle:[self weatherBundle] compatibleWithTraitCollection:nil];
}

- (NSBundle *)weatherBundle {
    if (!_weatherBundle) {
        _weatherBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Weather.framework"];
        [_weatherBundle load];
    }
    
    return _weatherBundle;
}

-(NSString *) localeTemperature{
    return [NSString stringWithFormat:@"%.0f°", [self.weatherPreferences isCelsius] ? self.city.temperature.celsius : self.city.temperature.fahrenheit];
}

- (NSString *)currentConditionOverview {
    return [self.city naturalLanguageDescription];
}

-(UIImage *) glyphWithOption:(NSInteger) option{
    NSInteger conditionCode = [self.city conditionCode];
    NSString *conditionImageName = conditionCode < 3200 ? [WeatherImageLoader conditionImageNameWithConditionIndex:conditionCode] : nil;
    ConditionImageType type = [conditionImageName containsString:@"day"] ? ConditionImageTypeDay : [conditionImageName containsString:@"night"] ? ConditionImageTypeNight : ConditionImageTypeDefault;
    NSString *rootName;
    
    switch (type) {
        case ConditionImageTypeDefault: {
            if((int)option == 0){
                return [self imageForKey:[conditionImageName stringByAppendingString:@"-nc"]];
            } else if((int)option == 1){
                return [self imageForKey:[conditionImageName stringByAppendingString:@"-white"]];
            } else if((int)option == 2){
                return [self imageForKey:[conditionImageName stringByAppendingString:@"-black"]];
            }
        } break;
            
        case ConditionImageTypeDay: {
            rootName = [[conditionImageName stringByReplacingOccurrencesOfString:@"-day" withString:@""] stringByReplacingOccurrencesOfString:@"_day" withString:@""];
            
            if((int)option == 0){
                return [self imageForKey:[rootName stringByAppendingString:@"_day-nc"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-day-nc"]];
            } else if((int)option == 1){
                return [self imageForKey:[rootName stringByAppendingString:@"_day-white"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-day-white"]];
            } else if((int)option == 2){
                return [self imageForKey:[rootName stringByAppendingString:@"_day-black"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-day-black"]];
            }
        } break;
            
        case ConditionImageTypeNight: {
            rootName = [[conditionImageName stringByReplacingOccurrencesOfString:@"-night" withString:@""] stringByReplacingOccurrencesOfString:@"_night" withString:@""];
            
            if((int)option == 0){
                return [self imageForKey:[rootName stringByAppendingString:@"_night-nc"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-night-nc"]];
            } else if((int)option == 1){
                return [self imageForKey:[rootName stringByAppendingString:@"_night-white"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-night-white"]];
            } else if((int)option == 2){
                return [self imageForKey:[rootName stringByAppendingString:@"_night-black"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-night-black"]];
            }
        } break;
    }
    return nil;
}

@end

%ctor{
    // Used to kickstart AWeatherModel.
    [[%c(AWeatherModel) sharedInstance] _kickStartWeatherFramework];
}
