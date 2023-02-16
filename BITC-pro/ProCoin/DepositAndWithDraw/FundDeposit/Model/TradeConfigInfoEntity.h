//
//  TradeConfigInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/23.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface TradeConfigInfoEntity : TJRBaseEntity

//frozenUsdt = "0.00000000";
//holdUsdt = "2.11154140";
//tolCash = "15.26";
//tolUsdt = "2.11154140";

@property (copy, nonatomic) NSString *holdCash;         //现金余额
@property (copy, nonatomic) NSString *holdUsdt;         //USDT余额
@property (copy, nonatomic) NSString *tolCash;          //总共Cash
@property (copy, nonatomic) NSString *tolUsdt;          //总共USDT
@property (copy, nonatomic) NSString *frozenUsdt;       //冻结USDT
@property (copy, nonatomic) NSString *holdCoin;         //持有某个币余额
@property (copy, nonatomic) NSString *randomNum;        //现金余额
@property (copy, nonatomic) NSString *usdtRate;         //USDT汇率
@property (copy, nonatomic) NSString *usdtRateWithdraw;         //提现的USDT汇率(只在提现中使用)
@property (copy, nonatomic) NSString *noticeMsg;        //通知消息 (在充值提现中使用到)
@property (copy, nonatomic) NSString *minFollowBalance;       //最小跟单数量
@property (copy, nonatomic) NSString *followFeeTip;     //跟单提示
@property (copy, nonatomic) NSString *minFollowAppendBalance; //最小追加数量

@end


