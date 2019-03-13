#include <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import "../source/UIImage+ScaledImage.h"
#define isSB [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) BOOL isTime;
@property (nonatomic, assign) BOOL isTapped;
@property (nonatomic,copy) NSString * originalText; 
-(void)setText:(id)arg1;
-(NSString *)originalText;
-(void)setAlternateText:(NSString *)arg1;
-(void)setShowsAlternateText:(BOOL)arg1 ;
-(void)swapTime;
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
%property (nonatomic, assign) BOOL isTapped;
-(void)setText:(id)arg1{
	/*if(self.isTime){
		UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapTime)];
		[self addGestureRecognizer:tapGesture];
	}*/
	%orig;
	if(self.isTime){
		UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapTime)];
		[self addGestureRecognizer:tapGesture];

		
	} //else{
	//}
}
-(void)setAlternateText:(NSString *)arg1{
	if(self.isTime && self.isTapped){
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
%new 
-(void)swapTime{
	if(!self.isTapped){
		self.isTapped = YES;
		[self setAlternateText:@""];
		[self setShowsAlternateText:TRUE];
	}else{
		self.isTapped = NO;
		[self setShowsAlternateText:FALSE];
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
	UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapTime)];
	[orig addGestureRecognizer:tapGesture];
	return orig;
}
/*%new
-(void)swapTime{
	if(!self.isTapped){
		self.isTapped = YES;
		[self 
	}
	

}*/
%end
