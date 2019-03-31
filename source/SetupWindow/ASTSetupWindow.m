#import "ASTSetupWindow.h"

@interface UIWindow (SETUP)
-(void) _setSecure:(BOOL)arg1;
@end


@implementation ASTSetupWindow
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.pageManager = [[ASTPageManager alloc] init];
        [self addSubview: self.pageManager.view];
        
        
        self.setupViewController = [[ASTSetupViewController alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = 1070; // This needs to be worked on. 1070
        [self _setSecure:YES];
        [self addSubview: self.setupViewController.view];
    }
    return self;
}
@end
