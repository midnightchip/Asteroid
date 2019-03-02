
#import <CoreFoundation/CFNotificationCenter.h>
#define isSB [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, retain) NSString *statusString;
-(void)setupTempText;
-(void)updateString;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@class AsteroidServer;
@interface AsteroidServer : NSObject
+(AsteroidServer *)sharedInstance;
-(NSDictionary *)returnWeatherTempDict;
@end

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

/*static NSString *weatherTemp() {
    NSDictionary* serverDict;
    if (isSB) {
        serverDict = [[%c(AsteroidServer) sharedInstance] returnWeatherTemp];
		//NSLog(@"ASTEROIDSERVER FROMSB");
    } else {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.midnightchips.asteroid.asteroidtemp"), NULL, NULL, true);
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(parseTemp) name:@"com.midnightchips.asteroid.statusbar" object:nil];
    }
	
	return serverDict[@"temp"];
    
}*/
static NSString *tempString = [[NSString alloc] init];

static inline void receiveWeather(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
        /* afaik you don't need any info you sent since you already messaged the specific observer? */
		NSLog(@"ASTEROIDSTATUS CALLED");
    NSDictionary *weather = (__bridge NSDictionary*)userInfo;
		tempString = weather[@"temp"];
		NSLog(@"ASTEROIDSTATUS CALLED %@", tempString);
		//CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.midnightchips.asteroid.asteroidstatusbar"), NULL, NULL, true);
        //[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.midnightchips.asteroid.statusbar" object:nil userInfo:tempDict];
}


%hook _UIStatusBarStringView
%property (nonatomic, retain) NSString *statusString;
- (void)setText:(NSString *)text {
	if([text containsString:@":"]) {
		if (isSB){
			NSDictionary *serverDict = [[NSDictionary alloc] init];
			serverDict = [[%c(AsteroidServer) sharedInstance] returnWeatherTempDict];
			tempString = serverDict[@"temp"];
		}else{
			CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.midnightchips.asteroid.asteroidtemp"), NULL, NULL, true);
			
		}
		[self updateString];
		NSString *newString = self.statusString;//weatherTemp();
		self.numberOfLines = 2;
		self.textAlignment = 1;
		[self setFont: [self.font fontWithSize:12]];
		%orig(newString);
	}
	else {
		%orig(text);
	}
}
%new 
-(void)updateString{
	self.statusString = tempString;
}

%end


%ctor{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                    NULL,
                                    &receiveWeather,
                                    CFSTR("com.midnightchips.asteroid.asteroidstatusbar"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately
                                    );
}
