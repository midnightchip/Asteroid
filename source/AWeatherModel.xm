#include "AWeatherModel.h"

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
            [self updateWeatherDataWithCompletion:^{
                [self setUpRefreshTimer];
            }];
        } else{
            NSLog(@"lock_TWEAK | didnt work");
            [self handleDefault];
            [self postNotification];
            [self setUpRefreshTimer];
        }
    }];
    [self.locationProviderModel setIsLocationTrackingEnabled:NO];
}

-(void)updateWeatherDataWithCompletion:(completion) compBlock{
    self.todayModel = [objc_getClass("WATodayModel") autoupdatingLocationModelWithPreferences:self.weatherPreferences effectiveBundleIdentifier:@"com.apple.weather"];
    [self.todayModel setLocationServicesActive:YES];
    [self.todayModel setIsLocationTrackingEnabled:YES];
    [self.todayModel executeModelUpdateWithCompletion:^(BOOL arg1, NSError *error) {
        if(!error){
            self.forecastModel = self.todayModel.forecastModel;
            self.city = self.forecastModel.city;
            [self verifyAndCorrectCondition];
            self.localWeather = self.city.isLocalWeatherCity;
            [self.todayModel setIsLocationTrackingEnabled:NO];
            self.populated = YES;
            self.hasFallenBack = NO;
            
        } else {
            [self handleDefault];
        }
        [self postNotification];
        if(compBlock) compBlock();
    }];
}

-(void)setUpRefreshTimer{
    // Creating a refresh timer
    if(!self.refreshTimer){
        if([prefs doubleForKey:@"refreshRate"] < 30){
            [prefs setObject: @(300) forKey:@"refreshRate"];
            [prefs save];
        }
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:[prefs doubleForKey:@"refreshRate"]
                                                             target:self
                                                           selector:@selector(updateWeather:)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}
-(void) updateWeather: (NSTimer *) sender {
    [self updateWeatherDataWithCompletion:nil];
}
-(void) postNotification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"weatherTimerUpdate"
         object:nil];
    });
}

-(void) handleDefault{
    if(((NSArray *)[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"]).count > 0){
        if(![prefs intForKey:@"astDefaultIndex"] && [[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults].count > 0){
            self.city = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][([[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults].count - 1)]];
        }else {
            self.city = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][[prefs intForKey:@"astDefaultIndex"]]];
        }
        [self verifyAndCorrectCondition];
        self.localWeather = self.city.isLocalWeatherCity;
        self.todayModel = [objc_getClass("WATodayModel") modelWithLocation:self.city.wfLocation];
        [self.todayModel executeModelUpdateWithCompletion:^{nil;}];
        self.forecastModel = self.todayModel.forecastModel;
        self.populated = YES;
        self.hasFallenBack = NO;
    } else {
        self.hasFallenBack = YES;
    }
}

-(void) verifyAndCorrectCondition{
    NSInteger conditionCode = [self.city conditionCode];
    NSString *conditionImageName = conditionCode < 3200 ? [WeatherImageLoader conditionImageNameWithConditionIndex:conditionCode] : nil;
    ConditionImageType type = [self conditionImageTypeForString: conditionImageName];
    
    // Handling special conditions that dont return glyphs:
    if(conditionCode == 7){
        self.city.conditionCode = 6;
    }
    
    // These codes are specific to day or night and have to be verified.
    if(conditionCode == 44 ||
       conditionCode == 30 ||
       conditionCode == 29 ||
       conditionCode == 34 ||
       conditionCode == 33 ||
       conditionCode == 32 ||
       conditionCode == 31 ||
       conditionCode == 28 ||
       conditionCode == 27){
        if(self.city.isDay && type == ConditionImageTypeNight){
            self.city.conditionCode ++;
        }else if(!self.city.isDay && type == ConditionImageTypeDay){
            if(conditionCode == 44){ // why are there two PartlyCloudyDay idk.
                conditionCode = 29;
            } else {
                self.city.conditionCode --;
            }
        }
    }
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
    if(!self.hasFallenBack){
        return [NSString stringWithFormat:@"%.0f°", [self.weatherPreferences isCelsius] ? self.city.temperature.celsius : self.city.temperature.fahrenheit];
    } else {
        return @"--";
    }
}

- (NSString *)currentConditionOverview {
    if(!self.hasFallenBack){
        return [self.city naturalLanguageDescription];
    } else {
        return @"Weather Unavailable";
    }
    
}

-(UIImage *) glyphWithOption:(ConditionOption) option{
    NSInteger conditionCode = [self.city conditionCode];
    NSString *conditionImageName = conditionCode < 3200 ? [WeatherImageLoader conditionImageNameWithConditionIndex:conditionCode] : nil;
    ConditionImageType type = [self conditionImageTypeForString: conditionImageName];
    NSString *rootName;
    
    switch (type) {
        case ConditionImageTypeDefault: {
            if(ConditionOptionDefault){
                return [self imageForKey:[conditionImageName stringByAppendingString:@"-nc"]];
            } else if(ConditionOptionWhite){
                return [self imageForKey:[conditionImageName stringByAppendingString:@"-white"]];
            } else if(ConditionOptionBlack){
                return [self imageForKey:[conditionImageName stringByAppendingString:@"-black"]];
            }
        } break;
            
        case ConditionImageTypeDay: {
            if([conditionImageName containsString:@"thunderstorm"]){
                rootName = [[conditionImageName stringByReplacingOccurrencesOfString:@"-" withString:@"_"] stringByReplacingOccurrencesOfString:@"_day" withString:@""];
            } else {
                rootName = [[conditionImageName stringByReplacingOccurrencesOfString:@"-day" withString:@""] stringByReplacingOccurrencesOfString:@"_day" withString:@""];
            }
            
            if(ConditionOptionDefault){
                return [self imageForKey:[rootName stringByAppendingString:@"_day-nc"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-day-nc"]];
            } else if(ConditionOptionWhite){
                return [self imageForKey:[rootName stringByAppendingString:@"_day-white"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-day-white"]];
            } else if(ConditionOptionBlack){
                return [self imageForKey:[rootName stringByAppendingString:@"_day-black"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-day-black"]];
            }
        } break;
            
        case ConditionImageTypeNight: {
            if([conditionImageName containsString:@"thunderstorm"]){
                rootName = [[conditionImageName stringByReplacingOccurrencesOfString:@"-" withString:@"_"] stringByReplacingOccurrencesOfString:@"_night" withString:@""];
            } else {
                rootName = [[conditionImageName stringByReplacingOccurrencesOfString:@"-night" withString:@""] stringByReplacingOccurrencesOfString:@"_night" withString:@""];
            }
            
            if(ConditionOptionDefault){
                return [self imageForKey:[rootName stringByAppendingString:@"_night-nc"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-night-nc"]];
            } else if(ConditionOptionWhite){
                return [self imageForKey:[rootName stringByAppendingString:@"_night-white"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-night-white"]];
            } else if(ConditionOptionBlack){
                return [self imageForKey:[rootName stringByAppendingString:@"_night-black"]] ? :
                [self imageForKey:[rootName stringByAppendingString:@"-night-black"]];
            }
        } break;
    }
    return nil;
}

-(ConditionImageType) conditionImageTypeForString: (NSString *) conditionString{
    if([conditionString containsString:@"day"]){
        return ConditionImageTypeDay;
    } else if([conditionString containsString:@"night"]){
        return ConditionImageTypeNight;
    } else return ConditionImageTypeDefault;
}

@end

%ctor{
    // Used to kickstart AWeatherModel.
    [[%c(AWeatherModel) sharedInstance] _kickStartWeatherFramework];
}
