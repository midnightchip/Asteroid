@protocol ASTGestureDelegate <NSObject>
@required
@property (nonatomic, retain) UIView *pieceForReset;

@optional
- (void) showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)resetPiece:(UIMenuController *)controller;

@end
