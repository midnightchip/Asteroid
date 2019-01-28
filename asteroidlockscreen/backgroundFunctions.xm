#import "AsteroidLockScreen.h"

// thanks mr squid
extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

void hapticFeedbackSoft(){
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:[NSNumber numberWithBool:YES]];
    [arr addObject:[NSNumber numberWithInt:30]];
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}
/*
 static void hapticFeedbackHard(){
 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
 NSMutableArray* arr = [NSMutableArray array];
 [arr addObject:[NSNumber numberWithBool:YES]];
 [arr addObject:[NSNumber numberWithInt:30]];
 [dict setObject:arr forKey:@"VibePattern"];
 [dict setObject:[NSNumber numberWithInt:2] forKey:@"Intensity"];
 AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
 }
 */
