//
//  HomeViewController.m
//  TJRtaojinroad
//
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "HomeViewController.h"
#import "NewbieHelpView.h"
#import "TJRBaseParserJson.h"
#import "CommonUtil.h"
#import "PlacardSQL.h"
#import "HomeNoticeAlertView.h"
#import <UserNotifications/UserNotifications.h>

#import "CircleSocket.h"
#import "CircleSQL.h"
#import "CircleEntity.h"
#import "CircleBaseDataEntity.h"
#import "CircleSettingRemindEntity.h"
#import "UIButton+NewNum.h"
#import "NetWorkManage+Circle.h"
#import "NetWorkManage+User.h"
#import "NetWorkManage+Home.h"
#import "NetWorkManage+Security.h"
#import "NetWorkManage+Share.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "UserInfoSQL.h"

#define alertTagUpdate        767
#define NewDotBaseTag       2928

@interface HomeViewController ()<UITabBarControllerDelegate> {
    
    BOOL bReqFinished;
    HomeNoticeAlertView *noticeAlertView;
    BOOL bDidload;
    BOOL bAPPUpdate;
}


@end

@implementation HomeViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatMsgData:) name:SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatMsgData:) name:SOCKET_NOTIFACATION_KEY_CIRCLE object:nil];
//    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
//    if (language) {
//        [NSBundle setLanguage:language];
//    }else{
//        [NSBundle setLanguage:@"zh-Hans"];
//    }
    //[NSBundle setLanguage:@"zh-HK"];
    /** 创建tab子类对象*/
    [self addTabBarChildViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (TJRIsIntroduction) {
        //欢迎页标记
        NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
        [userInfo setObject:@"YES" forKey:[NSString stringWithFormat:@"introduction_version_%@",TJRAppVersion]];
        [userInfo synchronize];
    }
    
    // Let the device know we want to receive push notifications,push功能(应用开启时需每次运行，否则获取不了Token)
    if (CURRENT_DEVICE_VERSION>=10) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }];
    } else if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    /** upload token*/
    if ([self getTJRAppDelegate].pushToken.length > 0) {
        [self uploadPushToken];
    }
    
    noticeAlertView = [[HomeNoticeAlertView alloc]init];
    
    bReqFinished = YES;
    bAPPUpdate = YES;
    bDidload = YES;
    [self getTJRAppInfo];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HomeRefreshNewDotKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    NSNumber *number = [self getValueFromModelDictionary:@"HomeSelectDic" forKey:@"SelectIndex"];
    if (number) {
        NSUInteger index = number.integerValue;
        if (index < self.viewControllers.count) {
            self.selectedIndex = index;
        }
    }
    [self removeParamFromModelDictionary:@"HomeSelectDic" forKey:@"SelectIndex"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId) && TTIsStringWithAnyText(ROOTCONTROLLER_USER.token) && [[CircleSocket shareCircleSocket] isClosed]) {
        //如果圈子的socket关闭了,就重连
        [[CircleSocket shareCircleSocket] reconnect];
    }
    
    if (bDidload) {
        bDidload = NO;
    }else{
        [self getTJRAppInfo];
    }
    
    //圈子消息以通知形式
    [self reloadChatMsgData:nil];
    
    if ([self getValueFromModelDictionary:LoginDict forKey:@"WelcomeADClicked"]) {
        NSString *pview = [self getValueFromModelDictionary:LoginDict forKey:@"WelcomeADPview"];
        NSString *params = [self getValueFromModelDictionary:LoginDict forKey:@"WelcomeADParams"];
        if (TTIsStringWithAnyText(pview)) {
            if (TTIsStringWithAnyText(params)) {
                [self putValueToParamDictionary:MSG_PARAMS value:params forKey:MSG_PARAMS];
            }
            [self pageToOrBackWithName:pview animated:NO];
        }
        [self removeParamFromModelDictionary:LoginDict forKey:@"WelcomeADClicked"];
        [self removeParamFromModelDictionary:LoginDict forKey:@"WelcomeADPview"];
        [self removeParamFromModelDictionary:LoginDict forKey:@"WelcomeADParams"];
    }
}

- (void)applicationDidBecomeActive
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - 创建tab bar view controller
- (void)addTabBarChildViewController
{
    NSArray *array = @[
                        @{TabClassKey:@"HomeMainController",TabClassTitle:NSLocalizedStringForKey(@"首页"),TabClassImageKey:@"tabbar_icon3_normal",TabClassSelectImageKey:@"tabbar_icon3_selected"},
                       @{TabClassKey:@"TYQuotationsBaseViewController",TabClassTitle:NSLocalizedStringForKey(@"行情"),TabClassImageKey:@"tabbar_icon4_normal",TabClassSelectImageKey:@"tabbar_icon4_selected"},
                       @{TabClassKey:@"TYAccountBaseViewController",TabClassTitle:NSLocalizedStringForKey(@"账户"),TabClassImageKey:@"tabbar_icon1_normal",TabClassSelectImageKey:@"tabbar_icon1_selected"},
                       @{TabClassKey:@"TYMineCommunityViewController",TabClassTitle:NSLocalizedStringForKey(@"社区"),TabClassImageKey:@"tabbar_icon2_normal",TabClassSelectImageKey:@"tabbar_icon2_selected"},
                       @{TabClassKey:@"HomeMineViewController",TabClassTitle:NSLocalizedStringForKey(@"我的"),TabClassImageKey:@"tabbar_icon5_normal",TabClassSelectImageKey:@"tabbar_icon5_selected"},
                      ];
    
    NSMutableArray* vcs = [[[NSMutableArray alloc]init]autorelease];
    for(int i = 0; i < [array count]; i++){
        NSDictionary *tabDic = array[i];
        UIViewController *viewController = [[[NSClassFromString([tabDic objectForKey:TabClassKey]) alloc] init] autorelease];
        viewController.tabBarItem.title = tabDic[TabClassTitle];
        [viewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBA(61, 58, 80, 0.3)} forState:UIControlStateNormal];
        [viewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBA(61, 58, 80, 1.0)} forState:UIControlStateSelected];
        viewController.tabBarItem.image = [UIImage imageNamed:tabDic[TabClassImageKey]];
        viewController.tabBarItem.selectedImage = [[UIImage imageNamed:tabDic[TabClassSelectImageKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if(@available(iOS 10.0,*)){
            viewController.tabBarItem.badgeColor = RGBA(251, 135, 90, 0.6);
            NSDictionary *dict = @{
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSFontAttributeName : [UIFont systemFontOfSize:14]
                                   };
            [viewController.tabBarItem setBadgeTextAttributes:dict forState:UIControlStateNormal];
        }
        
        [vcs addObject:viewController];
    }
    [self setViewControllers:vcs];
    
    UIView *tabBarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tabBar.bounds.size.width, TAB_BAR_HEIGHT)] autorelease];
    tabBarBackgroundView.backgroundColor = [UIColor whiteColor];
    [[UITabBar appearance] insertSubview:tabBarBackgroundView atIndex:0];
    
    self.delegate = self;
    //如果未登陆，则跳转到指定页面，这个逻辑需要根据具体情况变化
    if(!checkIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){
        [self setSelectedIndex:0];
    }
}

#pragma mark - tabBarController delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if(ROOTCONTROLLER_USER.userId){
        return YES;
    }else{
        //未登录状态的，点击这些页面都需要提示登陆
        if([viewController isKindOfClass:NSClassFromString(@"HomeAccountController")] || [viewController isKindOfClass:NSClassFromString(@"HomeFollowUserController")] || [viewController isKindOfClass:NSClassFromString(@"HomeMineViewController")] || [viewController isKindOfClass:NSClassFromString(@"TYMineCommunityViewController")] || [viewController isKindOfClass:NSClassFromString(@"TYAccountBaseViewController")]){
            [ROOTCONTROLLER gotoLogin];
            return NO;
        }
        return YES;
    }
}

#pragma mark -上传PushToken
- (void)uploadPushToken {
    if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId)) {
        [[NetWorkManage shareSingleNetWork] reqPushToken:self userId:ROOTCONTROLLER_USER.userId token:[self getTJRAppDelegate].pushToken finishedCallback:@selector(requestPushDataFinished:) failedCallback:@selector(requestPushDataFalid:)];
    }
}

- (void)requestPushDataFinished:(NSDictionary *)json
{
    TJRBaseParserJson *parser = [TJRBaseParserJson new];
    BOOL isok = [parser parseBaseIsOk:json];
    
    if (isok) {
        NSLog(@"上传token成功");
    }
    RELEASE(parser);
}

- (void)requestPushDataFalid:(NSDictionary *)json
{
    TJRBaseParserJson *parser = [TJRBaseParserJson new];
    BOOL isok = [parser parseBaseIsOk:json];
    
    if (!isok) {
        NSLog(@"上传token失败");
    }
    RELEASE(parser);
}

- (void)getTJRAppInfo
{
    PlacardSQL *sql = [PlacardSQL new];
    
    NSString *placardTime = [sql selectPlacardSQl].placardTime.length > 0 ?[sql selectPlacardSQl].placardTime : @"0";
    
    [[NetWorkManage shareSingleNetWork] reqHomeGet:self noticeTime:placardTime finishedCallback:@selector(TJRAppInfoFinish:) failedCallback:nil];
    RELEASE(sql);
}

- (void)TJRAppInfoFinish:(NSDictionary *)result
{
    TJRAppInfoParser *appParser = [[[TJRAppInfoParser alloc] init]autorelease];
    
    NSDictionary *dic = [result objectForKey:@"data"];
   
    HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    if (dic && (dic.count > 0)) {
        self.placard = [appParser parserPlacard:[dic objectForKey:@"notice"]];
        self.appInfo = [appParser parser:[dic objectForKey:@"version"]];
        //获取风险率提示并保存进本地
        NSString *riskRateDesc = [appParser stringParser:dic name:@"riskRateDesc"];
        NSString *localRiskRateDesc = [[NSUserDefaults standardUserDefaults] objectForKey:HomeRiskRateDescLocalKey];
        if(checkIsStringWithAnyText(localRiskRateDesc)){
            if(![localRiskRateDesc isEqualToString:riskRateDesc]){
                [[NSUserDefaults standardUserDefaults] setObject:riskRateDesc forKey:HomeRiskRateDescLocalKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:riskRateDesc forKey:HomeRiskRateDescLocalKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (!item) {
            item = [[[HomeNewNumEntity alloc] initWithJson:dic] autorelease];
            [[TJRCache shareTJRCache] putCacheValue:item forKey:HomeNewNumKey];
        } else {
            [item updataNewWithJson:dic];
        }
    }else if (!item) {
        item = [[[HomeNewNumEntity alloc] init] autorelease];
        [[TJRCache shareTJRCache] putCacheValue:item forKey:HomeNewNumKey];
    }
    
    [self reloadChatMsgData:nil];
//    [item postNotification];
    
    [self getRootController].isShowFastBuy = [appParser boolParser:dic name:@"isShowFastBuy"];
    [self getRootController].isShowDefault = [appParser boolParser:dic name:@"isShowDefault"];

    if (bAPPUpdate) {
        [self showUpdateAlert];
        bAPPUpdate = NO;
    }
     
    //记录上次状态，避免多次初始化
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self getRootController].isShowDefault] forKey:@"isShowDefault"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self getRootController].isShowFastBuy] forKey:@"isShowFastBuy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)showUpdateAlert
{
    _appInfo.isShowFirst = YES;
    
    if (_appInfo && _appInfo.versionNum > 0) {
        
        UIAlertView *alertView = nil;
        if (_appInfo.isForce) {
            // 强制更新
            alertView = [[UIAlertView alloc] initWithTitle:@"更新提示" message:_appInfo.bugMsg delegate:self cancelButtonTitle:nil otherButtonTitles:@"升级", nil];
        } else {
            alertView = [[UIAlertView alloc] initWithTitle:@"更新提示" message:_appInfo.bugMsg delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:@"升级", nil];
        }
        alertView.tag = alertTagUpdate;
        [alertView show];
        [alertView release];
        
    } else if (_placard && TTIsStringWithAnyText(_placard.content)) {
        
        PlacardSQL *sql = [[[PlacardSQL alloc]init]autorelease];
        NSString *placardTime = [sql selectPlacardSQl].placardTime;
        if (![placardTime isEqualToString:_placard.placardTime]) {
            [noticeAlertView show:self.selectedViewController.view title:_placard.title content:_placard.content updateTime:_placard.placardTime];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
            
        case alertTagUpdate:
        {
            if (buttonIndex == alertView.cancelButtonIndex) {
                if (_placard && TTIsStringWithAnyText(_placard.content)) {
                    PlacardSQL *sql = [[[PlacardSQL alloc]init]autorelease];
                    NSString *placardTime = [sql selectPlacardSQl].placardTime;
                    if (![placardTime isEqualToString:_placard.placardTime]) {
                        [noticeAlertView show:self.selectedViewController.view title:_placard.title content:_placard.content updateTime:_placard.placardTime];
                    }
                }
            } else if (buttonIndex == alertView.firstOtherButtonIndex) {
                NSURL *url = nil;
                
                url = [NSURL URLWithString:_appInfo.downloadUrl];
                
                if (url) {
                    [[UIApplication sharedApplication] openURL:url];
                    
                    if (_appInfo.isForce) [self getTJRAppInfo];
                }
            }
            break;
        }
            
        default:
            break;
    }
}

//通过通知设置
- (void)refreshHomeNewDot
{
    HomeNewNumEntity* homeNewEntity = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    
    NSUInteger number = 0;
    BOOL isShowNum = YES;
    
    number = homeNewEntity.circleNewCount;
    [self showDotWithIndex:0 count:number isShowNum:isShowNum];
    
    number = homeNewEntity.chatCount + homeNewEntity.msgCount;
    [self showDotWithIndex:3 count:number isShowNum:isShowNum];
    
}

- (void)reloadChatMsgData:(NSNotification *)notification
{
    
    HomeNewNumEntity* homeNewEntity = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    if (!homeNewEntity) {
        homeNewEntity = [[HomeNewNumEntity alloc] init];
        [[TJRCache shareTJRCache] putCacheValue:homeNewEntity forKey:HomeNewNumKey];
    }
    
    NSUInteger number = 0;
    BOOL isShowNum = YES;
    
    //私聊消息
    NSInteger pChatCount = 0;
    for (NSString *key in [CircleSocket shareCircleSocket].privateDetail.allKeys) {
        PrivateChatDataEntity *item = [[CircleSocket shareCircleSocket].privateDetail objectForKey:key];
        pChatCount = pChatCount + item.chatNews;
    }
    
    homeNewEntity.chatCount = pChatCount;
    
    number = homeNewEntity.chatCount + homeNewEntity.msgCount;
    [self showDotWithIndex:3 count:number isShowNum:isShowNum];
    
    //圈子消息
    NSInteger newNum = 0;
    for (CircleBaseDataEntity *d in [CircleSocket shareCircleSocket].circleDetail.objectEnumerator) {
        if (d) {
            NSUInteger num = d.chatNews + d.articleNews + d.applyNews + d.showNews;
            CircleSettingRemindEntity *sEntity = [CircleSQL queryCircleSettingWithCircleId:[NSString stringWithFormat:@"%@", d.circleId]];
            if (!sEntity.chatRemind) {
                newNum = newNum + num;
            }
        }
    }
    homeNewEntity.circleNewCount = newNum;

    number = homeNewEntity.circleNewCount;
    [self showDotWithIndex:0 count:number isShowNum:isShowNum];
}

- (void)showDotWithIndex:(NSUInteger)index count:(NSUInteger)count isShowNum:(BOOL)isShowNum
{
//    if (index < self.tabBar.items.count) {
//        NSUInteger tag = NewDotBaseTag + index;
//        UIButton *btnDot = (UIButton *)[self.tabBar viewWithTag:tag];
//        if (!btnDot) {
//            btnDot = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDot.titleLabel.font = [UIFont systemFontOfSize:11];
//            CGRect frame = CGRectZero;
//            frame.origin.x = CGRectGetWidth(self.tabBar.frame) / 4 * index + CGRectGetWidth(self.tabBar.frame) / 8 + 5;
//            btnDot.userInteractionEnabled = NO;
//            btnDot.frame = frame;
//            btnDot.tag = tag;
//            btnDot.hidden = YES;
//            [self.tabBar addSubview:btnDot];
//        }
//        NSString *imageName = nil;
//        btnDot.hidden = count <= 0;
//        if (count > 0) {
//            CGRect frame = btnDot.frame;
//            if (isShowNum) {
//                imageName = @"util_Icon_new_bg_red";
//                frame.origin.y = 3;
//                frame.size = CGSizeMake(17, 17);
//                btnDot.frame = frame;
//                [btnDot setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//                [btnDot showNewNum:count];
//            } else {
//                imageName = @"util_Icon_new_small_dot_red";
//                frame.size = CGSizeMake(10, 10);
//                frame.origin.y = 5;
//                [CommonUtil viewMasksToBounds:btnDot cornerRadius:5 borderColor:nil];
//                [btnDot setTitle:@"" forState:UIControlStateNormal];
//                [btnDot setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//                btnDot.frame = frame;
//            }
//        }
//    }
}


- (void)dealloc
{
    [[TJRCache shareTJRCache] removeCacheValueForKey:HomeNewNumKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RELEASE(_appInfo);
    RELEASE(_placard);

    [super dealloc];
}
@end

