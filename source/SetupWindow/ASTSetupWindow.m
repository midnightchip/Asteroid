#import "ASTSetupWindow.h"

@interface ASTSetupWindow ()
@end

@implementation ASTSetupWindow{
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.setupViewController = [[ASTSetupViewController alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        [self addSubview: self.setupViewController.view];
    }
    return self;
}
@end
