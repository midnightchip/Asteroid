#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "HighlightButton.h"
#import "ASTSetupPageStyles.h"
#import "LocalizedSetupStrings.h"

#import "ASTSourceDelegate.h"
#import "../source/LWPProvider.h"

@interface ASTChildViewController : UIViewController
@property (nonatomic, retain) UILabel *bigTitle;
@property (nonatomic, retain) UILabel *titleDescription;
@property (nonatomic, retain) AVPlayer *videoPlayer;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) HighlightButton *otherButton;
@property (nonatomic, retain) HighlightButton *nextButton;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) HighlightButton *backButton;
@property (nonatomic, assign) ASTSetupPageStyle style;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) id <ASTSourceDelegate> delegate;
@property (nonatomic, retain) NSDictionary *source;
@property (nonatomic, retain) NSString *key;

- (instancetype)initWithSource:(NSDictionary *) source;
@end
