//
//  CoinTradeOrderEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/22.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CoinTradeOrderEntity.h"
#import "TradeUtil.h"

@implementation CoinTradeOrderEntity



- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.followAmount = [self stringParser:@"copyAmount" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.dealTolAmount = [self stringParser:@"dealTolAmount" json:json];
        self.openFollow = [self boolParser:@"openCopy" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.state = [self integerParser:@"state" json:json];
        self.stateDesc = [self stringParser:@"stateDesc" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.originSymbol = [TradeUtil originSymbolAccquireBySymbol:self.symbol];
        self.unitSymbol = [TradeUtil unitSymbolAccquireBySymbol:self.symbol];
        self.tolAmount = [self stringParser:@"tolAmount" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.dealAmount = [self stringParser:@"dealAmount" json:json];
        self.followDealAmount = [self stringParser:@"copyDealAmount" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.profitShare = [self stringParser:@"profitShare" json:json];
        self.dealAvgPrice = [self stringParser:@"dealAvgPrice" json:json];
        self.balance = [self stringParser:@"balance" json:json];
        self.dealBalance = [self stringParser:@"dealBalance" json:json];
        self.followDealBalance = [self stringParser:@"copyDealBalance" json:json];
        self.tolBalance = [self stringParser:@"tolBalance" json:json];
        self.dealTolBalance = [self stringParser:@"dealTolBalance" json:json];
        self.serviceShare = [self stringParser:@"serviceShare" json:json];
        self.dealFee = [self stringParser:@"dealFee" json:json];
        self.followDealFee = [self stringParser:@"copyDealFee" json:json];
        self.dealTolFee = [self stringParser:@"dealTolFee" json:json];
    }
    return self;
}


- (void)dealloc
{
    [_amount release];
    [_buySell release];
    [_followAmount release];
    [_createTime release];
    [_dealTolAmount release];
    [_orderId release];
    [_stateDesc release];
    [_symbol release];
    [_originSymbol release];
    [_unitSymbol release];
    [_tolAmount release];
    [_userId release];
    [_price release];
    [_dealAmount release];
    [_followDealAmount release];
    [_profit release];
    [_profitShare release];
    [_dealAvgPrice release];
    [_balance release];
    [_dealBalance release];
    [_followDealBalance release];
    [_tolBalance release];
    [_dealTolBalance release];
    [_serviceShare release];
    [_dealFee release];
    [_followDealFee release];
    [_dealTolFee release];
    [super dealloc];
}

@end
