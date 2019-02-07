#include "AsteroidLockScreen.h"

//TODO Change today to use the cases in descriptions
//TODO Fix Blur on lockscreen vs just pulling down notification center
//TODO make only appear during set times
//TODO Ajust height of uilabel on text size. 
//TODO Add option for right alignment or left alignment
//TODO Add reset font sizes


#define DIRECTORY_PATH @"/var/mobile/Library/Asteroid"
#define FILE_PATH @"/var/mobile/Library/Asteroid/centerData.plist"

extern "C" NSString * NSStringFromCGAffineTransform(CGAffineTransform transform);

// external functions
extern void hapticFeedbackSoft();

NSBundle *tweakBundle = [NSBundle bundleWithPath:@"/Library/Application Support/lockWeather.bundle"];


//NSString *alertTitle = [tweakBundle localizedStringForKey:@"ALERT_TITLE" value:@"" table:nil];

// Statics
static BOOL isDismissed = NO;
static BOOL tc_editing;
static double lastZoomValue = 0;
static SBDashBoardMainPageView *mainPageView;
static MediaControlsPanelViewController *mediaPanelCont;
static NSNumber *initialIconFrame;
static NSNumber *initialForeFrame;
static BOOL isWeatherLocked = nil;


// Setting the gestures function
void setGesturesForView(UIView *superview, UIView *view){
    [view setUserInteractionEnabled:YES];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:superview action:@selector(tc_movingFilter:)];
    panGestureRecognizer.enabled = NO;
    [view addGestureRecognizer: panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:superview action:@selector(tc_zoomingFilter:)];
    pinchGestureRecognizer.enabled = NO;
    [view addGestureRecognizer: pinchGestureRecognizer];
    
    UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:superview action:@selector(tc_toggleEditMode:)];
    [view addGestureRecognizer: tapGestureRecognizer];
}

static void createDirectoryAndFile(){
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if(![fileManager fileExistsAtPath:FILE_PATH isDirectory:&isDir]){
        [fileManager createFileAtPath:FILE_PATH contents:nil attributes:nil];
    }
}

static void savingValuesToFile(SBDashBoardMainPageView *sender){
    SBDashBoardMainPageView *self = sender;
    NSDictionary *viewDict = @{ @"logo" : [NSValue valueWithCGPoint:self.logo.center], @"greetingLabel" : [NSValue valueWithCGPoint:self.greetingLabel.center], @"wDescription" : [NSValue valueWithCGPoint:self.wDescription.center], @"currentTemp" : [NSValue valueWithCGPoint:self.currentTemp.center], @"dismissButton" : [NSValue valueWithCGPoint:self.dismissButton.center], @"notificationLabel" : [NSValue valueWithCGPoint:self.notifcationLabel.center], @"forecastContView" : [NSValue valueWithCGPoint:self.forecastCont.view.center]
        
    };
    
    createDirectoryAndFile();
    [[NSKeyedArchiver archivedDataWithRootObject:viewDict] writeToFile:FILE_PATH atomically:YES];
}

// Master update notification
static void updatePreferenceValues(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    SBDashBoardMainPageView *self = (__bridge SBDashBoardMainPageView *)observer;
    
    // Resetting sizing.
    if([prefs boolForKey:@"resetSizing"]){
        /*
        [prefs removeObjectForKey:@"greetingSize"];
        [prefs removeObjectForKey:@"wDescriptionSize"];
        [prefs removeObjectForKey:@"tempSize"];
        [prefs removeObjectForKey:@"iconSize"];
        */
        [prefs setObject: @(NO) forKey:@"resetSizing"];
        [prefs save];
    }
    
    // Updating currentTemp font
    if([prefs boolForKey:@"customFont"]){
        self.currentTemp.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"tempSize"]];
    }else{
        self.currentTemp.font = [UIFont systemFontOfSize: [prefs intForKey:@"tempSize"] weight: UIFontWeightLight];
    }
    self.currentTemp.textColor = [prefs colorForKey:@"textColor"];
    
    // Setting Greeting Label Font
    if([prefs boolForKey:@"customFont"]){
        self.greetingLabel.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"greetingSize"]];
    }else{
        self.greetingLabel.font = [UIFont systemFontOfSize:[prefs intForKey:@"greetingSize"] weight: UIFontWeightLight];
    }
    self.greetingLabel.textColor = [prefs colorForKey:@"textColor"];
    
    // Setting the font for the wDescription
    if([prefs boolForKey:@"customFont"]){
        self.wDescription.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"wDescriptionSize"]];
    }else{
        self.wDescription.font = [UIFont systemFontOfSize:[prefs intForKey:@"wDescriptionSize"]];
    }
    self.wDescription.textColor = [prefs colorForKey:@"textColor"];
    
    // Setting the font for the dismissButton
    if([prefs boolForKey:@"customFont"]){
        self.dismissButton.titleLabel.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"dismissButtonSize"]];
    }else{
        self.dismissButton.titleLabel.font = [UIFont systemFontOfSize:[prefs intForKey:@"dismissButtonSize"]];
    }
    self.dismissButton.titleLabel.textColor = [prefs colorForKey:@"textColor"];
    
   if(![prefs boolForKey:@"enableForeHeader"]){
       
       self.forecastCont.headerView.hidden = YES;
       self.forecastCont.headerView = nil;
        self.forecastCont.dividerLineView.hidden = TRUE;
    }
    
    if(![prefs boolForKey:@"enableForeTable"]){
        self.forecastCont.hourlyForecastViews = nil;
        self.forecastCont.dividerLineView.hidden = TRUE;
    }
    
    if(![prefs boolForKey:@"enableForeHeader"] && ![prefs boolForKey:@"enableForeTable"]){
        [self.forecastCont.view removeFromSuperview];
    }
    
    // Reseting location
    if([prefs boolForKey:@"resetXY"]){
        self.centerDict = nil;
        
        // Just some rect stuff
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        self.logo.frame = CGRectMake(screenWidth/3.6, screenHeight/2.1, 100, 225);
        self.currentTemp.frame = CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225);
        self.greetingLabel.frame = CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, self.frame.size.height/8.6);
        
        self.wDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.1, (self.weather.frame.size.width * .9), self.frame.size.height/8.6)];
        CGPoint wDescriptionCenter = self.wDescription.center;
        wDescriptionCenter.x = self.weather.center.x;
        self.wDescription.center = wDescriptionCenter;
        
        self.dismissButton.frame = CGRectMake(0, self.frame.size.height/1.3, self.frame.size.width, self.frame.size.height/8.6);
        self.notifcationLabel.frame = CGRectMake(self.weather.frame.size.width - 60, self.frame.size.height/2.5, 25, 25);
        
        //Saving Values
        savingValuesToFile(self);
        
        
        [prefs setObject: @(NO) forKey:@"resetXY"];
    }
    
    
    // Update weather stuff
    [self updateLockView];
}

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *weather;
%property (nonatomic, retain) UIImageView *logo;
%property (nonatomic, retain) UILabel *greetingLabel;
%property (nonatomic, retain) UILabel *wDescription;
%property (nonatomic, retain) UILabel *currentTemp;
%property (nonatomic, retain) UILabel *editingLabel;
%property (retain, nonatomic) UIVisualEffectView *blurView;
%property (retain, nonatomic) UIButton *dismissButton;
%property (retain, nonatomic) NSTimer *inactiveTimer;
%property (nonatomic, retain) NSDictionary *centerDict;
%property (nonatomic, retain) AWeatherModel *weatherModel;
%property (nonatomic, retain) WAWeatherPlatterViewController *forecastCont;
%property (nonatomic, retain) UILabel *notifcationLabel;
%property (nonatomic, retain) ASTViewController *gestureViewController;

- (void)layoutSubviews {
    %orig;
    //NSLog(@"lock_TWEAK | value: %@", NSStringFromCGPoint(((NSValue*)self.centerDict[@"forecastContView"]).CGPointValue));
    
    // This is basically an init lol
    if(!self.weather){
        self.weather=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.weather setUserInteractionEnabled:YES];
        [self addSubview:self.weather];
        
        // Getting saved values.
        NSData *storeData = [NSData dataWithContentsOfFile: FILE_PATH];
        if(storeData){
            self.centerDict = [NSKeyedUnarchiver unarchiveObjectWithData: storeData];
        } else {
            createDirectoryAndFile();
        }
        
        
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
        
        // Registering observer for weather update
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWeather:) name:@"weatherTimerUpdate" object:nil];
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (const void*)self,
                                        updatePreferenceValues,
                                        CFSTR("com.midnightchips.asteroid.prefschanged"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        // Making sure the preference values set once
        [prefs postNotification];
        
    }
    
    // setting a static
    mainPageView = self;
    
    // Just some rect stuff
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Creating the logo (icon)
    if(!self.logo){
        self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/3.6, screenHeight/2.1, 100, 225)];
        if([prefs boolForKey:@"addLogo"]){
            [self.weather addSubview:self.logo];
        }
        
        //self.logo.center = [self.centerDict[@"logo"] CGPointValue];
        setGesturesForView(self, self.logo);
        
        if(self.centerDict[@"logo"]){
            self.logo.center = ((NSValue*)self.centerDict[@"logo"]).CGPointValue;
        }
        
        initialIconFrame = @(self.logo.frame.size.width);
        
        if([prefs doubleForKey:@"iconSize"]){
            [self.logo layer].anchorPoint = CGPointMake(0.5, 0.5);
            
            //NSLog(@"lock_TWEAK | %f", [prefs doubleForKey:@"iconSize"]);
            
            self.logo.transform = CGAffineTransformScale(self.logo.transform, [prefs doubleForKey:@"iconSize"], [prefs doubleForKey:@"iconSize"]);
        }
    }
    
    //Current Temperature Localized
    if(!self.currentTemp){
        
        self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225)];
        self.currentTemp.textAlignment = NSTextAlignmentCenter;
        if([prefs boolForKey:@"addTemp"]){
        [self.weather addSubview: self.currentTemp];
        }
        
        setGesturesForView(self, self.currentTemp);
        
        if(self.centerDict[@"currentTemp"]){
            self.currentTemp.center = ((NSValue*)self.centerDict[@"currentTemp"]).CGPointValue;
        }
    }
    
    if(!self.editingLabel){
        self.editingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 50, 25)];
        self.editingLabel.textAlignment = NSTextAlignmentCenter;
        self.editingLabel.textColor = [UIColor whiteColor];
        self.editingLabel.layer.masksToBounds = YES;
        self.editingLabel.adjustsFontSizeToFitWidth = YES;
        self.editingLabel.text = @"Editing";
        self.editingLabel.hidden = YES;
        
        self.editingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.weather addSubview:self.editingLabel];
    }
    
    if(!self.forecastCont){
        self.forecastCont = [[%c(WAWeatherPlatterViewController) alloc] init]; // Temp to make sure its called once
        
        //Thank you Matchstic, better than my janky check.
        self.forecastCont = [[%c(WAWeatherPlatterViewController) alloc] initWithLocation:self.weatherModel.city];
        ((UIView *)((NSArray *)self.forecastCont.view.layer.sublayers)[0]).hidden = YES; // Visual Effect view to hidden
        self.forecastCont.view.frame = CGRectMake(0, (self.frame.size.height / 2), self.frame.size.width, self.frame.size.height/3);
        [self.weather addSubview:self.forecastCont.view];
        
        [prefs postNotification];
        
        setGesturesForView(self, self.forecastCont.view);
        
        if(self.centerDict[@"forecastContView"]){
            self.forecastCont.view.center = ((NSValue*)self.centerDict[@"forecastContView"]).CGPointValue;
        }
        
        initialForeFrame = @(self.forecastCont.view.frame.size.width);
        
        if([prefs doubleForKey:@"forecastContViewSize"]){
            [self.forecastCont.view layer].anchorPoint = CGPointMake(0.5, 0.5);
            
            //NSLog(@"lock_TWEAK | %f", [prefs doubleForKey:@"iconSize"]);
            
            self.forecastCont.view.transform = CGAffineTransformScale(self.forecastCont.view.transform, [prefs doubleForKey:@"forecastContViewSize"], [prefs doubleForKey:@"forecastContViewSize"]);
        }
        
    }
    
    // Creating the greeting label
    if(!self.greetingLabel){
        self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, self.frame.size.height/8.6)];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
        if([prefs boolForKey:@"addgreetLabel"]){
        [self.weather addSubview:self.greetingLabel];
        }
        
        setGesturesForView(self, self.greetingLabel);
        
        if(self.centerDict[@"greetingLabel"]){
            self.greetingLabel.center = ((NSValue*)self.centerDict[@"greetingLabel"]).CGPointValue;
        }
    }
    
    // Creating the wDescription
    if(!self.wDescription){
        self.wDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.1, (self.weather.frame.size.width * .9), self.frame.size.height/8.6)];
        CGPoint wDescriptionCenter = self.wDescription.center;
        wDescriptionCenter.x = self.weather.center.x;
        self.wDescription.center = wDescriptionCenter;
        
        self.wDescription.textAlignment = NSTextAlignmentCenter;
        self.wDescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.wDescription.numberOfLines = 0;
        self.wDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.wDescription.preferredMaxLayoutWidth = self.weather.frame.size.width;
        if([prefs boolForKey:@"addDescription"]){
        [self.weather addSubview:self.wDescription];
        }
        
        
        setGesturesForView(self, self.wDescription);
        
        if(self.centerDict[@"wDescription"]){
            self.wDescription.center = ((NSValue*)self.centerDict[@"wDescription"]).CGPointValue;
        }
        
    }
    
    // Creating the dismiss button
    if(!self.dismissButton){
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dismissButton addTarget:self
                               action:@selector(buttonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        self.dismissButton.frame = CGRectMake(0, self.frame.size.height/1.3, self.frame.size.width, self.frame.size.height/8.6);
        if([prefs boolForKey:@"addDismiss"]){
        [self.weather addSubview:self.dismissButton];
        }
        
        setGesturesForView(self, self.dismissButton);
        
        if(self.centerDict[@"dismissButton"]){
            self.dismissButton.center = ((NSValue*)self.centerDict[@"dismissButton"]).CGPointValue;
        }
        
    }
    
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
        
        [self.weather addSubview:self.notifcationLabel];
        }
        
        setGesturesForView(self, self.notifcationLabel);
        
        if(self.centerDict[@"notificationLabel"]){
            self.notifcationLabel.center = ((NSValue*)self.centerDict[@"notificationLabel"]).CGPointValue;
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

// Begin of gesture methods -------------------
%new
- (void)tc_movingFilter:(UIPanGestureRecognizer *)sender{
    UIView *view = (UIView *)sender.view;
    
    CGPoint translation = [sender translationInView:view];
    translation.x = view.center.x + translation.x;
    translation.y = view.center.y + translation.y;
    view.center = translation;
    
    [sender setTranslation:CGPointZero inView:view];
}
%new

- (void)tc_zoomingFilter:(UIPinchGestureRecognizer *)sender{
    
    CGFloat scale = sender.scale;
    
    if([sender.view isKindOfClass: %c(UILabel)]){
        UILabel *label = (UILabel *)sender.view;
        //NSLog(@"lock_TWEAK | %f", [label.font _scaledValueForValue: (CGAffineTransformScale(label.transform, scale, scale)).a]);
        if((CGAffineTransformScale(label.transform, scale, scale)).a < 1.0 && ((CGAffineTransformScale(label.transform, scale, scale)).a - lastZoomValue) > 0) lastZoomValue = (CGAffineTransformScale(label.transform, scale, scale)).a;
        if((CGAffineTransformScale(label.transform, scale, scale)).a > 1.0 && ((CGAffineTransformScale(label.transform, scale, scale)).a - lastZoomValue) < 0) lastZoomValue = (CGAffineTransformScale(label.transform, scale, scale)).a;
        
        label.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size: 20 * ((CGAffineTransformScale(label.transform, scale, scale)).a - lastZoomValue) + label.font.pointSize];
        lastZoomValue = (CGAffineTransformScale(label.transform, scale, scale)).a;
        
        /*
         CGSize maximumLabelSize = CGSizeMake(self.weather.frame.size.width, self.frame.size.height/8.6);
         CGRect expectedLabelSize = [label.text boundingRectWithSize:maximumLabelSize
         options:nil
         attributes:nil
         context:nil];
         
         //adjust the label the the new height.
         CGRect newFrame = label.frame;
         newFrame.size.height = expectedLabelSize.size.height;
         label.frame = newFrame;
         */
    } else {
        UIView *view = (UIView *)sender.view;
        
        [view layer].anchorPoint = CGPointMake(0.5, 0.5);
        view.transform = CGAffineTransformScale(view.transform, scale, scale);
        sender.scale = 1.0;
    }
    
}

%new
- (void)tc_toggleEditMode:(UILongPressGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan) {
        hapticFeedbackSoft();
        if(tc_editing) {
            for(UIView *view in @[self.logo, self.greetingLabel, self.wDescription, self.currentTemp, self.dismissButton, self.notifcationLabel, self.forecastCont.view]){
                view.alpha=1;
                [view.layer removeAllAnimations];
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[0]).enabled = NO; // Pan
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[1]).enabled = NO; // Zoom
            }
            ((UIGestureRecognizer *)((NSArray *)[self.weather _gestureRecognizers])[0]).enabled = YES; // Swipe
            
            self.editingLabel.hidden = YES;
            tc_editing = NO;
            
            // Saving icon ratio
            if(self.logo.frame.origin.x) [prefs setObject: @(@(self.logo.frame.size.width).doubleValue / initialIconFrame.doubleValue) forKey:@"iconSize"];
            
            if(self.forecastCont.view.frame.origin.x) [prefs setObject: @(@(self.forecastCont.view.frame.size.width).doubleValue / initialForeFrame.doubleValue) forKey:@"forecastContViewSize"];
            
            // Saving values
            savingValuesToFile(self);
            
            [prefs setObject: @(self.currentTemp.font.pointSize) forKey:@"tempSize"];
            [prefs setObject: @(self.greetingLabel.font.pointSize) forKey:@"greetingSize"];
            [prefs setObject: @(self.wDescription.font.pointSize) forKey:@"wDescriptionSize"];
            [prefs setObject: @(self.dismissButton.titleLabel.font.pointSize) forKey:@"dismissButtonSize"];
            [prefs saveAndPostNotification];
        }
        else {
            for(UIView *view in @[self.logo, self.greetingLabel, self.wDescription, self.currentTemp, self.dismissButton, self.notifcationLabel, self.forecastCont.view]){
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[0]).enabled = YES; // Pan
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[1]).enabled = YES; // Zoom
                if([view isKindOfClass: %c(UILabel)]){
                    [self tc_animateFilter:view];
                }
            }
            ((UIGestureRecognizer *)((NSArray *)[self.weather _gestureRecognizers])[0]).enabled = NO; // Swipe
            
            self.editingLabel.hidden = NO;
            tc_editing = YES;
        }
    }
}

%new
- (void)tc_animateFilter: (UIView *)view {
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CGFloat wobbleAngle = 0.02f;
    
    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
    
    animation.autoreverses = YES;
    animation.duration = 0.125;
    animation.repeatCount = HUGE_VALF;
    
    [view.layer addAnimation: animation forKey:@"wobbleAnimation"];
    
    /*
     [UIView animateWithDuration:0.5
     delay:0.0
     options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
     animations:^{
     view.alpha = 0.5;
     }
     completion:^(BOOL finished) {
     if (finished) {
     [UIView animateWithDuration:0.5
     delay:0.0
     options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
     animations:^{
     view.alpha = 1.0;
     }
     completion:^(BOOL finished) {
     if (finished) {
     [self tc_animateFilter:view];
     }
     }];
     }
     }];
     */
}

// End of gesture methods ----------------------

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
        /*[UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{self.weather.alpha = 0;}
                         completion:^(BOOL finished){
                             self.weather.hidden = YES;
                             self.weather.alpha = 1;
                         }];*/
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
    //if(!isWeatherLocked){
    self.weather.hidden = NO;
    isDismissed = NO;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"weatherStateChanged"
     object:self];
    //}
}

// Handling a timer fire (refresh weather info)
%new
-(void) updateWeather: (NSNotification *) sender {
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"weatherTimerUpdate"
     object:nil];
    });
     */
    [self updateLockView];
}

%new
-(void) updateLockView {
    if(self.weatherModel.isPopulated){
        
        // Updating the image icon
        UIImage *icon;
        BOOL setColor = FALSE;
        if(![prefs boolForKey:@"customImage"]){
            icon = [self.weatherModel glyphWithOption:ConditionOptionDefault];
        }else if ([[prefs stringForKey:@"setImageType"] isEqualToString:@"Filled Solid Color"]){
            icon = [self.weatherModel glyphWithOption:ConditionOptionDefault];
            setColor = TRUE;
        }else{
            icon = [self.weatherModel glyphWithOption:ConditionOptionBlack];
            setColor = TRUE;
        }
        
        self.logo.image = icon;
        if(setColor){
            self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.logo setTintColor:[prefs colorForKey:@"glyphColor"]];
        }
        self.logo.contentMode = UIViewContentModeScaleAspectFit;
        
        
        self.currentTemp.text = [self.weatherModel localeTemperature];
        
        // Updating the Greeting Label
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH"];
        dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSDate *currentTime;
        currentTime = [NSDate date];
        
        switch ([[dateFormat stringFromDate:currentTime] intValue]){
            case 0 ... 4:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Evening" value:@"" table:nil];//NSLocalizedString(@"Good_Evening", @"Good Evening equivalent"); //@"Good Evening";
                break;
                
            case 5 ... 11:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Morning" value:@"" table:nil];
                break;
                
            case 12 ... 17:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Afternoon" value:@"" table:nil];
                break;
                
            case 18 ... 24:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Evening" value:@"" table:nil];//NSLocalizedString(@"Good_Evening", @"Good Evening equivalent");//@"Good Evening";
                break;
        }
        
        // Updating the the text of the wDescription
        self.wDescription.text = [self.weatherModel currentConditionOverview];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    
    //NSLog(@"lock_TWEAK | updating forecast");
    // Update the forecast
    self.forecastCont.model = self.weatherModel.todayModel;
    [self.forecastCont.model forecastModel];
    [self.forecastCont.headerView _updateContent];
    [self.forecastCont _updateViewContent];
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

%hook SBIdleTimerDefaults
-(double)minimumLockscreenIdleTime {
    return tc_editing ? 1000 : %orig;
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


// Make sure doesnt dim when editing
%hook SBDashBoardIdleTimerProvider
-(BOOL)isIdleTimerEnabled{
    if(tc_editing) return NO;
    else return %orig;
}
%end
/*
%hook WeatherPreferences
-(int) loadActiveCity {
    NSLog(@"lock_TWEAK | update weather");
    return %orig;
}
%end
*/
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
