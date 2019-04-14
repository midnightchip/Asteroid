#import "ASTChildViewController.h"

#define PATH_TO_CACHE @"/var/mobile/Library/Caches/Asteroid"

typedef void(^block)();

@interface ASTChildViewController ()
@end

@implementation ASTChildViewController {
    struct {
        BOOL changePage:1;
    } delegateRespondsTo;
}

#pragma mark - Delegate property

@synthesize delegate;
- (void)setDelegate:(id <ASTSourceDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        
        delegateRespondsTo.changePage = [delegate respondsToSelector:@selector(changePage:)];
    }
}
- (instancetype)initWithSource:(NSDictionary *) aSource{
    if(self = [super init]) {
        self.source = aSource;
        self.style = [[self.source objectForKey:@"style"] intValue];
    }
    return self;
}
-(void) viewDidLoad{
    [self.view setBackgroundColor: [UIColor whiteColor]];
    [self.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.view setUserInteractionEnabled:TRUE];
    
    [self formatButtons];
    switch (self.style) {
        case ASTSetupStyleBasic:
            [self unformattedTextForHeader];
            [self formatHeaderAndDescriptionTop];
            [self formatMediaPlayerStyleCenter];
            break;
        case ASTSetupStyleTwoButtons:
            [self unformattedTextForHeader];
            [self formatHeaderAndDescriptionTop];
            [self formatMediaPlayerStyleCenter];
            break;
        case ASTSetupStyleHeaderBasic:
            [self unformattedMediaForHeader];
            [self unformattedTextForHeader];
            break;
        case ASTSetupStyleHeaderTwoButtons:
            [self unformattedMediaForHeader];
            [self unformattedTextForHeader];
            break;
        default:
            [self formatHeaderAndDescriptionTop];
            [self formatMediaPlayerStyleCenter];
            break;
    }
    
    //Create navigation bar
    self.navBar = [[UINavigationBar alloc]init];
    //Make navigation bar background transparent
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    //Create the back button view
    UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-12, 0, 75, 50)];
    
    self.backButton = [HighlightButton buttonWithType:UIButtonTypeSystem];
    self.backButton.backgroundColor = [UIColor clearColor];
    self.backButton.frame = leftButtonView.frame;
    [self.backButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Asteroid.bundle/SetupResources/BackArrow.png"] forState:UIControlStateNormal];
    [self.backButton setTitle:BACK forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.tintColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    self.backButton.autoresizesSubviews = YES;
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftButtonView addSubview:self.backButton];
    
    //Add back button to navigation bar
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
    navItem.leftBarButtonItem = leftBarButton;
    
    self.navBar.items = @[ navItem ];
    [self.view addSubview:self.navBar];
    [self.view bringSubviewToFront:self.navBar];
    
    self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.navBar
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.navBar
                                  attribute: NSLayoutAttributeHeight
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: nil
                                  attribute: NSLayoutAttributeNotAnAttribute
                                 multiplier: 1
                                   constant: 50] setActive:true];
    
    [self registerForSettings];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.style == ASTSetupStyleBasic || self.style == ASTSetupStyleTwoButtons){
        CGRect playerFrame = self.mediaView.bounds;
        playerFrame.size.height = self.nextButton.frame.origin.y - self.mediaView.frame.origin.y - 15;
        self.playerLayer.frame = playerFrame;
    } else if(self.style == ASTSetupStyleHeaderBasic || self.style == ASTSetupStyleHeaderTwoButtons){
        self.mediaView.frame = self.playerLayer.frame;
    }
}

#pragma mark - Video Player For Style
-(void) formatMediaPlayerStyleCenter {
    self.imageView = [[UIImageView alloc] init];
    self.mediaView = [[UIView alloc] init];
    [self.mediaView addSubview:self.imageView];
    [self.view addSubview: self.mediaView];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeTop
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.titleDescription
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 10] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeBottom
                                  relatedBy: NSLayoutRelationLessThanOrEqual
                                     toItem: self.nextButton
                                  attribute: NSLayoutAttributeTop
                                 multiplier: 1
                                   constant: -20] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeHeight
                                  relatedBy: NSLayoutRelationLessThanOrEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeHeight
                                 multiplier: 1
                                   constant: 0] setActive:true];
    
    [[NSLayoutConstraint constraintWithItem: self.imageView
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.mediaView
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.imageView
                                  attribute: NSLayoutAttributeHeight
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.mediaView
                                  attribute: NSLayoutAttributeHeight
                                 multiplier: 1
                                   constant: 0] setActive:true];
    
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.mediaView.layer addSublayer:self.playerLayer];
}

-(void) unformattedMediaForHeader{
    self.mediaView = [[UIView alloc] init];
    [self.view addSubview:self.mediaView];
    [self.view sendSubviewToBack:self.mediaView];
    
    self.imageView = [[UIImageView alloc] init];
    [self.mediaView addSubview:self.imageView];
    
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    [self.mediaView.layer addSublayer:self.playerLayer];
}

-(void) formatImageViewStyleHeader {
    CGFloat ratio = self.imageView.image.size.height / self.imageView.image.size.width;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.imageView
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.imageView
                                  attribute: NSLayoutAttributeHeight
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: ratio
                                   constant: 0] setActive:true];
    
    self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.imageView
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeHeight
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.imageView
                                  attribute: NSLayoutAttributeHeight
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.mediaView
                                  attribute: NSLayoutAttributeTop
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeTop
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [self formatHeaderAndDescriptionToMedia];
}

-(void) formatVideoPlayerStyleHeader {
    AVAsset *asset = self.videoPlayer.currentItem.asset;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CGSize mediaSize = track.naturalSize;
    mediaSize = CGSizeApplyAffineTransform(mediaSize, track.preferredTransform);
    
    CGFloat ratio = fabs(mediaSize.height) / fabs(mediaSize.width);
    CGFloat newHeight = self.view.frame.size.width * ratio;
    self.playerLayer.frame = CGRectMake(0,0, self.view.frame.size.width, newHeight);
    self.mediaView.frame = self.playerLayer.frame;
    
    [self formatHeaderAndDescriptionToMedia];
}

#pragma mark - Button for Style
-(void) formatButtons{
    self.nextButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.nextButton setTitle: CONTINUE forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    self.nextButton.layer.cornerRadius = 7.5;
    self.nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.nextButton.titleLabel.textColor = [UIColor whiteColor];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.nextButton
                                  attribute: NSLayoutAttributeCenterX
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeCenterX
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.nextButton
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: nil
                                  attribute: NSLayoutAttributeNotAnAttribute
                                 multiplier: 1
                                   constant: 320] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.nextButton
                                  attribute: NSLayoutAttributeHeight
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: nil
                                  attribute: NSLayoutAttributeNotAnAttribute
                                 multiplier: 1
                                   constant: 50] setActive:true];
    if(self.style == ASTSetupStyleBasic || self.style == ASTSetupStyleHeaderBasic){
        [[NSLayoutConstraint constraintWithItem: self.nextButton
                                      attribute: NSLayoutAttributeBottom
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self.view
                                      attribute: NSLayoutAttributeBottom
                                     multiplier: 1
                                       constant: -30] setActive:true];
    } else {
        self.otherButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [self.otherButton setTitle:SET_UP_LATER_IN_SETTINGS forState:UIControlStateNormal];
        [self.otherButton setTitleColor:[UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        self.otherButton.backgroundColor = [UIColor clearColor];
        self.otherButton.layer.cornerRadius = 7.5;
        self.otherButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.otherButton.titleLabel.textColor = [UIColor whiteColor];
        self.otherButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.otherButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.otherButton];
        
        self.otherButton.translatesAutoresizingMaskIntoConstraints = NO;
        [[NSLayoutConstraint constraintWithItem: self.otherButton
                                      attribute: NSLayoutAttributeCenterX
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self.view
                                      attribute: NSLayoutAttributeCenterX
                                     multiplier: 1
                                       constant: 0] setActive:true];
        [[NSLayoutConstraint constraintWithItem: self.otherButton
                                      attribute: NSLayoutAttributeWidth
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: nil
                                      attribute: NSLayoutAttributeNotAnAttribute
                                     multiplier: 1
                                       constant: 320] setActive:true];
        [[NSLayoutConstraint constraintWithItem: self.otherButton
                                      attribute: NSLayoutAttributeHeight
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: nil
                                      attribute: NSLayoutAttributeNotAnAttribute
                                     multiplier: 1
                                       constant: 50] setActive:true];
        [[NSLayoutConstraint constraintWithItem: self.otherButton
                                      attribute: NSLayoutAttributeBottom
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self.view
                                      attribute: NSLayoutAttributeBottom
                                     multiplier: 1
                                       constant: -10] setActive:true];
        
        [[NSLayoutConstraint constraintWithItem: self.nextButton
                                      attribute: NSLayoutAttributeBottom
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self.otherButton
                                      attribute: NSLayoutAttributeTop
                                     multiplier: 1
                                       constant: 0] setActive:true];
    }
}

#pragma mark - Title and Descrition
-(void) formatHeaderAndDescriptionTop{
    [self.bigTitle sizeToFit];
    [self.titleDescription sizeToFit];
    self.bigTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.bigTitle
                                  attribute: NSLayoutAttributeTop
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeTop
                                 multiplier: 1
                                   constant: 30] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.bigTitle
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: .9
                                   constant: 1] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.bigTitle
                                  attribute: NSLayoutAttributeCenterX
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeCenterX
                                 multiplier: 1
                                   constant: 0] setActive:true];
    
    self.titleDescription.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeTop
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.bigTitle
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 10] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: .8
                                   constant: 1] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeCenterX
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeCenterX
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeLastBaseline
                                  relatedBy: NSLayoutRelationLessThanOrEqual
                                     toItem: self.nextButton
                                  attribute: NSLayoutAttributeTop
                                 multiplier: 1
                                   constant: -10] setActive:true];
}

-(void) unformattedTextForHeader {
    self.bigTitle = [[UILabel alloc] init];
    self.bigTitle.textAlignment = NSTextAlignmentCenter;
    self.bigTitle.font = [UIFont boldSystemFontOfSize:35];
    self.bigTitle.textAlignment = NSTextAlignmentCenter;
    self.bigTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.bigTitle.numberOfLines = 0;
    [self.view addSubview:self.bigTitle];
    
    self.titleDescription = [[UILabel alloc] init];
    self.titleDescription.textAlignment = NSTextAlignmentCenter;
    self.titleDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleDescription.numberOfLines = 0;
    self.titleDescription.font = [UIFont systemFontOfSize:20];
    [self.view addSubview: self.titleDescription];
}

-(void) formatHeaderAndDescriptionToMedia{
    [self.bigTitle sizeToFit];
    [self.titleDescription sizeToFit];
    self.bigTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.bigTitle
                                  attribute: NSLayoutAttributeTop
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.mediaView
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 10] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.bigTitle
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: .9
                                   constant: 1] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.bigTitle
                                  attribute: NSLayoutAttributeCenterX
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.mediaView
                                  attribute: NSLayoutAttributeCenterX
                                 multiplier: 1
                                   constant: 0] setActive:true];
    
    self.titleDescription.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeTop
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.bigTitle
                                  attribute: NSLayoutAttributeBottom
                                 multiplier: 1
                                   constant: 10] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeWidth
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeWidth
                                 multiplier: .8
                                   constant: 1] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeCenterX
                                  relatedBy: NSLayoutRelationEqual
                                     toItem: self.view
                                  attribute: NSLayoutAttributeCenterX
                                 multiplier: 1
                                   constant: 0] setActive:true];
    [[NSLayoutConstraint constraintWithItem: self.titleDescription
                                  attribute: NSLayoutAttributeLastBaseline
                                  relatedBy: NSLayoutRelationLessThanOrEqual
                                     toItem: self.nextButton
                                  attribute: NSLayoutAttributeTop
                                 multiplier: 1
                                   constant: -10] setActive:true];
}

-(void) registerForSettings{
    self.bigTitle.text = self.source[@"title"];
    self.titleDescription.text = self.source[@"description"];
    
    [self.nextButton setTitle: self.source[@"primaryButton"] forState:UIControlStateNormal];
    [self.otherButton setTitle: self.source[@"secondaryButton"] forState:UIControlStateNormal];
    
    [self setupMediaWithUrl:self.source[@"mediaURL"]];
    
    if([self.source[@"disableBack"] boolValue]){
        self.backButton.hidden = YES;
    }
}

-(void) sessionLoaded{
    AVAsset *asset = self.videoPlayer.currentItem.asset;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if(!self.imageView.image && tracks.count == 0){
        [self setupMediaWithUrl:self.source[@"mediaURL"]];
    }
}

-(void) setupMediaWithUrl:(NSString *) pathToUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", PATH_TO_CACHE, [NSURL URLWithString:pathToUrl].lastPathComponent];
    if ([fileManager fileExistsAtPath:filePath]){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSLog(@"lock_TWEAK | holding image");
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
            if (image) {
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"lock_TWEAK | setting image");
                    self.imageView.image = image;
                    if(self.style == ASTSetupStyleHeaderBasic || self.style == ASTSetupStyleHeaderTwoButtons){
                        [self formatImageViewStyleHeader];
                    }
                    self.playerLayer.hidden = YES;
                });
                
            } else {
                self.videoPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
                AVAsset *asset = self.videoPlayer.currentItem.asset;
                NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                if(tracks.count > 0){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self.style == ASTSetupStyleHeaderBasic || self.style == ASTSetupStyleHeaderTwoButtons){
                            [self formatVideoPlayerStyleHeader];
                        }
                        self.playerLayer.player = self.videoPlayer;
                        self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                        
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(playerItemDidReachEnd:)
                                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                                   object:[self.videoPlayer currentItem]];
                        [self.videoPlayer play];
                        self.imageView.hidden = YES;
                    });
                    
                }
            }
        });
    }
}
-(void) nextButtonPressed{
    if(delegateRespondsTo.changePage){
        [self.delegate changePage: UIPageViewControllerNavigationDirectionForward];
    }
    block primary = self.source[@"primaryBlock"];
    if(primary) primary();
}
-(void) backButtonPressed{
    if(delegateRespondsTo.changePage){
        [self.delegate changePage: UIPageViewControllerNavigationDirectionReverse];
    }
    block second = self.source[@"secondaryBlock"];
    if(second) second();
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
@end
