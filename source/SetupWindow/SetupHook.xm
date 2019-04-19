#import "ASTSetup.h"
#import "../source/LWPProvider.h"

@interface SBCoverSheetPrimarySlidingViewController
@property (nonatomic, retain) ASTSetup *setup;
@end

%hook SBCoverSheetPrimarySlidingViewController
%property (nonatomic, retain) ASTSetup *setup;
-(void)viewDidLoad {
    %orig;
    
    ASTSetupSettings *page1 = [[ASTSetupSettings alloc] init];
    page1.style = [ASTHeaderBasicController class];
    page1.title = @"Asteroid";
    page1.titleDescription = @"MidnightChips & the casle © 2019\n\nThank you for installing Asteroid. In order to deliver the best user experience, further setup is required.";
    page1.primaryButtonLabel = @"Setup";
    page1.secondaryButtonLabel = @"second";
    page1.backButtonLabel = @"Skip";
    page1.mediaURL = @"https://the-casle.github.io/TweakResources/Asteroid.png";

    ASTSetupSettings *page2 = [[ASTSetupSettings alloc] init];
    page2.style = [ASTHeaderTwoButtonsController class];
    page2.title = @"Lockscreen";
    page2.titleDescription = @"Basic iOS 12 lockscreen.";
    page2.primaryButtonLabel = @"Enable";
    page2.secondaryButtonLabel = @"Other Options";
    page2.mediaURL = @"https://the-casle.github.io/TweakResources/white.png";
    page2.primaryBlock = [^{
        [prefs setObject:@(YES) forKey:@"greetView"];
        [prefs setObject:@(YES) forKey:@"hideOnNotif"];
        [prefs setObject:@(YES) forKey:@"addgreetLabel"];
        [prefs setObject:@(YES) forKey:@"addDescription"];
        [prefs setObject:@(YES) forKey:@"addTemp"];
        [prefs setObject:@(YES) forKey:@"addDismiss"];
        [prefs setObject:@(YES) forKey:@"addLogo"];
        [prefs setObject:@(YES) forKey:@"addBlur"];
        [prefs save];
    } copy];
    page2.secondaryBlock = [^{
        [prefs setObject:@(NO) forKey:@"greetView"];
        [prefs setObject:@(NO) forKey:@"hideOnNotif"];
        [prefs setObject:@(NO) forKey:@"addgreetLabel"];
        [prefs setObject:@(NO) forKey:@"addDescription"];
        [prefs setObject:@(NO) forKey:@"addTemp"];
        [prefs setObject:@(NO) forKey:@"addDismiss"];
        [prefs setObject:@(NO) forKey:@"addLogo"];
        [prefs setObject:@(NO) forKey:@"addBlur"];
        [prefs save];
    } copy];

    ASTSetupSettings *page3 = [[ASTSetupSettings alloc] init];
    page3.style = [ASTTwoButtonsController class];
    page3.title = @"Lockscreen";
    page3.titleDescription = @"Hourly Forecast lockscreen.";
    page3.primaryButtonLabel = @"Enable";
    page3.secondaryButtonLabel = @"Set Up Later In Settings";
    page3.mediaURL = @"https://the-casle.github.io/TweakResources/forecast.jpg";
    page3.primaryBlock = [^{
        [prefs setObject:@(YES) forKey:@"greetView"];
        [prefs setObject:@(YES) forKey:@"hideOnNotif"];
        [prefs setObject:@(YES) forKey:@"addBlur"];
        [prefs setObject:@(YES) forKey:@"enableForeHeader"];
        [prefs setObject:@(YES) forKey:@"enableForeTable"];
        [prefs save];
    } copy];
    page3.secondaryBlock = [^{
        [prefs setObject:@(NO) forKey:@"enableForeHeader"];
        [prefs setObject:@(NO) forKey:@"enableForeTable"];
        [prefs save];
    } copy];
    
    ASTSetupSettings *page4 = [[ASTSetupSettings alloc] init];
    page4.style = [ASTBasicController class];
    page4.title = @"Editing Mode";
    page4.titleDescription = @"Move components and resize them.";
    page4.primaryButtonLabel = @"Continue";
    page4.mediaURL = @"https://the-casle.github.io/TweakResources/forecast.jpg";
    
    ASTSetupSettings *page5 = [[ASTSetupSettings alloc] init];
    page5.style = [ASTTwoButtonsController class];
    page5.title = @"Live Weather";
    page5.titleDescription = @"Live weather on the homescreen and lockscreen.";
    page5.primaryButtonLabel = @"Enable";
    page5.secondaryButtonLabel = @"Set Up Later In Settings",
    page5.mediaURL = @"https://the-casle.github.io/TweakResources/liveWeather.mov";
    page5.primaryBlock = [^{
        [prefs setObject:@(YES) forKey:@"lockScreenWeather"];
        [prefs setObject:@(YES) forKey:@"homeScreenWeather"];
        [prefs setObject:@(1) forKey:@"hideWeatherBackground"];
        [prefs save];
    } copy];
    page5.secondaryBlock = [^{
        [prefs setObject:@(NO) forKey:@"lockScreenWeather"];
        [prefs setObject:@(NO) forKey:@"homeScreenWeather"];
        [prefs setObject:@(0) forKey:@"hideWeatherBackground"];
        [prefs save];
    } copy];
    
    ASTSetupSettings *page6 = [[ASTSetupSettings alloc] init];
    page6.style = [ASTHeaderTwoButtonsController class];
    page6.title = @"Live Weather Layers";
    page6.titleDescription = @"Enable all layers of live weather. This includes the animation and the background.";
    page6.primaryButtonLabel = @"Enable";
    page6.secondaryButtonLabel = @"Set Up Later In Settings",
    page6.mediaURL = @"https://the-casle.github.io/TweakResources/yellow.png";
    page6.primaryBlock = [^{
        [prefs setObject:@(YES) forKey:@"lockScreenWeather"];
        [prefs setObject:@(YES) forKey:@"homeScreenWeather"];
        [prefs setObject:@(0) forKey:@"hideWeatherBackground"];
        [prefs save];
    } copy];
    
    ASTSetupSettings *page7 = [[ASTSetupSettings alloc] init];
    page7.style = [ASTHeaderTwoButtonsController class];
    page7.title = @"Weather Icon";
    page7.titleDescription = @"Live weather on the weather app icon.";
    page7.primaryButtonLabel = @"Enable";
    page7.secondaryButtonLabel = @"Set Up Later In Settings",
    page7.mediaURL = @"https://the-casle.github.io/TweakResources/Icon.PNG";
    page7.primaryBlock = [^{
        [prefs setObject:@(YES) forKey:@"appIcon"];
        [prefs setObject:@(YES) forKey:@"appScreenWeatherBackground"];
        [prefs save];
    } copy];
    page7.secondaryBlock = [^{
        [prefs setObject:@(NO) forKey:@"appIcon"];
        [prefs setObject:@(NO) forKey:@"appScreenWeatherBackground"];
        [prefs save];
    } copy];
    
    ASTSetupSettings *page8 = [[ASTSetupSettings alloc] init];
    page8.style = [ASTBasicController class];
    page8.title = @"Default Weather";
    page8.titleDescription = @"Selecting Asteroid's default weather.";
    page8.primaryButtonLabel = @"Continue";
    page8.mediaURL = @"https://the-casle.github.io/TweakResources/DefaultWeather.m4v";
    
    ASTSetupSettings *page9 = [[ASTSetupSettings alloc] init];
    page9.style = [ASTHeaderBasicController class];
    page9.title = @"Default Weather";
    page9.titleDescription = @"Asteroid will use local weather when location services for the weather app is set to \"always\". Otherwise, it will use the selected default within the weather app.";
    page9.primaryButtonLabel = @"Continue";
    page9.mediaURL = @"https://the-casle.github.io/TweakResources/locationService.jpg";
    
    ASTSetupSettings *page10 = [[ASTSetupSettings alloc] init];
    page10.style = [ASTTwoButtonsController class];
    page10.title = @"Status Bar";
    page10.titleDescription = @"Tapping the time on iPX or fluidity tweaks will show the current weather. Legacy status bars can be enabled from settings.";
    page10.primaryButtonLabel = @"Enable";
    page10.secondaryButtonLabel = @"Set Up Later in Settings.";
    page10.mediaURL = @"https://the-casle.github.io/TweakResources/status.m4v";
    page10.primaryBlock = [^{
        [prefs setObject:@(YES) forKey:@"enableTimeStatusX"];
        [prefs save];
    } copy];
    page10.secondaryBlock = [^{
        [prefs setObject:@(NO) forKey:@"enableTimeStatusX"];
        [prefs save];
    } copy];
    
    ASTSetupSettings *page11 = [[ASTSetupSettings alloc] init];
    page11.style = [ASTHeaderBasicController class];
    page11.title = @"Setup Complete";
    page11.titleDescription = @"Additional setting are always available under Asteroid's preferences.";
    page11.primaryButtonLabel = @"Finish";
    page11.mediaURL = @"http://aimra.org/goa_agm_application/img/animated-check.gif";
    page11.primaryBlock = [^{
         [prefs save];
    } copy];

    NSArray *pages = @[page1, page2, page3, page4, page5, page6, page7, page8, page9, page10, page11];
    self.setup = [[ASTSetup alloc] initWithPages:pages];
}
%end
