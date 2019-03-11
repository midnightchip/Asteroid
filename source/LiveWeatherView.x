#import "LiveWeather.h"
#import "LiveWeatherView.h"
#include "notify.h"
#import "Asteroid.h"

@interface LiveWeatherView ()
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *temp;
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
    NSLog(@"lock_TWEAK | just made reference: %f", self.referenceView.background.gradientLayer.bounds.size.height);
    if(![prefs boolForKey:@"appScreenWeather"]){
        self.referenceView.hidesConditions = YES;
    }
    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.referenceView.clipsToBounds = YES;
    [self addSubview:self.referenceView];
    [self sendSubviewToBack:self.referenceView];
    //self.referenceView.background.gradientLayer = nil;
    //self.referenceView.background.gradientLayer.bounds = self.frame; // Need to work on this.
    //self.referenceView.background.gradientLayer.position = CGPointMake(0,0);
    
    [self.referenceView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
    [self.referenceView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
    [self.referenceView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
    [self.referenceView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
    NSLog(@"lock_TWEAK | end of reference: %f", self.referenceView.background.gradientLayer.bounds.size.height);
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
            if([prefs boolForKey:@"customConditionIcon"]){
                _weatherModel.city.conditionCode = [prefs doubleForKey:@"weatherConditionsIcon"];
            }
            [self.referenceView.background setCity:_weatherModel.city];
            
            [[self.referenceView.background condition] resume];
            self.referenceView.background.gradientLayer.enableExpectedRect = YES;
            self.referenceView.background.gradientLayer.expectedRect = self.frame;
            NSLog(@"lock_TWEAK | right after setting condition: %f", self.referenceView.background.gradientLayer.bounds.size.height);
        } else {
            self.referenceView.backgroundColor = [UIColor grayColor];
        }
    }
}
@end

%hook WUIGradientLayer
%property (nonatomic, assign) BOOL enableExpectedRect;
%property (nonatomic, assign) CGRect expectedRect;
/*-(void) setBounds:(CGRect) aFrame{
    if(self.enableExpectedRect){
        %orig(self.expectedRect);
    } else %orig;
}*/
-(void) setFrame:(CGRect) aFrame{
    %orig(CGRectMake(0,0,60,60));
}
-(CGRect) frame{
    return self.expectedRect;
}
/*-(CGRect) bounds{
    return self.expectedRect;
}*/
%end

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
