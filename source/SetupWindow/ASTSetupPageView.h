#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "HighlightButton.h"

@interface ASTSetupPageView : UIView
@property (nonatomic, retain) UILabel *bigTitle;
@property (nonatomic, retain) UILabel *titleDescription;
@property (nonatomic, retain) AVPlayer *videoPlayer;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) HighlightButton *nextButton;
@property (nonatomic, retain) UIButton *skipButton;

-(void) setupVideoWithPathToFile:(NSString *) pathToFile;
-(void) setNextButtonTarget: (id) object withAction:(SEL) selector;
@end


// back button and nav bar properties, might be controller might be page
