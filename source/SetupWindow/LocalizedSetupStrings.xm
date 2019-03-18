#import "LocalizedSetupStrings.h"

NSString *BACK;
NSString *SET_UP_LATER_IN_SETTINGS;
NSString *CONTINUE;
NSString *GET_STARTED;
NSString *SETUP_MANUALLY;
NSString *OK;
NSString *DONT_USE;
NSString *OTHER_OPTIONS;
NSString *CANCEL;
NSString *NOT_NOW;
NSString *SKIP;

%ctor{
    NSBundle *setupApp = [NSBundle bundleWithPath:@"Applications/Setup.app"];
    
    BACK = [setupApp localizedStringForKey:@"BACK" value:@"" table:nil];
    SET_UP_LATER_IN_SETTINGS = [setupApp localizedStringForKey:@"SKIP_ENTER_APPLEID" value:@"" table:nil];
    CONTINUE = [setupApp localizedStringForKey:@"CONTINUE" value:@"" table:nil];
    GET_STARTED = [setupApp localizedStringForKey:@"GET_STARTED" value:@"" table:nil];
    SETUP_MANUALLY = [setupApp localizedStringForKey:@"PROXIMITY_SETUP_MANUALLY" value:@"" table:nil];
    OK = [setupApp localizedStringForKey:@"OK" value:@"" table:nil];
    DONT_USE = [setupApp localizedStringForKey:@"DONT_USE" value:@"" table:nil];
    OTHER_OPTIONS = [setupApp localizedStringForKey:@"OTHER_OPTIONS" value:@"" table:@"RestoreFromBackup"];
    CANCEL = [setupApp localizedStringForKey:@"CANCEL" value:@"" table:nil];
    NOT_NOW = [setupApp localizedStringForKey:@"SKIP" value:@"" table:@"SoftwareUpdate"];
    SKIP = [setupApp localizedStringForKey:@"SKIP" value:@"" table:nil];
}
