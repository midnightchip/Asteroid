//#include <AppSupport/CPDistributedMessagingCenter.h>
//#import <rocketbootstrap/rocketbootstrap.h>
#define isSB [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, retain) NSString *tempString;
-(void)setupTempText;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@class AsteroidServer;
@interface AsteroidServer : NSObject
+(AsteroidServer *)sharedInstance;
-(NSDictionary *)returnWeatherTempDict;
@end

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




%hook _UIStatusBarStringView
%property (nonatomic, retain) NSString *tempString;
- (void)setText:(NSString *)text {
	if([text containsString:@":"]) {
		if (isSB){
			NSDictionary *serverDict = [[NSDictionary alloc] init];
			serverDict = [[%c(AsteroidServer) sharedInstance] returnWeatherTempDict];
			self.tempString = serverDict[@"temp"];
		}else{
			[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTempText:) name:@"com.midnightchips.asteroid.statusbar" object:nil];
		
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.midnightchips.asteroid.asteroidtemp"), NULL, NULL, true);
			
		}
		NSString *newString = self.tempString;//weatherTemp();
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
-(void)setupTempText:(NSNotification *)notification{
	NSLog(@"ASTEROIDSTATUS CALLED %@", notification.userInfo);
	if(notification.userInfo[@"temp"]){
		self.tempString = notification.userInfo[@"temp"];
	}
}

%end
