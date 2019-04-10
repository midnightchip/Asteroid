#import "LiveWeather.h"
#import "LiveWeatherView.h"
#include "notify.h"
#import "Asteroid.h"

@interface LiveWeatherView ()
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) CAGradientLayer *gradientLayer;
@property (nonatomic, retain) UIView *gradientView;
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *temp;
-(CAGradientLayer *) gradientFromWeatherGradient:(WUIGradientLayer *) weatherGradient;
@end

@implementation LiveWeatherView{
    AWeatherModel *_weatherModel;
}

static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        if([prefs boolForKey:@"customAppColor"]) self.backgroundColor = [prefs colorForKey:@"appColor"];
        else self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        _weatherModel = [%c(AWeatherModel) sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherNotification:) name:@"weatherTimerUpdate" object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self updateWeatherDisplay]; // New instances will need to be setup immediate instead of on notification.
        });
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
    if(![prefs boolForKey:@"appScreenWeather"]){
        self.referenceView.hidesConditions = YES;
    }
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self sendSubviewToBack:self.referenceView];
    
    [self.referenceView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
    [self.referenceView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
    [self.referenceView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
    [self.referenceView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
    
    self.gradientView = [[UIView alloc] initWithFrame:self.frame];
    self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gradientView.clipsToBounds = YES;
    [self addSubview:self.gradientView];
    [self sendSubviewToBack:self.gradientView];
    
    [self.gradientView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
    [self.gradientView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
    [self.gradientView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
    [self.gradientView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
}

-(void) weatherNotification: (NSNotification *) notification{
    [self updateWeatherDisplay];
    
}

-(void)updateWeatherDisplay{    
    if([prefs boolForKey:@"appIcon"]){
        if(!self.isSetup){
            [self setupTempLabel];
            [self setupLogoView];
            if([prefs boolForKey:@"appScreenWeatherBackground"]) [self setupReferenceView];
            self.setup = YES;
        }
        
        self.temp.text = [_weatherModel localeTemperature];
        [self.temp layoutSubviews];
        
        UIImage *icon;
        icon = [_weatherModel glyphWithOption:ConditionOptionWhite];
        self.logo.image = icon;
        [self.logo layoutSubviews];
        [self layoutSubviews];
        
        if([prefs boolForKey:@"appScreenWeatherBackground"] && _weatherModel.isPopulated){
            City *backgroundCity = _weatherModel.city;
            if([prefs boolForKey:@"customConditionIcon"]){
                backgroundCity = [_weatherModel.city cityCopy];
                backgroundCity.conditionCode = [prefs doubleForKey:@"weatherConditionsIcon"];
            }
            [self.referenceView.background setCity:backgroundCity];
            if(![prefs boolForKey:@"appScreenWeather"]){
                self.gradientLayer.hidden = NO;
                self.referenceView.hidden = YES;
                [[self.referenceView.background condition] pause];
                
                self.gradientLayer = [self gradientFromWeatherGradient: self.referenceView.background.gradientLayer];
                self.gradientLayer.frame = self.gradientView.frame;
                self.gradientView.layer.sublayers = nil;
                [self.gradientView.layer insertSublayer:self.gradientLayer atIndex:0];
            } else {
                self.gradientView.hidden = YES;
                self.referenceView.hidden = NO;
                [[self.referenceView.background condition] resume];
            }
        } else {
            self.referenceView.backgroundColor = [UIColor grayColor];
        }
    }
}
-(CAGradientLayer *) gradientFromWeatherGradient:(WUIGradientLayer *) weatherGradient{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = weatherGradient.colors;
    gradientLayer.locations = weatherGradient.locations;
    gradientLayer.type = weatherGradient.type;
    gradientLayer.startPoint = weatherGradient.startPoint;
    gradientLayer.endPoint = weatherGradient.endPoint;
    return gradientLayer;
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
