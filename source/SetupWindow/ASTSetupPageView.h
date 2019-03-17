#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "HighlightButton.h"
#import "ASTSetupPageStyles.h"

@interface ASTSetupPageView : UIView
@property (nonatomic, retain) UILabel *bigTitle;
@property (nonatomic, retain) UILabel *titleDescription;
@property (nonatomic, retain) AVPlayer *videoPlayer;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) HighlightButton *nextButton;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic) NSUInteger pageIndex;

- (instancetype)initWithFrame:(CGRect)frame style:(ASTSetupPageStyle)setupStyle;
-(void) setupVideoWithPathToFile:(NSString *) pathToFile;
-(void) setHeaderText:(NSString *) headerText andDescription: (NSString *) desText;
-(void) setNextButtonTarget: (id) object withAction:(SEL) selector;
-(void) setBackButtonTarget: (id) object withAction:(SEL) selector;
@end


// back button and nav bar properties, might be controller might be page
