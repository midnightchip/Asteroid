#import "ASTPageViewController.h"

@interface ASTPageViewController ()
@end

@implementation ASTPageViewController {
    
}

- (instancetype)init{
    if(self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.astPageSources = @[@{@"astStyle":@(ASTSetupStyleTwoButtons)}];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    ASTChildViewController *initialViewController = [self viewControllerAtIndex:0];
    initialViewController.delegate = self;
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (void)changePage:(UIPageViewControllerNavigationDirection)direction {
    NSUInteger pageIndex = ((ASTChildViewController *) [self.pageController.viewControllers objectAtIndex:0]).index;
    if (direction == UIPageViewControllerNavigationDirectionForward){
        pageIndex++;
    }else {
        pageIndex--;
    }
    if(pageIndex >= self.astPageSources.count){
        for(ASTChildViewController *page in self.pageController.viewControllers){
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
        return;
    }
    
    ASTChildViewController *viewController = [self  viewControllerAtIndex:pageIndex];
    if (viewController == nil) {
        return;
    }
    [self.pageController setViewControllers:@[viewController] direction:direction animated:YES completion:nil];
}

- (ASTChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    ASTChildViewController *childViewController = [[ASTChildViewController alloc] initWithSource:self.astPageSources[0]];
    childViewController.index = index;
    childViewController.delegate = self;
    
    return childViewController;
}
@end
