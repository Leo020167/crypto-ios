//
//  QuotationCoinBaseEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "QuotationCoinBaseEntity.h"
#import "TradeUtil.h"

@implementation QuotationCoinBaseEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.price = [self stringParser:@"price" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.priceCNY = [self stringParser:@"priceCny" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.tip = [self stringParser:@"tip" json:json];
        self.originSymbol = [TradeUtil originSymbolAccquireBySymbol:self.symbol];
        self.unitSymbol = [TradeUtil originSymbolAccquireBySymbol:self.unitSymbol];
        self.marketType = [self stringParser:@"marketType" json:json];
        
        self.openMarketStr = [self stringParser:@"openMarketStr" json:json];
        self.name = [self stringParser:@"name" json:json];
        self.currency = [self stringParser:@"currency" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_openMarketStr release];
    [_name release];
    [_currency release];
    [_price release];
    [_rate release];
    [_symbol release];
    [_originSymbol release];
    [_unitSymbol release];
    [_priceCNY release];
    [_amount release];
    [_marketType release];
    [super dealloc];
}

@end
