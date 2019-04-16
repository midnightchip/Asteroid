typedef NS_ENUM(NSUInteger, ASTSetupPageStyle) {
    ASTSetupStyleBasic = 0,
    ASTSetupStyleTwoButtons = 1,
    ASTSetupStyleHeaderBasic = 2,
    ASTSetupStyleHeaderTwoButtons = 3
};

/*
 Each ASTSetupSettings that is initialized represents a page.
*/

@interface ASTSetupSettings : NSObject
@property (nonatomic, assign) ASTSetupPageStyle style;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *titleDescription;
@property (nonatomic, retain) NSString *primaryButtonLabel;
@property (nonatomic, retain) NSString *secondaryButtonLabel;
@property (nonatomic, retain) NSString *backButtonLabel;
@property (nonatomic, retain) UIColor *colorTheme;
@property (nonatomic, copy) void (^primaryBlock)(void); // Executed when primary button is pressed.
@property (nonatomic, copy) void (^secondaryBlock)(void); // Executed when secondary button is pressed.
@property (nonatomic, assign) BOOL disableBack;

@property (nonatomic, retain) NSString *mediaURL;
/*@2x and @3x images are recommnended when possible. Supports both video and images.
 ex: On a @2x screen the link provided is -> https://the-casle.github.io/TweakResources/white.png
 It will attempt to grab the @2x link first -> https://the-casle.github.io/TweakResources/white@2x.png
 But default back if not available -> https://the-casle.github.io/TweakResources/white.png
 */
@end

/*
 The controller will only display pages for ASTSetupSettings that are added to an array.
 The array should then be passed as an argument for initWithPages:
 The ordering of ASTSetupSettings within the array will be the same order as the pages created.
*/

@interface ASTSetup : NSObject
- (instancetype)initWithPages:(NSArray *)pages;
@end
