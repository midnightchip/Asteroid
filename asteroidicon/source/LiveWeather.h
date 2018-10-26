#define kPrefDomain "com.midnightchips.asteroid"

@import UIKit;

@interface SBIcon : NSObject
- (NSString *)leafIdentifier;
@end

@interface SBIconModel : NSObject
-(id)expectedIconForDisplayIdentifier:(id)arg1 ;
@end

@interface SBIconView : UIView
@property (nonatomic,retain) SBIcon * icon;
@end

@interface SBIconImageView : UIView
@property (assign,nonatomic) SBIconView * iconView;
- (id)_currentOverlayImage;
- (UIImage *)_iconBasicOverlayImage;
-(CGRect)visibleBounds;
@end

@interface SBIconViewMap : NSObject
+(id)homescreenMap;
- (SBIconView *)mappedIconViewForIcon:(id)arg1 ;
@end

@interface SBIconController : UIViewController
@property (nonatomic,readonly) SBIconViewMap * homescreenIconViewMap;
+(id)sharedInstance;
-(SBIconModel *)model;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;
@end

@interface FBBundleInfo : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;
@end

@interface FBApplicationInfo : FBBundleInfo
@end

@interface SBApplicationInfo : FBApplicationInfo
@property (nonatomic,retain) Class iconClass;
@end


@class LiveWeatherView;
@interface SBLiveWeatherIconImageView : SBIconImageView
@property (nonatomic, retain) LiveWeatherView *liveWeatherView;
- (void)updateWeatherForPresentation;
- (void)updateMask;
@end