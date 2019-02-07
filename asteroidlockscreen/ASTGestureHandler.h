#import "ASTGestureDelegate.h"

@interface ASTGestureHandler : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <ASTGestureDelegate> delegate;

-(UIPanGestureRecognizer *) delegatedPanGestureRecognizer;
-(UIRotationGestureRecognizer *) delegatedRotationGestureRecognizer;
-(UIPinchGestureRecognizer *) delegatedPinchGestureRecognizer;
-(UILongPressGestureRecognizer *) delegatedMenuGestureRecognizer;

- (void)setDelegate:(id <ASTGestureDelegate>)aDelegate;

@end
