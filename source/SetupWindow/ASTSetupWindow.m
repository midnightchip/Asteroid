#import "ASTSetupWindow.h"

@interface UIWindow (SETUP)
-(void) _setSecure:(BOOL)arg1;
@end

@interface ASTSetupWindow ()
@end

@implementation ASTSetupWindow{
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.setupViewController = [[ASTSetupViewController alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = 1070; // This needs to be worked on.
        [self _setSecure:YES];
        [self addSubview: self.setupViewController.view];
    }
    return self;
}
@end
