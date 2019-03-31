#import "ASTPageViewController.h"

@interface ASTPageViewController ()
@end

@implementation ASTPageViewController {
    
}

- (instancetype)init{
    if(self = [super init]) {
        self.styleSettings = [[ASTPageViewSettings alloc] init];
    }
    return self;
}
-(void) viewDidLoad{
    [self.view setBackgroundColor: [UIColor whiteColor]];
    [self.view setUserInteractionEnabled:TRUE];
    
    //Create navigation bar
    self.navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    //Make navigation bar background transparent
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    //Create the back button view
    UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];
    
    self.backButton = [HighlightButton buttonWithType:UIButtonTypeSystem];
    self.backButton.backgroundColor = [UIColor clearColor];
    self.backButton.frame = leftButtonView.frame;
    [self.backButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/BackArrow.png"] forState:UIControlStateNormal];
    [self.backButton setTitle:BACK forState:UIControlStateNormal];
    self.backButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    self.backButton.autoresizesSubviews = YES;
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftButtonView addSubview:self.backButton];
    
    //Add back button to navigation bar
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
    navItem.leftBarButtonItem = leftBarButton;
    
    self.navBar.items = @[ navItem ];
    [self.view addSubview:self.navBar];
    [self.view bringSubviewToFront:self.navBar];
}
@end
