#import "ASTSetupWindow.h"

@interface SBCoverSheetPrimarySlidingViewController
@property (nonatomic, retain) ASTSetupWindow *setupWindow;
@end

%hook SBCoverSheetPrimarySlidingViewController
%property (nonatomic, retain) ASTSetupWindow *setupWindow;
-(void)viewDidLoad {
    %orig;
    self.setupWindow = [[ASTSetupWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [self.setupWindow makeKeyAndVisible];
}
%end


@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

%hook UIStatusBar
-(UIColor *)foregroundColor{
    return [UIColor blackColor];
}

%end

