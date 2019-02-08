#import "ASTViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ASTViewController ()
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *greetingLabel;
@property (nonatomic, retain) UILabel *wDescription;
@property (nonatomic, retain) UILabel *currentTemp;
@property (retain, nonatomic) UIButton *dismissButton;

@property (nonatomic, retain) AWeatherModel *weatherModel;


@property (nonatomic, retain) ASTGestureHandler *gestureHandler;

@end

@implementation ASTViewController{

}

@synthesize pieceForReset = _pieceForReset;

- (instancetype) init{
    if(self = [super init]){
        self.gestureHandler = [[ASTGestureHandler alloc] init];
        self.gestureHandler.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherNotificationPosted:) name:@"weatherTimerUpdate" object:nil];
        
        self.weatherModel = [objc_getClass("AWeatherModel") sharedInstance];
    }
    return self;
}

- (void)viewDidLoad{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/3.6, screenHeight/2.1, 100, 225)];
    if([prefs boolForKey:@"addLogo"]){
        [self.view addSubview:self.logo];
    }
    
    self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225)];
    self.currentTemp.textAlignment = NSTextAlignmentCenter;
    if([prefs boolForKey:@"addTemp"]){
        [self.view addSubview: self.currentTemp];
    }
    
    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2.5, self.view.frame.size.width, self.view.frame.size.height/8.6)];
    self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    if([prefs boolForKey:@"addgreetLabel"]){
        [self.view addSubview:self.greetingLabel];
    }
    
    self.wDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2.1, (self.view.frame.size.width * .9), self.view.frame.size.height/8.6)];
    CGPoint wDescriptionCenter = self.wDescription.center;
    wDescriptionCenter.x = self.view.center.x;
    self.wDescription.center = wDescriptionCenter;
    
    self.wDescription.textAlignment = NSTextAlignmentCenter;
    self.wDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.wDescription.numberOfLines = 0;
    self.wDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.wDescription.preferredMaxLayoutWidth = self.view.frame.size.width;
    if([prefs boolForKey:@"addDescription"]){
        [self.view addSubview:self.wDescription];
    }
    
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dismissButton addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    self.dismissButton.frame = CGRectMake(0, self.view.frame.size.height/1.3, self.view.frame.size.width, self.view.frame.size.height/8.6);
    if([prefs boolForKey:@"addDismiss"]){
        [self.view addSubview:self.dismissButton];
    }
    
    NSArray *viewArray = @[self.logo, self.greetingLabel, self.wDescription, self.currentTemp, self.dismissButton];
    
    for(UIView *view in viewArray){
        [view addGestureRecognizer:[self.gestureHandler delegatedPanGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedRotationGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedPinchGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedMenuGestureRecognizer]];
        view.userInteractionEnabled = YES;
    }
    
    [self setupViewStyle];
}

-(void) setupViewStyle {
    if([prefs boolForKey:@"customFont"]){
        self.currentTemp.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"tempSize"]];
        self.greetingLabel.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"greetingSize"]];
        self.wDescription.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"wDescriptionSize"]];
        self.dismissButton.titleLabel.font = [UIFont fontWithName:[prefs stringForKey:@"availableFonts"] size:[prefs intForKey:@"dismissButtonSize"]];
    }else{
        self.currentTemp.font = [UIFont systemFontOfSize: [prefs intForKey:@"tempSize"] weight: UIFontWeightLight];
        self.greetingLabel.font = [UIFont systemFontOfSize:[prefs intForKey:@"greetingSize"] weight: UIFontWeightLight];
        self.wDescription.font = [UIFont systemFontOfSize:[prefs intForKey:@"wDescriptionSize"]];
        self.dismissButton.titleLabel.font = [UIFont systemFontOfSize:[prefs intForKey:@"dismissButtonSize"]];
    }
    self.currentTemp.textColor = [prefs colorForKey:@"textColor"];
    self.greetingLabel.textColor = [prefs colorForKey:@"textColor"];
    self.wDescription.textColor = [prefs colorForKey:@"textColor"];
    self.dismissButton.titleLabel.textColor = [prefs colorForKey:@"textColor"];
}

-(void) weatherNotificationPosted: (NSNotification *)notification{
    [self updateViewForWeatherData];
}

-(void) updateViewForWeatherData {
    if(self.weatherModel.isPopulated){
        UIImage *icon;
        BOOL setColor = FALSE;
        if(![prefs boolForKey:@"customImage"]){
            icon = [self.weatherModel glyphWithOption:ConditionOptionDefault];
        }else if ([[prefs stringForKey:@"setImageType"] isEqualToString:@"Filled Solid Color"]){
            icon = [self.weatherModel glyphWithOption:ConditionOptionDefault];
            setColor = TRUE;
        }else{
            icon = [self.weatherModel glyphWithOption:ConditionOptionBlack];
            setColor = TRUE;
        }
        self.logo.image = icon;
        if(setColor){
            self.logo.image = [self.logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.logo setTintColor:[prefs colorForKey:@"glyphColor"]];
        }
        self.logo.contentMode = UIViewContentModeScaleAspectFit;
        
        self.currentTemp.text = [self.weatherModel localeTemperature];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH"];
        dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSDate *currentTime;
        currentTime = [NSDate date];
        
        NSBundle *tweakBundle = [NSBundle bundleWithPath:@"/Library/Application Support/lockWeather.bundle"];
        switch ([[dateFormat stringFromDate:currentTime] intValue]){
            case 0 ... 4:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Evening" value:@"" table:nil];
                break;
                
            case 5 ... 11:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Morning" value:@"" table:nil];
                break;
                
            case 12 ... 17:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Afternoon" value:@"" table:nil];
                break;
                
            case 18 ... 24:
                self.greetingLabel.text = [tweakBundle localizedStringForKey:@"Good_Evening" value:@"" table:nil];
                break;
        }

        self.wDescription.text = [self.weatherModel currentConditionOverview];
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    }
}
- (void) buttonPressed: (UIButton*)sender{

}

#pragma mark - Menu Controller

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Delegated

- (void) showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        self.pieceForReset = [gestureRecognizer view];
        
        /*
         Set up the reset menu.
         */
        NSString *menuItemTitle = NSLocalizedString(@"Reset", @"Reset menu item title");
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle action:@selector(resetPiece:)];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setMenuItems:@[resetMenuItem]];
        
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);
        [menuController setTargetRect:menuLocation inView:[gestureRecognizer view]];
        
        [menuController setMenuVisible:YES animated:YES];
    }
}
- (void)resetPiece:(UIMenuController *)controller
{
    UIView *pieceForReset = self.pieceForReset;
    
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(pieceForReset.bounds), CGRectGetMidY(pieceForReset.bounds));
    CGPoint locationInSuperview = [pieceForReset convertPoint:centerPoint toView:[pieceForReset superview]];
    
    [[pieceForReset layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    [pieceForReset setCenter:locationInSuperview];
    
    [UIView beginAnimations:nil context:nil];
    [pieceForReset setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}
@end

