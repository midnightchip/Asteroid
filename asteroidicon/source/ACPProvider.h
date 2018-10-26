#include <CSPreferences/CSPreferencesProvider.h>
#define prefs [ACPProvider sharedProvider]

@interface ACPProvider : NSObject

+ (CSPreferencesProvider *)sharedProvider;

@end