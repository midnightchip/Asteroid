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
  /*for(NSString *file in files) {
    NSString *path = [@"/Library/Springy/" stringByAppendingPathComponent:file];
    BOOL isDir = NO;
    [fm fileExistsAtPath:path isDirectory:(&isDir)];
    if(isDir) {
      [fontList addObject:file];
    }
  }*/

  return fontNames;
}

@end 
@implementation LWPPreferenceController

@end
