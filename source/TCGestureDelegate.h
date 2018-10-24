#import <Foundation/NSObject.h>

@interface TCGestureDelegate : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL tc_editing;
- (void)tc_movingFilter:(UIPanGestureRecognizer *)sender;
- (void)tc_zoomingFilter:(UIPinchGestureRecognizer *)sender;
- (void)tc_toggleEditMode:(UILongPressGestureRecognizer *)sender;
@end
