#include <CSWeather/CSWeatherInformationProvider.h>
#include "lockweather.h"

// Make sure to add the camera fix from nine to this tweak. Seems to block notification scrolling, will look into. 


 // Data required for the isOnLockscreen() function
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
 } else if ((arg1 == 1) && ([self dismissalSlidingMode] == 1)){
 if(isUILocked()) isOnCoverSheet = YES;
 }
 %orig;
 }
 %end
 // end of data required for the isOnLockscreen() function
 
static BOOL numberOfNotifcations;

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *weather;
%property (nonatomic, retain) UIImageView *logo;
%property (nonatomic, retain) UILabel *greetingLabel;
%property (nonatomic, retain) UITextView *description;
%property (nonatomic, retain) UILabel *currentTemp;
%property (retain, nonatomic) UIVisualEffectView *blurView;

- (void)layoutSubviews {
    %orig;
    NSLog(@"lock_TWEAK | testing it before");
    //UIImage *icon;
    [[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
         NSLog(@"lock_TWEAK | on completion");
        //NSString *condition = weather[@"kCurrentFeelsLikefahrenheit"];
        //NSString *temp = weather[@"kCurrentTemperatureForLocale"];
        UIImage *icon = weather[@"kCurrentConditionImage_nc-variant"];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        NSLog(@"lock_TWEAK | testing it run");
        
        //CleanUp
        if(self.logo){
            [self.logo removeFromSuperview];
        }
        if(self.greetingLabel){
            [self.greetingLabel removeFromSuperview];
        }
        if(self.description){
            [self.description removeFromSuperview];
        }
        if(self.currentTemp){
            [self.currentTemp removeFromSuperview];
        }
        
        self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/3.6, screenHeight/2.1, 100, 225)];
        self.logo.image = icon;
        self.logo.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.logo];
        NSLog(@"YEET %@", self.logo);
        
        //Current Temperature Localized
        self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225)];
        if(weather[@"kCurrentTemperatureFahrenheit"] != nil){
            self.currentTemp.text = weather[@"kCurrentTemperatureForLocale"];
        }else{
            self.currentTemp.text = @"Error";
        }
        
        self.currentTemp.textAlignment = NSTextAlignmentCenter;
        if([prefs boolForKey:@"customFont"]){
            self.currentTemp.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"tempSize"]];
        }else{
            self.currentTemp.font = [UIFont systemFontOfSize: [prefs intForKey:@"tempSize"] weight: UIFontWeightLight];
        }
        //self.currentTemp.font = [UIFont systemFontOfSize: 50 weight: UIFontWeightLight];//UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin);//[UIFont UIFontWeightSemibold:50];
        self.currentTemp.textColor = [UIColor whiteColor];
        [self addSubview: self.currentTemp];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH"];
        dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSDate *currentTime;
        currentTime = [NSDate date];
        //[dateFormat stringFromDate:currentTime];
        
        self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.5, self.frame.size.width, self.frame.size.height/8.6)];
        
        switch ([[dateFormat stringFromDate:currentTime] intValue]){
            case 0 ... 4:
                self.greetingLabel.text = @"Good Evening";
                break;
                
            case 5 ... 11:
                self.greetingLabel.text = @"Good Morning";
                break;
                
            case 12 ... 17:
                self.greetingLabel.text = @"Good Afternoon";
                break;
                
            case 18 ... 24:
                self.greetingLabel.text = @"Good Evening";
                break;
        }
        
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
        if([prefs boolForKey:@"customFont"]){
            self.greetingLabel.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"greetingSize"]];
        }else{
            self.greetingLabel.font = [UIFont systemFontOfSize:[prefs intForKey:@"greetingSize"] weight: UIFontWeightLight];
        }
        ////[UIFont boldSystemFontOfSize:40];
        self.greetingLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.greetingLabel];
        
        //[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/21, self.frame.size.height/2, self.frame.size.width/1.1, self.frame.size.height/10)];
        
        self.description = [[UITextView alloc] initWithFrame:CGRectMake(self.frame.size.width/21, self.frame.size.height/2, self.frame.size.width/1.1, self.frame.size.height/2)];
        self.description.text = weather[@"kCurrentDescription"];
        self.description.textAlignment = NSTextAlignmentCenter;
        //self.description.lineBreakMode = NSLineBreakByWordWrapping;
        //self.description.numberOfLines = 0;
        self.description.backgroundColor = [UIColor clearColor];
        self.description.textColor = [UIColor whiteColor];
        [self.description setUserInteractionEnabled:NO];
        self.description.scrollEnabled = NO;
        if([prefs boolForKey:@"customFont"]){
            self.description.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"descriptionSize"]];
        }else{
            self.description.font = [UIFont systemFontOfSize:[prefs intForKey:@"descriptionSize"]];
        }
        //self.description.font = [UIFont systemFontOfSize:20];
        [self addSubview:self.description];
    }];
    
}

%end


// Checking content
%hook NCNotificationCombinedListViewController
-(BOOL)hasContent{
    BOOL content = %orig;
    if(content != numberOfNotifcations){
        // send a notification with user info for content. Dont forget to check ((!isOnLockscreen()) ? YES : self.isShowingNotificationsHistory)
        
    }
    // Sending values to the background controller
    //[[TCBackgroundViewController sharedInstance] updateSceenShot: content isRevealed: ((!isOnLockscreen()) ? YES : self.isShowingNotificationsHistory)]; // NC is never set to lock
    numberOfNotifcations = content;
    return content;
    
}
%end

//Blur 
%hook SBDashBoardViewController
%property (nonatomic, retain) UIVisualEffectView *notifEffectView;

-(void)loadView{
    %orig;
    
    NSLog(@"lock_TWEAK | blur");
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:5];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //always fill the view
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //[self.view addSubview:blurEffectView];
    //[self.view sendSubviewToBack: blurEffectView];
    [((SBDashBoardView *)self.view).backgroundView addSubview: blurEffectView];
}
%end 
