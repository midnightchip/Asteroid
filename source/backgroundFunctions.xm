#import "AsteroidLockScreen.h"

// Data required for the isOnLockscreen() function --------------------------------------------------------------------------------------
BOOL isUILocked() {
long count = [[[%c(SBFPasscodeLockTrackerForPreventLockAssertions) sharedInstance] valueForKey:@"_assertions"] count];
if (count == 0) return YES; // array is empty
if (count == 1) {
if ([[[[[[%c(SBFPasscodeLockTrackerForPreventLockAssertions) sharedInstance] valueForKey:@"_assertions"] allObjects] objectAtIndex:0] identifier] isEqualToString:@"UI unlocked"]) return NO; // either device is unlocked or an app is opened (from the ones allowed on lockscreen). Luckily system gives us enough info so we can tell what happened
else return YES; // if there are more than one should be safe enough to assume device is unlocked
}
else return NO;
}

static BOOL isOnCoverSheet; // the data that needs to be analyzed

BOOL isOnLockscreen() {
//NSLog(@"nine_TWEAK | %d", isOnCoverSheet);
if(isUILocked()){
isOnCoverSheet = YES; // This is used to catch an exception where it was locked, but the isOnCoverSheet didnt update to reflect.
return YES;
}
else if(!isUILocked() && isOnCoverSheet == YES) return YES;
else if(!isUILocked() && isOnCoverSheet == NO) return NO;
else return NO;
}

static id _instance;

%hook SBFPasscodeLockTrackerForPreventLockAssertions
- (id) init {
if (_instance == nil) _instance = %orig;
else %orig; // just in case it needs more than one instance
return _instance;
}
%new
// add a shared instance so we can use it later
+ (id) sharedInstance {
if (!_instance) return [[%c(SBFPasscodeLockTrackerForPreventLockAssertions) alloc] init];
return _instance;
}
%end

// Setting isOnCoverSheet properly, actually works perfectly
%hook SBCoverSheetSlidingViewController
- (void)_finishTransitionToPresented:(_Bool)arg1 animated:(_Bool)arg2 withCompletion:(id)arg3 {
if((arg1 == 0) && ([self dismissalSlidingMode] == 1)){
if(!isUILocked()) isOnCoverSheet = NO;
}
else if ((arg1 == 1) && ([self dismissalSlidingMode] == 1)){
if(isUILocked()) isOnCoverSheet = YES;
}
%orig;
}
%end
// end of data required for the isOnLockscreen() function ----------------------------------------------------


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
