//#include <AppSupport/CPDistributedMessagingCenter.h>
#import "AWeatherModel.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFNotificationCenter.h>
//#import <rocketbootstrap/rocketbootstrap.h>
extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end
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
		/*CPDistributedMessagingCenter * messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
		rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
		[messagingCenter runServerOnCurrentThread];

		// Register Messages
		[messagingCenter registerForMessageName:@"weatherIcon" target:self selector:@selector(returnWeatherLogo)];
		[messagingCenter registerForMessageName:@"weatherTemp" target:self selector:@selector(returnWeatherTemp)];*/
	}

	return self;
}

static inline void sendWeather(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
        /* afaik you don't need any info you sent since you already messaged the specific observer? */
		NSLog(@"ASTEROIDSERVER CALLED");
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:[[AsteroidServer sharedInstance] returnWeatherTemp] forKey:@"temp"];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.midnightchips.asteroid.statusbar" object:nil userInfo:tempDict];
}

-(UIImage *)returnWeatherLogo{
	return nil;
}
-(NSString *)returnWeatherTemp{
	if([self.weatherModel localeTemperature]){
		return [self.weatherModel localeTemperature];
	}else{
		return @"Error";
	}
}
-(NSDictionary *)returnWeatherTempDict{
	HBLogDebug(@"returningWEatherTemp");
	NSMutableDictionary *sendTemp = [[NSMutableDictionary alloc]init];
	NSLog(@"ASTEROIDSERVER RETURNINGWEATHER");
	if([self.weatherModel localeTemperature]){
		sendTemp[@"temp"] = [self.weatherModel localeTemperature];
	}else{
		sendTemp[@"temp"] = @"Error";
	}
	
	HBLogDebug(@"returningWEatherTemp %@", sendTemp);
	return sendTemp;
}

@end

%ctor{
	HBLogDebug(@"Loaded");
	[AsteroidServer load];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    &sendWeather,
                                    CFSTR("com.midnightchips.asteroid.asteroidtemp"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately
                                    );
}
