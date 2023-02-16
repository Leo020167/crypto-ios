//
//  InfluencerRankEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "InfluencerRankEntity.h"


@implementation InfluencerRankEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.correctRate = [self stringParser:@"correctRate" json:json];
        self.days = [self stringParser:@"days" json:json];
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.monthProfit = [self stringParser:@"monthProfit" json:json];
        self.totalProfit = [self stringParser:@"totalProfit" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_correctRate release];
    [_days release];
    [_headUrl release];
    [_monthProfit release];
    [_totalProfit release];
    [_userName release];
    [_userId release];
    [super dealloc];
}

@end
