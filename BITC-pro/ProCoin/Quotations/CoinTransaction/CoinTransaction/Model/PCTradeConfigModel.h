//
//  PCTradeConfigModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/25.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCTradeConfigModel : TJRBaseEntity

@property (copy, nonatomic) NSString *accountName;  //账户名称

/// 账户类型  stock 全球指数 digital 合约 spot 币币
@property (copy, nonatomic) NSString *accountType;
@property (copy, nonatomic) NSString *openFeeScale;
@property (assign, nonatomic) NSInteger priceDecimals;      //小数位数
@property (copy, nonatomic) NSString *usdtRate;     //usdt汇率
@property (copy, nonatomic) NSArray<NSString *> *handList;          //手数默认提供数组
@property (copy, nonatomic) NSArray<NSString *> *multiNumList;       //倍数数组
@property (copy, nonatomic) NSArray<NSNumber *> *openRateList;  //购买百分比

/// 币种
@property (nonatomic, copy) NSString *symbol;

@end

NS_ASSUME_NONNULL_END
