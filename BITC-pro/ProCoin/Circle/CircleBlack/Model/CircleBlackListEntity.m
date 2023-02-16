//
//  CircleBlackListEntity.m
//  Tjrv
//
//  Created by taojinroad on 2019/2/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CircleBlackListEntity.h"

@implementation CircleBlackListEntity

- (id)initWithJson:(NSDictionary *)json {
    self = [super initWithJson:json];
    if (self && json) {
        
        self.circleId = [self stringParser:@"circleId" json:json];    // 圈号
        self.userId = [self stringParser:@"userId" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.blackId = [self stringParser:@"blackId" json:json];
    }
    return self;
}

- (void)dealloc{

    [_blackId release];
    [_circleId release];
    [_userId release];
    [_userName release];
    [_headUrl release];
    [super dealloc];
}

@end
