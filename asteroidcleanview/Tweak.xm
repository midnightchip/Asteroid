#import <CSWeather/CSWeatherInformationProvider.h>

@interface SBDashBoardMainPageView : UIView
@property (nonatomic, retain) UIView *holderView;
@property (nonatomic, retain) UIImageView *cleanLogo;
@property (nonatomic, retain) UIView *cleanView;
@property (nonatomic, retain) UILabel *cleanCurrent;
@property (nonatomic, retain) UILabel *cleanTemp;
@property (nonatomic, retain) UILabel *cleanHi;
@property (nonatomic, retain) UILabel *cleanLow;
@end 

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *holderView;
%property (nonatomic, retain) UIView *cleanView;
%property (nonatomic, retain) UIImageView *cleanLogo;
%property (nonatomic, retain) UILabel *cleanCurrent;
%property (nonatomic, retain) UILabel *cleanTemp;
%property (nonatomic, retain) UILabel *cleanHi;
%property (nonatomic, retain) UILabel *cleanLow;

- (void)layoutSubviews {
    %orig;
    if(!self.holderView){
        self.holderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.holderView setUserInteractionEnabled:YES];
        [self addSubview:self.holderView];
        
	}
	if(!self.cleanView){
		self.cleanView=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/1.2, self.frame.size.width/2, self.frame.size.height/6)];
		[self.cleanView setUserInteractionEnabled:NO];
		self.cleanView.backgroundColor = [UIColor clearColor];
		

		self.cleanCurrent = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
		[self.cleanCurrent setCenter:CGPointMake(self.cleanView.frame.size.width/2, self.cleanView.frame.size.height/6)];


		self.cleanTemp = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
		[self.cleanTemp setCenter:CGPointMake(self.cleanView.frame.size.width/2, self.cleanView.frame.size.height/4)];

		self.cleanHi = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
		[self.cleanHi setCenter:CGPointMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height/2)];

		self.cleanLow = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
		[self.cleanLow setCenter:CGPointMake(self.cleanView.frame.size.width/4, self.cleanView.frame.size.height/2)];
		[[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
		//Prepend weather icon to current condition string
		NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
		attachment.image = weather[@"kCurrentConditionImage"];
		NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
		NSMutableAttributedString *currentInfo= [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
		NSAttributedString *weatherInfo = [[NSMutableAttributedString alloc] initWithString:weather[@"kCurrentConditionString"]];
		[currentInfo appendAttributedString: weatherInfo];
		self.cleanCurrent.attributedText = currentInfo;
		//Set current temp
		self.cleanCurrent.text = weather[@"kCurrentTemperatureForLocale"];
		//Current Low
		NSString *downArrow = @"↓";
		self.cleanLow.text = [downArrow stringByAppendingString:weather[@"kCurrentTemperatureForLocale"]];
		//Current High
		NSString *upArrow = @"↑";
		self.cleanHi.text = [upArrow stringByAppendingString:weather[@"kCurrentTemperatureForLocale"]];
		}];
		
		[self.cleanView addSubview: self.cleanCurrent];
		[self.cleanView addSubview: self.cleanHi];
		[self.cleanView addSubview: self.cleanTemp];
		[self.cleanView addSubview: self.cleanLow];
		[self.holderView addSubview: self.cleanView];
	}
	
}
%end 