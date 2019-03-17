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
    }
    return self;
}

-(void) generatePages {
    ASTSetupPageView *welcomeView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleBasic];
    [welcomeView setHeaderText:@"Asteroid" andDescription: @"the casle & midnightchips"];
    [welcomeView setNextButtonText:SETUP_MANUALLY andOtherButton:nil];
    [welcomeView setupMediaWithPathToFile:PATH_TO_SNOW];
    welcomeView.backButton.hidden = YES;
    [self indexPage: welcomeView];
    
    ASTSetupPageView *randomPage = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleTwoButtons];
    [randomPage setHeaderText:@"Woo another page" andDescription: @"more tests cooc"];
    [randomPage setNextButtonText:CONTINUE andOtherButton:nil];
    [randomPage setupMediaWithPathToFile:PATH_TO_IMAGE];
    [self indexPage: randomPage];
    
    ASTSetupPageView *secondView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame style:ASTSetupStyleHeaderBasic];
    [secondView setHeaderText:@"New Header Style" andDescription: @"This is the description text underneath the header!"];
    [secondView setNextButtonText:GET_STARTED andOtherButton:nil];
    [secondView setupMediaWithPathToFile:PATH_TO_BANNER];
    [self indexPage: secondView];
}

- (void)viewDidLoad{
    [self generatePages];
    for(ASTSetupPageView *page in self.allPages){
        [page setNextButtonTarget:self withAction:@selector(transitionToNextPage)];
        [page setOtherButtonTarget:self withAction:@selector(transitionToNextPage)];
        [page setBackButtonTarget:self withAction:@selector(transitionToBackPage)];
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
    }];
}

#pragma mark - Utility
-(void) indexPage:(ASTSetupPageView *) page{
    page.pageIndex = self.allPages.count;
    [self.allPages addObject:page];
}

-(void) transitionToNextPage{
    if(self.visiblePage == [self nextPageForPage:self.visiblePage]){ // Last page.
        [self exitSetup];
    } else {
        self.visiblePage = [self nextPageForPage:self.visiblePage];
        
        [self.view bringSubviewToFront:self.visiblePage];
        self.visiblePage.center = CGPointMake(self.view.frame.size.width/2 + 350, self.view.center.y);
        [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
            ///Move new view into frame and above old view
            self.visiblePage.center = self.view.center;
        }
                         completion:^(BOOL finished){
                             [self.visiblePage.videoPlayer play];
                         }];
    }
}

-(void) transitionToBackPage{
    self.visiblePage = [self backPageForPage:self.visiblePage];
    
    [self.view bringSubviewToFront:self.visiblePage];
    self.visiblePage.center = CGPointMake(self.view.frame.size.width/2 - 350, self.view.center.y);
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut  animations:^{
        ///Move new view into frame and above old view
        self.visiblePage.center = self.view.center;
    }
                     completion:^(BOOL finished){
                         [self.visiblePage.videoPlayer play];
                     }];
}

-(ASTSetupPageView *) nextPageForPage:(ASTSetupPageView *) currentPage{
    int newIndex = currentPage.pageIndex + 1;
    if(self.allPages.count > newIndex){
        return self.allPages[newIndex];
    } else {
        return self.visiblePage;
    }
}

-(ASTSetupPageView *) backPageForPage:(ASTSetupPageView *) currentPage{
    int newIndex = currentPage.pageIndex - 1;
    if(0 <= newIndex){
        return self.allPages[newIndex];
    } else {
        return self.visiblePage;
    }
}

-(void) adjustForVisiblePage{
    [self.view bringSubviewToFront:self.visiblePage];
    [self.visiblePage.videoPlayer play];
}

@end
