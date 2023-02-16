//
//  HoldCoinEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "HoldCoinEntity.h"
#import "TradeUtil.h"

@implementation HoldCoinEntity


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.costPrice = [self stringParser:@"costPrice" json:json];
        self.frozenAmount = [self stringParser:@"frozenAmount" json:json];
        self.holdAmount = [self stringParser:@"holdAmount" json:json];
        self.hide = [self boolParser:@"hide" json:json];
        self.market = [self stringParser:@"market" json:json];
        self.marketCny = [self stringParser:@"marketCny" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.originSymbol = [TradeUtil originSymbolAccquireBySymbol:self.symbol];
        self.unitSymbol = [TradeUtil unitSymbolAccquireBySymbol:self.symbol];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_costPrice release];
    [_frozenAmount release];
    [_holdAmount release];
    [_market release];
    [_marketCny release];
    [_profit release];
    [_profitRate release];
    [_symbol release];
    [_originSymbol release];
    [_unitSymbol release];
    [_userId release];
    [super dealloc];
}
@end
