/*#import <CSWeather/CSWeatherInformationProvider.h>
#import "WeatherHeaders.h"
#import "AWeatherModel.h"

@interface SBDashBoardMainPageView : UIView
@property (nonatomic, retain) UIView *holderView;
@property (nonatomic, retain) UIImageView *cleanLogo;
@property (nonatomic, retain) WAWeatherPlatterViewController *cleanView;
@property (nonatomic, retain) UILabel *cleanCurrent;
@property (nonatomic, retain) UILabel *cleanTemp;
@property (nonatomic, retain) UILabel *cleanHi;
@property (nonatomic, retain) UILabel *cleanLow;
@end 

%hook SBDashBoardMainPageView
%property (nonatomic, retain) UIView *holderView;
%property (nonatomic, retain) WAWeatherPlatterViewController *cleanView;
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
        self.cleanView = [[%c(WAWeatherPlatterViewController) alloc] init]; // Temp to make sure its called once
        static AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
        [weatherModel updateWeatherDataWithCompletion:^{
            self.cleanView = [[%c(WAWeatherPlatterViewController) alloc] initWithLocation:weatherModel.city];
            
            // Setting text color white.
            
            NSLog(@"lock_TWEAK | %@", self.cleanView.hourlyBeltView.allSubviews[0]);
            
            ((UIView *)((NSArray *)self.cleanView.view.layer.sublayers)[0]).hidden = YES; // Visual Effect view to hidden
            self.cleanView.view.frame = CGRectMake(0, (self.frame.size.height / 2), self.frame.size.width/2, self.frame.size.height);
            self.cleanView.hourlyForecastViews = nil;
            self.cleanView.dividerLineView.hidden = TRUE;
            [self addSubview:self.cleanView.view];
        }];
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
