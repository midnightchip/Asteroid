#import <UIKit/UIKit.h>
#import <CSWeather/CSWeatherStore.h>

@interface LiveWeatherView : UIView
@property (nonatomic, getter=isSetup) BOOL setup;
-(void) setupTempLabel;
-(void) setupLogoView;
-(void) setupReferenceView;
-(void) weatherNotification: (NSNotification *) notification;
-(void) startCSWeatherBlock;
@end 
