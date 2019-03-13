#include <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import "../source/UIImage+ScaledImage.h"
#define isSB [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) BOOL isTime;
@property (nonatomic,copy) NSString * originalText; 
@end 


@class AsteroidServer;
@interface AsteroidServer : NSObject
+(AsteroidServer *)sharedInstance;
-(NSDictionary *)returnWeatherTemp;
-(NSDictionary *)returnWeatherItems;
-(NSDictionary *)returnWeatherLogo;
@end


static UIImage *getWeatherImage(){
	UIImage *image;
	NSDictionary *weatherItem;
	if(isSB){
		weatherItem = [[%c(AsteroidServer) sharedInstance] returnWeatherLogo];
		image = weatherItem[@"image"];
	}else{
		CPDistributedMessagingCenter *messagingCenter;
		messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
		rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
		weatherItem = [messagingCenter sendMessageAndReceiveReplyName:@"weatherIcon" userInfo:nil];
		image = weatherItem[@"image"];
	}
	return image;
}

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
%property (nonatomic, assign) BOOL isTime;
-(void)setText:(id)arg1{
	if(self.isTime){
		NSTextAttachment *weatherAttach = [[NSTextAttachment alloc] init];
		UIImage *weatherImage = getWeatherImage();//weatherItems[@"image"];
		double aspect = weatherImage.size.width / weatherImage.size.height;
		weatherImage = [weatherImage scaleImageToSize:CGSizeMake(self.font.lineHeight * aspect, self.font.lineHeight)];
		[weatherAttach setBounds:CGRectMake(0, roundf(self.font.capHeight - weatherImage.size.height)/2.f, weatherImage.size.width, weatherImage.size.height)];
		weatherImage = [weatherImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		weatherAttach.image = weatherImage;
		//Stupid Tint workaround
    	NSMutableAttributedString *imageFixText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    	NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:weatherAttach];
		[imageFixText appendAttributedString:attachmentString];
    	[imageFixText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:0] range:NSMakeRange(0, imageFixText.length)]; // Put font size 0 to prevent offset
    	[imageFixText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
		//End stupid UIKit workaround
		NSDictionary *attribs = @{
                          NSFontAttributeName: self.font
                          };
		NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:weatherTemp() attributes:attribs];
		[imageFixText appendAttributedString:tempString];
		[self setAttributedText:imageFixText];
	}else{
		%orig;
	}
}

%end

@interface _UIStatusBarTimeItem
@property (copy) _UIStatusBarStringView *shortTimeView;
@property (copy) _UIStatusBarStringView *pillTimeView;
@end

%hook _UIStatusBarTimeItem

-(_UIStatusBarStringView *)shortTimeView{
	_UIStatusBarStringView *orig = %orig;
	NSLog(@"ASTEROIDTIMEHERE %@", orig.originalText);
	orig.isTime = TRUE;
	return orig;
}

%end
