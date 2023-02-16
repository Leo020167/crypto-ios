//
//  CDCostBaseEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CDCostBaseEntity.h"



@implementation CDCostBaseEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amountDecimals = [self stringParser:@"amountDecimals" json:json];
        self.avgCostPrice = [self stringParser:@"avgCostPrice" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.priceDecimals = [self stringParser:@"priceDecimals" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.totalAmount = [self stringParser:@"totalAmount" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amountDecimals release];
    [_avgCostPrice release];
    [_price release];
    [_priceDecimals release];
    [_profitRate release];
    [_symbol release];
    [_totalAmount release];
    [super dealloc];
}

@end
