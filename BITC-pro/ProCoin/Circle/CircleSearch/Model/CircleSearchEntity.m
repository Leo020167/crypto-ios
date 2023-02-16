//
//  CircleSearchEntity.m
//  Redz
//
//  Created by Hay on 2018/12/4.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "CircleSearchEntity.h"

@implementation CircleSearchEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.circleId = [self stringParser:@"circleId" json:json];    // 圈号
        self.circleName = [self stringParser:@"circleName" json:json];// 圈名
        self.circleLogo = [self stringParser:@"circleLogo" json:json];// 圈logo
        self.createUserId = [self stringParser:@"userId" json:json];// 创建人UserId
    }
    return self;
}


- (void)dealloc
{
    [_circleId release];
    [_circleLogo release];
    [_circleName release];
    [_createUserId release];
    [super dealloc];
}
@end
