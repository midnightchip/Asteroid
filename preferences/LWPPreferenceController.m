#include "LWPPreferenceController.h"
#import <spawn.h>
#import <AudioToolbox/AudioToolbox.h>


@interface CSPListController (Asteroid)
-(NSDictionary*) weatherConditionsDict;
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
    pid_t pid;
    const char* args[] = {"killall", "-9", "backboardd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}
-(void)resetSizeMethod{
    [prefs setObject: @(YES) forKey:@"resetSizing"];
    [prefs saveAndPostNotification];
}

-(NSArray*)weatherConditionsKeys{
    NSDictionary *conditions = [self weatherConditionsDict];
    NSArray *unorganizedKeys = [conditions allKeys];
    return [unorganizedKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];;
}

-(NSArray*)weatherConditionsValues{
    NSDictionary *conditions = [self weatherConditionsDict];
    NSArray *organizedKeys = [self weatherConditionsKeys];
    NSMutableArray *organizedValues = [[NSMutableArray alloc] init];
    for(NSString *key in organizedKeys){
        [organizedValues addObject:conditions[key]];
    }
    return organizedValues;
}
-(NSDictionary*) weatherConditionsDict{
    NSDictionary *conditions = [[NSDictionary alloc] initWithObjectsAndKeys: @3, @"SevereThunderstorm", @12, @"Rain", @4, @"Thunderstorm", @21, @"Haze", @30, @"PartlyCloudyDay", @5, @"MixedRainAndSnow", @13, @"SnowFlurries", @22, @"Smoky", @6, @"MixedRainAndSleet", @31, @"ClearNight", @14, @"SnowShowers", @7, @"MixedSnowAndSleet", @23, @"Breezy", @40, @"ScatteredSnowShowers", @8, @"FreezingDrizzle", @15, @"BlowingSnow", @32, @"Sunny", @9, @"Drizzle", @24, @"Windy", @33, @"MostlySunnyNight", @16, @"Snow", @41, @"HeavySnow", @25, @"Frigid", @42, @"ScatteredSnowShowers", @34, @"MostlySunnyDay", @17, @"Hail", @43, @"Blizzard", @26, @"Cloudy", @35, @"MixedRainFall", @18, @"Sleet", @44, @"PartlyCloudyDay", @27, @"MostlyCloudyNight", @36, @"Hot", @19, @"Dust", @45, @"HeavyRain", @28, @"MostlyCloudyDay", @37, @"IsolatedThunderstorms", @46, @"SnowShowers", @29, @"PartlyCloudyNight", @38, @"ScatteredShowers", @47, @"IsolatedThundershowers", @39, @"ScatteredThunderstorms", @0, @"Tornado", @10, @"FreezingRain", @1, @"TropicalStorm", @11, @"Showers1", @2, @"Hurricane", @20, @"Fog", nil];
    return conditions;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applySettings)];
        self.navigationItem.rightBarButtonItem = applyButton;


}
-(void)applySettings {
    UIAlertController* respringAlert = [UIAlertController alertControllerWithTitle:@"Respring Warning"
                           message:@"Applying settings will respring your device"
                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {}];
    UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                 [self startRespring];
                               }];

    [respringAlert addAction:cancelAction];
    [respringAlert addAction:respringAction];
    [self presentViewController:respringAlert animated:YES completion:nil];
}

- (void)startRespring {
    //make a visual effect view to fade in for the blur
    [self.view endEditing:YES]; //save changes to text fields and dismiss keyboard

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    visualEffectView.frame = [[UIApplication sharedApplication] keyWindow].bounds;
    visualEffectView.alpha = 0.0;

    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:visualEffectView];

    //animate in the alpha
    [UIView animateWithDuration:3.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         visualEffectView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             NSLog(@"Squiddy says hello");
                             NSLog(@"Midnight replys with 'where am I?'");
                             //call the animation here for the screen fade and respring
                             [self graduallyAdjustBrightnessToValue:0.0f];
                         }
                     }];

    //sleep(15);

    //[[UIScreen mainScreen] setBrightness:0.0f]; //so the screen fades back in when the respringing is done
}

- (void)graduallyAdjustBrightnessToValue:(CGFloat)endValue{
    CGFloat startValue = [[UIScreen mainScreen] brightness];

    CGFloat fadeInterval = 0.01;
    double delayInSeconds = 0.005;
    if (endValue < startValue)
        fadeInterval = -fadeInterval;

    CGFloat brightness = startValue;
    while (fabs(brightness-endValue)>0) {

        brightness += fadeInterval;

        if (fabs(brightness-endValue) < fabs(fadeInterval))
            brightness = endValue;

        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UIScreen mainScreen] setBrightness:brightness];
        });
    }
    UIView *finalDarkScreen = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
    finalDarkScreen.backgroundColor = [UIColor blackColor];
    finalDarkScreen.alpha = 0.3;

    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:finalDarkScreen];

    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         finalDarkScreen.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             //DIE
                        AudioServicesPlaySystemSound(1521);
                        sleep(1);
                             pid_t pid;
                             const char* args[] = {"killall", "-9", "backboardd", NULL};
                             posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
                         }
                     }];
}


@end
