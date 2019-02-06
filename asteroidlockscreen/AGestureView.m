#import "AGestureView.h"

@implementation AGestureView{
    BOOL _editing;
}

- (instancetype) initWithFrame:(CGRect) frame{
    if(self = [super initWithFrame:frame]){
        self.frame = frame;
    }
    return self;
}
-(void) zoomingFilter:(UIPinchGestureRecognizer *)sender{
    
}
-(void) movingFilter:(UIPanGestureRecognizer *)sender{
    
}
-(void) animateFilter: (UIView *)view{
    
}
-(void) toggleEditMode:(UILongPressGestureRecognizer *)sender{
    
}
-(void) setupGestures{
    
}


@end
