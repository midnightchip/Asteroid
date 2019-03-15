#import "ASTSetupViewController.h"

@interface ASTSetupViewController ()
@end

@implementation ASTSetupViewController {
    
}

- (instancetype)init{
    if(self = [super init]) {
        
    }
    return self;
}
- (void)viewDidLoad{
    self.welcomeView = [[ASTSetupPageView alloc] initWithFrame: self.view.frame];
    [self.view addSubview: self.welcomeView];
}
@end
