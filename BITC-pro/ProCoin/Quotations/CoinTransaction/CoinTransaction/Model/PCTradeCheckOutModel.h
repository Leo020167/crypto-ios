//
//  CoinTradeCheckOutEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/21.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"

@interface PCTradeCheckOutModel : TJRBaseEntity

/// 买入时最大可购买数量 或者可开手数
@property (copy, nonatomic) NSString *maxHand;

/// 买入时所需usdt
@property (copy, nonatomic) NSString *needMoney;

/// 买入时所需usdt 或者保证金
@property (copy, nonatomic) NSString *openBail;

/// 卖出时可卖出数量
@property (copy, nonatomic) NSString *availableAmount;

/// 卖出时价格换算后的usdt数量
@property (copy, nonatomic) NSString *usdtAmount;

/// 买入还是卖出  buy和sell
@property (nonatomic, copy) NSString *buySell;

@end

