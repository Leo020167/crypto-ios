//
//  PCBaseHoldCoinModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/19.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCBaseHoldCoinModel.h"

@implementation PCBaseHoldCoinModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.buySell = [self stringParser:@"buySell" json:json];
        self.buySellValue = [self stringParser:@"buySellValue" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.openHand = [self stringParser:@"openHand" json:json];
        self.openPrice = [self stringParser:@"openPrice" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_buySell release];
    [_buySellValue release];
    [_profitRate release];
    [_openHand release];
    [_openPrice release];
    [_profit release];
    [_symbol release];
    [_orderId release];
    [super dealloc];
}

@end
