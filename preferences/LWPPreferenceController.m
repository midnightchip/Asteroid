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
-(void)gplInfo{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"License Information"
                           message: @"Asteroid is Licensed under the GPL 3.0 License. A Copy is included in the preference bundle of this tweak, along with my github page."
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];

    UIAlertAction* read = [UIAlertAction actionWithTitle:@"Let Me See it" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self openGPL];
                                   }];

    [alert addAction:defaultAction];
    [alert addAction:read];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)openGPL{
    NSURL *url = [NSURL URLWithString:@"https://github.com/midnightchip/Asteroid/blob/master/LICENSE.md"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
@end 

@implementation LWPPreferenceController

@end
