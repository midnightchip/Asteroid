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
-(NSString *)returnWeatherTempString;
-(NSDictionary *)returnWeatherItems;
-(NSDictionary *)returnWeatherLogo;
-(UIImage *)returnWeatherLogoImage;
@end

static NSDictionary *getWeatherItems() {
	NSMutableDictionary *serverDict = [NSMutableDictionary new];
	if(isSB){
		serverDict[@"image"] = [[%c(AsteroidServer) sharedInstance] returnWeatherLogoImage];
		serverDict[@"temp"] = [[%c(AsteroidServer) sharedInstance] returnWeatherTempString];
	}else{
		NSDictionary *weatherItem;
		CPDistributedMessagingCenter *messagingCenter;
		messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
		rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
		weatherItem = [messagingCenter sendMessageAndReceiveReplyName:@"weatherItems" userInfo:nil];
		UIImage *weatherImage = [UIImage imageWithData:weatherItem[@"image"]];
		serverDict[@"image"] = weatherImage;
		serverDict[@"temp"] = weatherItem[@"temp"];
	}
	return serverDict;
}

%hook _UIStatusBarStringView
%property (nonatomic, assign) BOOL isTime;
-(void)setText:(id)arg1{
	if(self.isTime){
		NSDictionary *weatherItems = getWeatherItems();
		NSTextAttachment *weatherAttach = [[NSTextAttachment alloc] init];
		UIImage *weatherImage = weatherItems[@"image"];//weatherItems[@"image"];
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
		NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:weatherItems[@"temp"] attributes:attribs];
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
	orig.isTime = TRUE;
	return orig;
}

%end
