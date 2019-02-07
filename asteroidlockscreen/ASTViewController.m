#import "ASTViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ASTViewController ()
@property (nonatomic, retain) UIView *firstPieceView;
@property (nonatomic, retain) UIView *secondPieceView;
@property (nonatomic, retain) UIView *thirdPieceView;

@property (nonatomic, retain) ASTGestureHandler *gestureHandler;

@end



@implementation ASTViewController{

}

- (instancetype) init{
    if(self = [super init]){
        self.gestureHandler = [[ASTGestureHandler alloc] init];
        self.gestureHandler.delegate = self;
    }
    return self;
}

- (void)viewDidLoad{
    self.firstPieceView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    self.secondPieceView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 100, 100)];
    self.thirdPieceView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    
    NSArray *viewArray = @[self.firstPieceView, self.secondPieceView, self.thirdPieceView];
    
    for(UIView *view in viewArray){
        [view addGestureRecognizer:[self.gestureHandler delegatedPanGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedRotationGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedPinchGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedMenuGestureRecognizer]];
    }
    
    self.firstPieceView.backgroundColor = [UIColor redColor];
    self.secondPieceView.backgroundColor = [UIColor blueColor];
    self.thirdPieceView.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:self.firstPieceView];
    [self.view addSubview:self.secondPieceView];
    [self.view addSubview:self.thirdPieceView];
}

#pragma mark - Menu Controller

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)resetPiece:(UIMenuController *)controller
{
    [self.gestureHandler resetPiece:controller];
}
@end
