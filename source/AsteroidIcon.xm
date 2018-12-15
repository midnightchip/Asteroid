#include <Asteroid.h>
#import <UIKit/UIImage+Private.h>
#import "LiveWeather.h"
#import "LiveWeatherView.h"



static void updateWeatherForIconView(SBIconView *iconView) {
	if ([[iconView.icon leafIdentifier] isEqualToString:@"com.apple.weather"]) {
		SBLiveWeatherIconImageView * img = [iconView valueForKey:@"_iconImageView"];
		img.layer.contents = nil;
		if([img isKindOfClass:NSClassFromString(@"SBLiveWeatherIconImageView")]) {
			[img updateWeatherForPresentation];

		}
	}
}

static WUIDynamicWeatherBackground* dynamicBG = nil;
static WUIWeatherCondition* condition = nil;


%subclass SBLiveWeatherIconImageView : SBIconImageView

%property (nonatomic, retain) LiveWeatherView *liveWeatherView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = %orig)) {
        if([self viewWithTag:55668] == nil) {

            //overrideUsageStrings = YES;
            if(self.liveWeatherView){
                [self.liveWeatherView removeFromSuperview];
            }

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

	NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/System/Library/PrivateFrameworks/MobileIcons.framework"]];
	UIImage *maskImage = [UIImage imageNamed:@"AppIconMask" inBundle:bundle];

	CALayer *mask = [CALayer layer];
	mask.contents = (id)[maskImage CGImage];
	mask.frame = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
	self.liveWeatherView.layer.mask = mask;
	self.liveWeatherView.layer.masksToBounds = YES;
}
%new 
- (void)updateWeatherForPresentation{
  if(self.liveWeatherView) {
		[self.liveWeatherView updateWeatherDisplay];
	}
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

	/*
	 * Override the icon class if it's the Weather App
	 * There are other ways but they have different degrees of brokenness across the
	 * firmwares LiveRings supports. This works across all.
	 */
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

%hook SBLockScreenManager

-(void)lockScreenViewControllerWillDismiss {
	%orig;

	/*
	 * After lockscreen is dismissed, update the rings in case their on first page
	 */
	SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];

	SBIconViewMap *iconViewMap = nil;
	if([iconController respondsToSelector:@selector(homescreenIconViewMap)]) {
		iconViewMap = [iconController homescreenIconViewMap];
	} else if([NSClassFromString(@"SBIconViewMap") respondsToSelector:@selector(homescreenMap)]){
		iconViewMap = [NSClassFromString(@"SBIconViewMap") homescreenMap];
	}

	SBIcon *icon = [[iconController model] expectedIconForDisplayIdentifier:@"com.apple.weather"];
	SBIconView *iconView = [iconViewMap mappedIconViewForIcon:icon];
	updateWeatherForIconView(iconView);
}

%end


%ctor {

	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"] && [prefs boolForKey:@"appIcon"] && [prefs boolForKey:@"kLWPEnabled"]){
        %init();
    }

}
