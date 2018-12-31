#import "LWPProvider.h"
#import "AWeatherModel.h"
#import <CoreLocation/CoreLocation.h>

/* weather background */
@interface WUIWeatherCondition : NSObject
@property (assign,nonatomic) long long condition;
-(void)pause;
-(void)resume;
-(City *)city;
-(void)setPlaying:(BOOL)arg1;
-(BOOL)playing;
-(double)alpha;
-(void)setAlpha:(double)arg1 ;
-(void)setCondition:(long long)arg1;
@end;

@interface WUIDynamicWeatherBackground : UIView
-(void)setCity:(id)arg1 ;
-(void)setCondition:(long long)arg1 ;
-(WUIWeatherCondition *)condition;
@end

@interface WUIWeatherConditionBackgroundView : UIView
-(id)initWithFrame:(CGRect)arg1 ;
-(WUIDynamicWeatherBackground *)background;
-(void)prepareToSuspend;
-(void)prepareToResume;
@end

@interface WALockscreenWidgetViewController : UIViewController
@property (nonatomic,retain) WATodayModel * todayModel;
@end

/*static NSDictionary *conditions = @{@"SevereThunderstorm" : @3,
@"Rain" : @12,
@"Thunderstorm" : @4,
@"Haze" : @21,
@"PartlyCloudyDay" :  @30,
@"MixedRainAndSnow" : @5,
@"SnowFlurries" : @13,
@"Smoky" : @22,
@"MixedRainAndSleet" : @6,
@"ClearNight" : @31,
@"SnowShowers" : @14,
@"MixedSnowAndSleet" : @7,
@"Breezy" : @23,
@"ScatteredSnowShowers" : @40,
@"FreezingDrizzle" : @8,
@"BlowingSnow" : @15,
@"Sunny" : @32,
@"Drizzle" : @9,
@"Windy" : @24,
@"MostlySunnyNight" : @33,
@"Snow" : @16,
@"HeavySnow" : @41,
@"Frigid" : @25,
@"ScatteredSnowShowers" : @42,
@"MostlySunnyDay" : @34,
@"Hail" : @17,
@"Blizzard" : @43,
@"Cloudy" : @26,
@"MixedRainFall" : @35,
@"Sleet" : @18,
@"PartlyCloudyDay" : @44,
@"MostlyCloudyNight" : @27,
@"Hot" : @36,
@"Dust" : @19,
@"HeavyRain" : @45,
@"MostlyCloudyDay" : @28,
@"IsolatedThunderstorms" : @37,
@"SnowShowers" : @46,
@"PartlyCloudyNight" : @29,
@"ScatteredShowers" : @38,
@"IsolatedThundershowers" : @47,
@"ScatteredThunderstorms" : @39,
@"Tornado" : @0,
@"FreezingRain" : @10,
@"TropicalStorm" : @1,
@"Showers1" : @11,
@"Hurricane" : @2,
@"Fog" : @20
};*/

