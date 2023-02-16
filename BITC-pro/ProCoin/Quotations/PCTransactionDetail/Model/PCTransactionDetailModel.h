//
//  PCTransactionDetailModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/29.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface PCTransactionDetailModel : TJRBaseEntity

//buySell = buy;
//buySellValue = "\U770b\U6da8(\U505a\U591a)";
//closeDone = 0;
//closeFee = "---";
//closePrice = "---";
//closeState = submitted;
//closeStateDesc = "\U59d4\U6258\U4e2d";
//closeTime = 0;
//last = "199.5861";
//multiNum = 100;
//nowStateDesc = "\U6301\U4ed3\U4e2d";
//openBail = "99.88035 USDT";
//openDone = 1;
//openFee = "2.99641050 USDT";
//openHand = "1\U624b";
//openPrice = "199.7607 USDT";
//openState = filled;
//openStateDesc = "\U5168\U90e8\U6210\U4ea4";
//openTime = 1582794327;
//orderId = 14;
//price = "199.7607 USDT";
//priceDecimals = 4;
//profit = "-8.73";
//profitRate = "-8.74";
//rate = "0.01";
//stopLossPrice = 0;
//stopWinPrice = 0;
//symbol = "ABC/USDT";
//userId = 500041;
@property (copy, nonatomic) NSString *profit;           //盈利
@property (copy, nonatomic) NSString *profitRate;       //盈利比例
@property (copy, nonatomic) NSString *openPrice;        //开仓价
@property (copy, nonatomic) NSString *buySell;          //交易方向
@property (copy, nonatomic) NSString *buySellValue;     //交易方向文本
@property (copy, nonatomic) NSString *openBail;         //开仓保证金
@property (copy, nonatomic) NSString *openHand;         //开仓手数
@property (copy, nonatomic) NSString *openFee;          //开仓手续费
@property (assign, nonatomic) BOOL openDone;            //是否开仓成功    1为开仓成功，0为未开仓
@property (copy, nonatomic) NSString *openTime;         //开仓时间
@property (copy, nonatomic) NSString *openState;        //开仓状态
@property (copy, nonatomic) NSString *openStateDesc;    //开仓状态描述
@property (copy, nonatomic) NSString *stopLossPrice;    //止损价
@property (copy, nonatomic) NSString *stopWinPrice;     //止盈价
@property (assign, nonatomic) BOOL closeDone;           //是否已平仓, 1为平仓，0为未平仓
@property (copy, nonatomic) NSString *closeFee;         //平仓手续费
@property (copy, nonatomic) NSString *closePrice;       //平仓价
@property (copy, nonatomic) NSString *closeState;       //平仓状态
@property (copy, nonatomic) NSString *closeStateDesc;   //平仓状态描述
@property (copy, nonatomic) NSString *closeTime;        //平仓时间
@property (copy, nonatomic) NSString *symbol;           //交易对
@property (copy, nonatomic) NSString *last;             //现价
@property (copy, nonatomic) NSString *rate;             //涨幅
@property (assign, nonatomic) NSInteger priceDecimals;    //小数位数
@property (copy, nonatomic) NSString *marketType;       //币种类型

@end


