#import "ASTChildViewController.h"

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
    [self.view setUserInteractionEnabled:TRUE];
    
    switch (self.style) {
        case ASTSetupStyleBasic:
            [self formatMediaPlayerStyleBasic];
            [self formatForSingleButton];
            [self formatHeaderAndDescriptionTop];
            break;
        case ASTSetupStyleTwoButtons:
            [self formatMediaPlayerStyleShort];
            [self formatForTwoButtons];
            [self formatHeaderAndDescriptionTop];
            break;
        case ASTSetupStyleHeaderBasic:
            [self unformattedMediaForHeader];
            [self formatForSingleButton];
            [self unformattedTextForHeader];
            break;
        case ASTSetupStyleHeaderTwoButtons:
            [self unformattedMediaForHeader];
            [self formatForTwoButtons];
            [self unformattedTextForHeader];
            break;
        default:
            [self formatMediaPlayerStyleBasic];
            [self formatForSingleButton];
            [self formatHeaderAndDescriptionTop];
            break;
    }
    
    //Create navigation bar
    self.navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
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
    
    [self registerForSettings];
}

#pragma mark - Video Player For Style
-(void) formatMediaPlayerStyleBasic {
    CGFloat width = (self.view.frame.size.height*0.59)/1.777777777;
    CGFloat height = self.view.frame.size.height*0.59;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-((self.view.frame.size.height*0.59)/1.777777777)/2, 150, width, height)];
    [self.view addSubview:self.imageView];
    
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.frame = CGRectMake(self.view.frame.size.width/2-((self.view.frame.size.height*0.59)/1.777777777)/2, 150, width, height);
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:self.playerLayer];
}

-(void) formatMediaPlayerStyleShort {
    CGFloat width = (self.view.frame.size.height*0.54)/1.777777777;
    CGFloat height = self.view.frame.size.height*0.54;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-((self.view.frame.size.height*0.54)/1.777777777)/2, 150, width, height)];
    [self.view addSubview:self.imageView];
    
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.frame = CGRectMake(self.view.frame.size.width/2-((self.view.frame.size.height*0.54)/1.777777777)/2, 150, width, height);
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:self.playerLayer];
}

-(void) unformattedMediaForHeader{
    CGFloat width = self.view.frame.size.width;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    [self.view addSubview:self.imageView];
    [self.view sendSubviewToBack:self.imageView];
    
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:self.playerLayer];
    
}

-(void) formatImageViewStyleHeader {
    CGFloat ratio = self.imageView.image.size.height / self.imageView.image.size.width;
    CGFloat newHeight = self.view.frame.size.width * ratio;
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight);
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
    
    [self formatHeaderAndDescriptionToMedia];
}

#pragma mark - Button for Style
-(void) formatForSingleButton{
    self.nextButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.nextButton setTitle: CONTINUE forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    self.nextButton.layer.cornerRadius = 7.5;
    self.nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.nextButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height/1.09);
    self.nextButton.titleLabel.textColor = [UIColor whiteColor];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
}
-(void) formatForTwoButtons{
    self.nextButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.nextButton setTitle:CONTINUE forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextButton.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0];
    self.nextButton.layer.cornerRadius = 7.5;
    self.nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.nextButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height/1.16);
    self.nextButton.titleLabel.textColor = [UIColor whiteColor];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    self.otherButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.otherButton setTitle:SET_UP_LATER_IN_SETTINGS forState:UIControlStateNormal];
    [self.otherButton setTitleColor:[UIColor colorWithRed:10 / 255.0 green:106 / 255.0 blue:255 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    self.otherButton.backgroundColor = [UIColor clearColor];
    self.otherButton.layer.cornerRadius = 7.5;
    self.otherButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.otherButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height/1.06);
    self.otherButton.titleLabel.textColor = [UIColor whiteColor];
    self.otherButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.otherButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.otherButton];
}

#pragma mark - Title and Descrition
-(void) formatHeaderAndDescriptionTop{
    self.bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 100)];
    self.bigTitle.textAlignment = NSTextAlignmentCenter;
    self.bigTitle.font = [UIFont boldSystemFontOfSize:35];
    [self.view addSubview:self.bigTitle];
    
    self.titleDescription = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, 75, self.view.frame.size.width*0.8, 100)];
    self.titleDescription.textAlignment = NSTextAlignmentCenter;
    self.titleDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleDescription.numberOfLines = 0;
    self.titleDescription.font = [UIFont systemFontOfSize:20];
    [self.view addSubview: self.titleDescription];
}

-(void) unformattedTextForHeader {
    self.bigTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 100)];
    self.bigTitle.textAlignment = NSTextAlignmentCenter;
    self.bigTitle.font = [UIFont boldSystemFontOfSize:35];
    [self.view addSubview:self.bigTitle];
    
    self.titleDescription = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, 75, self.view.frame.size.width*0.8, 100)];
    self.titleDescription.textAlignment = NSTextAlignmentCenter;
    self.titleDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleDescription.numberOfLines = 0;
    self.titleDescription.font = [UIFont systemFontOfSize:20];
    [self.view addSubview: self.titleDescription];
}

-(void) formatHeaderAndDescriptionToMedia{
    CGFloat height = self.videoPlayer ? self.playerLayer.frame.size.height : self.imageView.frame.size.height;
    height = height - 10;
    
    self.bigTitle.frame = CGRectMake(0, height, self.view.frame.size.width, 100);
    
    self.titleDescription.frame = CGRectMake(self.view.frame.size.width*0.1, height + (self.bigTitle.frame.size.height /1.35), self.view.frame.size.width*0.8, 100);
    [self.titleDescription sizeToFit];
    
    // Centering after adjusting size
    CGRect centerDescriptionFrame = self.titleDescription.frame;
    centerDescriptionFrame = CGRectMake(centerDescriptionFrame.origin.x, centerDescriptionFrame.origin.y, self.view.frame.size.width*0.8, centerDescriptionFrame.size.height);
    self.titleDescription.frame = centerDescriptionFrame;
}

-(void) registerForSettings{
    self.bigTitle.text = self.source[@"title"];
    self.titleDescription.text = self.source[@"description"];
    
    [self.nextButton setTitle: self.source[@"primaryLabel"] forState:UIControlStateNormal];
    [self.otherButton setTitle: self.source[@"secondaryLabel"] forState:UIControlStateNormal];
    
    [self setupMediaWithPathToFile:self.source[@"mediaPath"]];
    
    self.key = self.source[@"prefKey"];
    
    if(self.source[@"disableBack"]){
        self.backButton.hidden = YES;
    }
}

-(void) setupMediaWithPathToFile:(NSString *) pathToFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathToFile]){
        NSString *mediaPath = pathToFile;
        UIImage *image = [UIImage imageNamed:mediaPath];
        if (image) {
            self.imageView.image = [UIImage imageWithContentsOfFile:mediaPath];
            if(self.style == ASTSetupStyleHeaderBasic || self.style == ASTSetupStyleHeaderTwoButtons){
                [self formatImageViewStyleHeader];
            }
            self.playerLayer.hidden = YES;
        } else {
            self.videoPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:mediaPath]];
            if(self.style == ASTSetupStyleHeaderBasic || self.style == ASTSetupStyleHeaderTwoButtons){
                [self formatVideoPlayerStyleHeader];
            }
            self.playerLayer.player = self.videoPlayer;
            self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.videoPlayer currentItem]];
            self.imageView.hidden = YES;
        }
    }
}
-(void) nextButtonPressed{
    if(delegateRespondsTo.changePage){
        [self.delegate changePage: UIPageViewControllerNavigationDirectionForward];
    }
    NSString *key = self.source[@"key"];
    if(key){
        [prefs setObject:@(YES) forKey:key];
    }
}
-(void) backButtonPressed{
    if(delegateRespondsTo.changePage){
        [self.delegate changePage: UIPageViewControllerNavigationDirectionReverse];
    }
    NSString *key = self.source[@"key"];
    if(key){
        [prefs setObject:@(NO) forKey:key];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
@end
