//
//  SearchCoinDataEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "SearchCoinDataEntity.h"
#import "TradeUtil.h"

@implementation SearchCoinDataEntity


- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.priceCny = [self stringParser:@"priceCny" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.sortNum = [self stringParser:@"sortNum" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.originSymbol = [TradeUtil originSymbolAccquireBySymbol:self.symbol];
        self.unitSymbol = [TradeUtil unitSymbolAccquireBySymbol:self.symbol];
        self.type = [self integerParser:@"type" json:json];
        self.url = [self stringParser:@"url" json:json];
        self.marketType = [self stringParser:@"marketType" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_price release];
    [_priceCny release];
    [_rate release];
    [_sortNum release];
    [_symbol release];
    [_originSymbol release];
    [_unitSymbol release];
    [_url release];
    [_marketType release];
    [super dealloc];
}

@end
