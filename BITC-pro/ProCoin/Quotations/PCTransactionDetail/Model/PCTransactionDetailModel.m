//
//  PCTransactionDetailModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/29.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransactionDetailModel.h"

@implementation PCTransactionDetailModel



- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.profit = [self stringParser:@"profit" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.openPrice = [self stringParser:@"openPrice" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.buySellValue = [self stringParser:@"buySellValue" json:json];
        self.openBail = [self stringParser:@"openBail" json:json];
        self.openHand = [self stringParser:@"openHand" json:json];
        self.openFee = [self stringParser:@"openFee" json:json];
        self.openDone = [self boolParser:@"openDone" json:json];
        self.openTime = [self stringParser:@"openTime" json:json];
        self.openState = [self stringParser:@"openState" json:json];
        self.openStateDesc = [self stringParser:@"openStateDesc" json:json];
        self.stopLossPrice = [self stringParser:@"stopLossPrice" json:json];
        self.stopWinPrice = [self stringParser:@"stopWinPrice" json:json];
        self.closeDone = [self boolParser:@"closeDone" json:json];
        self.closeFee = [self stringParser:@"closeFee" json:json];
        self.closePrice = [self stringParser:@"closePrice" json:json];
        self.closeState = [self stringParser:@"closeState" json:json];
        self.closeStateDesc = [self stringParser:@"closeStateDesc" json:json];
        self.closeTime = [self stringParser:@"closeTime" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.last = [self stringParser:@"last" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.priceDecimals = [self integerParser:@"priceDecimals" json:json];
        self.marketType = [self stringParser:@"marketType" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_profit release];
    [_profitRate release];
    [_openPrice release];
    [_buySell release];
    [_buySellValue release];
    [_openBail release];
    [_openHand release];
    [_openFee release];
    [_openTime release];
    [_openState release];
    [_openStateDesc release];
    [_stopLossPrice release];
    [_stopWinPrice release];
    [_closeFee release];
    [_closePrice release];
    [_closeState release];
    [_closeStateDesc release];
    [_closeTime release];
    [_symbol release];
    [_last release];
    [_rate release];
    [_marketType release];
    [super dealloc];
}

@end
