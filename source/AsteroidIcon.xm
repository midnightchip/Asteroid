#include <Asteroid.h>
#import <UIKit/UIImage+Private.h>
#import "LiveWeather.h"
#import "LiveWeatherView.h"

static void updateWeatherForIconView(SBIconView *iconView) {
	if ([[iconView.icon leafIdentifier] isEqualToString:@"com.apple.weather"]) {
		SBLiveWeatherIconImageView * img = [iconView valueForKey:@"_iconImageView"];
		img.layer.contents = nil;
	}
}

@interface LiveWeatherView ()
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *temp;
@end
//Needed for SnowBoard Radius
@interface SnowBoardThemeLoader : NSObject
+(CGFloat) customCornerRadius;
@end




static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;

%subclass SBLiveWeatherIconImageView : SBIconImageView
%property (nonatomic, retain) LiveWeatherView *liveWeatherView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = %orig)) {
        if([self viewWithTag:55668] == nil) {
            if(self.liveWeatherView){
                [self.liveWeatherView removeFromSuperview];
            }
            NSLog(@"lock_TWEAK | initIcon");

            self.liveWeatherView = [[NSClassFromString(@"LiveWeatherView") alloc]initWithFrame:CGRectZero];
            self.liveWeatherView.tag = 55668;
            self.liveWeatherView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:self.liveWeatherView];
            self.liveWeatherView.clipsToBounds = YES;
            [self.liveWeatherView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
            [self.liveWeatherView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
            [self.liveWeatherView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            [self.liveWeatherView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

            [self updateMask];
        }
    }
    return self;
}

%new
- (void)updateMask {
	if([%c(SnowBoardThemeLoader) class]){
		self.liveWeatherView.layer.cornerRadius = [%c(SnowBoardThemeLoader) customCornerRadius];
	}else{
		NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/System/Library/PrivateFrameworks/MobileIcons.framework"]];
		UIImage *maskImage = [UIImage imageNamed:@"AppIconMask" inBundle:bundle];

		CALayer *mask = [CALayer layer];
		mask.contents = (id)[maskImage CGImage];
		mask.frame = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
		self.liveWeatherView.layer.mask = mask;
	}
	self.liveWeatherView.layer.masksToBounds = YES;
    
    NSLog(@"lock_TWEAK | updateMask");
}
%end

%subclass SBLiveWeatherIcon : SBApplicationIcon
/*
 * subclass our own application icon and return a custom subclassed icon view
 */
-(Class)iconImageViewClassForLocation:(int)arg1 {
	return NSClassFromString(@"SBLiveWeatherIconImageView");
}
%end

%hook SBApplicationInfo
-(Class)iconClass {
	if([self.bundleIdentifier isEqualToString:@"com.apple.weather"]) {
		return NSClassFromString(@"SBLiveWeatherIcon");
	}
	return %orig;
}
%end

%hook SBIconView
-(void)_setIcon:(id)icon animated:(BOOL)animated {
	/*
	 * This happens during icon recycling so update rings to keep them fresh
	 */
	if([[icon leafIdentifier] isEqualToString:@"com.apple.weather"]){
		%orig;
		updateWeatherForIconView(self);
	}else{
		%orig;
	}
}
%end

%ctor {
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"] && [prefs boolForKey:@"appIcon"] && [prefs boolForKey:@"kLWPEnabled"]){
        %init();
    }
}
