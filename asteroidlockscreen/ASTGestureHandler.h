@interface ASTGestureHandler : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, retain) UIViewController *delegate;

- (void)resetPiece:(UIMenuController *)controller;
-(UIPanGestureRecognizer *) delegatedPanGestureRecognizer;
-(UIRotationGestureRecognizer *) delegatedRotationGestureRecognizer;
-(UIPinchGestureRecognizer *) delegatedPinchGestureRecognizer;
-(UILongPressGestureRecognizer *) delegatedMenuGestureRecognizer;

@end
