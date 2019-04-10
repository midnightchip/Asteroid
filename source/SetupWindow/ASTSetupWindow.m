#import "ASTSetupWindow.h"

@interface UIWindow (SETUP)
-(void) _setSecure:(BOOL)arg1;
@end


@implementation ASTSetupWindow
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.pageManager = [[ASTPageViewController alloc] init];
        [self addSubview: self.pageManager.view];
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = 1070; // This overlaps status bar. 1070
        [self _setSecure:YES];
    }
    return self;
}
@end
