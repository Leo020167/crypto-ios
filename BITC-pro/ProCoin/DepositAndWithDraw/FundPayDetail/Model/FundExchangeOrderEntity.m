//
//  FundExchangeOrderEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundExchangeOrderEntity.h"

@implementation FundExchangeOrderEntity

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.balanceCny = [self stringParser:@"balanceCny" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.priceCny = [self stringParser:@"priceCny" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.expireTime = [self stringParser:@"expireTime" json:json];
        self.inOutId = [self stringParser:@"inOutId" json:json];
        self.orderCashId = [self stringParser:@"orderCashId" json:json];
        self.state = [self integerParser:@"state" json:json];
        self.stateDesc = [self stringParser:@"stateDesc" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_balanceCny release];
    [_amount release];
    [_priceCny release];
    [_createTime release];
    [_expireTime release];
    [_inOutId release];
    [_orderCashId release];
    [_stateDesc release];
    [super dealloc];
}

@end
