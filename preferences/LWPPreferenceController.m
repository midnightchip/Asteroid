#include "LWPPreferenceController.h"


@interface CSPListController (lockscreen)
@end 

@implementation CSPListController (lockscreen)
-(NSArray *)getImageType{
	return [[NSArray alloc] initWithObjects: @"Standard", @"Filled Solid Color", @"Outline Image", nil];
}


@end 
@implementation LWPPreferenceController

@end
