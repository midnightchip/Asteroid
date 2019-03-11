#import <UIKit/UIKit.h>
#import "../source/LWPProvider.h"
#import "../source/WeatherHeaders.h"
#import "DefaultWeatherView.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface WAPageCollectionViewController
@property (nonatomic, retain) NSArray *cities;

@end

@interface WAWeatherCardView : UIView
@property (nonatomic, retain) DefaultWeatherView *defaultWeatherView;
@property (nonatomic,retain) NSString *cityName;
@property (nonatomic, assign) BOOL isLocalWeatherCity;
@property (nonatomic, retain) UILabel *temperatureLabel;
-(id) _viewControllerForAncestor;
@end
