//
//  HomeNewNumEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/4/2.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "HomeNewNumEntity.h"

NSString *const HomeNewNumKey = @"HomeNewNumKey";

NSString *const HomeRefreshNewDotKey = @"HomeRefreshNewDotKey";//通知刷新首页四个tab上的new的KEY

@implementation HomeNewNumEntity

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self && json) {
        self.msgCount = [self integerParser:@"msgCount" json:json];// 消息
    }
    return self;
}

- (void)updataNewWithJson:(NSDictionary *)json {
    if (json) {
        self.msgCount = [self integerParser:@"msgCount" json:json];// 消息
    }
}


#pragma mark - 通知首页刷新4个tab上面的红点
- (void)postNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:HomeRefreshNewDotKey object:nil userInfo:@{HomeNewNumKey:self}];
}

- (void)dealloc{
    [super dealloc];
}

@end
