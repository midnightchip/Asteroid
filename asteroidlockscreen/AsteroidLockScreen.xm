#include "AsteroidLockScreen.h"

//TODO Change today to use the cases in descriptions
//TODO Fix Blur on lockscreen vs just pulling down notification center
//TODO make only appear during set times
//TODO Ajust height of uilabel on text size. 
//TODO Add option for right alignment or left alignment
//TODO Add reset font sizes

// Statics
static BOOL isDismissed = NO;
static SBDashBoardMainPageView *mainPageView;
static MediaControlsPanelViewController *mediaPanelCont;
static BOOL isWeatherLocked = nil;

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *weather;
%property (retain, nonatomic) NSTimer *inactiveTimer;
%property (nonatomic, retain) AWeatherModel *weatherModel;
%property (nonatomic, retain) UILabel *notifcationLabel;
%property (nonatomic, retain) ASTViewController *gestureViewController;

- (void)layoutSubviews {
    %orig;
    // This is basically an init lol
    if(!self.weather){
        self.weather=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.weather setUserInteractionEnabled:YES];
        [self addSubview:self.weather];
        
        // Swipe Up to dismiss
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [self.weather addGestureRecognizer: swipeUp];
        
        [[NSNotificationCenter defaultCenter] addObserverForName: @"SBBacklightFadeFinishedNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
            [self.inactiveTimer invalidate];
            NSLog(@"lock_TWEAK | Timer set");
            self.inactiveTimer = [NSTimer scheduledTimerWithTimeInterval:([prefs doubleForKey:@"inactiveValue"] * 60)
                                                                  target:self
                                                                selector:@selector(revealWeather:)
                                                                userInfo:nil
                                                                 repeats:YES];
            isWeatherLocked = NO;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName: @"SBCoverSheetWillDismissNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
            [self.inactiveTimer invalidate];
            NSLog(@"lock_TWEAK | Cancel Timer");
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonPressed:) name:@"astDimissButtonPressed" object:nil];
    }
    
    // setting a static
    mainPageView = self;
    
    // Creating the notification label
    if(!self.notifcationLabel){
        self.notifcationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.weather.frame.size.width - 60, self.frame.size.height/2.5, 25, 25)];
        self.notifcationLabel.textAlignment = NSTextAlignmentCenter;
        self.notifcationLabel.textColor = [UIColor whiteColor];
        self.notifcationLabel.backgroundColor = [UIColor redColor];
        self.notifcationLabel.layer.masksToBounds = YES;
        self.notifcationLabel.adjustsFontSizeToFitWidth = YES;
        self.notifcationLabel.layer.cornerRadius = 12.5;
        
        self.notifcationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if([prefs boolForKey:@"addNotification"]){
            //[self.weather addSubview:self.notifcationLabel];
        }
    }
    
    if(!self.weatherModel){
        self.weatherModel = [%c(AWeatherModel) sharedInstance];
        //[self.weatherModel updateWeatherDataWithCompletion:^{nil;}];
    }
    
    if(!self.gestureViewController){
        self.gestureViewController = [[%c(ASTViewController) alloc] init];
        [self.weather addSubview: self.gestureViewController.view];
    }
}
// Dismiss button pressed
%new
- (void) buttonPressed: (UIButton*)sender{
    if(!self.weather.hidden){
        [UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{self.weather.alpha = 0;}
                         completion:^(BOOL finished){
                             self.weather.hidden = YES;
                             self.weather.alpha = 1;
                             
                             isDismissed = YES;
                             isWeatherLocked = YES;
                             [[NSNotificationCenter defaultCenter]
                              postNotificationName:@"weatherStateChanged"
                              object:self];
                         }];
    }
}
//Hide weather with notification
%new
- (void) hideWeather{
    if(!self.weather.hidden){
        self.weather.hidden = YES;
        isDismissed = YES;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"weatherStateChanged"
         object:self];
    }
}

// Handles reveal
%new
- (void) revealWeather: (NSTimer *) sender{
    [self updateWeatherReveal];
}
%new
-(void) updateWeatherReveal{
    self.weather.hidden = NO;
    isDismissed = NO;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"weatherStateChanged"
     object:self];
}
%end

// hacky way to catch the city name not matching with rest of forecast
%hook WATodayHeaderView
-(NSString *)locationName{
    // Checking to make sure the city name matches with the actual content
    if(![((NSString *)((WAWeatherPlatterViewController *)self._viewControllerForAncestor).model.forecastModel.city.name) isEqualToString: ((NSString *)((AWeatherModel *)[%c(AWeatherModel) sharedInstance]).city.name)]){
        // something is fucked up, force everything to update
        [[%c(AWeatherModel) sharedInstance] updateWeatherDataWithCompletion:^{nil;}];
     }
    return ((AWeatherModel *)[%c(AWeatherModel) sharedInstance]).city.name;
}
%end 

// Making sure the forecast view is the right color
%hook WAWeatherPlatterViewController
-(void) viewWillLayoutSubviews{
    for(id object in self.view.allSubviews){
        if([object isKindOfClass:%c(UILabel)]){
            UILabel *label = object;
            label.textColor = [UIColor whiteColor];
        }
        if([object isKindOfClass:%c(UIVisualEffectView)]){
            UIVisualEffectView *effect = object;
            effect.contentEffects = nil;
        }
    }
    self.dividerLineView.backgroundColor = [UIColor whiteColor];
}
%end

%hook SBDashBoardWallpaperEffectView
// removes the wallpaper view when opening camera
// checks if the blur is visible when applying the new animation
-(void)setHidden:(BOOL) arg1 {
    %orig(YES);
}
%end

%hook NCNotificationPriorityList
-(NSUInteger) count {
    mainPageView.notifcationLabel.text = [NSString stringWithFormat:@"%i", (int)%orig];
    return %orig;
}
%end

// Hide when media present
%hook MediaControlsPanelViewController
-(BOOL) isOnScreen {
    mediaPanelCont = self;
    if(%orig && !isDismissed){
        [mainPageView hideWeather];
        isWeatherLocked = YES;
    }
    return %orig;
}
%end

// Checking content
%hook NCNotificationCombinedListViewController
-(id) init{
    if((self = %orig)){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewCollectionWhenDismissed:) name:@"weatherStateChanged" object:nil];
        self.view.hidden = YES;
    }
    return self;
}
-(BOOL)hasContent{
    BOOL content = %orig;
    
    //This is some black magic, I wrote this and I have no idea whats going on. -Midnightchips & the casle 2018
    if(content && [prefs boolForKey:@"hideOnNotif"] && !isDismissed){
        [mainPageView hideWeather];
        NSLog(@"lock_TWEAK | hiding weather");
    } else if(!isWeatherLocked && isDismissed && mediaPanelCont.isOnScreen == NO && [[%c(SBMediaController) sharedInstance] isPlaying] == NO){
        if([prefs boolForKey:@"hideOnNotif"] && !content){ // Will make check hideOnNotif and content before revealing lock
            [mainPageView updateWeatherReveal];
        } else if(![prefs boolForKey:@"hideOnNotif"]){ // Do as normally would if hideOnNotif not enabled
             [mainPageView updateWeatherReveal];
        }
    }
    return content;
    
}
%new
-(void) updateViewCollectionWhenDismissed:(NSNotification *)sender{
    if(isDismissed){
        self.view.alpha = 0;
        self.view.hidden = NO;
        [UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{self.view.alpha = 1;}
                         completion:nil];
    } else {
        [UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{self.view.alpha = 1;}
                         completion:^(BOOL finished){
                             self.view.hidden = YES;
                             self.view.alpha = 1;
                         }];
    }
    
}
%end

//Blur
%hook SBDashBoardViewController
%property (nonatomic, retain) UIVisualEffectView *blurEffectView;

-(void)loadView{
    %orig;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:[prefs intForKey:@"blurAmount"]];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //always fill the view
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if([prefs boolForKey:@"addBlur"]){
    [((SBDashBoardView *)self.view).backgroundView addSubview: self.blurEffectView];
    }
    // Notification called when the lockscreen / nc is revealed (this is posted by the system)
    [[NSNotificationCenter defaultCenter] addObserverForName: @"weatherStateChanged" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        if(isDismissed){
            [UIView animateWithDuration:.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{self.blurEffectView.alpha = 0;}
                             completion:^(BOOL finished){
                                 self.blurEffectView.hidden = YES;
                                 self.blurEffectView.alpha = 1;
                             }];
        } else {
            self.blurEffectView.alpha = 0;
            self.blurEffectView.hidden = NO;
            [UIView animateWithDuration:.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{self.blurEffectView.alpha = 1;}
                             completion:nil];
        }
        
    }];
}

%end

// Debugging
/*
 %hookf(uint32_t, notify_post, const char *name) {
 uint32_t r = %orig;
 //if (strstr(name, "notification")) {
 NSLog(@"NOTI_MON: %s", name);
 //}
 return r;
 }
 %hookf(void, CFNotificationCenterPostNotification, CFNotificationCenterRef center, CFNotificationName name, const void *object, CFDictionaryRef userInfo, Boolean deliverImmediately) {
 %orig;
 NSString *notiName = (__bridge NSString *)name;
 //if ([notiName containsString:@"notification"]) {
 NSLog(@"NOTI_MON: %@", notiName);
 //}
 }
 */


/*%ctor{
    if([prefs boolForKey:@"greetView"]){
        %init(_ungrouped);
    }
    
}*/

%ctor{
    if([prefs boolForKey:@"kLWPEnabled"] && [prefs boolForKey:@"greetView"]){
        %init();
    }
    //Thank you june
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			NSString *processName = [executablePath lastPathComponent];
			BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
			BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			if (isSpringBoard || isApplication) {
				/* Weather */
				dlopen("System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
				/* WeatherUI */
    			dlopen("System/Library/PrivateFrameworks/WeatherUI.framework/WeatherUI", RTLD_NOW);
			}
		}
    }
}
