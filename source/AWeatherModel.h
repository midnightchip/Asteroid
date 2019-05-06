#import <CSPreferences/CSPreferencesProvider.h>
#import "LWPProvider.h"
#import <objc/runtime.h>
#import "WeatherHeaders.h"
#import "ConditionOption.h"
#import "ConditionImageType.h"
#import "DGLogging.h"
#define prefs [LWPProvider sharedProvider]

typedef void(^completion)();

@interface AWeatherModel : NSObject
@property (nonatomic, retain) WeatherPreferences *weatherPreferences;
@property (nonatomic, retain) WATodayAutoupdatingLocationModel *locationProviderModel;
@property (nonatomic, retain) WATodayAutoupdatingLocationModel *todayModel;
@property (nonatomic, retain) WAForecastModel *forecastModel;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, getter=isLocalWeather) BOOL localWeather;
@property (nonatomic, getter=isPopulated) BOOL populated;
@property (nonatomic) BOOL hasFallenBack;

+ (instancetype)sharedInstance;
-(void)updateWeatherDataWithCompletion:(completion) compBlock;
-(void)setUpRefreshTimer;
-(void) postNotification;
-(void) verifyAndCorrectCondition;
- (UIImage *)imageForKey:(NSString *)key;
- (NSBundle *)weatherBundle;
-(NSString *) localeTemperature;
- (NSString *)currentConditionOverview;
-(UIImage *) glyphWithOption:(ConditionOption) option;
-(ConditionImageType) conditionImageTypeForString: (NSString *) conditionString;
@end

@interface City (Condition)
-(void)setConditionCode:(long long)arg1;
@end
