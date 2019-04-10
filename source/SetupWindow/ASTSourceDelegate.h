#import <UIKit/UIKit.h>

@protocol ASTSourceDelegate <NSObject>
- (void)changePage:(UIPageViewControllerNavigationDirection)direction;
@end
