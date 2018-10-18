#include <CSWeather/CSWeatherInformationProvider.h>
#include "lockweather.h"

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *weather;
%property (nonatomic, retain) UIImageView *logo;
%property (nonatomic, retain) UILabel *greetingLabel;
%property (nonatomic, retain) UILabel *description;
%property (nonatomic, retain) UILabel *currentTemp;
%property (retain, nonatomic) UIVisualEffectView *blurView;

- (void)layoutSubviews {
	%orig;

	//UIImage *icon;
	[[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
    //NSString *condition = weather[@"kCurrentFeelsLikefahrenheit"];
    //NSString *temp = weather[@"kCurrentTemperatureForLocale"];
    UIImage *icon = weather[@"kCurrentConditionImage_nc-variant"];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    //CleanUp
    if(self.logo){
        [self.logo removeFromSuperview];
    }
    if(self.greetingLabel){
        [self.greetingLabel removeFromSuperview];
    }
    if(self.description){
        [self.description removeFromSuperview];
    }
    if(self.currentTemp){
        [self.currentTemp removeFromSuperview];
    }

	self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/3.6, screenHeight/2, 100, 225)];
    self.logo.image = icon;
    self.logo.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.logo];
	NSLog(@"YEET %@", self.logo);
    
    //Current Temperature Localized
    self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2, 100, 225)];
    if(weather[@"kCurrentTemperatureFahrenheit"] != nil){
        self.currentTemp.text = weather[@"kCurrentTemperatureFahrenheit"];
    }else{
        self.currentTemp.text = @"Error";
    }
    self.currentTemp.textAlignment = NSTextAlignmentCenter;
    self.currentTemp.font = [UIFont systemFontOfSize: 50 weight: UIFontWeightLight];//UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin);//[UIFont UIFontWeightSemibold:50];
    self.currentTemp.textColor = [UIColor whiteColor];
    [self addSubview: self.currentTemp];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH"];
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDate *currentTime;
    currentTime = [NSDate date];
    //[dateFormat stringFromDate:currentTime];

    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, 115)];

    switch ([[dateFormat stringFromDate:currentTime] intValue]){
        case 0 ... 4:
        self.greetingLabel.text = @"Good Evening";
        break;

        case 5 ... 11:
        self.greetingLabel.text = @"Good Morning";
        break; 

        case 12 ... 17:
        self.greetingLabel.text = @"Good Afternoon";
        break;

        case 18 ... 24:
        self.greetingLabel.text = @"Good Evening";
        break;
    }
    
    self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    self.greetingLabel.font = [UIFont systemFontOfSize: 40 weight: UIFontWeightLight];//[UIFont boldSystemFontOfSize:40];
    self.greetingLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.greetingLabel];

    self.description = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/21, self.frame.size.height/2, self.frame.size.width/1.1, 100)];
    self.description.text = weather[@"kCurrentDescription"];
    self.description.textAlignment = NSTextAlignmentCenter;
    self.description.lineBreakMode = NSLineBreakByWordWrapping;
    self.description.numberOfLines = 0;
    self.description.textColor = [UIColor whiteColor];
    self.description.font = [UIFont systemFontOfSize:20];
    [self addSubview:self.description];
	}];
                                           
}

%end

//Blur 
%hook SBDashBoardViewController
%property (nonatomic, retain) UIVisualEffectView *notifEffectView;

-(void)loadView{
    %orig;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:20];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //always fill the view
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //[self.view addSubview:blurEffectView];
    //[self.view sendSubviewToBack: blurEffectView];
    [((SBDashBoardView *)self.view).backgroundView addSubview: blurEffectView];
}
%end 