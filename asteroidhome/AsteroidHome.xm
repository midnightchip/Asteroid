#import "../asteroidicon/source/Asteroid.h"
@interface SBHomeScreenView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@end 

@interface SBHomeScreenView (Weather)
-(void)updateView;
@end 



%hook SBHomeScreenView
%property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;

- (void)insertSubview:(UIView*)view atIndex:(int)index {
    %orig;
    
    if(!self.referenceView){
        WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
        City* city = [wPrefs localWeatherCity];
        if (city){
            self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
            [self.referenceView.background setCity:city];
            [[self.referenceView.background condition] resume];
            
            self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.referenceView.clipsToBounds = YES;
            [self addSubview:self.referenceView];
            [self sendSubviewToBack:self.referenceView];
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:300.0f
                                     target:self
                                   selector:@selector(updateView)
                                   userInfo:nil
                                    repeats:YES];

}
%new 
-(void)updateView{
    
    WeatherPreferences* wPrefs = [%c(WeatherPreferences) sharedPreferences];
    City* city = [wPrefs localWeatherCity];
        if (city){
            [self.referenceView removeFromSuperview];
    
            self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
            [self.referenceView.background setCity:city];
            [[self.referenceView.background condition] resume];

            self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.referenceView.clipsToBounds = YES;
            [self addSubview:self.referenceView];
            [self sendSubviewToBack:self.referenceView];
    }
}
        
%end 

@interface SBIconBlurryBackgroundView : UIView
@end 

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end 

%hook SBFolderIconBackgroundView
-(void)layoutSubviews{
    %orig;
    self.hidden = TRUE;
}
%end 

@interface SBDockView : UIView 
@end 

@interface SBWallpaperEffectView : UIView
@end 

%hook SBDockView
-(void)layoutSubviews{
    %orig;
    MSHookIvar<SBWallpaperEffectView*>(self, "_backgroundView").hidden = YES;
    MSHookIvar<UIImageView*>(self, "_backgroundImageView").hidden = YES;
}
%end 

@interface SBHighlightView : UIView
@end 

%hook SBHighlightView
-(void)layoutSubviews{
    %orig;
    self.hidden = YES;
}
%end 
