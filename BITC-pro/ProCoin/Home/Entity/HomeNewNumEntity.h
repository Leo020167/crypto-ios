//
//  HomeNewNumEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/4/2.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseEntity.h"
#import "TJRCache.h"

extern NSString *const HomeNewNumKey;//缓存中保存newNum的Key
extern NSString *const HomeRefreshNewDotKey;//通知刷新首页四个tab上的new的KEY

@interface HomeNewNumEntity : TJRBaseEntity
@property (assign, nonatomic) NSInteger chatCount;      // 客服
@property (assign, nonatomic) NSInteger msgCount;       // 消息
@property (assign, nonatomic) NSInteger circleNewCount;  // 圈子

- (void)updataNewWithJson:(NSDictionary *)json;

#pragma mark - 通知首页刷新4个tab上面的蓝点
- (void)postNotification;
@end
