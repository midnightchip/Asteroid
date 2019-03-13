#import "UIImage+ScaledImage.h"
#import "AWeatherModel.h"
@interface _UIStatusBarItem : NSObject
@end 

@interface _UIStatusBarCellularItem : _UIStatusBarItem
@end 

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, retain) NSString *timeString;
@property (nonatomic, assign) BOOL isServiceView;
@property (nonatomic, assign) BOOL hasTime;
-(void) generateWeatherView;
@end 

@interface SBStatusBarStateAggregator : NSObject
+(id)sharedInstance;
-(void)_updateServiceItem;
@end 

%hook _UIStatusBarStringView
%property (nonatomic, assign) BOOL isServiceView;
%property (nonatomic, retain) NSString *timeString;
%property (nonatomic, assign) BOOL hasTime;
-(id) initWithFrame: (CGRect) aframe{
    if((self = %orig)){
        UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapTime:)];
        [self addGestureRecognizer:tapGesture];
        self.hasTime = NO;
        self.userInteractionEnabled = YES;
    }
    return self;
}
-(void)setText:(id)arg1{
    self.timeString = arg1;
	if(!self.hasTime){
        [self generateWeatherView];
	}else{
		%orig;
	}
}

%new
-(void) generateWeatherView{
    AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
    NSTextAttachment *weatherAttach = [[NSTextAttachment alloc] init];
    UIImage *weatherImage = [weatherModel glyphWithOption:ConditionOptionDefault];
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
    NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:[weatherModel localeTemperature] attributes:attribs];
    [imageFixText appendAttributedString:tempString];
    [self setAttributedText:imageFixText];
}

%new
-(void)swapTime: (UITapGestureRecognizer *) gesture{
    if(self.hasTime){
        self.hasTime = NO;
    }else{
        self.hasTime = YES;
    }
    NSLog(@"lock_TWEAK | gesture tapped");
    [self setText:self.timeString];
}

-(void) setUserInteractionEnabled:(BOOL) arg1{
    %orig(YES);
}
-(BOOL) userInteractionEnabled{
    return YES;
}
%end 

%hook _UIStatusBarCellularItem 
-(_UIStatusBarStringView *)serviceNameView{
	_UIStatusBarStringView *orig = %orig;
	orig.isServiceView = TRUE;
	return orig;
}
%end 

