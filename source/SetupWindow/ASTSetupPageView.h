#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "HighlightButton.h"
#import "ASTSetupPageStyles.h"
#import "LocalizedSetupStrings.h"

typedef void(^ButtonBlock)();

@interface ASTSetupPageView : UIView
@property (nonatomic, retain) UILabel *bigTitle;
@property (nonatomic, retain) UILabel *titleDescription;
@property (nonatomic, retain) AVPlayer *videoPlayer;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) HighlightButton *otherButton;
@property (nonatomic, retain) HighlightButton *nextButton;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) HighlightButton *backButton;
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic, assign) ASTSetupPageStyle style;

- (instancetype)initWithFrame:(CGRect)frame style:(ASTSetupPageStyle)setupStyle;

-(void) setupMediaWithPathToFile:(NSString *) pathToFile;
-(void) setHeaderText:(NSString *) headerText andDescription:(NSString *) desText;
-(void) setNextButtonText:(NSString *) nextText andOtherButton:(NSString *) otherText;

-(void) setNextButtonTarget: (id) object withTransition:(SEL) selector overridePage:(ASTSetupPageView *) page completion:(ButtonBlock)block;
-(void) setOtherButtonTarget: (id) object withTransition:(SEL) selector overridePage:(ASTSetupPageView *) page completion:(ButtonBlock)block;
-(void) setBackButtonTarget: (id) object withTransition:(SEL) selector overridePage:(ASTSetupPageView *) page completion:(ButtonBlock)block;
@end
