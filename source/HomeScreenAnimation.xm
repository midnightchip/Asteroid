#import "Asteroid.h"
#import <objc/message.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import "ConditionImageType.h"

@interface SBHomeScreenView : UIView
//@interface SBFWallpaperView : UIView
@property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
@property (nonatomic, retain) AWeatherModel *weatherModel;
@end 

@interface SBHomeScreenView (Weather)
//@interface SBFWallpaperView (Weather)
-(void)updateView;
-(BOOL) needsUpdateForCondition:(WUIWeatherCondition *) condition;
@end

@interface UIApplication (asteroid)
-(id)_accessibilityFrontMostApplication;
@end

static float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
static WUIWeatherCondition* condition = nil;
static int conditionNumberSet;

static void updateAnimation(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if([[UIApplication sharedApplication] _accessibilityFrontMostApplication] == 0 && MSHookIvar<BOOL>([%c(SBLockScreenManager) sharedInstance], "_isScreenOn")){
        [condition resume];
    } else{
        [condition pause];
    }
}

%group LiveWeather
%hook SBHomeScreenView
//%hook SBFWallpaperView
%property (nonatomic, retain) WUIWeatherConditionBackgroundView *referenceView;
%property (nonatomic, retain) AWeatherModel *weatherModel;

- (void)layoutSubviews {
    %orig;
    if(!self.referenceView){
        self.weatherModel = [%c(AWeatherModel) sharedInstance];
        [self updateView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherTimer:) name:@"weatherTimerUpdate" object:nil];
    }
}
%new
- (void) weatherTimer: (NSNotification *)notification{
    [self updateView];
}

%new
-(void) updateView{
    if(self.weatherModel.isPopulated && [self needsUpdateForCondition:self.referenceView.background.condition]){
        [self.referenceView removeFromSuperview];
        
        self.referenceView = [[%c(WUIWeatherConditionBackgroundView) alloc] initWithFrame:self.frame];
        if([prefs intForKey:@"hideWeatherBackground"] == 1){
            self.referenceView.background.hidesBackground = YES;
            self.referenceView.background.condition.hidesConditionBackground = YES;
        } else if([prefs intForKey:@"hideWeatherBackground"] == 2){
            self.referenceView.hidesConditions = YES;
        }
        
        City *backgroundCity = self.weatherModel.city;
        if([prefs boolForKey:@"customCondition"]){
            backgroundCity = [self.weatherModel.city cityCopy];
            backgroundCity.conditionCode = [prefs doubleForKey:@"weatherConditions"];
        }
        
        [self.referenceView.background setCity:backgroundCity];
        [self.referenceView.background setTag:123];
        
        [[self.referenceView.background condition] resume];
        condition = [self.referenceView.background condition];
        self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.referenceView.clipsToBounds = YES;
        conditionNumberSet = condition.condition;
        [self addSubview:self.referenceView];
        [self sendSubviewToBack:self.referenceView];
    }
}

%new
-(BOOL) needsUpdateForCondition:(WUIWeatherCondition *) condition{
    NSInteger conditionCode = condition.condition;
    NSInteger actualCode = self.weatherModel.city.conditionCode;
    if(conditionCode != actualCode){
        return YES;
    }
    NSString *conditionLoadedFile = [condition loadedFileName];
    ConditionImageType currentType = [self.weatherModel conditionImageTypeForString: conditionLoadedFile];
    
    ConditionImageType actualType = self.weatherModel.city.isDay ? ConditionImageTypeDay : ConditionImageTypeNight;
    
    if(currentType != ConditionImageTypeDefault && currentType != actualType) return YES;
    else return NO;
}
%end

//Start stop view, save battery
%hook SBHomeScreenWindow
-(void)becomeKeyWindow
{
    %orig;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (const void*)self,
                                        updateAnimation,
                                        CFSTR("com.apple.springboard.screenchanged"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    });
}

%end


@interface SBIconBlurryBackgroundView : UIView
@end 

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end 

/*%hook SBFolderIconImageView 
// Thanks poomsmart
- (void)_updateAccessibilityBackgroundContrast
{
	%orig;
	SBFolderIconBackgroundView *backgroundView = MSHookIvar<SBFolderIconBackgroundView *>(self, "_backgroundView");
	UIView *accessibilityBackgroundView = MSHookIvar<UIView *>(self, "_accessibilityBackgroundView");
	backgroundView.hidden = YES;
	accessibilityBackgroundView.hidden = YES;

}
%end*/

%hook SBFolderIconBackgroundView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noFolders"]){
        self.hidden = TRUE;
    }
}
//Thanks iPad_Kid, for whatever reason, the substrate update changed us from being hidden after being displayed once.
- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
    if([prefs boolForKey:@"noFolders"]){
        %orig(CGRectNull, NULL, NULL);
    
        self.backgroundColor = [UIColor clearColor];
    } else %orig;
    
}
%end
%end

//Dock 
@interface SBDockView : UIView 
@end 

@interface SBWallpaperEffectView : UIView
@end 

%hook SBDockView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noDock"]){
        MSHookIvar<SBWallpaperEffectView*>(self, "_backgroundView").hidden = YES;
        MSHookIvar<UIImageView*>(self, "_backgroundImageView").hidden = YES;
    }
}
%end 

@interface SBHighlightView : UIView
@end 

%hook SBHighlightView
-(void)layoutSubviews{
    %orig;
    if([prefs boolForKey:@"noDock"]){
        self.hidden = YES;
    } 
}
%end 

%hook City
%new
-(id) cityCopy{
    City *city = [[City alloc] init];
    NSArray *prpArray = [[City cplAllPropertyNames] allObjects];
    for(NSString *prpString in prpArray){
        objc_property_t property = class_getProperty([City class], [prpString UTF8String]);
        if(property){
            const char *propertyAttributes = property_getAttributes(property);
            NSArray *attributes = [[NSString stringWithUTF8String:propertyAttributes]
                                   componentsSeparatedByString:@","];
            if(![attributes containsObject:@"R"]){ // Not readonly
                [city setValue: [self valueForKey:prpString] forKey:prpString];
            }
        }
    }
    return city;
}
%end

//Hide background accross views
//Thanks June
%group WeatherBackground
%hook WUIDynamicWeatherBackground
%property (nonatomic, assign) BOOL hidesBackground;
-(id)gradientLayer{
    if(self.hidesBackground) return nil;
    else return %orig;
}
-(void)setCurrentBackground:(CALayer *)arg1{
    if(!self.hidesBackground){
        %orig;
    }
}
-(void)setBackgroundCache:(NSCache *)arg1{
    if(!self.hidesBackground){
        %orig;
    }
    
}
/* 11.1.2 Still nees improving */
-(void)addSublayer:(id)arg1{
    %orig;
    if(deviceVersion < 11.3 && self.hidesBackground){
        CALayer* layer = arg1;
        for(CALayer* firstLayers in layer.sublayers){
            if(firstLayers.backgroundColor){
                firstLayers.backgroundColor = [UIColor clearColor].CGColor;
            }
            for(CALayer* secLayers in firstLayers.sublayers){
                for(CALayer* thrLayers in secLayers.sublayers){
                    if([thrLayers isKindOfClass:[CAGradientLayer class]]){
                        thrLayers.hidden = YES;
                    }
                }
            }
        }
    }
}
%end

%hook WUIWeatherCondition
%property (nonatomic, assign) BOOL hidesConditionBackground;
	-(CALayer *)layer{
		if((self.alpha == 982 || self.condition == 3) && self.hidesConditionBackground){
			CALayer* layer = %orig;
			for(CALayer* firstLayers in layer.sublayers){
				if(firstLayers.backgroundColor){
					firstLayers.backgroundColor = [UIColor clearColor].CGColor;
				}
				for(CALayer* secLayers in firstLayers.sublayers){
					if(deviceVersion >= 11.1 && deviceVersion < 11.3){
						/*
							11.1.2 (at night)
							Cold condition number 25 
							Mostly cloudy night	condition number 27
							Mostly cloudy day condition number 28
							Clear night condition number 31
							Sunny condition number 32
							shows black background, this removes it.
						*/
						if(!condition.city.isDay){
							if(secLayers.backgroundColor){
								if(conditionNumberSet == 25 || conditionNumberSet == 27 || conditionNumberSet == 28 || conditionNumberSet == 31 || conditionNumberSet == 32 || conditionNumberSet == 46){
									secLayers.backgroundColor = [UIColor clearColor].CGColor;
								}
							}
						}
					}
					for(CALayer* thrLayers in secLayers.sublayers){
						//NSLog(@"WTest style %@", thrLayers.name);
						/* 
							11.1.2 (night) clouds show a black box around clouds
							Hiding the clouds here.
						*/
						if(deviceVersion >= 11.1 && deviceVersion < 11.3){
							if(!condition.city.isDay){
								if([thrLayers.name isEqualToString:@"💭 Background"]){
									if(conditionNumberSet == 3 || conditionNumberSet == 4 || conditionNumberSet == 37 || conditionNumberSet == 47){
										thrLayers.hidden = YES;
									}
								}
								thrLayers.backgroundColor = [UIColor clearColor].CGColor;
							}
						}
						if(![thrLayers isKindOfClass:[CAEmitterLayer class]] && ![thrLayers isKindOfClass:[CATransformLayer class]]){
							if(thrLayers.backgroundColor){
								thrLayers.backgroundColor = [UIColor clearColor].CGColor;
							}
						}
					}
				}
			}
		}
		return %orig;
	}
%end

%end 

%ctor{
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"] && [prefs boolForKey:@"kLWPEnabled"]) {
        if([prefs boolForKey:@"homeScreenWeather"]){
            %init(LiveWeather);
            }
        if([prefs boolForKey:@"hideWeatherBackground"]){
            %init(WeatherBackground);
            }
        %init(_ungrouped);
    }
    //Thank you june
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			NSString *processName = [executablePath lastPathComponent];
			BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
			BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			if (isSpringBoard || isApplication) {
				/* Weather */
				dlopen("System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
				/* WeatherUI */
    			dlopen("System/Library/PrivateFrameworks/WeatherUI.framework/WeatherUI", RTLD_NOW);
			}
		}
    }
}
