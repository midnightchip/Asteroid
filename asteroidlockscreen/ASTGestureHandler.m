#import "ASTGestureHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface ASTGestureHandler ()

@end

@implementation ASTGestureHandler{
    id <ASTGestureDelegate> delegate;
    
    struct {
        BOOL showResetMenu:1;
        BOOL resetPiece:1;
    } delegateRespondsTo;
}

@synthesize delegate;


- (void)setDelegate:(id <ASTGestureDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        
        delegateRespondsTo.showResetMenu = [delegate respondsToSelector:@selector(showResetMenu:)];
        delegateRespondsTo.resetPiece = [delegate respondsToSelector:@selector(resetPiece:)];
    }
}

#pragma mark - Utility methods

/**
 Scale and rotation transforms are applied relative to the layer's anchor point this method moves a gesture recognizer's view's anchor point between the user's fingers.
 */
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


/**
 Display a menu with a single item to allow the piece's transform to be reset.
 */
- (void)_showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(delegateRespondsTo.showResetMenu){
        [self.delegate performSelector:@selector(showResetMenu:) withObject: gestureRecognizer];
    }
}

#pragma mark - Creating Gestures

-(UIPanGestureRecognizer *) delegatedPanGestureRecognizer{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(panPiece:)];
    panGesture.delegate = self;
    return panGesture;
}

-(UIRotationGestureRecognizer *) delegatedRotationGestureRecognizer{
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(rotatePiece:)];
    rotateGesture.delegate = self;
    return rotateGesture;
}

-(UIPinchGestureRecognizer *) delegatedPinchGestureRecognizer{
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(scalePiece:)];
    pinchGesture.delegate = self;
    return pinchGesture;
}

-(UILongPressGestureRecognizer *) delegatedMenuGestureRecognizer{
    UILongPressGestureRecognizer *menuGesture = [[UILongPressGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(_showResetMenu:)];
    //menuGesture.delegate = self;
    return menuGesture;
}


#pragma mark - Touch handling

/**
 Shift the piece's center by the pan amount.
 Reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position.
 */
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}


/**
 Rotate the piece by the current rotation.
 Reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation.
 */
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}


/**
 Scale the piece by the current scale.
 Reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale.
 */
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}


/**
 Ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously.
 Prevent other gesture recognizers from recognizing simultaneously.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // If the gesture recognizers are on different views, don't allow simultaneous recognition.
    if (gestureRecognizer.view != otherGestureRecognizer.view) {
        return NO;
    }
    
    // If either of the gesture recognizers is the long press, don't allow simultaneous recognition.
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}
@end
