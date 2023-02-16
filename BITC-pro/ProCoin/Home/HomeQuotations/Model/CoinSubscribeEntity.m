//
//  CoinSubscribeEntity.m
//  Cropyme
//
//  Created by Hay on 2019/9/6.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinSubscribeEntity.h"
#import "TradeUtil.h"

@implementation CoinSubscribeEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.mySubAmount = [self stringParser:@"mySubAmount" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.priceCny = [self stringParser:@"priceCny" json:json];
        self.produceAmount = [self stringParser:@"produceAmount" json:json];
        self.subId = [self stringParser:@"subId" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.originSymbol = [TradeUtil originSymbolAccquireBySymbol:_symbol];
        self.totalAmount = [self stringParser:@"totalAmount" json:json];
        NSArray *array = [json objectForKey:@"amountList"];
        if([array isKindOfClass:[NSArray class]]){
            self.balanceList = [NSArray arrayWithArray:array];
        }
    }
    return self;
}

- (void)dealloc
{
    [_mySubAmount release];
    [_price release];
    [_priceCny release];
    [_produceAmount release];
    [_subId release];
    [_symbol release];
    [_totalAmount release];
    [_balanceList release];
    [super dealloc];
}

@end
