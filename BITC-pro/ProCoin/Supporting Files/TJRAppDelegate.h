//
//  TJRAppDelegate.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-25.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootController.h"
#import "TJRRootNavigationController.h"
#import "TJRNavigationController.h"
#import "YLNavigationController.h"
#import "TJRWindow.h"


extern NSString *const StatusBarClick;


@interface TJRAppDelegate : UIResponder <UIApplicationDelegate>{
    TJRRootNavigationController *_navigation;
    RootController *_rootController;
    //    SinaWeiboLogin *sinaweibo;    /* 新浪sdk */
    //    TencentOAuth *tencentOAuth;    /* 腾讯qq */
}
@property (nonatomic, assign) UINavigationController *navigation;
@property (nonatomic, assign) UINavigationController *navPresent;
@property (nonatomic, assign) TJRNavigationController *navLandscape;
@property (strong, nonatomic) TJRWindow *window;
@property (nonatomic, assign) RootController *rootController;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;


@property (copy, nonatomic) NSString *pushToken;/* 本机token */
@end

