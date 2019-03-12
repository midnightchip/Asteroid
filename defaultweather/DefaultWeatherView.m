#import "DefaultWeatherView.h"

@interface DefaultWeatherView()
@property (nonatomic, retain) UISwitch *defaultWeatherSwitch;
@property (nonatomic, retain) UILabel *weatherSwitchLabel;
@property (nonatomic, assign) BOOL selectedCity;

-(void) sendRBSData;
@end


@implementation DefaultWeatherView
- (instancetype) initWithFrame:(CGRect) frame index:(NSUInteger) aIndex{
    if(self = [super initWithFrame:frame]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchChangedNotification:) name:@"astDefaultSwitchChanged" object:nil];
        
        self.index = aIndex;
        self.defaultWeatherSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0,0, 55, 40)];
        [self.defaultWeatherSwitch addTarget: self action: @selector(switchFlipped:) forControlEvents: UIControlEventValueChanged];
        [self addSubview:self.defaultWeatherSwitch];
        
        self.weatherSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(-100, 24, 150, 45)];
        self.weatherSwitchLabel.textAlignment = NSTextAlignmentRight;
        self.weatherSwitchLabel.text = [NSString stringWithFormat:@"Default City: %i", (int)self.index + 1];
        self.weatherSwitchLabel.numberOfLines = 0;
        self.weatherSwitchLabel.textColor = [UIColor whiteColor];
        self.weatherSwitchLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.weatherSwitchLabel];
        
        
        if(self.index == (NSUInteger)[prefs intForKey:@"astDefaultIndex"]){
            self.defaultWeatherSwitch.on = YES;
        }
    }
    return self;
}

-(void) switchFlipped: (UISwitch *) aSwitch {
    if(aSwitch.isOn == YES){
        self.selectedCity = YES;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"astDefaultSwitchChanged"
         object:nil];
        [prefs setObject:@(self.index) forKey:@"astDefaultIndex"];
        [prefs save];
        [self sendRBSData];
    } else {
        aSwitch.on = YES;
    }
    
}

-(void) sendRBSData{
    CPDistributedMessagingCenter *messagingCenter;
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.midnightchips.AsteroidServer"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
    
    NSMutableDictionary *sendIndex = [[NSMutableDictionary alloc]init];
    sendIndex[@"index"] = @([prefs intForKey:@"astDefaultIndex"]);
    [messagingCenter sendMessageName:@"returnCityIndex" userInfo:sendIndex];
}

-(void) switchChangedNotification: (NSNotification *) notification{
    if(self.defaultWeatherSwitch.on){
        if(self.selectedCity){
            self.selectedCity = NO;
        } else {
            [self.defaultWeatherSwitch setOn: NO animated: YES];
        }
    }
}
@end
