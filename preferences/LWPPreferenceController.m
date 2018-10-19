#include "LWPPreferenceController.h"


@interface CSPListController (lockscreen)
@end 

@implementation CSPListController (lockscreen)
-(NSArray*)availableFonts{
    NSMutableArray *fontNames = [[NSMutableArray alloc] init];
    for (NSString *familyName in [UIFont familyNames]){
        NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
            [fontNames addObject: fontName];
            }
        }

    [fontNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return fontNames;
}

@end 
@implementation LWPPreferenceController

@end
