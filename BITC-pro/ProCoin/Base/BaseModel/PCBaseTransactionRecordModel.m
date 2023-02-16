//
//  PCBaseTransactionRecordModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/2.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCBaseTransactionRecordModel.h"

@implementation PCBaseTransactionRecordModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.symbol = [self stringParser:@"symbol" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.buySellValue = [self stringParser:@"buySellValue" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.openHand = [self stringParser:@"openHand" json:json];
        self.openPrice = [self stringParser:@"openPrice" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.openTime = [self stringParser:@"openTime" json:json];
        self.openDone = [self boolParser:@"openDone" json:json];
        self.closeDone = [self boolParser:@"closeDone" json:json];
        self.openFee = [self stringParser:@"openFee" json:json];
        self.openBail = [self stringParser:@"openBail" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.closeState = [self stringParser:@"closeState" json:json];
        self.closeStateDesc = [self stringParser:@"closeStateDesc" json:json];
    }
    return self;
}



- (void)dealloc
{
    [_symbol release];
    [_buySell release];
    [_buySellValue release];
    [_profitRate release];
    [_openHand release];
    [_openPrice release];
    [_price release];
    [_profit release];
    [_openTime release];
    [_openFee release];
    [_openBail release];
    [_orderId release];
    [_closeState release];
    [_closeStateDesc release];
    [super dealloc];
}

@end
