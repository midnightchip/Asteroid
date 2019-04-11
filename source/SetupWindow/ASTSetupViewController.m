/*
 ======OUTDATED=====
 Will remove after transfering anything useful.
 */

#import "ASTSetupViewController.h"

#define PATH_TO_SNOW @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Snow.mov"
#define PATH_TO_IMAGE @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Image.PNG"
#define PATH_TO_BANNER @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Asteroid.png"
#define PATH_TO_HORIZANTAL_VIDEO @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Hor.MP4"

#define PATH_TO_LOCK_VID @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/LockScreen.m4v"
#define PATH_TO_TWELVE_LOCK @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/twelveLock.png"
#define PATH_TO_EDITING @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/EditingMode.m4v"



@interface ASTSetupViewController ()
@property (nonatomic, retain) NSMutableArray *allPages;
@property (nonatomic, retain) ASTSetupPageView *visiblePage;
-(ASTSetupPageView *) nextPageForPage:(ASTSetupPageView *) currentPage;
-(ASTSetupPageView *) backPageForPage:(ASTSetupPageView *) currentPage;


@property (nonatomic, retain) ASTSetupPageView *welcomeView;
@property (nonatomic, retain) ASTSetupPageView *lockPage;
@property (nonatomic, retain) ASTSetupPageView *lockInfo;
@property (nonatomic, retain) ASTSetupPageView *twelveLock;
@property (nonatomic, retain) ASTSetupPageView *hourlyLock;
@property (nonatomic, retain) ASTSetupPageView *animationPage;
@property (nonatomic, retain) ASTSetupPageView *lockAnimation;
@property (nonatomic, retain) ASTSetupPageView *homeAnimation;
@property (nonatomic, retain) ASTSetupPageView *iconPage;
@property (nonatomic, retain) ASTSetupPageView *basicIcon;
@property (nonatomic, retain) ASTSetupPageView *liveIcon;
@property (nonatomic, retain) ASTSetupPageView *statusPage;
@end

@implementation ASTSetupViewController {
    
}

- (instancetype)init{
    if(self = [super init]) {
        self.allPages = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"astDisableLock"
         object:self];
    }
    return self;
}

-(void) generatePages {
    self.welcomeView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleHeaderBasic];
    NSString *welcomeDescription = @"MidnightChips & the casle © 2019\n\nThank you for installing Asteroid. In order to deliver the best user experience, further setup is required.";
    [self.welcomeView setHeaderText:@"Asteroid" andDescription: welcomeDescription];
    [self.welcomeView setNextButtonText:SETUP_MANUALLY andOtherButton:nil];
    [self.welcomeView setupMediaWithPathToFile:PATH_TO_BANNER];
    self.welcomeView.backButton.hidden = YES;
    [self.welcomeView setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self indexPage: self.welcomeView];
    
    self.lockPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleHeaderTwoButtons];
    [self.lockPage setHeaderText:@"Lockscreen" andDescription: @"Enable the Asteroid Lockscreen."];
    [self.lockPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [self.lockPage setupMediaWithPathToFile:PATH_TO_LOCK_VID];
    [self.lockPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.lockPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:self.animationPage completion:nil];
    [self.lockPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.lockPage];
    
    self.lockInfo = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleBasic];
    [self.lockInfo setHeaderText:@"Lockscreen" andDescription: @"Long press on component to edit."];
    [self.lockInfo setNextButtonText:CONTINUE andOtherButton:nil];
    [self.lockInfo setupMediaWithPathToFile:PATH_TO_EDITING];
    [self.lockInfo setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.lockInfo setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.lockInfo];
    
    self.twelveLock = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.twelveLock setHeaderText:@"Stock iOS 12 Style" andDescription: @"Stock-styled components are enabled."];
    [self.twelveLock setNextButtonText:CONTINUE andOtherButton:OTHER_OPTIONS];
    [self.twelveLock setupMediaWithPathToFile:PATH_TO_TWELVE_LOCK];
    [self.twelveLock setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:self.animationPage  completion:nil];
    [self.twelveLock setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.twelveLock setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.twelveLock];
    
    self.hourlyLock = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleBasic];
    [self.hourlyLock setHeaderText:@"Hourly Style" andDescription: @"Only the hourly components are enabled."];
    [self.hourlyLock setNextButtonText:CONTINUE andOtherButton:nil];
    [self.hourlyLock setupMediaWithPathToFile:PATH_TO_BANNER];
    [self.hourlyLock setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.hourlyLock setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.hourlyLock];
    
    self.animationPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.animationPage setHeaderText:@"Weather Animations" andDescription: @"Enable weather animations."];
    [self.animationPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [self.animationPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [self.animationPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.animationPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:self.iconPage completion:nil];
    [self.animationPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:self.lockInfo completion:nil];
    [self indexPage: self.animationPage];
    
    self.lockAnimation = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.lockAnimation setHeaderText:@"Lock Animations" andDescription: @"Enable weather animations on lockscreen."];
    [self.lockAnimation setNextButtonText:CONTINUE andOtherButton:SKIP];
    [self.lockAnimation setupMediaWithPathToFile:PATH_TO_BANNER];
    [self.lockAnimation setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.lockAnimation setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.lockAnimation setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.lockAnimation];
    
    self.homeAnimation = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.homeAnimation setHeaderText:@"Home Animations" andDescription: @"Enable weather animations on homescreen."];
    [self.homeAnimation setNextButtonText:CONTINUE andOtherButton:SKIP];
    [self.homeAnimation setupMediaWithPathToFile:PATH_TO_BANNER];
    [self.homeAnimation setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.homeAnimation setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.homeAnimation setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.homeAnimation];
    
    self.iconPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.iconPage setHeaderText:@"Weather Icon" andDescription: @"Enable live weather app icon."];
    [self.iconPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [self.iconPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [self.iconPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.iconPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:self.statusPage completion:nil];
    [self.iconPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:self.animationPage completion:nil];
    [self indexPage: self.iconPage];
    
    self.basicIcon = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.basicIcon setHeaderText:@"Basic Icon" andDescription: @"Icon and background update."];
    [self.basicIcon setNextButtonText:CONTINUE andOtherButton:SKIP];
    [self.basicIcon setupMediaWithPathToFile:PATH_TO_BANNER];
    [self.basicIcon setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.basicIcon setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:self.statusPage completion:nil];
    [self.basicIcon setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.basicIcon];
    
    self.liveIcon = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.liveIcon setHeaderText:@"Live Weather" andDescription: @"Icon background includes live weather."];
    [self.liveIcon setNextButtonText:CONTINUE andOtherButton:SKIP];
    [self.liveIcon setupMediaWithPathToFile:PATH_TO_BANNER];
    [self.liveIcon setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.liveIcon setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.liveIcon setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:nil completion:nil];
    [self indexPage: self.liveIcon];
    
    self.statusPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [self.statusPage setHeaderText:@"Status Bar" andDescription: @"Enable weather in status bar."];
    [self.statusPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [self.statusPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [self.statusPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.statusPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overridePage:nil completion:nil];
    [self.statusPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overridePage:self.iconPage completion:nil];
    [self indexPage: self.statusPage];
}

- (void)viewDidLoad{
    [self generatePages];
    for(ASTSetupPageView *page in self.allPages){
        [self.view addSubview: page];
    }
    if(self.allPages.count > 0) self.visiblePage = self.allPages[0];
    [self adjustForVisiblePage];
}

-(void) exitSetup{
    for(ASTSetupPageView *page in self.allPages){
        [page.videoPlayer pause];
    }
    [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
        self.view.center = CGPointMake(self.view.center.x, - (2 * self.view.frame.size.height));
    } completion:^(BOOL finished){
        self.view.superview.hidden = YES;
        self.view.center = self.view.superview.center;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"astEnableLock"
         object:self];
        //[self startRespring]; // MAKE SURE TO ENABLE THIS WHEN DONE MAKING!!!!!!!!!!!!!!!!!
    }];
}

#pragma mark - Utility
-(void) indexPage:(ASTSetupPageView *) page{
    page.pageIndex = self.allPages.count;
    [self.allPages addObject:page];
}

-(void) transitionToRight:(HighlightButton *) sender{
    if(sender.targetIndex){ // Specified Page
        self.visiblePage = [self pageForIndex:sender.targetIndex.intValue];
        [self animateForwardsForPage:self.visiblePage];
    } else {
        if(self.visiblePage == [self nextPageForPage:self.visiblePage]){ // Last page.
            [self exitSetup];
        } else {
            self.visiblePage = [self nextPageForPage:self.visiblePage];
            [self animateForwardsForPage:self.visiblePage];
        }
    }
}

-(void) transitionToLeft:(HighlightButton *) sender{
    if(sender.targetIndex){ // Specified Page
        self.visiblePage = [self pageForIndex:sender.targetIndex.intValue];
        [self animateBackwardsForPage:self.visiblePage];
    } else {
        self.visiblePage = [self backPageForPage:self.visiblePage];
        [self animateBackwardsForPage:self.visiblePage];
    }
}

-(void) animateForwardsForPage:(ASTSetupPageView *) page{
    [self.view bringSubviewToFront:page];
    page.center = CGPointMake(self.view.frame.size.width/2 + 350, self.view.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
        ///Move new view into frame and above old view
        page.center = self.view.center;
    }
                     completion:^(BOOL finished){
                         [page.videoPlayer play];
                     }];
}

-(void) animateBackwardsForPage:(ASTSetupPageView *) page{
    [self.view bringSubviewToFront:page];
    page.center = CGPointMake(self.view.frame.size.width/2 - 350, self.view.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
        ///Move new view into frame and above old view
        page.center = self.view.center;
    }
                     completion:^(BOOL finished){
                         [page.videoPlayer play];
                     }];
}

-(ASTSetupPageView *) nextPageForPage:(ASTSetupPageView *) currentPage{
    int newIndex = currentPage.pageIndex + 1;
    return [self pageForIndex:newIndex];
}

-(ASTSetupPageView *) backPageForPage:(ASTSetupPageView *) currentPage{
    int newIndex = currentPage.pageIndex - 1;
    return [self pageForIndex:newIndex];
}

-(ASTSetupPageView *)pageForIndex:(NSUInteger) index{
    if(index < self.allPages.count && self.allPages.count > 0){
        return self.allPages[index];
    } else {
        return self.visiblePage;
    }
}

-(void) adjustForVisiblePage{
    [self.view bringSubviewToFront:self.visiblePage];
    [self.visiblePage.videoPlayer play];
}

#pragma mark - Respring
- (void)startRespring {
    [self.view endEditing:YES]; //save changes to text fields and dismiss keyboard
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIApplication sharedApplication] keyWindow].bounds;
    visualEffectView.alpha = 0.0;
    
    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:visualEffectView];
    
    //animate in the alpha
    [UIView animateWithDuration:3.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         visualEffectView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             NSLog(@"Squiddy says hello");
                             NSLog(@"Midnight replys with 'where am I?'");
                             //call the animation here for the screen fade and respring
                             [self graduallyAdjustBrightnessToValue:0.0f];
                         }
                     }];
}
- (void)graduallyAdjustBrightnessToValue:(CGFloat)endValue{
    CGFloat startValue = [[UIScreen mainScreen] brightness];
    
    CGFloat fadeInterval = 0.01;
    double delayInSeconds = 0.005;
    if (endValue < startValue)
        fadeInterval = -fadeInterval;
    
    CGFloat brightness = startValue;
    while (fabs(brightness-endValue)>0) {
        
        brightness += fadeInterval;
        
        if (fabs(brightness-endValue) < fabs(fadeInterval))
            brightness = endValue;
        
        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UIScreen mainScreen] setBrightness:brightness];
        });
    }
    UIView *finalDarkScreen = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
    finalDarkScreen.backgroundColor = [UIColor blackColor];
    finalDarkScreen.alpha = 0.3;
    
    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:finalDarkScreen];
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         finalDarkScreen.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             //DIE
                             AudioServicesPlaySystemSound(1521);
                             sleep(1);
                             pid_t pid;
                             const char* args[] = {"killall", "-9", "backboardd", NULL};
                             posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
                         }
                     }];
}

@end
