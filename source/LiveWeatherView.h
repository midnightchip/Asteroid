#import <UIKit/UIKit.h>
#import <CSWeather/CSWeatherStore.h>

@interface LiveWeatherView : UIView 
- (void)updateWeatherDisplay;
-(void) setupTempLabel;
-(void) setupLogoView;
-(void) setupReferenceView;
-(void) startCSWeatherBlock;
@end 
