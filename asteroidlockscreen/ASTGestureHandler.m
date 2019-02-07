#import "ASTGestureHandler.h"
#import <QuartzCore/QuartzCore.h>

// Heavily based off of:
// https://developer.apple.com/library/archive/samplecode/Touches/Touches.zip

@interface ASTGestureHandler ()

@end

@implementation ASTGestureHandler{
    id <ASTGestureDelegate> delegate;
    
    struct {
        BOOL showResetMenu:1;
        BOOL resetPiece:1;
    } delegateRespondsTo;
}

#pragma mark - Delegate property

@synthesize delegate;

- (void)setDelegate:(id <ASTGestureDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        
        delegateRespondsTo.showResetMenu = [delegate respondsToSelector:@selector(showResetMenu:)];
        delegateRespondsTo.resetPiece = [delegate respondsToSelector:@selector(resetPiece:)];
    }
}

#pragma mark - Utility methods

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
    menuGesture.delegate = self;
    return menuGesture;
}


#pragma mark - Touch handling

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

- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.view != otherGestureRecognizer.view) {
        return NO;
    }
    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}
@end
