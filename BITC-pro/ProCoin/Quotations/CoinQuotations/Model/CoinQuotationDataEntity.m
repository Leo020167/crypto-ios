//
//  CoinQuotationDataEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/25.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CoinQuotationDataEntity.h"

@implementation CoinQuotationDataEntity

//@property (assign, nonatomic) CGFloat amount;           //成交数量
//@property (assign, nonatomic) CGFloat amt;              //涨跌数字
//@property (assign, nonatomic) CGFloat balance;          //成交金额
//@property (assign, nonatomic) CGFloat high;             //今日最高价
//@property (assign, nonatomic) CGFloat last;             //当前价格
//@property (assign, nonatomic) CGFloat low;              //今日最低价
//@property (assign, nonatomic) CGFloat open;             //今日开盘价
//@property (assign, nonatomic) CGFloat preClose;         //昨日收盘价
//@property (copy, nonatomic) NSString *timeStamp;        //最后更新时间
//@property (assign, nonatomic) CGFloat rate;             //涨幅
//@property (copy, nonatomic) NSString *symbol;           //币种

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.amount = [self doubleParser:@"amount" json:json];
        self.amountString = [self stringParser:@"amount" json:json];
        self.amt = [self stringParser:@"amt" json:json];
        self.balance = [self doubleParser:@"balance" json:json];
        self.high = [self doubleParser:@"high" json:json];
        self.highString = [self stringParser:@"high" json:json];
        self.last = [self stringParser:@"last" json:json];
        self.lastCny = [self stringParser:@"lastCny" json:json];
        self.low = [self doubleParser:@"low" json:json];
        self.lowString = [self stringParser:@"low" json:json];
        self.open = [self doubleParser:@"open" json:json];
        self.openString = [self stringParser:@"open" json:json];
        self.preClose = [self doubleParser:@"preClose" json:json];
        self.timeStamp = [self stringParser:@"timestamp" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.tip = [self stringParser:@"tip" json:json];
        self.priceDecimals = [self integerParser:@"priceDecimals" json:json];
        self.amountDecimals = [self integerParser:@"amountDecimals" json:json];
        
        self.openMarketStr = [self stringParser:@"openMarketStr" json:json];
        self.currency = [self stringParser:@"currency" json:json];
        self.name = [self stringParser:@"name" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_currency release];
    [_openMarketStr release];
    [_amountString release];
    [_amt release];
    [_last release];
    [_lastCny release];
    [_timeStamp release];
    [_rate release];
    [_symbol release];
    [_highString release];
    [_lowString release];
    [_openString release];
    [super dealloc];
}

@end
