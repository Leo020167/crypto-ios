//
//  MsgNotificationController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 1/18/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "MsgNotificationController.h"

@interface MsgNotificationController ()

@property (retain, nonatomic) IBOutlet UILabel *pushLabel;
@property (retain, nonatomic) IBOutlet UISwitch *noiceSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *vibrationSwitch;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation MsgNotificationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BOOL enabled;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        enabled =  (types & UIUserNotificationTypeAlert);
        
    }else if ([[UIApplication sharedApplication] respondsToSelector:@selector(enabledRemoteNotificationTypes)]) {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        enabled =  (types & UIRemoteNotificationTypeAlert);
        
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication]enabledRemoteNotificationTypes];
        int typeBadge = (type & UIRemoteNotificationTypeBadge);
        int typeSound = (type & UIRemoteNotificationTypeSound);
        int typeAlert = (type & UIRemoteNotificationTypeAlert);
        enabled =  !typeBadge || !typeSound || !typeAlert;
    }
#pragma clang diagnostic pop
    
    _pushLabel.text = enabled?NSLocalizedStringForKey(@"已开启"):NSLocalizedStringForKey(@"已关闭");
    
    MsgNotification* msg = [MsgNotification shareNotify];
    _noiceSwitch.on = msg.noice;
    _vibrationSwitch.on = msg.vibration;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _scrollView.contentSize = CGSizeMake(phoneRectScreen.size.width, phoneRectScreen.size.height - 60);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}
- (IBAction)noiceValueChanged:(id)sender {
    
    UISwitch* sch = (UISwitch*)sender;
    
    MsgNotification* msg = [MsgNotification shareNotify];
    msg.noice = sch.on;
}
- (IBAction)vibrationValueChanged:(id)sender {
    
    UISwitch* sch = (UISwitch*)sender;
    
    MsgNotification* msg = [MsgNotification shareNotify];
    msg.vibration = sch.on;
}

- (void)dealloc {
    [_pushLabel release];
    [_noiceSwitch release];
    [_vibrationSwitch release];
    [_scrollView release];
    [super dealloc];
}
@end


@implementation MsgNotification
static MsgNotification *notify;

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

+ (MsgNotification *)shareNotify{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!notify)  notify = [[MsgNotification alloc] init];
    });
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    if (![notify jsonHasKey:@"MsgNotification-noice" json:userInfo.dictionaryRepresentation]) {
        notify.noice = NO;
    }
    if (![notify jsonHasKey:@"MsgNotification-vibration" json:userInfo.dictionaryRepresentation]) {
        notify.vibration = YES;
    }
    
    notify.noice = [[userInfo objectForKey:@"MsgNotification-noice"] boolValue];
    notify.vibration = [[userInfo objectForKey:@"MsgNotification-vibration"] boolValue];
    
    return notify;
}

- (void)setNoice:(BOOL)noice{
    _noice = noice;
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setObject:[NSString stringWithFormat:@"%d",_noice] forKey:@"MsgNotification-noice"];
    [userInfo synchronize];
}

- (void)setVibration:(BOOL)vibration{
    _vibration = vibration;
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setObject:[NSString stringWithFormat:@"%d",_vibration] forKey:@"MsgNotification-vibration"];
    [userInfo synchronize];
}

- (void)dealloc {
    [super dealloc];
}

@end
