//
//  CircleJoinRecordEntity.m
//  Tjrv
//
//  Created by taojinroad on 2019/2/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CircleJoinRecordEntity.h"

@implementation CircleJoinRecordEntity

- (id)initWithJson:(NSDictionary *)json {
    self = [super initWithJson:json];
    if (self && json) {
        
        self.applyId = [self stringParser:@"applyId" json:json];
        self.circleId = [self stringParser:@"circleId" json:json];    // 圈号
        self.userId = [self stringParser:@"userId" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.handleUserName = [self stringParser:@"handleUserName" json:json];
        self.reason = [self stringParser:@"reason" json:json];
        self.handleUid = [self stringParser:@"handleUid" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.status = [self integerParser:@"status" json:json];
    }
    return self;
}

- (void)dealloc{
    [_applyId release];
    [_createTime release];
    [_handleUid release];
    [_reason release];
    [_circleId release];
    [_userId release];
    [_userName release];
    [_headUrl release];
    [_handleUserName release];
    [super dealloc];
}

@end
