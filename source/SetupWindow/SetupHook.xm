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

