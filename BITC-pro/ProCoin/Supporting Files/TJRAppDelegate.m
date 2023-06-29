//
//  TJRAppDelegate.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-25.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//


#import "TJRAppDelegate.h"
#import "UncaughtExceptionHandler.h"
#import "TJRBaseViewController.h"
#import "HomeViewController.h"

#import "TJRBaseSocket.h"


#import "TJRCache.h"
#import "CircleEntity.h"
#import <UserNotifications/UserNotifications.h>
#import "CircleSocket.h"
#import "QuotationSocket.h"
#import <WXApiObject.h>
#import <WXApi.h>

NSString *const StatusBarClick = @"StatusBarClick";

@interface TJRAppDelegate () <UNUserNotificationCenterDelegate,WXApiDelegate>
{
}

@end

@implementation TJRAppDelegate
@synthesize navigation = _navigation;
@synthesize window = _window;
@synthesize rootController = _rootController;
@synthesize pushToken = _pushToken;

- (void)dealloc
{
    [_pushToken release];
    [_window release];
    [_navLandscape release];
    TT_RELEASE_SAFELY(_navigation);
    [super dealloc];
}
// 点击状态栏
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    if (location.y > 0 && location.y < 20) {
        [[NSNotificationCenter defaultCenter] postNotificationName:StatusBarClick object:nil];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [self getSystemIP];
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"kaobaochina.cn" forKey:@"ipInfo"];
    [[NSUserDefaults standardUserDefaults] setObject:@"twtwe.com" forKey:@"ipInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.window = [[[TJRWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _rootController = [[RootController alloc] init];
    _navigation = [[TJRRootNavigationController alloc] initWithRootViewController:_rootController];
    _navigation.navigationBarHidden = YES;
    self.window.rootViewController = _navigation;
    
    [self.window makeKeyAndVisible];
    if (@available(iOS 15.0, *)) {
         [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    
    
    if(CURRENT_DEVICE_VERSION>=10.0){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    
    
#ifdef DEBUG
    [[NSBundle bundleWithPath:@"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle"] load];
#else
    //启动腾讯mta数据统计
#endif
    
    [NSThread sleepForTimeInterval:2];
    //[self report];
    return YES;
}


- (void)getSystemIP{
    NSArray *ipList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IpList" ofType:@"plist"]];

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *plistPath = [path stringByAppendingPathComponent:@"IpList.plist"];
    NSArray *plistDataArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSLog(@"plistPath : %@", plistPath);
    if (plistDataArray.count == 0) {
        [ipList writeToFile:plistPath atomically:YES];
    }else{
        ipList = [NSArray arrayWithContentsOfFile:plistPath];
        if (ipList.count) {
            [[NSUserDefaults standardUserDefaults] setObject:ipList.firstObject forKey:@"ipInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [self getApiUrl:0 plistPath:plistPath ipList:ipList];
}

- (void)getApiUrl:(NSInteger)index plistPath:(NSString *)plistPath ipList:(NSArray *)ipList{
    
    if (index >= ipList.count) {
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.%@/procoin/home/checkServer.do", ipList[index]];
    [YYRequestUtility get:urlStr parameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            NSLog(@"设置成功%@", responseDict);
            NSArray * array = responseDict[@"data"];
            if (array.count) {
                [[NSUserDefaults standardUserDefaults] setObject:array.firstObject forKey:@"ipInfo"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [array writeToFile:plistPath atomically:YES];
        }else{
            NSInteger i = index;
            i = index + 1;
            [self getApiUrl:i plistPath:plistPath ipList:ipList];
        }
    } failure:^(NSError *error) {
        NSInteger i = index;
        i = index + 1;
        [self getApiUrl:i plistPath:plistPath ipList:ipList];
    }];
}

- (void)report {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *host = [[NSURL URLWithString:ApiBaseUrl] host];
    host = host ? host: ApiBaseUrl;
    NSDictionary *param = @{
                            @"appCode": @"Fwdetsc ", @"appName": infoDictionary[@"CFBundleDisplayName"],
                            @"appGateway": host, @"channel": @"iOS",
                            @"clientVersion": infoDictionary[@"CFBundleShortVersionString"],
                            @"clientDeviceId": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                            @"clientModel": [[UIDevice currentDevice] model],
                            @"reportType": @"startup"
    };
    NSDictionary *allP = @{@"data": param, @"service": @"licenceReport", @"requestNo": currentDateStr,
                           @"partnerId": @"23011918131600340030", @"version": @"1.0"
    };
    NSString *toSignStr = [NSString stringWithFormat:@"%@%@", allP.yy_modelToJSONString, @"4c8f89de2a90e68545b1a67167d64dd2"];

    NSString* sign =  [[CommonUtil getMD5: toSignStr] lowercaseString];
   
    NSDictionary *header = @{@"x-api-accessKey": @"23011918131600340030", @"x-api-signType": @"MD5", @"x-api-sign": sign};
    NSString *urlStr = @"http://190.92.245.81/gateway.do";
    [YYRequestUtility post:urlStr parameters: allP header: header progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            NSLog(@"~~~~~~~~~~~~~~~");
        }
    } failure:^(NSError *error) {
        NSLog(@"~~~~~~~~~~~~~~~");
    }];
}


//普通字符串转换为十六进制的。

+ (NSString *)hexStringFromString:(NSString *)string{
NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
Byte *bytes = (Byte *)[myD bytes];
//下面是Byte 转换为16进制。
NSString *hexStr=@"";
for(int i=0;i<[myD length];i++)

{
NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数

if([newHexStr length]==1)

hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];

else

hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
}
return hexStr;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // 将要进入后台的过渡过程(拉出通知中心等)
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if (_rootController) {
        _rootController.isBackgroud = YES;
        [_rootController sleepApplication];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // 注册push通知
    [application beginReceivingRemoteControlEvents];
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        [[CircleSocket shareCircleSocket] close];
        [[QuotationSocket shareQuotationSocket] quotationSocketClose];
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    _rootController.isBackgroud = NO;
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (_rootController) {
        _rootController.isBackgroud = NO;
        [_rootController wakeUpApplication];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *tokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    self.pushToken = [NSString stringWithFormat:@"%@", tokenStr];
    
    for (id object in [_navigation.viewControllers objectEnumerator]) {
        if ([object isKindOfClass:[HomeViewController class]]) {
            if (self.pushToken.length > 0) {
                [((HomeViewController *)object)uploadPushToken];
            }
            break;
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0) {
    
    NSLog(@"userInfo: %@", userInfo);
    if (userInfo) {
        [_rootController didReceiveRemoteNotification:userInfo];
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        // 更新显示的徽章个数
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        badge--;
        badge = badge >= 0 ? badge : 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification NS_AVAILABLE_IOS(4_0) {
    
    NSDictionary *userInfo = notification.userInfo;
    [self application:application didReceiveRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    return NO;
}


#pragma mark - 第三方登录SDK
// iOS9 以上用这个方法接收
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    if (!url) return NO;

    NSString *URLString = [url absoluteString];

    // 可视化埋点代码
        return YES;

    //处理safari 跳转回调
    if ([URLString hasPrefix:SafariPageToHeader]) {
        NSString *param = [URLString substringFromIndex:SafariPageToHeader.length];
        [self safariPageToTJRWithURL:param];
        return YES;
    }

    // 处理 微信回调
    if ([[[URLString componentsSeparatedByString:@":"] objectAtIndex:0] isEqualToString:WXAppId]) {
        return [WXApi handleOpenURL:url delegate:self];
    }

    return NO;
}
// iOS9 以下用这个方法接收
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    if (!url) return NO;

    NSString *URLString = [url absoluteString];

    // 可视化埋点代码
        return YES;

    //处理safari 跳转回调
    if ([URLString hasPrefix:SafariPageToHeader]) {
        NSString *param = [URLString substringFromIndex:SafariPageToHeader.length];
        [self safariPageToTJRWithURL:param];
        return YES;
    }

    // 处理 微信回调
    if ([[[URLString componentsSeparatedByString:@":"] objectAtIndex:0] isEqualToString:WXAppId]) {
        return [WXApi handleOpenURL:url delegate:self];
    }

    return NO;

}

/**
 *  处理从safari跳转进入
 *
 *  @param url
 */
- (void)safariPageToTJRWithURL:(NSString *)url {

    if (TTIsStringWithAnyText(url)) {
        NSArray *array = [url componentsSeparatedByString:@"&"];
        if (!array || array.count == 0) return;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        for (NSString *str in array) {
            NSArray *pArray = [str componentsSeparatedByString:@"="];
            if (pArray && pArray.count > 1) {
                NSString *key = [pArray firstObject];
                NSString *value = pArray[1];
                if (!value) value = @"";
                [userInfo setObject:value forKey:key];
            }
        }

        NSString *params = userInfo[@"params"];
        NSString *pView = userInfo[@"pview"];
        if(TTIsStringWithAnyText(params)){
            [[TJRCache shareTJRCache] putValueToParamDictionary:MSG_PARAMS value:params forKey:MSG_PARAMS];
        }

        if(TTIsStringWithAnyText(pView)){
            BOOL isExist = NO;
            for (id object in [_navigation.viewControllers objectEnumerator]) {
                if ([object isKindOfClass:[HomeViewController class]]) {
                    isExist = YES;
                    break;
                }
            }
            if (isExist) {//Home页存在时(代表用户已登陆),直接跳转
                TJRBaseViewController *vc = (TJRBaseViewController *)_navigation.topViewController;
                [vc pageToOrBackWithName:pView];
            } else {//不存在Home页时,保存跳转页面,等home页启动时,再跳转
                [[TJRCache shareTJRCache] putValueToParamDictionary:PushDict value:pView forKey:@"PushPview"];
            }
        }
    }
}


#pragma mark - 发送成功后回调(微信)
- (void)onResp:(BaseResp *)resp {
    // 发送成功后回调

    if ([resp isKindOfClass:[SendMessageToWXResp class]]) { // 微信分享
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:resp.errCode],@"errCode",LoginAccountTypeWeiXin,@"thirdType", nil];
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:@"ShareResp" object:nil userInfo:dic]];
    } else if ([resp isKindOfClass:[SendAuthResp class]]) { // 微信登录
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:@"WeixinResp" object:nil
                                     userInfo:[NSDictionary dictionaryWithObject:resp forKey:@"Resp"]]];
    }else if([resp isKindOfClass:[PayResp class]]){ // 微信支付

        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:@"WeixinPayResp" object:nil
                                     userInfo:[NSDictionary dictionaryWithObject:resp forKey:@"Resp"]]];

    }

}

@end

