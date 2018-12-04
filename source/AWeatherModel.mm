#include "AWeatherModel.h"



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
    if([prefs boolForKey:@"isLocal"]){
        self.localWeather = YES;
        //This sets up local weather, and anyone on github better appreciate this - the casle
        self.weatherPreferences = [objc_getClass("WeatherPreferences") sharedPreferences];
        self.locationProviderModel = [NSClassFromString(@"WATodayModel") autoupdatingLocationModelWithPreferences: self.weatherPreferences effectiveBundleIdentifier:@"com.apple.weather"];
        [self.locationProviderModel.locationManager forceLocationUpdate];
        [self.locationProviderModel _executeLocationUpdateForLocalWeatherCityWithCompletion:^{
            if(self.locationProviderModel.geocodeRequest.geocodedResult){
                self.todayModel = [objc_getClass("WATodayModel") modelWithLocation:self.locationProviderModel.geocodeRequest.geocodedResult];
                [self.todayModel executeModelUpdateWithCompletion:^{
                    self.forecastModel = self.todayModel.forecastModel;
                    [self.locationProviderModel _willDeliverForecastModel:self.forecastModel];
                    self.locationProviderModel.forecastModel = self.forecastModel;
                    self.city = self.forecastModel.city;
                    [self postNotification];
                    [self setUpRefreshTimer];
                    compBlock();
                }];
            } else NSLog(@"lock_TWEAK | didnt work");
        }];
        
    } else {
        self.localWeather = NO;
        self.city = [[objc_getClass("WeatherPreferences") sharedPreferences] cityFromPreferencesDictionary:[[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
        compBlock();
    }
    
}

-(void)setUpRefreshTimer{
    // Creating a refresh timer
    if(!self.refreshTimer){
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
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
