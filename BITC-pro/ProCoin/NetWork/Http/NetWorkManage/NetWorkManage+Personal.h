//
//  NetWorkManage+Personal.h
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (Personal)

/** 关注某人*/
- (void)reqFollowUser:(id)delegate followUid:(NSString *)followUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 取关某人*/
- (void)reqCancelFollowUser:(id)delegate followUid:(NSString *)followUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 订阅/续费某人*/
- (void)reqSubscribeUser:(id)delegate attentionUid:(NSString *)attentionUid num:(NSString *)num finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 工作台数据
/** 获取工作台数据*/
- (void)reqPersonConsoleData:(id)delegate userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 个人主页数据
/** 个人主页数据*/
- (void)reqPersonalMainData:(id)delegate targetUid:(NSString *)targetUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取图形数据 type（1：个人业绩 2：跟单人气 3：交易次数，4：累计盈亏）*/
- (void)reqPersonalLineChartData:(id)delegate targetUid:(NSString *)targetUid timeType:(NSString *)timeType type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



@end


