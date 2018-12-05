#include "LWPPreferenceController.h"


@interface CSPListController (lockscreen)
@end 

@implementation CSPListController (lockscreen)
-(NSArray *)getImageType{
	return [[NSArray alloc] initWithObjects: @"Filled Solid Color", @"Outline Image", nil];
}
-(void) refreshImage{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                           message:@"This is an alert."
                           preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
	
	[alert addAction:defaultAction];
	[self presentViewController:alert animated:YES completion:nil];
}
-(void) resetLoc{
    [prefs setObject: @(YES) forKey:@"resetXY"];
    [prefs saveAndPostNotification];
}
-(void)resetSizeMethod{
    [prefs setObject: @(YES) forKey:@"resetSizing"];
    [prefs saveAndPostNotification];
}

@end 

@implementation LWPPreferenceController

@end
