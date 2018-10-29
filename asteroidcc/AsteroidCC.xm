#import "../asteroidicon/source/Asteroid.h"

@interface CCUIModularControlCenterOverlayViewController : UIViewController
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@end 

%hook CCUIModularControlCenterOverlayViewController
%property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
-(void)viewWillLayoutSubviews{
    %orig;

    /*UIView *picker = [[UIView alloc] initWithFrame:self.view.bounds];
    picker.backgroundColor=[UIColor blueColor];
    [self.view addSubview: picker];
    [self.view sendSubviewToBack:picker];*/
    WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
                City* city = [wPrefs localWeatherCity];
                if (city){
                    self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.view.frame];
                    [self.referenceView.background setCity:city];
                    [[self.referenceView.background condition] resume];

                    self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    self.referenceView.clipsToBounds = YES;
        }
        
}

-(id)_beginPresentationAnimated:(BOOL)arg1 interactive:(BOOL)arg2{
    [UIView animateWithDuration:0.1f animations:^{
        [self.view setAlpha:1.0f];
        [self.view insertSubview:self.referenceView atIndex:1];
        } completion:nil];
    return %orig;
}

-(id)_beginDismissalAnimated:(BOOL)arg1 interactive:(BOOL)arg2{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setAlpha:0.0f];
        [self.referenceView removeFromSuperview];
        } completion:nil];
    return %orig;
}
%end 