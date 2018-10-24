#import "TCGestureDelegate.h"

@implementation TCGestureDelegate
- (void)tc_movingFilter:(UIPanGestureRecognizer *)sender{
    UIView *view = (UIView *)sender.view;
    
    CGPoint translation = [sender translationInView:view];
    translation.x = view.center.x + translation.x;
    translation.y = view.center.y + translation.y;
    view.center = translation;
    
    [sender setTranslation:CGPointZero inView:view];
}
- (void)tc_zoomingFilter:(UIPinchGestureRecognizer *)sender{
    UIView *view = (UIView *)sender.view;
    
    CGFloat scale = sender.scale;
    [view layer].anchorPoint = CGPointMake(0.5, 0.5);
    view.transform = CGAffineTransformScale(view.transform, scale, scale);
    sender.scale = 1.0;
}
- (void)tc_toggleEditMode:(UILongPressGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan) {
        [[[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium] impactOccurred];
        UIView *view = (UIView *)sender.view;
        if(self.tc_editing) {
            view.alpha = 1.0;
            self.tc_editing = NO;
        }
        else {
            view.alpha = .5;
            self.tc_editing = YES;
        }
    }
}
@end
