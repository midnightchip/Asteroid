#import "defaultweather.h"

%hook WAWeatherCardView
%property (nonatomic, retain) DefaultWeatherView *defaultWeatherView;
-(void) layoutSubviews{
    if(!self.isLocalWeatherCity){
        [self.defaultWeatherView removeFromSuperview];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        self.temperatureLabel.hidden = YES;
        int i = 0;
        for(NSDictionary *cityInArray in [[[objc_getClass("WeatherPreferences") userDefaultsPersistence]userDefaults] objectForKey:@"Cities"]){
            if([self.cityName isEqualToString:cityInArray[@"Name"]]){
                self.defaultWeatherView = [[DefaultWeatherView alloc] initWithFrame:CGRectMake(screenWidth - 70, 20, 100, 50) index:(NSUInteger)i];
                [self addSubview: self.defaultWeatherView];
                break;
            } else i++;
        }
    }
}
%end
