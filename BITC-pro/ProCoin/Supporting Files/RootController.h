//
//  RootController.h
//  tjr-taojinroad
//
//  Created by taojinroad on 12-8-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRUser.h"
#import <AVFoundation/AVFoundation.h>

@class TJRBaseSocket;

@interface RootController : UIViewController
{

}

@property (nonatomic, assign) BOOL isRun,isBackgroud;
@property (nonatomic, retain) TJRUser *user;
@property (assign, nonatomic) long long sleepTime;
@property (nonatomic, assign) BOOL isRotation;                      // 是否强制旋转屏幕了
@property (assign, nonatomic) NSInteger globalFontLevel;            // 定义全局字体大小

@property (nonatomic, assign) BOOL isShowFastBuy;                    //是否显示快捷购买
@property (nonatomic, assign) BOOL isShowDefault;                   //是否显示OTC交易

@property (assign, nonatomic) NSTimeInterval quotationRefreshTime;     //行情刷新时间，默认3s

- (void)sleepApplication;
- (void)wakeUpApplication;

- (void)reqRootBackgroundFinished:(NSDictionary*)jsonDic;
- (void)reqRootBackgroundFailed:(NSDictionary*)jsonDic;

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - 接口检验回调
- (BOOL)rootCheckJson:(NSDictionary *)dic;

- (void)clean;
- (void)logout;

#pragma mark - 获取是否登录状态
- (BOOL)getLoginStatus;
- (void)gotoLogin;

#pragma mark - 重新获取行情刷新时间
- (void)reloadQuotationRefreshTime;

#pragma mark - 获取当前最顶部的viewController（不一定为当前navigationController下的vc）
- (UIViewController *)getCurrentTopViewControllerView;


@end
