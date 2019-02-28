#include <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#define isSB [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]

@interface _UIStatusBarStringView : UILabel
@end

@class AsteroidServer;
@interface AsteroidServer : NSObject
+(AsteroidServer *)sharedInstance;
-(NSDictionary *)returnWeatherTemp;
@end

static NSString *weatherTemp() {
    NSDictionary* serverDict;
    if (isSB) {
        serverDict = [[%c(AsteroidServer) sharedInstance] returnWeatherTemp];
    } else {
        CPDistributedMessagingCenter *messagingCenter;
	messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
	rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
        serverDict = [messagingCenter sendMessageAndReceiveReplyName:@"weatherTemp" userInfo:nil/* optional dictionary */];
    }
    return serverDict[@"temp"];
}

%hook _UIStatusBarStringView
- (void)setText:(NSString *)text {
	if([text containsString:@":"]) {
        //self.weatherModel = [%c(AWeatherModel) sharedInstance];
		//NSTextAttachment *image = [[NSTextAttachment alloc] init];
		//image.image = [self.weatherModel glyphWithOption:ConditionOptionWhite];
		//NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:image];
		//icon = 
		//NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"Hi"];
		//[myString appendAttributedString:attachmentString];
		//NSString *newString = [NSString stringWithFormat:@"%@ %@", text, @"Hi"];
		//[self.weatherModel localeTemperature];
		NSString *newString = weatherTemp();
		self.numberOfLines = 2;
		self.textAlignment = 1;
		[self setFont: [self.font fontWithSize:12]];
		%orig(newString);
	}
	else {
		%orig(text);
	}
}

%end
