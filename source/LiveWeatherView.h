#import <UIKit/UIKit.h>

@interface LiveWeatherView : UIView
@property (nonatomic, getter=isSetup) BOOL setup;
-(void) setupTempLabel;
-(void) setupLogoView;
-(void) setupReferenceView;
-(void) weatherNotification: (NSNotification *) notification;
-(void)updateWeatherDisplay;
@end 
