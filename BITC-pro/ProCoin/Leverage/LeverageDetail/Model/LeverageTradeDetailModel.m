//
//  LeverageTradeDetailModel.m
//  BYY
//
//  Created by Hay on 2019/12/30.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageTradeDetailModel.h"

@implementation LeverageTradeDetailModel

//@property (copy, nonatomic) NSString *profit;           //盈亏
//@property (copy, nonatomic) NSString *totalAssets;      //总资产
//@property (copy, nonatomic) NSString *assetsRate;       //资产涨幅
//@property (copy, nonatomic) NSString *bailBalance;      //保证金
//@property (copy, nonatomic) NSString *buySellValue;     //开仓方向文字描述
//@property (copy, nonatomic) NSString *openCostPrice;    //开仓成本价
//@property (copy, nonatomic) NSString *openDealAmount;   //开仓成交数量
//@property (copy, nonatomic) NSString *openDealBalance;  //开仓成交额
//@property (copy, nonatomic) NSString *openDealFee;      //开仓手续费
//@property (copy, nonatomic) NSString *openTime;         //开仓时间
//@property (copy, nonatomic) NSString *borrowBalance;    //已借金额
//@property (copy, nonatomic) NSString *interest;         //利息
//@property (copy, nonatomic) NSString *interestBrief;    //利息描述
//@property (copy, nonatomic) NSString *sysStopPrice;     //强平价
//@property (copy, nonatomic) NSString *sysStopWarn;      //强平警告语
//@property (copy, nonatomic) NSString *stopProfitLossValue;  //止盈止损文字
//@property (copy, nonatomic) NSString *closeCostPrice;       //平仓成本价
//@property (copy, nonatomic) NSString *closeDealAmount;      //平仓成交数量
//@property (copy, nonatomic) NSString *closeDealBalance;     //平仓成本额
//@property (copy, nonatomic) NSString *closeDealFee;         //平仓手续费
//@property (copy, nonatomic) NSString *closeTime;            //平仓时间
//
//@property (assign, nonatomic) NSInteger closeDone;         //是否完成,0平仓中，1平仓结束
//@property (assign, nonatomic) NSInteger closeState;
//@property (copy, nonatomic) NSString *closeStateDesc;
//@property (copy, nonatomic) NSString *last;         //最新价
//@property (copy, nonatomic) NSString *rate;         //当前涨幅
//
//@property (assign, nonatomic) CGFloat stopWin;      //止盈百分比
//@property (assign, nonatomic) CGFloat stopLoss;     //止损百分比
//@property (assign, nonatomic) CGFloat stopMaxLoss;  //最大止损百分比

- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.profit = [self stringParser:@"profit" json:json];
        self.totalAssets = [self stringParser:@"totalAssets" json:json];
        self.assetsRate = [self stringParser:@"assetsRate" json:json];
        self.bailBalance = [self stringParser:@"bailBalance" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.buySellValue = [self stringParser:@"buySellValue" json:json];
        self.openCostPrice = [self stringParser:@"openCostPrice" json:json];
        self.openCostPriceValue = [self stringParser:@"openCostPriceValue" json:json];
        self.openDealAmount = [self stringParser:@"openDealAmount" json:json];
        self.openDealBalance = [self stringParser:@"openDealBalance" json:json];
        self.openDealFee = [self stringParser:@"openDealFee" json:json];
        self.openTime = [self stringParser:@"openTime" json:json];
        self.borrowBalance = [self stringParser:@"borrowBalance" json:json];
        self.bailBalanceValue = [self stringParser:@"bailBalanceValue" json:json];
        self.borrowBalanceValue = [self stringParser:@"borrowBalanceValue" json:json];
        self.interest = [self stringParser:@"interest" json:json];
        self.interestValue = [self stringParser:@"interestValue" json:json];
        self.interestBrief = [self stringParser:@"interestBrief" json:json];
        self.sysStopPrice = [self stringParser:@"sysStopPrice" json:json];
        self.sysStopWarn = [self stringParser:@"sysStopWarn" json:json];
        self.stopProfitLossValue = [self stringParser:@"stopProfitLossValue" json:json];
        self.closeCostPrice = [self stringParser:@"closeCostPrice" json:json];
        self.closeDealAmount = [self stringParser:@"closeDealAmount" json:json];
        self.closeDealBalance = [self stringParser:@"closeDealBalance" json:json];
        self.closeDealFee = [self stringParser:@"closeDealFee" json:json];
        self.closeTime = [self stringParser:@"closeTime" json:json];
        self.closeDone = [self integerParser:@"closeDone" json:json];
        self.closeState = [self integerParser:@"closeState" json:json];
        self.closeStateDesc = [self stringParser:@"closeStateDesc" json:json];
        self.last = [self stringParser:@"last" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.stopWin = [self integerParser:@"stopWin" json:json];
        self.stopLoss = [self integerParser:@"stopLoss" json:json];
        self.stopMaxLoss = [self integerParser:@"stopMaxLoss" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.priceDecimals = [self stringParser:@"priceDecimals" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_profit release];
    [_totalAssets release];
    [_assetsRate release];
    [_bailBalance release];
    [_buySell release];
    [_buySellValue release];
    [_openCostPrice release];
    [_openCostPriceValue release];
    [_openDealAmount release];
    [_openDealBalance release];
    [_openDealFee release];
    [_openTime release];
    [_borrowBalance release];
    [_borrowBalanceValue release];
    [_bailBalanceValue release];
    [_interest release];
    [_interestValue release];
    [_interestBrief release];
    [_sysStopPrice release];
    [_sysStopWarn release];
    [_stopProfitLossValue release];
    [_closeCostPrice release];
    [_closeDealAmount release];
    [_closeDealBalance release];
    [_closeDealFee release];
    [_closeTime release];
    [_closeStateDesc release];
    [_last release];
    [_rate release];
    [_symbol release];
    [_priceDecimals release];
    [super dealloc];
}

@end
