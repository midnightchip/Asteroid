#import "HighlightButton.h"

@interface HighlightButton ()
@end

@implementation HighlightButton{
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.alpha = 0.8;
    }
    else {
        self.alpha = 1.0;
    }
}
@end
