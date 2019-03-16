#import "ASTSetupViewController.h"

@interface ASTSetupViewController ()
@property (nonatomic, retain) NSMutableArray *allPages;
@property (nonatomic, retain) ASTSetupPageView *visiblePage;
-(ASTSetupPageView *) nextPageForPage:(ASTSetupPageView *) currentPage;
-(ASTSetupPageView *) backPageForPage:(ASTSetupPageView *) currentPage;
@end

@implementation ASTSetupViewController {
    
}

@synthesize visiblePage = _visiblePage;
- (instancetype)init{
    if(self = [super init]) {
        
    }
    return self;
}
- (void)viewDidLoad{
    self.allPages = [[NSMutableArray alloc] init];
    
    self.welcomeView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame];
    [self.welcomeView setHeaderText:@"Asteroid" andDescription: @"the casle & midnightchips"];
    [self.welcomeView setupVideoWithPathToFile:@"insertPathToFile"];
    [self.welcomeView setNextButtonTarget:self withAction:@selector(welcomeViewNext)];
    [self.view addSubview: self.welcomeView];
    [self.view sendSubviewToBack:self.welcomeView];
    
    self.welcomeView.pageIndex = self.allPages.count;
    [self.allPages addObject:self.welcomeView];
    
    
    self.secondView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame];
    [self.secondView setHeaderText:@"Next Page" andDescription: @"Cool!"];
    [self.secondView setupVideoWithPathToFile:@"insertPathToFile"];
    [self.secondView setNextButtonTarget:self withAction:@selector(welcomeViewNext)];
    [self.view addSubview: self.secondView];
    [self.view sendSubviewToBack:self.secondView];
    
    self.secondView.pageIndex = self.allPages.count;
    [self.allPages addObject:self.secondView];
    
    
    self.visiblePage = self.allPages[0];
}

#pragma mark - Next Button Pressed
-(void) welcomeViewNext{
    [self transitionToNextPageFrom:self.welcomeView];
}

#pragma mark - Utility
-(void) transitionToNextPageFrom:(ASTSetupPageView *) currentPage{
    self.visiblePage = [self nextPageForPage:currentPage];
}

-(void) transitionToBackPageFrom:(ASTSetupPageView *) currentPage{
    self.visiblePage = [self backPageForPage:currentPage];
}

-(ASTSetupPageView *) nextPageForPage:(ASTSetupPageView *) currentPage{
    return self.allPages[currentPage.pageIndex + 1];
}

-(ASTSetupPageView *) backPageForPage:(ASTSetupPageView *) currentPage{
    return self.allPages[currentPage.pageIndex - 1];
}

-(void) setVisiblePage:(ASTSetupPageView *) page{
    _visiblePage = page;
    [self adjustForVisiblePage];
}

-(void) adjustForVisiblePage{
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

@end
