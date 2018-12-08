#include "LWPPreferenceController.h"


@interface CSPListController (Asteroid)
@end 

@implementation CSPListController (Asteroid)
-(NSArray *)getImageType{
	return [[NSArray alloc] initWithObjects: @"Filled Solid Color", @"Outline Image", nil];
}
-(void) refreshImage{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                           message:@"This is an alert."
                           preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
	
	[alert addAction:defaultAction];
	[self presentViewController:alert animated:YES completion:nil];
}
-(void) resetLoc{
    [prefs setObject: @(YES) forKey:@"resetXY"];
    [prefs saveAndPostNotification];
}
-(void)resetSizeMethod{
    [prefs setObject: @(YES) forKey:@"resetSizing"];
    [prefs saveAndPostNotification];
}

-(NSArray*)weatherConditions{
    NSArray *unorganized =  [[NSArray alloc] initWithObjects: @"SevereThunderstorm",@"Rain", @"Thunderstorm", @"Haze", @"PartlyCloudyDay", @"MixedRainAndSnow", @"SnowFlurries", @"Smoky", @"MixedRainAndSleet", @"ClearNight", @"SnowShowers", @"MixedSnowAndSleet", @"Breezy", @"ScatteredSnowShowers", @"FreezingDrizzle", @"BlowingSnow", @"Sunny", @"Drizzle", @"Windy", @"MostlySunnyNight", @"Snow", @"HeavySnow", @"Frigid", @"ScatteredSnowShowers", @"MostlySunnyDay", @"Hail", @"Blizzard", @"Cloudy", @"MixedRainFall", @"Sleet", @"PartlyCloudyDay", @"MostlyCloudyNight", @"Hot", @"Dust", @"HeavyRain", @"MostlyCloudyDay", @"IsolatedThunderstorms", @"SnowShowers", @"PartlyCloudyNight", @"ScatteredShowers", @"IsolatedThundershowers", @"ScatteredThunderstorms", @"Tornado", @"FreezingRain", @"TropicalStorm", @"Showers1", @"Hurricane", @"Fog", nil];
    return [unorganized sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}
@end 

@implementation LWPPreferenceController

@end
