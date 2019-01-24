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

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        if([prefs boolForKey:@"customAppColor"]) self.backgroundColor = [prefs colorForKey:@"appColor"];
        else self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherNotification:) name:@"weatherTimerUpdate" object:nil];
        [self startCSWeatherBlock]; // New instances will need to be setup immediate instead of on notification.
    }
    return self;
}

-(void) setupTempLabel{
    self.temp = [[UILabel alloc]init];
    self.temp.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.temp.textColor = [UIColor whiteColor];
    self.temp.textAlignment = NSTextAlignmentCenter;
    [self.temp setCenter:CGPointMake(self.frame.size.width / 1.9, self.frame.size.height / 1.3)];
    [self addSubview: self.temp];
}

-(void) setupLogoView{
    self.logo = [[UIImageView alloc] init];
    self.logo.frame = CGRectMake(0, 0, self.frame.size.width /1.5 , self.frame.size.height /1.5 );
    self.logo.contentMode = UIViewContentModeScaleAspectFit;
    [self.logo setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2.5)];
    [self addSubview: self.logo];
    
    [self.logo.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
    [self.logo.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
    [self.logo.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
    [self.logo.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
}

-(void) setupReferenceView{
    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self sendSubviewToBack:self.referenceView];
    
    [self.referenceView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
    [self.referenceView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
    [self.referenceView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
    [self.referenceView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
}

-(void) weatherNotification: (NSNotification *) notification{
    [self startCSWeatherBlock];
}

-(void) startCSWeatherBlock{
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
    
    self.store = [CSWeatherStore weatherStoreForLocalWeather:YES updateHandler:^(CSWeatherStore *store) {
        if([prefs boolForKey:@"appIcon"]){
            if(!self.isSetup){
                [self setupTempLabel];
                [self setupLogoView];
                if([prefs boolForKey:@"appScreenWeather"]) [self setupReferenceView];
                self.setup = YES;
            }
            
            self.temp.text = store.currentTemperatureLocale;
            
            UIImage *icon;
            icon = store.currentConditionImageSmall;
            self.logo.image = icon;
            
            if([prefs boolForKey:@"appScreenWeather"]){
                AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
                if([prefs boolForKey:@"customConditionIcon"]){
                    weatherModel.city.conditionCode = [[conditions objectForKey:[prefs stringForKey:@"weatherConditionsIcon"]] doubleValue];
                }
                [self.referenceView.background setCity:weatherModel.city];
                
                [[self.referenceView.background condition] resume];
            }
        }
    }];
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
