#include <CSPreferences/CSPreferencesProvider.h>
#define prefs [LWPProvider sharedProvider]

@interface LWPProvider : NSObject

+ (CSPreferencesProvider *)sharedProvider;

@end
