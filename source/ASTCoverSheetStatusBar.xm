#import "UIImage+ScaledImage.h"
#import "AWeatherModel.h"
@interface _UIStatusBarItem : NSObject
@end 

@interface _UIStatusBarCellularItem : _UIStatusBarItem
@end 

@interface _UIStatusBarStringView : UILabel
@property (nonatomic,copy) NSString * originalText; 
@property (nonatomic, assign) BOOL isServiceView;
@end 

@interface SBStatusBarStateAggregator : NSObject
+(id)sharedInstance;
-(void)_updateServiceItem;
@end 

%hook _UIStatusBarStringView
%property (nonatomic, assign) BOOL isServiceView;
-(void)setText:(id)arg1{
	if(self.isServiceView){
		AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
		NSTextAttachment *weatherAttach = [[NSTextAttachment alloc] init];
		UIImage *weatherImage = [weatherModel glyphWithOption:ConditionOptionDefault];
		double aspect = weatherImage.size.width / weatherImage.size.height;
		weatherImage = [weatherImage scaleImageToSize:CGSizeMake(self.font.lineHeight * aspect, self.font.lineHeight)];
		[weatherAttach setBounds:CGRectMake(0, roundf(self.font.capHeight - weatherImage.size.height)/2.f, weatherImage.size.width, weatherImage.size.height)];
		weatherAttach.image = weatherImage;

		NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:weatherAttach];

		NSDictionary *attribs = @{
                          NSFontAttributeName: self.font
                          };
		NSMutableAttributedString *image = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
		NSAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:[weatherModel localeTemperature] attributes:attribs];
		[image appendAttributedString:temp];
		[self setAttributedText:image];
	}else{
		%orig;
	}
}
%end 

%hook _UIStatusBarCellularItem 
-(_UIStatusBarStringView *)serviceNameView{
	_UIStatusBarStringView *orig = %orig;
	orig.isServiceView = TRUE;
	return orig;
}
%end 

