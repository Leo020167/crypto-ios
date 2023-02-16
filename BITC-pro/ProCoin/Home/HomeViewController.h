//
//  HomeViewController.h
//  TJRtaojinroad
//
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseTabBarController.h"
#import "TJRBaseViewController.h"
#import "TJRAppInfo.h"
#import "TJRAppInfoParser.h"
#import "HomeNewNumEntity.h"

#define TabClassKey                     @"TabClassKey"
#define TabClassTitle                   @"TabClassTitle"
#define TabClassImageKey                @"TabClassImageKey"
#define TabClassSelectImageKey          @"TabClassSelectImageKey"



@interface HomeViewController : TJRBaseTabBarController {
    
    BOOL isNotFirst;
}

@property (retain, nonatomic) TJRAppInfo *appInfo;
@property (retain, nonatomic) TJRPlacard *placard;


- (void)uploadPushToken;
- (void)refreshHomeNewDot;

@end

