/*
 TODO: Notification counter
 */

#import "ASTViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <substrate.h>

#define DIRECTORY_PATH @"/var/mobile/Library/Asteroid"
#define FILE_PATH @"/var/mobile/Library/Asteroid/centerData.plist"

@interface SBDashBoardQuickActionsButton : UIButton
-(id)initWithType:(long long)arg1 ;
@end

@interface ASTViewController ()
@property (nonatomic, retain) UIImageView *logo;
@property (nonatomic, retain) UILabel *greetingLabel;
@property (nonatomic, retain) UILabel *wDescription;
@property (nonatomic, retain) UILabel *currentTemp;
@property (nonatomic, retain) WAWeatherPlatterViewController *forecastCont;
@property (retain, nonatomic) UIView *dismissButtonView;
@property (retain, nonatomic) UIButton *dismissButton;
@property (nonatomic, retain) UILabel *notificationLabel;

@property (nonatomic, retain) ASTComponentView *logoComponentView;
@property (nonatomic, retain) ASTComponentView *greetingLabelComponentView;
@property (nonatomic, retain) ASTComponentView *wDescriptionComponentView;
@property (nonatomic, retain) ASTComponentView *currentTempComponentView;
@property (nonatomic, retain) ASTComponentView *forecastComponentView;
@property (nonatomic, retain) ASTComponentView *dismissButtonComponentView;
@property (nonatomic, retain) ASTComponentView *notificationLabelComponentView;

@property (nonatomic, retain) UIView *logoGestureView;
@property (nonatomic, retain) UIView *greetingLabelGestureView;
@property (nonatomic, retain) UIView *wDescriptionGestureView;
@property (nonatomic, retain) UIView *currentTempGestureView;
@property (nonatomic, retain) UIView *forecastGestureView;
@property (nonatomic, retain) UIView *dismissButtonGestureView;
@property (nonatomic, retain) UIView *notificationLabelGestureView;

@property (nonatomic, retain) AWeatherModel *weatherModel;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, retain) UIView *doneButtonView;
@property (nonatomic, assign) UIDeviceOrientation previousRotation;

@property (nonatomic, retain) ASTGestureHandler *gestureHandler;

-(void) adjustWDescriptionViewsForString:(NSString *) string;
@end

@implementation ASTViewController{
    
}
@synthesize editing;
@synthesize pieceForReset = _pieceForReset;

- (instancetype) init{
    if(self = [super init]){
        self.gestureHandler = [[ASTGestureHandler alloc] init];
        self.gestureHandler.delegate = self;
        self.weatherModel = [objc_getClass("AWeatherModel") sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherNotificationPosted:) name:@"weatherTimerUpdate" object:nil];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(orientationChanged:)
         name:@"UIApplicationDidChangeStatusBarOrientationNotification"
         object: [UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(orientationWillChange:)
         name:@"UIApplicationWillChangeStatusBarOrientationNotification"
         object: [UIApplication sharedApplication]];
    }
    return self;
}

- (void)viewDidLoad{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.logoGestureView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/3.6, screenHeight/2.1, 100, 225)];
    self.logoComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.logoGestureView.frame.size.width, self.logoGestureView.frame.size.height)];
    self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.logoComponentView.frame.size.width, self.logoComponentView.frame.size.height)];
    [self.logoComponentView addSubview:self.logo];
    [self.logoGestureView addSubview: self.logoComponentView];
    if([prefs boolForKey:@"addLogo"]){
        [self.view addSubview: self.logoGestureView];
    }
    
    self.currentTempGestureView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2.1, screenHeight/2.1, 100, 225)];
    self.currentTempComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.currentTempGestureView.frame.size.width, self.currentTempGestureView.frame.size.height)];
    self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.currentTempComponentView.frame.size.width, self.currentTempComponentView.frame.size.height)];
    self.currentTemp.textAlignment = NSTextAlignmentCenter;
    [self.currentTempComponentView addSubview: self.currentTemp];
    [self.currentTempGestureView addSubview: self.currentTempComponentView];
    if([prefs boolForKey:@"addTemp"]){
        [self.view addSubview: self.currentTempGestureView];
    }
    
    self.greetingLabelGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2.5, self.view.frame.size.width, self.view.frame.size.height/8.6)];
    self.greetingLabelComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.greetingLabelGestureView.frame.size.width, self.greetingLabelGestureView.frame.size.height)];
    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.greetingLabelComponentView.frame.size.width, self.greetingLabelComponentView.frame.size.height)];
    self.greetingLabel.textAlignment = NSTextAlignmentCenter;
    [self.greetingLabelComponentView addSubview: self.greetingLabel];
    [self.greetingLabelGestureView addSubview: self.greetingLabelComponentView];
    if([prefs boolForKey:@"addgreetLabel"]){
        [self.view addSubview:self.greetingLabelGestureView];
    }
    
    self.wDescriptionGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2.1, (self.view.frame.size.width * .9), self.view.frame.size.height/8.6)];
    self.wDescriptionComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.wDescriptionGestureView.frame.size.width, self.wDescriptionGestureView.frame.size.height)];
    self.wDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.wDescriptionComponentView.frame.size.width, self.wDescriptionComponentView.frame.size.height)];
    CGPoint wDescriptionCenter = self.wDescriptionGestureView.center;
    wDescriptionCenter.x = self.view.center.x;
    self.wDescriptionGestureView.center = wDescriptionCenter;
    self.wDescription.textAlignment = NSTextAlignmentCenter;
    self.wDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.wDescription.numberOfLines = 0;
    self.wDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.wDescription.preferredMaxLayoutWidth = self.view.frame.size.width;
    [self.wDescriptionComponentView addSubview: self.wDescription];
    [self.wDescriptionGestureView addSubview: self.wDescriptionComponentView];
    if([prefs boolForKey:@"addDescription"]){
        [self.view addSubview:self.wDescriptionGestureView];
    }
    
    self.forecastGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height / 2), self.view.frame.size.width, self.view.frame.size.height/3)];
    self.forecastComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.forecastGestureView.frame.size.width, self.forecastGestureView.frame.size.height)];
    self.forecastCont = [[objc_getClass("WAWeatherPlatterViewController") alloc] initWithLocation:self.weatherModel.city];
    ((UIView *)((NSArray *)self.forecastCont.view.layer.sublayers)[0]).hidden = YES; // Visual Effect view to hidden
    self.forecastCont.view.frame = CGRectMake(0, 0, self.forecastComponentView.frame.size.width, self.forecastComponentView.frame.size.height);
    [self.forecastComponentView addSubview:self.forecastCont.view];
    [self.forecastGestureView addSubview: self.forecastComponentView];
    if([prefs boolForKey:@"enableForeHeader"] || [prefs boolForKey:@"enableForeTable"]){
        [self.view addSubview: self.forecastGestureView];
    }
    
    self.dismissButtonGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/1.3, self.view.frame.size.width, self.view.frame.size.height/8.6)];
    self.dismissButtonComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.dismissButtonGestureView.frame.size.width, self.dismissButtonGestureView.frame.size.height)];
    self.dismissButtonView = [[UIView alloc] initWithFrame:CGRectMake(0,0,110,50)];
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    SBDashBoardQuickActionsButton *actionButton = [[objc_getClass("SBDashBoardQuickActionsButton") alloc] initWithType:2];
    UIVisualEffectView *effectView = MSHookIvar<UIVisualEffectView *>(actionButton, "_backgroundEffectView");
    effectView.frame = self.dismissButtonView.bounds;
    [self.dismissButton addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    self.dismissButton.frame = self.dismissButtonView.bounds;
    effectView.layer.cornerRadius = 25;
    effectView.layer.masksToBounds = YES;
    CGPoint dismissButtonCenter = self.dismissButtonView.center;
    dismissButtonCenter.x = self.view.center.x;
    dismissButtonCenter.y = self.dismissButtonComponentView.bounds.size.height / 2;
    self.dismissButtonView.center = dismissButtonCenter;
    [self.dismissButtonView addSubview: effectView];
    [self.dismissButtonView addSubview: self.dismissButton];
    [self.dismissButtonComponentView addSubview: self.dismissButtonView];
    [self.dismissButtonGestureView addSubview: self.dismissButtonComponentView];
    if([prefs boolForKey:@"addDismiss"]){
        [self.view addSubview:self.dismissButtonGestureView];
    }
    
    self.notificationLabelGestureView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height/2.5, 25, 25)];
    self.notificationLabelComponentView = [[ASTComponentView alloc] initWithFrame:CGRectMake(0, 0, self.notificationLabelGestureView.frame.size.width, self.notificationLabelGestureView.frame.size.height)];
    self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.notificationLabel.textAlignment = NSTextAlignmentCenter;
    self.notificationLabel.textColor = [UIColor whiteColor];
    self.notificationLabel.backgroundColor = [UIColor redColor];
    self.notificationLabel.layer.masksToBounds = YES;
    self.notificationLabel.adjustsFontSizeToFitWidth = YES;
    self.notificationLabel.layer.cornerRadius = 12.5;
    self.notificationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.notificationLabelComponentView addSubview:self.notificationLabel];
    [self.notificationLabelGestureView addSubview: self.notificationLabelComponentView];
    if([prefs boolForKey:@"addNotification"]){
        [self.view addSubview:self.notificationLabelGestureView];
    }
    
    CGRect stausBarFrame = [[objc_getClass("SpringBoard") sharedApplication] statusBarFrame];
    
    self.doneButtonView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, stausBarFrame.size.height + 5, 50, 20)];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self
                           action:@selector(doneButtonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont boldSystemFontOfSize:13],
                               NSForegroundColorAttributeName : [UIColor blackColor]
                               };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Done" attributes:attrDict];
    [doneButton setAttributedTitle:attrString forState:UIControlStateNormal];
    doneButton.frame = self.doneButtonView.bounds;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.doneButtonView.bounds;
    self.doneButtonView.layer.cornerRadius = 10;
    self.doneButtonView.layer.masksToBounds = YES;
    self.doneButtonView.alpha = 0;
    [self.doneButtonView addSubview:blurEffectView];
    [self.doneButtonView addSubview:doneButton];
    [self.view addSubview:self.doneButtonView];
    
    NSArray *gestureArray = [self arrayOfGestureViews];
    for(UIView *view in gestureArray){
        [view addGestureRecognizer:[self.gestureHandler delegatedMenuGestureRecognizer]];
        view.userInteractionEnabled = YES;
    }
    
    [self creatingTagsForGestures];
    [self setupViewStyle];
    self.editing = NO;
}

#pragma mark - Syncronize objects
- (void) buttonPressed: (UIButton*)sender{
    if(!self.view.hidden){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"astDimissButtonPressed"
         object:self];
    }
}

-(void) creatingTagsForGestures{
    int i = 80085;
    for(UIView *view in [self arrayOfGestureViews]){
        view.tag = i;
        i++;
    }
    [self creatingDirectoryAndFile];
}

-(void) setEditing:(BOOL) edit{
    editing = edit;
    NSArray *componentViews = [self arrayOfComponentViews];
    for(ASTComponentView *view in componentViews){
        view.editing = edit;
    }
}
-(void) orientationWillChange:(NSNotification *)note {
    UIApplication *application = note.object;
    self.previousRotation = application.statusBarOrientation;
}

- (void) orientationChanged:(NSNotification *)note {
    UIApplication *application = note.object;
    CGRect screenRect = [application keyWindow].bounds;
    if(application.statusBarOrientation == UIDeviceOrientationPortrait){
        if(self.previousRotation == UIDeviceOrientationLandscapeLeft || self.previousRotation == UIDeviceOrientationLandscapeRight){
            for(UIView *view in [self arrayOfGestureViews]){
                view.frame = [self rotateFrame:view.frame withContext:screenRect];
                if(view.frame.origin.x >= screenRect.size.width || view.frame.origin.y >= screenRect.size.height){ // Something went wrong with the rotation.
                    [self readingValuesFromFile];
                    break;
                }
            }
        }
    } else if(application.statusBarOrientation == UIDeviceOrientationPortraitUpsideDown){
        if(self.previousRotation == UIDeviceOrientationLandscapeLeft || self.previousRotation == UIDeviceOrientationLandscapeRight){
            for(UIView *view in [self arrayOfGestureViews]){
                view.frame = [self rotateFrame:view.frame withContext:screenRect];
            }
        }
    } else if(application.statusBarOrientation == UIDeviceOrientationLandscapeLeft){
        if(self.previousRotation == UIDeviceOrientationPortrait || self.previousRotation == UIDeviceOrientationLandscapeRight){
            for(UIView *view in [self arrayOfGestureViews]){
                view.frame = [self rotateFrame:view.frame withContext:screenRect];
            }
        }
    } else if(application.statusBarOrientation == UIDeviceOrientationLandscapeRight){
        if(self.previousRotation == UIDeviceOrientationPortrait || self.previousRotation == UIDeviceOrientationLandscapeRight){
            for(UIView *view in [self arrayOfGestureViews]){
                view.frame = [self rotateFrame:view.frame withContext:screenRect];
            }
        }
    }
}

-(CGRect) rotateFrame:(CGRect) frame withContext:(CGRect) context {
    CGRect adjustedFrame = frame;
    adjustedFrame.origin.x = ((frame.origin.x + (frame.size.width / 2)) / context.size.height) * context.size.width - (frame.size.width / 2);
    adjustedFrame.origin.y = ((frame.origin.y + (frame.size.height / 2)) / context.size.width) * context.size.height - (frame.size.height / 2);
    return adjustedFrame;
}

#pragma mark - Weather Setup
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
    
    if(![prefs boolForKey:@"enableForeHeader"]){
        
        self.forecastCont.headerView.hidden = YES;
        self.forecastCont.headerView = nil;
        self.forecastCont.dividerLineView.hidden = TRUE;
    }
    if(![prefs boolForKey:@"enableForeTable"]){
        self.forecastCont.hourlyForecastViews = nil;
        self.forecastCont.dividerLineView.hidden = TRUE;
    }
    if(![prefs boolForKey:@"enableForeHeader"] && ![prefs boolForKey:@"enableForeTable"]){
        [self.forecastCont.view removeFromSuperview];
    }
    
    self.currentTemp.textColor = [prefs colorForKey:@"textColor"];
    self.greetingLabel.textColor = [prefs colorForKey:@"textColor"];
    self.wDescription.textColor = [prefs colorForKey:@"textColor"];
    //self.dismissButton.titleLabel.textColor = [prefs colorForKey:@"textColor"];
    
    [self readingValuesFromFile];
}

-(void) weatherNotificationPosted: (NSNotification *)notification{
    [self updateViewForWeatherData];
}

-(void) updateViewForWeatherData {
    if(self.weatherModel.isPopulated || self.weatherModel.hasFallenBack){
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
        
        NSBundle *tweakBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/Asteroid.bundle"];
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
        self.greetingLabel.textAlignment = NSTextAlignmentCenter;
        
        [self adjustWDescriptionViewsForString:[self.weatherModel currentConditionOverview]];

        if(self.weatherModel.isPopulated){
            self.forecastCont.model = self.weatherModel.todayModel;
            [self.forecastCont.model forecastModel];
            [self.forecastCont.headerView _updateContent];
            [self.forecastCont _updateViewContent];
        }
    }
}

-(void) adjustWDescriptionViewsForString:(NSString *) string{
    CGSize maximumLabelSize = CGSizeMake(self.wDescriptionComponentView.frame.size.width, 120);
    CGRect expectedLabelRect = [string boundingRectWithSize:maximumLabelSize
                                                    options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                 attributes:@{NSFontAttributeName:self.wDescription.font}
                                                    context:nil];
    CGRect tempLabelFrame = self.wDescription.frame;
    tempLabelFrame.size.height = expectedLabelRect.size.height;
    self.wDescription.frame = tempLabelFrame;
    self.wDescription.center = self.wDescriptionComponentView.center;

    self.wDescription.text = string;
}

-(void) updateNotifcationWithText:(NSString *) text{
    self.notificationLabel.text = text;
}

#pragma mark - Read/Write to disk
-(void) creatingDirectoryAndFile{
    if([prefs boolForKey:@"resetXY"]){
        [[NSFileManager defaultManager] removeItemAtPath:FILE_PATH error:nil];
        [prefs setObject: @(NO) forKey:@"resetXY"];
        [prefs save];
    }
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DIRECTORY_PATH isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:DIRECTORY_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if(![fileManager fileExistsAtPath:FILE_PATH isDirectory:&isDir]){
        [fileManager createFileAtPath:FILE_PATH contents:nil attributes:nil];
    }
}

-(void) saveValuesToFile{
    NSArray *gestureArray = [self arrayOfGestureViews];
    NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
    for(UIView *view in gestureArray){
        NSString *centerKey = [NSString stringWithFormat:@"%d-center", (int)view.tag];
        valueDict[centerKey] = [NSValue valueWithCGPoint:view.center];
        NSString *anchorKey = [NSString stringWithFormat:@"%d-anchor", (int)view.tag];
        valueDict[anchorKey] = [NSValue valueWithCGPoint:view.layer.anchorPoint];
        NSString *transformKey = [NSString stringWithFormat:@"%d-transform", (int)view.tag];
        valueDict[transformKey] = [self convertCGAffineTransformToArray:[view transform]];
    }
    [[NSKeyedArchiver archivedDataWithRootObject:valueDict] writeToFile:FILE_PATH atomically:YES];
}

-(void) readingValuesFromFile{
    NSDictionary *valueDict = [NSKeyedUnarchiver unarchiveObjectWithData: [NSData dataWithContentsOfFile: FILE_PATH]];
    NSArray *gestureArray = [self arrayOfGestureViews];
    for(UIView *view in gestureArray){
        NSString *centerKey = [NSString stringWithFormat:@"%d-center", (int)view.tag];
        CGPoint center = [valueDict[centerKey] CGPointValue];
        NSString *anchorKey = [NSString stringWithFormat:@"%d-anchor", (int)view.tag];
        CGPoint anchor = [valueDict[anchorKey] CGPointValue];
        if(center.x != 0 && center.y != 0) view.center = center;
        NSString *transformKey = [NSString stringWithFormat:@"%d-transform", (int)view.tag];
        CGAffineTransform transform = [self convertArrayToCGAffineTransform:valueDict[transformKey]];
        if(anchor.x != 0 && anchor.y != 0)view.layer.anchorPoint = anchor;
        if(transform.a != 0 || transform.b != 0) [view setTransform:transform];
    }
}

#pragma mark - Handling Gestures
- (void) doneButtonPressed: (UIButton*)sender{
    // Only edit in portrait so values match up right.
    if([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown){
        self.editing = NO;
        [self removeASTGesturesAndHideButton];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"astEnableLock"
         object:self];
        [self saveValuesToFile];
    } else {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Asteroid"
                                     message:@"Please rotate to portrait to save values."
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"Ok"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) addASTGesturesAndRevealButton{
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{self.doneButtonView.alpha = 1;}
                     completion:nil];
    
    NSArray *gestureArray = [self arrayOfGestureViews];
    for(UIView *view in gestureArray){
        [view addGestureRecognizer:[self.gestureHandler delegatedPanGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedRotationGestureRecognizer]];
        [view addGestureRecognizer:[self.gestureHandler delegatedPinchGestureRecognizer]];
        view.userInteractionEnabled = YES;
    }
}

-(void) removeASTGesturesAndHideButton{
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{self.doneButtonView.alpha = 0;}
                     completion:nil];
    NSArray *gestureArray = [self arrayOfGestureViews];
    for(UIView *view in gestureArray){
        NSArray *gestureRecognizers = [view gestureRecognizers];
        for(UIGestureRecognizer *gestureRecognizer in gestureRecognizers){
            if(![gestureRecognizer isKindOfClass:objc_getClass("UILongPressGestureRecognizer")]){
                [view removeGestureRecognizer:gestureRecognizer];
            }
        }
    }
}

#pragma mark - util
-(NSArray *) convertCGAffineTransformToArray:(CGAffineTransform) transform{
    return @[[NSNumber numberWithFloat:transform.a], [NSNumber numberWithFloat:transform.b], [NSNumber numberWithFloat:transform.c], [NSNumber numberWithFloat:transform.d], [NSNumber numberWithFloat:transform.tx], [NSNumber numberWithFloat:transform.ty]];
}

-(CGAffineTransform) convertArrayToCGAffineTransform:(NSArray *) array{
    NSNumber *a = array[0];
    NSNumber *b = array[1];
    NSNumber *c = array[2];
    NSNumber *d = array[3];
    NSNumber *tx = array[4];
    NSNumber *ty = array[5];
    
    return CGAffineTransformMake(a.floatValue, b.floatValue, c.floatValue, d.floatValue, tx.floatValue, ty.floatValue);
}

-(NSArray *) arrayOfGestureViews{
    return @[self.logoGestureView, self.greetingLabelGestureView, self.wDescriptionGestureView, self.currentTempGestureView, self.forecastGestureView, self.dismissButtonGestureView, self.notificationLabelGestureView];
}

-(NSArray *) arrayOfComponentViews{
    return @[self.logoComponentView, self.greetingLabelComponentView, self.wDescriptionComponentView, self.currentTempComponentView, self.forecastComponentView, self.dismissButtonComponentView, self.notificationLabelComponentView];
}

#pragma mark - Menu Controller

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Delegated

- (void) showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if(self.isEditing){
            [self becomeFirstResponder];
            self.pieceForReset = [gestureRecognizer view];
            
            //Set up the reset menu.
            NSString *menuItemTitle = NSLocalizedString(@"Reset", @"Reset menu item title");
            UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle action:@selector(resetPiece:)];
            
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            [menuController setMenuItems:@[resetMenuItem]];
            
            CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
            CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);
            [menuController setTargetRect:menuLocation inView:[gestureRecognizer view]];
            
            [menuController setMenuVisible:YES animated:YES];
        } else if(!self.isEditing && [prefs boolForKey:@"enableEditingMode"]){
            self.editing = YES;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"astDisableLock"
             object:self];
            [self addASTGesturesAndRevealButton];
                
        }
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

