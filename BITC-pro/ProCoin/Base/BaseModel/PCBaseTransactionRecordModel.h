//
//  PCBaseTransactionRecordModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/2.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"
//buySell = buy;
//buySellValue = "\U770b\U6da8(\U505a\U591a)";
//closeDone = 0;
//closeFee = "---";
//closePrice = "---";
//closeState = submitted;
//closeStateDesc = "\U59d4\U6258\U4e2d";
//closeTime = 0;
//multiNum = 100;
//nowStateDesc = "\U6301\U4ed3\U4e2d";
//openBail = "1728.922 USDT";
//openDone = 1;
//openFee = "51.86766000 USDT";
//openHand = "2\U624b";
//openPrice = "8644.61 USDT";
//openState = filled;
//openStateDesc = "\U5168\U90e8\U6210\U4ea4";
//openTime = 1583137929;
//orderId = 32;
//price = "\U5e02\U4ef7";
//priceDecimals = 0;
//profit = 674;
//profitRate = "38.98";
//stopLossPrice = 0;
//stopWinPrice = 0;
//symbol = "BTC/USDT";
//userId = 500041;

NS_ASSUME_NONNULL_BEGIN

@interface PCBaseTransactionRecordModel : TJRBaseEntity

@property (copy, nonatomic) NSString *symbol;           //交易对
@property (copy, nonatomic) NSString *buySell;          //看涨看跌类型
@property (copy, nonatomic) NSString *buySellValue;     //看涨看跌类型描述
@property (copy, nonatomic) NSString *profitRate;       //收益率
@property (copy, nonatomic) NSString *openHand;         //手数
@property (copy, nonatomic) NSString *openPrice;        //开仓价
@property (copy, nonatomic) NSString *price;            //委托价
@property (copy, nonatomic) NSString *profit;           //盈亏
@property (copy, nonatomic) NSString *openTime;         //开仓时间
@property (assign, nonatomic) BOOL openDone;            //开仓是否成功
@property (assign, nonatomic) BOOL closeDone;           //是否平仓成功
@property (copy, nonatomic) NSString *openFee;          //开仓手续费
@property (copy, nonatomic) NSString *openBail;         //开仓保证金
@property (copy, nonatomic) NSString *orderId;          //订单id
@property (copy, nonatomic) NSString *closeState;       //关闭订单状态
@property (copy, nonatomic) NSString *closeStateDesc;    //关闭订单状态描述
@property (nonatomic, copy) NSString *amount;

/// 金额
@property (nonatomic, copy) NSString *sum;

/// 创建时间
@property (nonatomic, copy) NSString *createTime;

/// 手续费
@property (nonatomic, copy) NSString *fee;

/// 成本
@property (nonatomic, copy) NSString *originPrice;


// 1历史 0 委托
@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
