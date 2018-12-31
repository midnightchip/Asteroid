#import "LiveWeather.h"
#import "LiveWeatherView.h"
#include "notify.h"
#import "Asteroid.h"

@interface LiveWeatherView ()
@property (assign, nonatomic) BOOL readyForUpdates;
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *temp;
@property (nonatomic, strong) CSWeatherStore *store;
@end

@implementation LiveWeatherView

static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;

//Find a place to store this
//static NSDictionary *conditions = nil;


- (instancetype)initWithFrame:(CGRect)frame {
NSDictionary *conditions = @{@"SevereThunderstorm" : @3,
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

    if(self = [super initWithFrame:frame]) {
        /*dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){*/
        //dispatch_async(dispatch_get_main_queue(), ^{
            if([prefs boolForKey:@"customAppColor"]){
                self.backgroundColor = [prefs colorForKey:@"appColor"];
            }else{
                self.backgroundColor = [UIColor clearColor];
            }
            //colorWithRed:0.118 green:0.118 blue:0.125 alpha:1.00];
            self.clipsToBounds = YES;
            City *city = ([[%c(WeatherPreferences) sharedPreferences] isLocalWeatherEnabled] ? [[%c(WeatherPreferences) sharedPreferences] localWeatherCity] : [[%c(WeatherPreferences) sharedPreferences] cityFromPreferencesDictionary:[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]]);
            //if(city){

            //self.store =
            [CSWeatherStore weatherStoreForLocalWeather:YES autoUpdateInterval:15 savedCityIndex:0 updateHandler:^(CSWeatherStore *store) {
                //Temperature Data
                self.temp = [[UILabel alloc]init];
                self.temp.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                self.temp.text = store.currentTemperatureLocale;
                self.temp.textColor = [UIColor whiteColor];
                self.temp.textAlignment = NSTextAlignmentCenter;
                [self.temp setCenter:CGPointMake(self.frame.size.width / 1.9, self.frame.size.height / 1.3)];
                [self addSubview: self.temp];
                
                //Icon
                self.logo = [[UIImageView alloc] init];//WithFrame:self.frame];
                self.logo.frame = CGRectMake(0, 0, self.frame.size.width /1.5 , self.frame.size.height /1.5 );
                UIImage *icon;
                icon = store.currentConditionImageSmall;
                self.logo.image = icon;
                self.logo.contentMode = UIViewContentModeScaleAspectFit;
                [self.logo setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2.5)];
                //self.logo.center = self.center;
                
                /*self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                 //TODO enable changing this color
                 [self.logo setTintColor:[UIColor whiteColor]];
                 self.logo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;*/
                [self addSubview: self.logo];
                
                [self.logo.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
                [self.logo.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
                [self.logo.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
                [self.logo.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
                
                //Live background
                //if([prefs boolForKey:@"appScreenWeather"]){
                    WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
                    WATodayAutoupdatingLocationModel *todayModel = [[%c(WATodayAutoupdatingLocationModel) alloc] init];
                
                    [todayModel setPreferences:wPrefs];
                    
                //[[%c(WeatherPreferences) sharedPreferences] isLocalWeatherEnabled]
                if([prefs boolForKey:@"appScreenWeather"]){
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4);
                    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
                    if([prefs boolForKey:@"customConditionIcon"]){
                        city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditionsIcon"]] doubleValue];
                    }
                    [self.referenceView.background setCity:city];
                    
                    [[self.referenceView.background condition] resume];
                
                    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    self.referenceView.clipsToBounds = YES;
                    [self addSubview:self.referenceView];
                    [self sendSubviewToBack:self.referenceView];
        
                
                    [self.referenceView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
                    [self.referenceView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
                    [self.referenceView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
                    [self.referenceView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
                    });
                }
                //}
                
                
            }];
        //}
        //});
    }
    
    return self;
}
-(void)updateWeatherDisplay{
//Objective-C requires this to be done in runtime rather than compile time. objective-C++ doesn't have this restriction.
NSDictionary *conditions = @{@"SevereThunderstorm" : @3,
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

    /*ispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){*/
        WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
        WATodayAutoupdatingLocationModel *todayModel = [[%c(WATodayAutoupdatingLocationModel) alloc] init];
        
        [todayModel setPreferences:wPrefs];
        City *city = ([[%c(WeatherPreferences) sharedPreferences] isLocalWeatherEnabled] ? [[%c(WeatherPreferences) sharedPreferences] localWeatherCity] : [[%c(WeatherPreferences) sharedPreferences] cityFromPreferencesDictionary:[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]]);
        
        //self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.bounds];
        //if([prefs boolForKey:@"appScreenWeather"]){
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            if([prefs boolForKey:@"customConditionIcon"]){
                city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditionsIcon"]] doubleValue];
            }
            [self.referenceView.background setCity:city];
            [[self.referenceView.background condition] resume];
            self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        });
        //}else{

       // }
        //[self addSubview:self.referenceView];
        //[self sendSubviewToBack:self.referenceView];
        //if(city){
            [CSWeatherStore weatherStoreForLocalWeather:YES autoUpdateInterval:15 savedCityIndex:0 updateHandler:^(CSWeatherStore *store) {
                UIImage *icon;
                icon = store.currentConditionImageSmall;
                self.logo.image = icon;
                self.logo.contentMode = UIViewContentModeScaleAspectFit;
                self.logo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                 [self.logo setTintColor:[UIColor whiteColor]];
                
                self.temp.text = store.currentTemperatureLocale;
                //TODO set adaptive color
                self.temp.textColor = [UIColor whiteColor];
                
            }];
        //}
        city = nil;
    //});
    
}

@end


%ctor{
    if([prefs boolForKey:@"kLWPEnabled"]){
        %init();
    }
    //Thank you june
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			NSString *processName = [executablePath lastPathComponent];
			BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
			BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			if (isSpringBoard || isApplication) {
				/* Weather */
				dlopen("System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
				/* WeatherUI */
    			dlopen("System/Library/PrivateFrameworks/WeatherUI.framework/WeatherUI", RTLD_NOW);
			}
		}
    }
}
