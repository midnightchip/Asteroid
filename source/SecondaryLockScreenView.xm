/*#import <CSWeather/CSWeatherInformationProvider.h>
#import "WeatherHeaders.h"
#import "AWeatherModel.h"

@interface SBDashBoardMainPageView : UIView
@property (nonatomic, retain) UIView *holderView;
@property (nonatomic, retain) UIImageView *cleanLogo;
@property (nonatomic, retain) UIView *cleanView;
@property (nonatomic, retain) UILabel *cleanCurrent;
@property (nonatomic, retain) UILabel *cleanTemp;
@property (nonatomic, retain) UILabel *cleanHi;
@property (nonatomic, retain) UILabel *cleanLow;
@end 

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *holderView;
%property (nonatomic, retain) UIView *cleanView;
%property (nonatomic, retain) UIImageView *cleanLogo;
%property (nonatomic, retain) UILabel *cleanCurrent;
%property (nonatomic, retain) UILabel *cleanTemp;
%property (nonatomic, retain) UILabel *cleanHi;
%property (nonatomic, retain) UILabel *cleanLow;

- (void)layoutSubviews {
    %orig;
    if(!self.holderView){
        self.holderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.holderView setUserInteractionEnabled:YES];
        [self addSubview:self.holderView];
        
    }
    
    if(!self.cleanView){
        self.cleanView=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/1.2, self.frame.size.width/2, self.frame.size.height/6)];
        [self.cleanView setUserInteractionEnabled:NO];
        self.cleanView.backgroundColor = [UIColor clearColor];
        
        
        self.cleanCurrent = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
        [self.cleanCurrent setCenter:CGPointMake(self.cleanView.frame.size.width/2, self.cleanView.frame.size.height/6)];
        
        
        self.cleanTemp = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
        [self.cleanTemp setCenter:CGPointMake(self.cleanView.frame.size.width/2, self.cleanView.frame.size.height/4)];
        
        self.cleanHi = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
        [self.cleanHi setCenter:CGPointMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height/2)];
        
        self.cleanLow = [[UILabel alloc] initWithFrame:CGRectMake(self.cleanView.frame.size.width, self.cleanView.frame.size.height, self.cleanView.frame.size.width, self.cleanView.frame.size.height/3)];
        [self.cleanLow setCenter:CGPointMake(self.cleanView.frame.size.width/4, self.cleanView.frame.size.height/2)];
        City *city = ([[%c(WeatherPreferences) sharedPreferences] cityFromPreferencesDictionary:[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]]);
        
        if(city){
            [[CSWeatherInformationProvider sharedProvider] updatedWeatherWithCompletion:^(NSDictionary *weather) {
                //Prepend weather icon to current condition string
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = weather[@"kCurrentConditionImage"];
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                NSMutableAttributedString *currentInfo= [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
                NSAttributedString *weatherInfo = [[NSMutableAttributedString alloc] initWithString:weather[@"kCurrentConditionString"]];
                [currentInfo appendAttributedString: weatherInfo];
                self.cleanCurrent.attributedText = currentInfo;
                //Set current temp
                self.cleanCurrent.text = weather[@"kCurrentTemperatureForLocale"];
                //Current Low
                NSString *downArrow = @"↓";
                self.cleanLow.text = [downArrow stringByAppendingString:weather[@"kCurrentTemperatureForLocale"]];
                //Current High
                NSString *upArrow = @"↑";
                self.cleanHi.text = [upArrow stringByAppendingString:weather[@"kCurrentTemperatureForLocale"]];
            }];
            
            [self.cleanView addSubview: self.cleanCurrent];
            [self.cleanView addSubview: self.cleanHi];
            [self.cleanView addSubview: self.cleanTemp];
            [self.cleanView addSubview: self.cleanLow];
            [self.holderView addSubview: self.cleanView];
        }
    }
}
%end 



// Experimental---------------------------------------
/*
@interface SBPagedScrollView : UIView
@property (nonatomic,copy) NSArray * pageViews;
@end

@interface SBDashBoardMainPageContentViewController : UIViewController

@end

@interface SBDashBoardView : UIView
@end

@interface SBDashBoardPageViewController

@end

@interface SBDashBoardViewController : UIViewController
@property (setter=_setPageViewControllers:,nonatomic,copy) NSArray * pageViewControllers;
@end
// THis one actually sort of woeks except causes crash when going to camera

%hook SBPagedScrollView
-(void) setPageViews:(id) arg1{
    NSLog(@"lock_TWEAK | The arg: %@", arg1[0]);
    NSArray *pageViews = arg1;
    //if(pageViews){
        if(pageViews.count < 4){
            
            SBDashBoardView *view = [[%c(SBDashBoardView) alloc] initWithFrame:self.frame];
            NSArray *newPages = @[pageViews[0], pageViews[1], view, pageViews[2]];
            %orig(newPages);
        } //else %orig;
    //} else %orig;
    
    
}
%end


// This crashes stuff
//SBDashBoardMainPageContentViewController *viewCont = [[%c(SBDashBoardMainPageContentViewController) alloc] init];
/*
@interface SBDashBoardWeatherPageContentViewController : SBDashBoardPageViewController {
    
}
@end
@implementation
-(instancetype) init{
    if(self = [super init]){
    }
    return self;
}

@end

%hook SBDashBoardViewController
-(NSUInteger) _indexOfCameraPage{
    return 3;
}
-(id) pageViewControllerAtIndex:(NSUInteger)arg1{
    if((int)arg1 == 3){
        return self.pageViewControllers[2];
    }
    else return %orig;
}

-(void) _setPageViewControllers:(id) arg1{
    NSLog(@"lock_TWEAK | The arg: %@", arg1[0]);
    NSArray *pageViews = arg1;
    //if(pageViews){
    if(pageViews.count < 4){
        viewCont.view.frame = self.view.frame;
        NSArray *newPages = @[pageViews[0], pageViews[1], viewCont, pageViews[2]];
        %orig(newPages);
    } else %orig;
    //} else %orig;
    
    
}

-(void) _setAllowedPageViewControllers:(id) arg1{
    NSLog(@"lock_TWEAK | The arg: %@", arg1[0]);
    NSArray *pageViews = arg1;
    //if(pageViews){
    if(pageViews.count < 4){
        viewCont.view.frame = self.view.frame;
        NSArray *newPages = @[pageViews[0], pageViews[1], pageViews[2], viewCont];
        %orig(newPages);
    } else %orig;
    //} else %orig;
}

%end


%hook SBDashBoardMainPageContentViewController
-(id)initWithNibName:(id)arg1 bundle:(id)arg2 {
    if((self = %orig)){
        NSLog(@"lock_TWEAK | %@, %@", arg1, arg2);
    }
    return self;
}
%end
*/
