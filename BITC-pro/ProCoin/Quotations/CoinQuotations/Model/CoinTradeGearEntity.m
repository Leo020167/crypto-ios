//
//  CoinTradeGearEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CoinTradeGearEntity.h"

@implementation CoinTradeGearEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.depthRate = [self stringParser:@"depthRate" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_price release];
    [_depthRate release];
    [super dealloc];
}

@end
