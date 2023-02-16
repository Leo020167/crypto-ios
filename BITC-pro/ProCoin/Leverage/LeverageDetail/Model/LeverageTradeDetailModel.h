//
//  LeverageTradeDetailModel.h
//  BYY
//
//  Created by Hay on 2019/12/30.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface LeverageTradeDetailModel : TJRBaseEntity

@property (copy, nonatomic) NSString *profit;           //盈亏
@property (copy, nonatomic) NSString *totalAssets;      //总资产
@property (copy, nonatomic) NSString *assetsRate;       //资产涨幅
@property (copy, nonatomic) NSString *bailBalance;      //保证金
@property (copy, nonatomic) NSString *buySell;          //开仓方向
@property (copy, nonatomic) NSString *buySellValue;     //开仓方向文字描述
@property (copy, nonatomic) NSString *openCostPrice;    //开仓成本价
@property (copy, nonatomic) NSString *openCostPriceValue;   //开仓成本价，用来计算
@property (copy, nonatomic) NSString *openDealAmount;   //开仓成交数量
@property (copy, nonatomic) NSString *openDealBalance;  //开仓成交额
@property (copy, nonatomic) NSString *openDealFee;      //开仓手续费
@property (copy, nonatomic) NSString *openTime;         //开仓时间
@property (copy, nonatomic) NSString *borrowBalance;    //已借金额
@property (copy, nonatomic) NSString *borrowBalanceValue;   //已借金额，用来计算
@property (copy, nonatomic) NSString *bailBalanceValue;     //保证金，用来计算
@property (copy, nonatomic) NSString *interest;         //利息
@property (copy, nonatomic) NSString *interestValue;    //利息描述
@property (copy, nonatomic) NSString *interestBrief;    //利息说明
@property (copy, nonatomic) NSString *sysStopPrice;     //强平价
@property (copy, nonatomic) NSString *sysStopWarn;      //强平警告语
@property (copy, nonatomic) NSString *stopProfitLossValue;  //止盈止损文字
@property (copy, nonatomic) NSString *closeCostPrice;       //平仓成本价
@property (copy, nonatomic) NSString *closeDealAmount;      //平仓成交数量
@property (copy, nonatomic) NSString *closeDealBalance;     //平仓成本额
@property (copy, nonatomic) NSString *closeDealFee;         //平仓手续费
@property (copy, nonatomic) NSString *closeTime;            //平仓时间

@property (assign, nonatomic) NSInteger closeDone;         //是否完成,0未平仓，1平仓
@property (assign, nonatomic) NSInteger closeState;
@property (copy, nonatomic) NSString *closeStateDesc;
@property (copy, nonatomic) NSString *last;         //最新价
@property (copy, nonatomic) NSString *rate;         //当前涨幅
@property (copy, nonatomic) NSString *symbol;       //交易对

@property (assign, nonatomic) CGFloat stopWin;      //止盈百分比
@property (assign, nonatomic) CGFloat stopLoss;     //止损百分比
@property (assign, nonatomic) CGFloat stopMaxLoss;  //最大止损百分比
@property (copy, nonatomic) NSString *priceDecimals;     //小数位数

@end


