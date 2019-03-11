#include <AppSupport/CPDistributedMessagingCenter.h>
#import "AWeatherModel.h"
#import <rocketbootstrap/rocketbootstrap.h>

@interface AsteroidServer : NSObject
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end

@implementation AsteroidServer 

+ (void)load {
	[self sharedInstance];
}

+ (id)sharedInstance {
	static dispatch_once_t once = 0;
	__strong static id sharedInstance = nil;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id)init {
	if ((self = [super init])) {
		self.weatherModel = [%c(AWeatherModel) sharedInstance];
		// ...
		// Center name must be unique, recommend using application identifier.
		CPDistributedMessagingCenter * messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
		rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
		[messagingCenter runServerOnCurrentThread];

		// Register Messages
		[messagingCenter registerForMessageName:@"weatherIcon" target:self selector:@selector(returnWeatherLogo)];
		[messagingCenter registerForMessageName:@"weatherTemp" target:self selector:@selector(returnWeatherTemp)];
        [messagingCenter registerForMessageName:@"cityIndex" target:self selector:@selector(returnCurrentIndex)];
        [messagingCenter registerForMessageName:@"returnCityIndex" target:self selector:@selector(saveCurrentIndexName:withUserInfo:)];
	}
	return self;
}

-(UIImage *)returnWeatherLogo{
	return nil;
}

-(NSDictionary *)returnWeatherTemp{
	HBLogDebug(@"returningWEatherTemp");
	NSMutableDictionary *sendTemp= [[NSMutableDictionary alloc]init];
	sendTemp[@"temp"] = [self.weatherModel localeTemperature];
	HBLogDebug(@"returningWEatherTemp %@", sendTemp);
	return sendTemp;
}

-(NSDictionary *) returnCurrentIndex{
    NSMutableDictionary *sendIndex = [[NSMutableDictionary alloc]init];
    sendIndex[@"index"] = @([prefs intForKey:@"astDefaultIndex"]);
    return sendIndex;
}

-(void) saveCurrentIndexName:(NSString *)name withUserInfo:(NSDictionary *)indexDict{
    NSNumber *indexValue = indexDict[@"index"];
    [prefs setObject:indexValue forKey:@"astDefaultIndex"];
    [prefs save];
}
@end

%ctor{
	HBLogDebug(@"Loaded");
	[AsteroidServer load];
}
