#import "../source/AWeatherModel.h"

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end

%hook _UIStatusBarStringView
%property (nonatomic, retain) AWeatherModel *weatherModel;
- (void)setText:(NSString *)text {
	if([text containsString:@":"]) {
        self.weatherModel = [%c(AWeatherModel) sharedInstance];
		//NSTextAttachment *image = [[NSTextAttachment alloc] init];
		//image.image = [self.weatherModel glyphWithOption:ConditionOptionWhite];
		//NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:image];
		//icon = 
		//NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"Hi"];
		//[myString appendAttributedString:attachmentString];
		//NSString *newString = [NSString stringWithFormat:@"%@ %@", text, @"Hi"];
        NSString *newString = [self.weatherModel localeTemperature];
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