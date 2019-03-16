#import "ASTSetupViewController.h"

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
- (void)viewDidLoad{
    self.welcomeView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame];
    [self.welcomeView setHeaderText:@"Asteroid" andDescription: @"the casle & midnightchips"];
    [self.welcomeView setupVideoWithPathToFile:@"insertPathToFile"];
    self.welcomeView.backButton.hidden = YES;
    [self indexPage: self.welcomeView];

    self.secondView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame];
    [self.secondView setHeaderText:@"Next Page" andDescription: @"Cool!"];
    [self.secondView setupVideoWithPathToFile:@"insertPathToFile"];
    [self.secondView setNextButtonTarget:self withAction:@selector(exitSetup)];
    [self.secondView.nextButton setTitle:@"Finish" forState:UIControlStateNormal];
    [self indexPage: self.secondView];
    
    
    for(ASTSetupPageView *page in self.allPages){
        if(page.nextButton.allTargets.count == 0){
            [page setNextButtonTarget:self withAction:@selector(transitionToNextPage)];
        }
        [page setBackButtonTarget:self withAction:@selector(transitionToBackPage)];
        [self.view addSubview: page];
    }
    
    self.visiblePage = self.allPages[0];
    [self adjustForVisiblePage];
}

-(void) exitSetup{
    self.view.superview.hidden = YES; // could make this fancier later
}

#pragma mark - Utility
-(void) indexPage:(ASTSetupPageView *) page{
    page.pageIndex = self.allPages.count;
    [self.allPages addObject:page];
}

-(void) transitionToNextPage{
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
}

@end
