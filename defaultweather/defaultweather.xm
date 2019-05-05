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
    } else {
        self.defaultWeatherView.hidden = YES;
        self.temperatureLabel.hidden = NO;
    }
}
%end

%ctor{
    CPDistributedMessagingCenter *messagingCenter;
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
    NSDictionary *serverDict = [messagingCenter sendMessageAndReceiveReplyName:@"cityIndex" userInfo:nil/* optional dictionary */];
    NSNumber *indexValue = serverDict[@"index"];
    if(indexValue){
        [prefs setObject:indexValue forKey:@"astDefaultIndex"];
    }
    
    [prefs save];
}
