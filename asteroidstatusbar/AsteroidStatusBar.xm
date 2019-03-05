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
				NSLog(@"RECIVEDDICT %@", serverDict);
    }
    return serverDict[@"temp"];
}

%hook _UIStatusBarStringView
- (void)setText:(NSString *)text {
	if([text containsString:@":"]) {
		NSString *newString = [NSString stringWithFormat:@"%@\n%@", text, weatherTemp()];
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

@interface _UIStatusBarTimeItem
@property (copy) _UIStatusBarStringView *shortTimeView;
@property (copy) _UIStatusBarStringView *pillTimeView;
@end

%hook _UIStatusBarTimeItem

- (id)applyUpdate:(id)arg1 toDisplayItem:(id)arg2 {
	id returnThis = %orig;
	[self.shortTimeView setFont: [self.shortTimeView.font fontWithSize:12]];
	[self.pillTimeView setFont: [self.pillTimeView.font fontWithSize:12]];
	return returnThis;
}

%end

@interface _UIStatusBarBackgroundActivityView : UIView
@property (copy) CALayer *pulseLayer;
@end

%hook _UIStatusBarBackgroundActivityView

- (void)setCenter:(CGPoint)point {
	point.y = 11;
	self.frame = CGRectMake(0, 0, self.frame.size.width, 31);
	self.pulseLayer.frame = CGRectMake(0, 0, self.frame.size.width, 31);
	%orig(point);
}

%end
