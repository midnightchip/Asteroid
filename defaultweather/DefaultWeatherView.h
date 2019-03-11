#import "../source/LWPProvider.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface DefaultWeatherView : UIView
@property (nonatomic, assign) NSUInteger index;
-(instancetype) initWithFrame:(CGRect) frame index:(NSUInteger) aIndex;
@end
