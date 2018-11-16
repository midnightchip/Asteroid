#include "lockweather.h"

//TODO Change today to use the cases in descriptions
//TODO Fix Blur on lockscreen vs just pulling down notification center
//TODO make only appear during set times
//TODO Ajust height of uilabel on text size.
//TODO Add option for right alignment or left alignment
//TODO Add reset font sizes


#define DIRECTORY_PATH @"/var/mobile/Library/Astroid"
#define FILE_PATH @"/var/mobile/Library/Astroid/centerData.plist"

extern "C" NSString * NSStringFromCGAffineTransform(CGAffineTransform transform);

// external functions
extern BOOL isOnLockscreen();
extern void hapticFeedbackSoft();

NSBundle *tweakBundle = [NSBundle bundleWithPath:@"/Library/Application Support/lockWeather.bundle"];
//NSString *alertTitle = [tweakBundle localizedStringForKey:@"ALERT_TITLE" value:@"" table:nil];

// Statics
static NSDictionary *savedCenterData = [NSKeyedUnarchiver unarchiveObjectWithData: [NSData dataWithContentsOfFile: FILE_PATH]];
static BOOL isDismissed = NO;
static NSDictionary *viewDict;
static BOOL tc_editing;
static double lastZoomValue = 0;
static SBDashBoardMainPageView *mainPageView;
static NSNumber *initialIconFrame;


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

static void savingValuesToFile(SBDashBoardMainPageView *sender){
    SBDashBoardMainPageView *self = sender;
    viewDict = @{ @"logo" : [NSValue valueWithCGPoint:self.logo.center], @"greetingLabel" : [NSValue valueWithCGPoint:self.greetingLabel.center], @"wDescription" : [NSValue valueWithCGPoint:self.wDescription.center], @"currentTemp" : [NSValue valueWithCGPoint:self.currentTemp.center], @"dismissButton" : [NSValue valueWithCGPoint:self.dismissButton.center], @"notificationLabel" : [NSValue valueWithCGPoint:self.notifcationLabel.center]};
    
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if(![fileManager fileExistsAtPath:FILE_PATH isDirectory:&isDir]){
        [fileManager createFileAtPath:FILE_PATH contents:nil attributes:nil];
    }
    [[NSKeyedArchiver archivedDataWithRootObject:viewDict] writeToFile:FILE_PATH atomically:YES];
}

// Master update notification
static void updatePreferenceValues(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    SBDashBoardMainPageView *self = (__bridge SBDashBoardMainPageView *)observer;
    
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
    
    // Reseting location
    if([prefs boolForKey:@"resetXY"]){
        savedCenterData = nil;
        
        // Just some rect stuff
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        self.logo.frame = CGRectMake(screenWidth/3.6, screenHeight/2.1, 100, 225);
        self.currentTemp.frame = CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225);
        self.greetingLabel.frame = CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, self.frame.size.height/8.6);
        self.wDescription.frame = CGRectMake(0, self.frame.size.height/2.1, self.weather.frame.size.width, self.frame.size.height/8.6);
        self.dismissButton.frame = CGRectMake(0, self.frame.size.height/1.3, self.frame.size.width, self.frame.size.height/8.6);
        self.notifcationLabel.frame = CGRectMake(self.weather.frame.size.width - 75, self.frame.size.height/3.5, 25, 25);
        
        //Saving Values
        savingValuesToFile(self);
        
        
        [prefs setObject: @(NO) forKey:@"resetXY"];
    }
    
    // Update weather stuff
    [self.refreshTimer fire];
}

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *weather;
%property (nonatomic, retain) UIImageView *logo;
%property (nonatomic, retain) UILabel *greetingLabel;
%property (nonatomic, retain) UILabel *wDescription;
%property (nonatomic, retain) UILabel *currentTemp;
%property (retain, nonatomic) UIVisualEffectView *blurView;
%property (retain, nonatomic) UIButton *dismissButton;
%property (retain, nonatomic) WALockscreenWidgetViewController *weatherCont;
%property (retain, nonatomic) NSTimer *refreshTimer;
%property (retain, nonatomic) NSTimer *inactiveTimer;
%property (nonatomic, retain) NSDictionary *centerDict;
%property (nonatomic, retain) WAWeatherPlatterViewController *weatherController;


%property (nonatomic, retain) UILabel *notifcationLabel;

- (void)layoutSubviews {
    %orig;
    /*if(!self.weatherController){
    self.weatherController = [[NSClassFromString(@"WAWeatherPlatterViewController") alloc] init];
    [self addSubview: self.weatherController.view];

    }*/
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
            self.inactiveTimer = [NSTimer scheduledTimerWithTimeInterval:600.0
                                                                  target:self
                                                                selector:@selector(revealWeather:)
                                                                userInfo:nil
                                                                 repeats:NO];
            
            if(![MSHookIvar<NCNotificationCombinedListViewController *>(((SBDashBoardMainPageContentViewController *)((UIView *)self)._viewDelegate).combinedListViewController, "_listViewController") hasContent]){
                [self.inactiveTimer fire];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName: @"SBCoverSheetWillDismissNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
            [self.inactiveTimer invalidate];
            NSLog(@"lock_TWEAK | Cancel Timer");
            
        }];
        
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (const void*)self,
                                        updatePreferenceValues,
                                        CFSTR("com.midnightchips.lockweather.prefschanged"),
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
        [self.weather addSubview:self.logo];
        //self.logo.center = [self.centerDict[@"logo"] CGPointValue];
        setGesturesForView(self, self.logo);
        
        if(savedCenterData[@"logo"]){
            self.logo.center = ((NSValue*)savedCenterData[@"logo"]).CGPointValue;
        }
        
        initialIconFrame = @(self.logo.frame.size.width);
        
        if([prefs doubleForKey:@"iconSize"]){
            [self.logo layer].anchorPoint = CGPointMake(0.5, 0.5);
            
            NSLog(@"lock_TWEAK | %f", [prefs doubleForKey:@"iconSize"]);
            
            self.logo.transform = CGAffineTransformScale(self.logo.transform, [prefs doubleForKey:@"iconSize"], [prefs doubleForKey:@"iconSize"]);
        }
    }
    
    //Current Temperature Localized
    if(!self.currentTemp){
        
        self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225)];
        self.currentTemp.textAlignment = NSTextAlignmentCenter;
        [self.weather addSubview: self.currentTemp];
        
        setGesturesForView(self, self.currentTemp);
        
        if(savedCenterData[@"currentTemp"]){
            self.currentTemp.center = ((NSValue*)savedCenterData[@"currentTemp"]).CGPointValue;
        }
    }
    
    // Creating the greeting label
    if(!self.greetingLabel){
        self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, self.frame.size.height/8.6)];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
        [self.weather addSubview:self.greetingLabel];
        
        setGesturesForView(self, self.greetingLabel);
        
        if(savedCenterData[@"greetingLabel"]){
            self.greetingLabel.center = ((NSValue*)savedCenterData[@"greetingLabel"]).CGPointValue;
        }
    }
    
    // Creating the wDescription
    if(!self.wDescription){
        self.wDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.1, self.weather.frame.size.width, self.frame.size.height/8.6)];
        self.wDescription.textAlignment = NSTextAlignmentCenter;
        self.wDescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.wDescription.numberOfLines = 0;
        self.wDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.wDescription.preferredMaxLayoutWidth = self.weather.frame.size.width;
        
        [self.weather addSubview:self.wDescription];
        
        
        setGesturesForView(self, self.wDescription);
        
        if(savedCenterData[@"wDescription"]){
            self.wDescription.center = ((NSValue*)savedCenterData[@"wDescription"]).CGPointValue;
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
        [self.weather addSubview:self.dismissButton];
        
        setGesturesForView(self, self.dismissButton);
        
        if(savedCenterData[@"dismissButton"]){
            self.dismissButton.center = ((NSValue*)savedCenterData[@"dismissButton"]).CGPointValue;
        }
        
    }
    
    // Creating the notification label
    if(!self.notifcationLabel){
        self.notifcationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.weather.frame.size.width - 75, self.frame.size.height/3.5, 25, 25)];
        self.notifcationLabel.textAlignment = NSTextAlignmentCenter;
        self.notifcationLabel.textColor = [UIColor whiteColor];
        self.notifcationLabel.backgroundColor = [UIColor redColor];
        self.notifcationLabel.layer.masksToBounds = YES;
        self.notifcationLabel.adjustsFontSizeToFitWidth = YES;
        self.notifcationLabel.layer.cornerRadius = 12.5;
        
        self.notifcationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.weather addSubview:self.notifcationLabel];
        
        setGesturesForView(self, self.notifcationLabel);
        
        if(savedCenterData[@"notificationLabel"]){
            self.notifcationLabel.center = ((NSValue*)savedCenterData[@"notificationLabel"]).CGPointValue;
        }
        
        
    }
    /*
    if(!self.weatherController){
        WATodayAutoUpdatingLocationModel *locModel = [[%c(WATodayAutoUpdatingLocationModel) alloc] initWithPreferences: [%c(WeatherPreferences) sharedPreferences] effectiveBundleIdentifier: @"com.apple.weather"];
        self.weatherController = [[%c(WAWeatherPlatterViewController) alloc] initWithLocation: locModel];
        [self.weatherController _buildModelForLocation: locModel];
        [self addSubview: self.weatherController.view];
        
    }
    */
    // Creating a refresh timer
    if(!self.refreshTimer){
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                             target:self
                                                           selector:@selector(updateWeather:)
                                                           userInfo:nil
                                                            repeats:YES];
        
        // making sure the weather is updated once
        [self.refreshTimer fire];
    }
    
}

- (void) updateForPresentation:(id) arg1 {
    %orig;
    NSLog(@"lock_TWEAK | Updating");
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
            for(UIView *view in @[self.logo, self.greetingLabel, self.wDescription, self.currentTemp, self.dismissButton, self.notifcationLabel]){
                view.alpha=1;
                [view.layer removeAllAnimations];
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[0]).enabled = NO; // Pan
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[1]).enabled = NO; // Zoom
            }
            ((UIGestureRecognizer *)((NSArray *)[self.weather _gestureRecognizers])[0]).enabled = YES; // Swipe
            
            tc_editing = NO;
            
            // Saving icon ratio
            [prefs setObject: @(@(self.logo.frame.size.width).doubleValue / initialIconFrame.doubleValue) forKey:@"iconSize"];
            
            // Saving values
            savingValuesToFile(self);
            
            [prefs setObject: @(self.currentTemp.font.pointSize) forKey:@"tempSize"];
            [prefs setObject: @(self.greetingLabel.font.pointSize) forKey:@"greetingSize"];
            [prefs setObject: @(self.wDescription.font.pointSize) forKey:@"wDescriptionSize"];
            [prefs saveAndPostNotification];
        }
        else {
            for(UIView *view in @[self.logo, self.greetingLabel, self.wDescription, self.currentTemp, self.dismissButton, self.notifcationLabel]){
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[0]).enabled = YES; // Pan
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[1]).enabled = YES; // Zoom
                [self tc_animateFilter:view];
                
            }
            ((UIGestureRecognizer *)((NSArray *)[self.weather _gestureRecognizers])[0]).enabled = NO; // Swipe
            
            tc_editing = YES;
        }
    }
}

%new
- (void)tc_animateFilter: (UIView *)view {
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
                         }];
        isDismissed = YES;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"weatherStateChanged"
         object:self];
    }
}

// Handles reveal
%new
- (void) revealWeather: (NSTimer *) sender{
    NSLog(@"lock_TWEAK | Timer fired");
    self.weather.hidden = NO;
    isDismissed = NO;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"weatherStateChanged"
     object:self];
}

// Handling a timer fire (refresh weather info)
%new
- (void) updateWeather: (NSTimer *) sender{
    [[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
        
        // Updating the image icon
        UIImage *icon;
        BOOL setColor = FALSE;
        if(![prefs boolForKey:@"customImage"]){
            icon = weather[@"kCurrentConditionImage_nc-variant"];
        }else if ([[prefs stringForKey:@"setImageType"] isEqualToString:@"Filled Solid Color"]){
            icon = weather[@"kCurrentConditionImage_white-variant"];
            setColor = TRUE;
        }else{
            icon = weather[@"kCurrentConditionImage_black-variant"];
            setColor = TRUE;
        }
        
        self.logo.image = icon;
        if(setColor){
            self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.logo setTintColor:[prefs colorForKey:@"glyphColor"]];
        }
        self.logo.contentMode = UIViewContentModeScaleAspectFit;
        
        // Setting the current temperature text
        if(weather[@"kCurrentTemperatureFahrenheit"] != nil){
            self.currentTemp.text = weather[@"kCurrentTemperatureForLocale"];
        }else{
            self.currentTemp.text = @"Error";
        }
        
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
        self.wDescription.text = weather[@"kCurrentDescription"];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    }];
}
%end

%hook NCNotificationPriorityList
-(NSUInteger) count {
    mainPageView.notifcationLabel.text = [NSString stringWithFormat:@"%i", (int)%orig];
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
    
    [((SBDashBoardView *)self.view).backgroundView addSubview: self.blurEffectView];
    
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

%ctor{
    if([prefs boolForKey:@"kLWPEnabled"]){
        %init(_ungrouped);
    }
}
