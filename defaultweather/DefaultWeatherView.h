#import "../source/LWPProvider.h"

@interface DefaultWeatherView : UIView
@property (nonatomic, assign) NSUInteger index;
-(instancetype) initWithFrame:(CGRect) frame index:(NSUInteger) aIndex;
@end
