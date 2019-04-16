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
    page1.style = ASTSetupStyleHeaderBasic;
    page1.title = @"Asteroid";
    page1.titleDescription = @"MidnightChips & the casle © 2019\n\nThank you for installing Asteroid. In order to deliver the best user experience, further setup is required.";
    page1.primaryButtonLabel = @"Setup";
    page1.backButtonLabel = @"Skip";
    page1.mediaURL = @"https://the-casle.github.io/TweakResources/Asteroid.png";
/*
    NSDictionary *page2 = @{@"style": @(ASTSetupStyleHeaderTwoButtons),
        @"title": @"Lockscreen",
        @"description": @"Basic iOS 12 lockscreen.",
        @"primaryButton": @"Enable",
        @"secondaryButton": @"Other Options",
        @"colorTheme": [UIColor redColor],
        @"mediaURL": @"https://the-casle.github.io/TweakResources/white.png",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy]
    };
    NSDictionary *page3 = @{@"style": @(ASTSetupStyleTwoButtons),
        @"title": @"Lockscreen",
        @"description": @"Hourly Forecast lockscreen.",
        @"primaryButton": @"Enable",
        @"secondaryButton": @"Setup Later In Settings",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/forecast.jpg",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };
    NSDictionary *page4 = @{@"style": @(ASTSetupStyleBasic),
        @"title": @"Editing Mode",
        @"description": @"Move components and resize them.",
        @"primaryButton": @"Continue",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/editing.m4v",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };
    NSDictionary *page5 = @{@"style": @(ASTSetupStyleTwoButtons),
        @"title": @"Live Weather",
        @"description": @"Live weather on the homescreen and lockscreen.",
        @"primaryButton": @"Enable",
        @"secondaryButton": @"Setup Later In Settings",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/liveWeather.mov",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };
    NSDictionary *page6 = @{@"style": @(ASTSetupStyleHeaderTwoButtons),
        @"title": @"Live Weather Layers",
        @"description": @"Enable all layers of live weather. This includes the animation and the background.",
        @"primaryButton": @"Enable",
        @"secondaryButton": @"Setup Later In Settings",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/yellow.png",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };
    NSDictionary *page7 = @{@"style": @(ASTSetupStyleHeaderTwoButtons),
        @"title": @"Weather Icon",
        @"description": @"Live weather on the weather app icon.",
        @"primaryButton": @"Enable",
        @"secondaryButton": @"Setup Later In Settings",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/Icon.PNG",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };
    NSDictionary *page8 = @{@"style": @(ASTSetupStyleBasic),
        @"title": @"Default Weather",
        @"description": @"Selecting Asteroid's default weather.",
        @"primaryButton": @"Continue",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/DefaultWeather.m4v",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };
    NSDictionary *page9 = @{@"style": @(ASTSetupStyleHeaderBasic),
        @"title": @"Default Weather",
        @"description": @"Asteroid will use local weather when location services for the weather app is set to \"always\". Otherwise, it will use the selected default within the weather app.",
        @"primaryButton": @"Continue",
        @"mediaURL": @"https://the-casle.github.io/TweakResources/locationService.jpg",
        @"primaryBlock": [^{ NSLog(@"lock_TWEAK | block 1");} copy],
        //@"secondaryBlock": [^{ NSLog(@"lock_TWEAK | block 2");} copy],
        @"disableBack": @(NO)
    };*/
    
    NSArray *pages = @[page1];
    self.setup = [[ASTSetup alloc] initWithPages:pages];
}
%end
