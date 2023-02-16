//
//  CoinTradeOrderEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/22.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"




@interface CoinTradeOrderEntity : TJRBaseEntity

//amount = "4.83343341";
//balance = "0.39692638";
//buySell = "-1";
//copyOrderId = 2;
//costPrice = "0.08201234";
//createTime = 1559811775;
//dealAmount = "4.83343024";
//dealAvgPrice = "0.08212099";
//dealBalance = "0.39692612";
//dealFee = "0.00079385";
//doneTime = 1559811777;
//isLimit = 1;
//orderId = 80;
//price = "0.082121";
//profit = "-0.00026865";
//profitScale = "0.25";
//profitShare = 0;
//state = 30;
//stateDesc = "\U5168\U90e8\U6210\U4ea4";
//symbol = ADA;
//tradeId = 37;
//usdtRate = "7.01";
//userId = 5;

@property (copy, nonatomic) NSString *amount;                       //我的委托数量
@property (copy, nonatomic) NSString *buySell;                      //买卖方向，1为买，2为卖
@property (copy, nonatomic) NSString *followAmount;                 //跟单委托数量
@property (copy, nonatomic) NSString *createTime;                   //创建时间
@property (copy, nonatomic) NSString *dealTolAmount;                //总的成交数量
@property (assign, nonatomic) BOOL openFollow;                      //是否开通跟单功能
@property (copy, nonatomic) NSString *orderId;                      //委托id
@property (assign, nonatomic) NSInteger state;                      //状态
@property (copy, nonatomic) NSString *stateDesc;                    //状态描述
@property (copy, nonatomic) NSString *symbol;                       //交易对
@property (copy, nonatomic) NSString *originSymbol;                 //原始币种
@property (copy, nonatomic) NSString *unitSymbol;                   //单位币种
@property (copy, nonatomic) NSString *tolAmount;                    //委托总数量
@property (copy, nonatomic) NSString *userId;                       //userid
@property (copy, nonatomic) NSString *price;                        //委托价格
@property (copy, nonatomic) NSString *dealAmount;                   //我的成交数量
@property (copy, nonatomic) NSString *followDealAmount;             //跟单成交数量
@property (copy, nonatomic) NSString *profit;                       //盈利
@property (copy, nonatomic) NSString *profitShare;                  //跟单分成
@property (copy, nonatomic) NSString *dealAvgPrice;                 //成交均价
@property (copy, nonatomic) NSString *dealBalance;                  //成交额
@property (copy, nonatomic) NSString *followDealBalance;            //跟单成交额
@property (copy, nonatomic) NSString *balance;                      //委托额
@property (copy, nonatomic) NSString *tolBalance;                   //委托总额(个人+跟单)
@property (copy, nonatomic) NSString *dealTolBalance;               //总的成交额
@property (copy, nonatomic) NSString *serviceShare;                 //技术服务费
@property (copy, nonatomic) NSString *dealFee;                      //我的手续费
@property (copy, nonatomic) NSString *followDealFee;                //跟单的手续费
@property (copy, nonatomic) NSString *dealTolFee;                   //总的手续费





@end


