#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "HighlightButton.h"

@interface ASTSetupPageView : UIView
@property (nonatomic, retain) UILabel *bigTitle;
@property (nonatomic, retain) UILabel *titleDescription;
@property (nonatomic, retain) AVPlayer *videoPlayer;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) HighlightButton *nextButton;
@property (nonatomic) NSUInteger pageIndex;

-(void) setupVideoWithPathToFile:(NSString *) pathToFile;
-(void) setHeaderText:(NSString *) headerText andDescription: (NSString *) desText;
-(void) setNextButtonTarget: (id) object withAction:(SEL) selector;
@end


// back button and nav bar properties, might be controller might be page
