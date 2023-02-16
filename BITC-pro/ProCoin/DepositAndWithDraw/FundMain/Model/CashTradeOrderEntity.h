//
//  CashTradeOrderEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/24.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CashTradeOrderEntity : TJRBaseEntity

//amount = 0;
//balance = "0.78970588";
//balanceCash = "5.37";
//buySell = 1;
//createTime = 1558610631;
//doneTime = 1558610732;
//expireTime = 1558612431;
//handleUid = 80817;
//isLimit = 1;
//orderCashId = 97;
//orderId = 0;
//price = 1;
//priceCash = "6.8";
//receiptId = 3;
//state = 2;
//stateDesc = "\U5df2\U5b8c\U6210";
//symbol = USDT;
//usdtRate = "6.8";
//userId = 80818;
@property (copy, nonatomic) NSString *buySell;          //1为充值和购买，-1为提现和卖出
@property (copy, nonatomic) NSString *symbol;           //币种
@property (copy, nonatomic) NSString *stateDesc;        //状态描述
@property (assign, nonatomic) NSInteger state;          //状态
@property (copy, nonatomic) NSString *balanceCny;       //充值的金额
@property (copy, nonatomic) NSString *priceCny;        //买入某币的买入价
@property (copy, nonatomic) NSString *createTime;       //创建时间
@property (copy, nonatomic) NSString *orderCashId;      //订单id
@property (copy, nonatomic) NSString *chatTopic;

@end


