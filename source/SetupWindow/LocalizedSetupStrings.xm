#import "LocalizedSetupStrings.h"
NSString *SET_UP_LATER_IN_SETTINGS;
NSString *CONTINUE;
NSString *GET_STARTED;
NSString *SETUP_MANUALLY;

%ctor{
    NSBundle *setupApp = [NSBundle bundleWithPath:@"Applications/Setup.app"];
    SET_UP_LATER_IN_SETTINGS = [setupApp localizedStringForKey:@"SKIP_ENTER_APPLEID" value:@"" table:nil];
    CONTINUE = [setupApp localizedStringForKey:@"CONTINUE" value:@"" table:nil];
    GET_STARTED = [setupApp localizedStringForKey:@"GET_STARTED" value:@"" table:nil];
    SETUP_MANUALLY = [setupApp localizedStringForKey:@"PROXIMITY_SETUP_MANUALLY" value:@"" table:nil];
}
