#import <UIKit/UIKit.h>
#import "ASTChildViewController.h"
#import "ASTSourceDelegate.h"

@interface ASTPageViewController : UIViewController <ASTSourceDelegate>
@property (nonatomic, retain) UIPageViewController *pageController;

@property (nonatomic, retain) NSArray *astPageSources;
@end
