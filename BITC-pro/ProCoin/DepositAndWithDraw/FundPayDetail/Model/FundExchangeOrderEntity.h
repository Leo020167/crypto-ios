//
//  FundExchangeOrderEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface FundExchangeOrderEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *balanceCny;                //后台返回充值提现金额
@property (copy, nonatomic) NSString *amount;                    //充值或提现数量
@property (copy, nonatomic) NSString *priceCny;                  //单价
@property (copy, nonatomic) NSString *createTime;                //创建时间
@property (copy, nonatomic) NSString *expireTime;                //交易过期时间，格式是时间戳
@property (copy, nonatomic) NSString *inOutId;                   //交易id
@property (copy, nonatomic) NSString *orderCashId;               //订单号
/** state 状态
 (0, "待付款"),(1, "已标记付款"),(2, "已完成"), (-1, "已过期"),(-2, "已撤销"), (-3, "系统撤销");
 */
@property (assign, nonatomic) NSInteger state;                   //订单状态
@property (copy, nonatomic) NSString *stateDesc;               //订单状态描述

@end


