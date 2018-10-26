#include "lockweather.h"

//TODO Change today to use the cases in descriptions
//TODO Fix Blur on lockscreen vs just pulling down notification center
//TODO Customization, move portion of view around

//TODO add dismiss button
//TODO make only appear during set times
//TODO Prob switch the notification for the inactive timer


NSBundle *tweakBundle = [NSBundle bundleWithPath:@"/Library/Application Support/lockWeather.bundle"];
//NSString *alertTitle = [tweakBundle localizedStringForKey:@"ALERT_TITLE" value:@"" table:nil];


// Data required for the isOnLockscreen() function --------------------------------------------------------------------------------------
BOOL isUILocked() {
    long count = [[[%c(SBFPasscodeLockTrackerForPreventLockAssertions) sharedInstance] valueForKey:@"_assertions"] count];
    if (count == 0) return YES; // array is empty
    if (count == 1) {
        if ([[[[[[%c(SBFPasscodeLockTrackerForPreventLockAssertions) sharedInstance] valueForKey:@"_assertions"] allObjects] objectAtIndex:0] identifier] isEqualToString:@"UI unlocked"]) return NO; // either device is unlocked or an app is opened (from the ones allowed on lockscreen). Luckily system gives us enough info so we can tell what happened
        else return YES; // if there are more than one should be safe enough to assume device is unlocked
    }
    else return NO;
}

static BOOL isOnCoverSheet; // the data that needs to be analyzed

BOOL isOnLockscreen() {
    //NSLog(@"nine_TWEAK | %d", isOnCoverSheet);
    if(isUILocked()){
        isOnCoverSheet = YES; // This is used to catch an exception where it was locked, but the isOnCoverSheet didnt update to reflect.
        return YES;
    }
    else if(!isUILocked() && isOnCoverSheet == YES) return YES;
    else if(!isUILocked() && isOnCoverSheet == NO) return NO;
    else return NO;
}

static id _instance;

%hook SBFPasscodeLockTrackerForPreventLockAssertions
- (id) init {
    if (_instance == nil) _instance = %orig;
        else %orig; // just in case it needs more than one instance
    return _instance;
}
%new
// add a shared instance so we can use it later
+ (id) sharedInstance {
    if (!_instance) return [[%c(SBFPasscodeLockTrackerForPreventLockAssertions) alloc] init];
    return _instance;
}
%end

// Setting isOnCoverSheet properly, actually works perfectly
%hook SBCoverSheetSlidingViewController
- (void)_finishTransitionToPresented:(_Bool)arg1 animated:(_Bool)arg2 withCompletion:(id)arg3 {
    if((arg1 == 0) && ([self dismissalSlidingMode] == 1)){
        if(!isUILocked()) isOnCoverSheet = NO;
    }
    else if ((arg1 == 1) && ([self dismissalSlidingMode] == 1)){
        if(isUILocked()) isOnCoverSheet = YES;
    }
    %orig;
}
%end
// end of data required for the isOnLockscreen() function --------------------------------------------------------------------------------------


// thanks mr squid
extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

 static void hapticFeedbackSoft(){
 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
 NSMutableArray* arr = [NSMutableArray array];
 [arr addObject:[NSNumber numberWithBool:YES]];
 [arr addObject:[NSNumber numberWithInt:30]];
 [dict setObject:arr forKey:@"VibePattern"];
 [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
 AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
 }
 /*
static void hapticFeedbackHard(){
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:[NSNumber numberWithBool:YES]];
    [arr addObject:[NSNumber numberWithInt:30]];
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"Intensity"];
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}
*/


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

static BOOL isDismissed = NO;

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *weather;
%property (nonatomic, retain) UIImageView *logo;
%property (nonatomic, retain) UILabel *greetingLabel;
%property (nonatomic, retain) UILabel *description;
%property (nonatomic, retain) UILabel *currentTemp;
%property (retain, nonatomic) UIVisualEffectView *blurView;
%property (retain, nonatomic) UIButton *dismissButton;
%property (retain, nonatomic) WALockscreenWidgetViewController *weatherCont;
%property (retain, nonatomic) NSTimer *refreshTimer;
%property (retain, nonatomic) NSTimer *inactiveTimer;
%property (nonatomic, retain) NSDictionary *centerDict;

%property (nonatomic, retain) BOOL tc_editing;

-(id) init{
    if((self = %orig)){
        self.centerDict = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Library/PreferenceBundles/lockweather.bundle/centerData.plist"];
    }
    return self;
}
- (void)layoutSubviews {
    %orig;
    if(!self.weather){
        self.weather=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.weather setUserInteractionEnabled:YES];
        [self addSubview:self.weather];
        
        // Find a better trigger
        [[NSNotificationCenter defaultCenter] addObserverForName: @"SBCoverSheetDidDismissNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
            [self.inactiveTimer invalidate];
            NSLog(@"lock_TWEAK | Timer set");
            self.inactiveTimer = [NSTimer scheduledTimerWithTimeInterval:600.0
                                                                  target:self
                                                                selector:@selector(revealWeather:)
                                                                userInfo:nil
                                                                 repeats:NO];
            
        }];
    }
    
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
    }
    
    //Current Temperature Localized
    if(!self.currentTemp){
        
        self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225)];
        self.currentTemp.textAlignment = NSTextAlignmentCenter;
        [self.weather addSubview: self.currentTemp];
        
        setGesturesForView(self, self.currentTemp);
    }
    
    // Updating the font
    if([prefs boolForKey:@"customFont"]){
        self.currentTemp.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"tempSize"]];
    }else{
        self.currentTemp.font = [UIFont systemFontOfSize: [prefs intForKey:@"tempSize"] weight: UIFontWeightLight];
    }
    self.currentTemp.textColor = [prefs colorForKey:@"textColor"];
    
    // Creating the greeting label
    if(!self.greetingLabel){
        self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, self.frame.size.height/8.6)];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
        [self.weather addSubview:self.greetingLabel];
        
        setGesturesForView(self, self.greetingLabel);
    }
    
    // Setting Greeting Label Font
    if([prefs boolForKey:@"customFont"]){
        self.greetingLabel.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"greetingSize"]];
    }else{
        self.greetingLabel.font = [UIFont systemFontOfSize:[prefs intForKey:@"greetingSize"] weight: UIFontWeightLight];
    }
    self.greetingLabel.textColor = [prefs colorForKey:@"textColor"];

    
    // Creating the description
    if(!self.description){
        self.description = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.1, self.weather.frame.size.width, self.frame.size.height/8.6)];
        self.description.textAlignment = NSTextAlignmentCenter;
        self.description.lineBreakMode = NSLineBreakByWordWrapping;
        self.description.numberOfLines = 0;
        self.description.textColor = [prefs colorForKey:@"textColor"];
        self.description.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.description.preferredMaxLayoutWidth = self.weather.frame.size.width;
        
        [self.weather addSubview:self.description];
        
        
        setGesturesForView(self, self.description);
        
    }
    
    // Setting the font for the description
    if([prefs boolForKey:@"customFont"]){
        self.description.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"descriptionSize"]];
    }else{
        self.description.font = [UIFont systemFontOfSize:[prefs intForKey:@"descriptionSize"]];
    }
    self.description.textColor = [prefs colorForKey:@"textColor"];
    
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
    }
    
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
    
    //[self.inactiveTimer invalidate]; // Its no longer inactive;

}
extern "C" NSString * NSStringFromCGAffineTransform(CGAffineTransform transform);
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

static double change = nil;
- (void)tc_zoomingFilter:(UIPinchGestureRecognizer *)sender{
    
    CGFloat scale = sender.scale;
    
    if([sender.view isKindOfClass: %c(UILabel)]){
        UILabel *label = (UILabel *)sender.view;
        NSLog(@"lock_TWEAK | %f", [label.font _scaledValueForValue: (CGAffineTransformScale(label.transform, scale, scale)).a]);
       if((CGAffineTransformScale(label.transform, scale, scale)).a < 1.0 && ((CGAffineTransformScale(label.transform, scale, scale)).a - change) > 0) change = (CGAffineTransformScale(label.transform, scale, scale)).a;
        if((CGAffineTransformScale(label.transform, scale, scale)).a > 1.0 && ((CGAffineTransformScale(label.transform, scale, scale)).a - change) < 0) change = (CGAffineTransformScale(label.transform, scale, scale)).a;
        
        label.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size: 20 * ((CGAffineTransformScale(label.transform, scale, scale)).a - change) + label.font.pointSize];
        
        change = (CGAffineTransformScale(label.transform, scale, scale)).a;
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
        if(self.tc_editing) {
            for(UIView *view in @[self.logo, self.greetingLabel, self.description, self.currentTemp, self.dismissButton]){
                view.alpha=1;
                [view.layer removeAllAnimations];
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[0]).enabled = NO; // Pan
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[1]).enabled = NO; // Zoom
            }
            self.tc_editing = NO;
        }
        else {
            for(UIView *view in @[self.logo, self.greetingLabel, self.description, self.currentTemp, self.dismissButton]){
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[0]).enabled = YES; // Pan
                ((UIGestureRecognizer *)((NSArray *)[view _gestureRecognizers])[1]).enabled = YES; // Zoom
                [self tc_animateFilter:view];
                
            }
            self.tc_editing = YES;
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

/*%new
-(void)updateImage:(NSNotification *) notification{
    NSLog(@"IMRUNNINGOK");
    [[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
        UIImage *icon;
        if([[notification name] isEqualToString:@"setStandard"]){
            icon = weather[@"kCurrentConditionImage_nc-variant"];
        }
        if([[notification name] isEqualToString:@"setFilled"]){
            icon = weather[@"kCurrentConditionImage_white-variant"];
        }
        if([[notification name] isEqualToString:@"setOutline"]){
            icon = weather[@"kCurrentConditionImage_black-variant"];
        }

        self.logo.image = icon;
        self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.logo setTintColor:[prefs colorForKey:@"glyphColor"]];

        self.logo.contentMode = UIViewContentModeScaleAspectFit;

    }];
}*/

-(void) dealloc {
    NSLog(@"lock_TWEAK | dealloc");
    NSDictionary *dict = @{ @"logo" : [NSValue valueWithCGPoint:self.logo.center], @"dismiss" : [NSValue valueWithCGPoint:self.dismissButton.center]};
    [NSKeyedArchiver archiveRootObject:dict toFile:@"/Library/PreferenceBundles/lockweather.bundle/centerData.plist"];
    
    // Making sure the timer goes away
    [self.refreshTimer invalidate];
    %orig;
}
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
        
        // Updating the the text of the description
        self.description.text = weather[@"kCurrentDescription"];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    }];
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

//Blur 
%hook SBDashBoardViewController
//%property (nonatomic, retain) UIVisualEffectView *notifEffectView; <-- Whats this supposed to do
%property (nonatomic, retain) UIVisualEffectView *blurEffectView;

-(void)loadView{
    %orig;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:[prefs intForKey:@"blurAmount"]];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //always fill the view
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //[self.view addSubview:blurEffectView];
    //[self.view sendSubviewToBack: blurEffectView];
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
    [[NSNotificationCenter defaultCenter] addObserverForName: @"weatherStateChanged" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        if(!isDismissed) self.blurEffectView.hidden = isOnLockscreen() ? NO : YES;
    }];
}

%end 

%ctor{
    if([prefs boolForKey:@"kLWPEnabled"]){
        %init(_ungrouped);
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:NULL object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        if ([note.name containsString:@"UIViewAnimationDidCommitNotification"] || [note.name containsString:@"UIViewAnimationDidStopNotification"] || [note.name containsString:@"UIScreenBrightnessDidChangeNotification"]){
        } else {
            NSLog(@"UNIQUE: %@", note.name);
        }
    }];
    
}
