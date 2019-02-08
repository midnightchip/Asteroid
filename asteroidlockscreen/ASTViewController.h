#import "ASTGestureHandler.h"
#import "ASTGestureDelegate.h"
#import "../source/AWeatherModel.h"

@interface ASTViewController : UIViewController <ASTGestureDelegate>
-(void) setupViewStyle;
-(void) updateViewForWeatherData;
@end
