//
//  AppInfo.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-10-15.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJRAppInfo : NSObject 
@property (nonatomic, copy) NSString *bugMsg;
@property (nonatomic, copy) NSString *platform;  // 平台
@property (nonatomic, copy) NSString *identifyCode; // 识别码
@property (nonatomic, copy) NSString *downloadUrl;  // 下载地址
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, assign) BOOL isShowFirst;
@property (nonatomic, assign) int versionNum;
@property (nonatomic, assign) BOOL isForce;  // 是否强制
@end


@interface TJRPlacard : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *placardTime; // 公告时间
@property (nonatomic, copy) NSString *title;
@end
