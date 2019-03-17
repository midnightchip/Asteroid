#include <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import "../source/UIImage+ScaledImage.h"
#import "../source/LWPProvider.h"
#define isSB [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]

@interface _UIStatusBarDataStringEntry
@property (nonatomic, retain) NSString *stringValue;
@end

@interface _UIStatusBarData
@property (nonatomic, retain) _UIStatusBarDataStringEntry *timeEntry;
@end

@interface _UIStatusBar
@property (nonatomic, retain) _UIStatusBarData *currentData;
@end

@interface UIStatusBar_Modern
@property (nonatomic, retain) _UIStatusBar *statusBar;
@end

@interface UIApplication (asteroid)
-(id)statusBar;
@end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) BOOL isTime;
@property (nonatomic, assign) BOOL isTapped;
@property (nonatomic,copy) NSString * originalText; 
@property (nonatomic, assign) BOOL foundBlocks;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic) CGRect timeFrame;
-(void)setText:(id)arg1;
-(NSString *)originalText;
-(void)setAlternateText:(NSString *)arg1;
-(void)setShowsAlternateText:(BOOL)arg1 ;
-(void)generateWeatherData;
-(void)generateWeatherWithTime:(NSString *)currentTime;
-(void)swapTime:(UIGestureRecognizer *)sender;
-(void)resetTime;
-(NSString *)returnDateString;
@end 

//Allow touches
@interface UIView (Gestures)
@property (nonatomic, retain) NSArray *allSubviews;
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
%property (nonatomic, assign) BOOL foundBlocks;
%property (nonatomic, assign) CGRect timeFrame;
%property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
-(void)didMoveToWindow{
    %orig;
	if(self.isTime){
		self.isTapped = NO;
		[self setText:[self returnDateString]];
	}
	if(self.isTime && !self.tapGesture){
		self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapTime:)];
        self.tapGesture.numberOfTapsRequired = 1; 
		[self.tapGesture setCancelsTouchesInView: NO];
        [self.superview.superview addGestureRecognizer:self.tapGesture];
        
	}
}

-(void)setText:(id)arg1{
	if(self.isTime){
        %orig(@""); // Make sure the font properties are all there
        if(self.isTapped){
            [UIView transitionWithView:self
                              duration:0.15f
                               options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                            animations:^{
                                [self generateWeatherData];
                            } completion:nil];
        }else{
            if([prefs boolForKey:@"enableGlyphTimeX"]){
                [self generateWeatherWithTime:arg1];
            } else {
                [UIView transitionWithView:self
                                  duration:0.15f
                                   options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                                animations:^{
                                    %orig;
                                } completion:nil];
            }
        }
	}else{
		%orig;
	}	
}
%new
-(void)generateWeatherData{
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
    [imageFixText appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];
	//End stupid UIKit workaround
	NSDictionary *attribs = @{
                        NSFontAttributeName: self.font
                        };
	NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:weatherItems[@"temp"] attributes:attribs];
	[imageFixText appendAttributedString:tempString];
	[self setAttributedText:imageFixText];
}
%new
-(void)generateWeatherWithTime:(NSString *)currentTime{
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
    [imageFixText appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];
	//End stupid UIKit workaround
	NSDictionary *attribs = @{
                        NSFontAttributeName: self.font
                        };
	NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:currentTime attributes:attribs];
	[imageFixText appendAttributedString:tempString];
	[self setAttributedText:imageFixText];
}
%new 
-(void)swapTime:(UIGestureRecognizer *)sender{
	CGPoint location = [sender locationInView:sender.view];
    CGRect newFrame = [self.superview.superview convertRect:self.frame fromView:self.superview];
	if(CGRectContainsPoint(CGRectMake(newFrame.origin.x, 0 , newFrame.size.width, newFrame.size.height + newFrame.origin.y), location)){ // Extend test frame to top of screen.
		if(!self.isTapped){
			self.isTapped = YES;
			[self setText:@"RUN"];
			[self performSelector:@selector(resetTime) withObject:nil afterDelay:10];
		} else{
			[self resetTime];
		}
	}
}
%new 
-(void)resetTime{
	self.isTapped = NO;
	[self setText:[self returnDateString]];
}
%new 
-(NSString *)returnDateString{
    UIStatusBar_Modern *modernStat = [[UIApplication sharedApplication] statusBar];
    NSString *timeString = modernStat.statusBar.currentData.timeEntry.stringValue;
    timeString = [timeString stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
    timeString = [timeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return timeString;
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
	orig.timeFrame = orig.frame;
    orig.isTime = YES;
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

%ctor{
	if([prefs boolForKey:@"enableTimeStatusX"] && [prefs boolForKey:@"kLWPEnabled"]){
		%init();
	}
}
