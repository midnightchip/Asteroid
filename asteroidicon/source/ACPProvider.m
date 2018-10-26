#include "ACPProvider.h"

@implementation ACPProvider

#pragma mark Initialization

+ (CSPreferencesProvider *)sharedProvider {
    static dispatch_once_t once;
    static CSPreferencesProvider *sharedProvider;
    dispatch_once(&once, ^{

        NSString *tweakId = @"com.midnightchips.asteroid";
        NSString *prefsNotification = [tweakId stringByAppendingString:@".prefschanged"];
        NSString *defaultsPath = @"/Library/PreferenceBundles/Asteroid.bundle/defaults.plist";

        sharedProvider = [[CSPreferencesProvider alloc] initWithTweakID:tweakId defaultsPath:defaultsPath postNotification:prefsNotification notificationCallback:^void (CSPreferencesProvider *provider) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ACPSettingsChanged" object:nil userInfo:nil];
        }];

    });
    return sharedProvider;
}

@end
