typedef NS_ENUM(NSUInteger, ASTSetupPageStyle) {
    ASTSetupStyleBasic = 0,
    ASTSetupStyleTwoButtons = 1,
    ASTSetupStyleHeaderBasic = 2,
    ASTSetupStyleHeaderTwoButtons = 3
};

@interface ASTSetup : NSObject
- (instancetype)initWithPages:(NSArray *)pages;
@end
