//
//  CoinTransactionDetailEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/28.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CoinTransactionDetailEntity.h"
#import "TradeUtil.h"

@implementation CoinTransactionDetailEntity


- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.timestamp = [self stringParser:@"timestamp" json:json];
        self.dealAmount = [self stringParser:@"dealAmount" json:json];
        self.dealFee = [self stringParser:@"dealFee" json:json];
        self.dealPrice = [self stringParser:@"dealPrice" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.originSymbol = [TradeUtil originSymbolAccquireBySymbol:self.symbol];
        self.unitSymbol = [TradeUtil unitSymbolAccquireBySymbol:self.symbol];
    }
    return self;
}

- (void)dealloc
{
    [_timestamp release];
    [_dealAmount release];
    [_dealFee release];
    [_dealPrice release];
    [_symbol release];
    [_buySell release];
    [_originSymbol release];
    [_unitSymbol release];
    [super dealloc];
}

@end
