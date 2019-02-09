#import "ASTComponentView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface ASTComponentView ()

@end

@interface SBIconView : UIView
+(id)_jitterXTranslationAnimation;
+(id)_jitterYTranslationAnimation;
+(id)_jitterRotationAnimation;
@end

@implementation ASTComponentView{

}
@synthesize editing;

- (instancetype) initWithFrame:(CGRect) frame{
    if(self = [super initWithFrame:frame]){
        self.frame = frame;
        self.layer.cornerRadius = 13;
    }
    return self;
}

-(void) setEditing:(BOOL) edit{
    editing = edit;
    [self handleEditChange];
}

-(void) handleEditChange{
    if(self.isEditing){
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];}
                         completion:^(BOOL finished){
                             [self addJitterAnimations];
                         }];
    } else{
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{self.backgroundColor = [UIColor clearColor];}
                         completion:^(BOOL finished){
                             [self removeJitterAnimations];
                         }];
    }
}

-(void) addJitterAnimations{
    CABasicAnimation *jitterX = [self _jitterXTranslationAnimation];
    CABasicAnimation *jitterY = [self _jitterYTranslationAnimation];
    CABasicAnimation *jitterRotation = [self _jitterRotationAnimation];
    
    [self.layer addAnimation:jitterX forKey:@"astAnimateJitterX"];
    [self.layer addAnimation:jitterY forKey:@"astAnimateJitterY"];
    [self.layer addAnimation:jitterRotation forKey:@"astAnimateJitterRotation"];
}

-(void) removeJitterAnimations{
    [self.layer removeAllAnimations];
}

-(CABasicAnimation *) _jitterXTranslationAnimation{
    return [objc_getClass("SBIconView") _jitterXTranslationAnimation];
}
-(CABasicAnimation *) _jitterYTranslationAnimation{
    return [objc_getClass("SBIconView") _jitterYTranslationAnimation];
}
-(CABasicAnimation *)_jitterRotationAnimation{
    return [objc_getClass("SBIconView") _jitterRotationAnimation];
}
@end
