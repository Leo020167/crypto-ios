//
//  CoinTransactionDetailEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/28.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CoinTransactionDetailEntity : TJRBaseEntity

//buySell = 1;
//dealAmount = "3.000000";
//dealFee = "0.000000";
//dealPrice = "0.082166";
//symbol = ADA;
//timestamp = 1559714529423;
@property (copy, nonatomic) NSString *timestamp;            //创建时间
@property (copy, nonatomic) NSString *dealAmount;            //成交数量
@property (copy, nonatomic) NSString *dealFee;            //成交手续费
@property (copy, nonatomic) NSString *dealPrice;            //成交价格
@property (copy, nonatomic) NSString *symbol;               //交易对
@property (copy, nonatomic) NSString *originSymbol;         //币种
@property (copy, nonatomic) NSString *unitSymbol;           //计价单位
@property (copy, nonatomic) NSString *buySell;          //买卖方向


@end


