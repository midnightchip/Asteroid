#import "LiveWeather.h"
#import "LiveWeatherView.h"
#include "notify.h"
#import "Asteroid.h"

@interface LiveWeatherView ()
@property (assign, nonatomic) BOOL readyForUpdates;
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *temp;
@end

@implementation LiveWeatherView

static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;



- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundColor = [UIColor clearColor];//colorWithRed:0.118 green:0.118 blue:0.125 alpha:1.00];
            self.clipsToBounds = YES;
            [[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
                //Temperature Data
                self.temp = [[UILabel alloc]init];
                self.temp.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                self.temp.text = weather[@"kCurrentTemperatureForLocale"];
                self.temp.textColor = [UIColor whiteColor];
                self.temp.textAlignment = NSTextAlignmentCenter;
                [self.temp setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 1.2)];
                [self addSubview: self.temp];

                //Icon
                self.logo = [[UIImageView alloc] init];//WithFrame:self.frame];
                self.logo.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
                UIImage *icon;
                icon = weather[@"kCurrentConditionImage_black-variant"];
                self.logo.image = icon;
                self.logo.contentMode = UIViewContentModeScaleAspectFit;
                self.logo.center = self.center;
                
                self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                //TODO enable changing this color
                [self.logo setTintColor:[UIColor whiteColor]];
                self.logo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self addSubview: self.logo];

                [self.logo.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:4].active = YES;
                [self.logo.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-4].active = YES;
                [self.logo.topAnchor constraintEqualToAnchor:self.topAnchor constant:4].active = YES;
                [self.logo.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
                //Live background
                WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
                City* city = [wPrefs localWeatherCity];
                    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
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
           
            }];
        });
    }

    return self;
}
-(void)updateWeatherDisplay{
        dispatch_async(dispatch_get_main_queue(), ^{
        WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
        City* city = [wPrefs localWeatherCity];
            //self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.bounds];
            [self.referenceView.background setCity:city];
            [[self.referenceView.background condition] resume];
            self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            //[self addSubview:self.referenceView];
            //[self sendSubviewToBack:self.referenceView];
        [[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
          UIImage *icon;
          icon = weather[@"kCurrentConditionImage_black-variant"];
          self.logo.image = icon;
          self.logo.contentMode = UIViewContentModeScaleAspectFit;
          self.logo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
          self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
          [self.logo setTintColor:[UIColor whiteColor]];

          self.temp.textColor = [UIColor whiteColor];

        }];
    });

}

@end
