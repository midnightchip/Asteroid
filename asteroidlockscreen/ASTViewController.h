#import "ASTGestureHandler.h"
#import "ASTGestureDelegate.h"
#import "ASTComponentView.h"
#import "../source/AWeatherModel.h"
#import "../source/WeatherHeaders.h"

@interface ASTViewController : UIViewController <ASTGestureDelegate>
-(void) setupViewStyle;
-(void) updateViewForWeatherData;
@end
