#import <UIKit/UIKit.h>
#import <spawn.h>
#import "ASTChildViewController.h"
#import "ASTSourceDelegate.h"
#import "LocalizedSetupStrings.h"
#import "../source/LWPProvider.h"

@interface ASTPageViewController : UIViewController <ASTSourceDelegate>
@property (nonatomic, retain) UIPageViewController *pageController;

@property (nonatomic, retain) NSArray *astPageSources;
@end
