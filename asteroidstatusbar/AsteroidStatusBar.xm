#include <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
@interface _UIStatusBarStringView : UILabel
@end

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
		CPDistributedMessagingCenter *messagingCenter;
		messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
		rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
        NSDictionary *serverDict = [messagingCenter sendMessageAndReceiveReplyName:@"weatherTemp" userInfo:nil/* optional dictionary */];//[self.weatherModel localeTemperature];
		NSString *newString = serverDict[@"temp"];
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