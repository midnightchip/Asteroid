#import "ASTSetupViewController.h"

#define PATH_TO_SNOW @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Snow.mov"
#define PATH_TO_IMAGE @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Image.PNG"
#define PATH_TO_BANNER @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Asteroid.png"
#define PATH_TO_HORIZANTAL_VIDEO @"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/Hor.MP4"


@interface ASTSetupViewController ()
@property (nonatomic, retain) NSMutableArray *allPages;
@property (nonatomic, retain) ASTSetupPageView *visiblePage;
-(ASTSetupPageView *) nextPageForPage:(ASTSetupPageView *) currentPage;
-(ASTSetupPageView *) backPageForPage:(ASTSetupPageView *) currentPage;
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
    ASTSetupPageView *welcomeView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleHeaderBasic];
    NSString *welcomeDescription = @"MidnightChips & the casle © 2019\n\nThank you for installing Asteroid. In order to deliver the best user experience, further setup is required.";
    [welcomeView setHeaderText:@"Asteroid" andDescription: welcomeDescription];
    [welcomeView setNextButtonText:SETUP_MANUALLY andOtherButton:nil];
    [welcomeView setupMediaWithPathToFile:PATH_TO_BANNER];
    welcomeView.backButton.hidden = YES;
    [welcomeView setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [self indexPage: welcomeView];
    
    ASTSetupPageView *lockPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [lockPage setHeaderText:@"Lockscreen" andDescription: @"Enable the Asteroid Lockscreen."];
    [lockPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [lockPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [lockPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [lockPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:@4 completion:nil];
    [lockPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:nil completion:nil];
    [self indexPage: lockPage];
    
    ASTSetupPageView *twelveLock = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [twelveLock setHeaderText:@"Stock iOS 12 Style" andDescription: @"Stock-styled components are enabled."];
    [twelveLock setNextButtonText:CONTINUE andOtherButton:OTHER_OPTIONS];
    [twelveLock setupMediaWithPathToFile:PATH_TO_BANNER];
    [twelveLock setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:@4 completion:nil];
    [twelveLock setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [twelveLock setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:nil completion:nil];
    [self indexPage: twelveLock];
    
    ASTSetupPageView *hourlyLock = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleBasic];
    [hourlyLock setHeaderText:@"Hourly Style" andDescription: @"Only the hourly components are enabled."];
    [hourlyLock setNextButtonText:CONTINUE andOtherButton:nil];
    [hourlyLock setupMediaWithPathToFile:PATH_TO_BANNER];
    [hourlyLock setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [hourlyLock setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:nil completion:nil];
    [self indexPage: hourlyLock];
    
    ASTSetupPageView *animationPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [animationPage setHeaderText:@"Weather Animations" andDescription: @"Enable weather animations."];
    [animationPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [animationPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [animationPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [animationPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:@7 completion:nil];
    [animationPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:@1 completion:nil];
    [self indexPage: animationPage];
    
    ASTSetupPageView *lockAnimation = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [lockAnimation setHeaderText:@"Lock Animations" andDescription: @"Enable weather animations on lockscreen."];
    [lockAnimation setNextButtonText:CONTINUE andOtherButton:SKIP];
    [lockAnimation setupMediaWithPathToFile:PATH_TO_BANNER];
    [lockAnimation setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:@7 completion:nil];
    [lockAnimation setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [lockAnimation setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:nil completion:nil];
    [self indexPage: lockAnimation];
    
    ASTSetupPageView *homeAnimation = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [homeAnimation setHeaderText:@"Home Animations" andDescription: @"Enable weather animations on homescreen."];
    [homeAnimation setNextButtonText:CONTINUE andOtherButton:SKIP];
    [homeAnimation setupMediaWithPathToFile:PATH_TO_BANNER];
    [homeAnimation setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [homeAnimation setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [homeAnimation setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:nil completion:nil];
    [self indexPage: homeAnimation];
    
    ASTSetupPageView *iconPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [iconPage setHeaderText:@"Weather Icon" andDescription: @"Enable live weather app icon."];
    [iconPage setNextButtonText:CONTINUE andOtherButton:SET_UP_LATER_IN_SETTINGS];
    [iconPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [iconPage setNextButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [iconPage setOtherButtonTarget:self withTransition:@selector(transitionToRight:) overrideIndex:nil completion:nil];
    [iconPage setBackButtonTarget:self withTransition:@selector(transitionToLeft:) overrideIndex:@4 completion:nil];
    [self indexPage: iconPage];
}

- (void)viewDidLoad{
    [self generatePages];
    for(ASTSetupPageView *page in self.allPages){
        [self.view addSubview: page];
    }
    if(self.allPages.count >= 0) self.visiblePage = self.allPages[0];
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
    if(index < self.allPages.count && index >= 0){
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
