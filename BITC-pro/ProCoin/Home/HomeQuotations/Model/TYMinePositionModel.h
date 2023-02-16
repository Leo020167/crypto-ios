//
//  TYMinePositionModel.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/3.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYMinePositionModel : NSObject

/// 可用数量
@property (nonatomic, copy) NSString *availableAmount;

/// usdt
@property (nonatomic, copy) NSString *usdtAmount;

/// 凍結  委託
@property (nonatomic, copy) NSString *frozenAmount;
/// 货币符号
@property (nonatomic, copy) NSString *symbol;

/// 持仓均价
@property (nonatomic, copy) NSString *price;

/// 持仓收益
@property (nonatomic, copy) NSString *profit;

/// 用户id
@property (nonatomic, copy) NSString *userId;

/// 详情
/// 盈亏比率
@property (nonatomic, copy) NSString *profitRate;

/// 数量
@property (nonatomic, copy) NSString *amount;

/// 现价
@property (nonatomic, copy) NSString *last;

/// 比率
@property (nonatomic, copy) NSString *rate;


@end

NS_ASSUME_NONNULL_END
