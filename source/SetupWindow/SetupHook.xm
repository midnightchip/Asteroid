#import "ASTSetupWindow.h"

@interface SBCoverSheetPrimarySlidingViewController
@property (nonatomic, retain) ASTSetupWindow *setupWindow;
@end

@interface SBDashBoardIdleTimerProvider
- (void)turnOffAutoLock;
- (void)turnOnAutoLock;
-(void) addDisabledIdleTimerAssertionReason:(NSString *)reason;
-(void) removeDisabledIdleTimerAssertionReason:(NSString *)reason;
@end

%hook SBCoverSheetPrimarySlidingViewController
%property (nonatomic, retain) ASTSetupWindow *setupWindow;
-(void)viewDidLoad {
    %orig;
    //self.setupWindow = [[ASTSetupWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    //[self.setupWindow makeKeyAndVisible];
}
%end

%hook SBDashBoardIdleTimerProvider
- (instancetype)initWithDelegate:(id)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffAutoLock) name:@"astDisableLock" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnAutoLock) name:@"astEnableLock" object:nil];
    return self;
}

%new
- (void)turnOffAutoLock {
    [self addDisabledIdleTimerAssertionReason:@"Asteroid_owo"];
}

%new
- (void)turnOnAutoLock {
    [self removeDisabledIdleTimerAssertionReason:@"Asteroid_owo"];
}
%end
