//
//  CoinOperationInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/9/11.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CoinOperationInfoEntity : TJRBaseEntity

/// 地址
@property (copy, nonatomic) NSString *address;

/// 手续费
@property (nonatomic, copy) NSString *fee;

/// 二维码图片
@property (nonatomic, copy) NSString *image;

/// 名称
@property (nonatomic, copy) NSString *type;

@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSArray *chainTypes;
@property (copy, nonatomic) NSString *inOutTip;
@property (copy, nonatomic) NSString *withdrawFee;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *minWithdrawAmt;
@property (assign, nonatomic) NSInteger maxWithdrawDecimals;

@end


@interface CoinChargeConfigAddress : NSObject
/// 地址
@property (copy, nonatomic) NSString *address;
/// 币种
@property (nonatomic, copy) NSString *symbol;
/// 链
@property (nonatomic, copy) NSString *chainType;
@end
 

/// {"availableAmount": "10","addressList": [{"address": "JKLJKSJGIOUIO454334","symbol": "BTC"}],"minChargeAmount": "1"}
@interface CoinChargeConfigEntity : NSObject

/// 可用
@property (copy, nonatomic) NSString *availableAmount;

/// 地址列表
@property (nonatomic, copy) NSArray<CoinChargeConfigAddress *> *addressList;

/// 最小充值
@property (nonatomic, copy) NSString *minChargeAmount;


@end








