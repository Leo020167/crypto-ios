//
//  FollowOrderDistributeChartEntity.m
//  Cropyme
//
//  Created by Hay on 2019/7/25.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FollowOrderDistributeChartEntity.h"

@implementation FollowOrderDistributeChartEntity

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.balance = [self stringParser:@"balance" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.amount = [self stringParser:@"amount" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_balance release];
    [_rate release];
    [_symbol release];
    [_amount release];
    [super dealloc];
}

@end
