@interface AGestureView : UIView
-(void) zoomingFilter:(UIPinchGestureRecognizer *)sender;
-(void) movingFilter:(UIPanGestureRecognizer *)sender;
-(void) animateFilter: (UIView *)view;
-(void) toggleEditMode:(UILongPressGestureRecognizer *)sender;
-(void) setupGestures;


@end
