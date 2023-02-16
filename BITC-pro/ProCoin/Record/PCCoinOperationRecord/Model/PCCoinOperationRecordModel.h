//
//  PCCoinOperationRecordModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/9.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN


@interface PCCoinOperationRecordModel : TJRBaseEntity

@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *chainType;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *dwId;
@property (copy, nonatomic) NSString *fee;

/// 1：充币，-1：提币，2：申购冻结，3:申购成功转换，4：申购失败退回
@property (assign, nonatomic) NSInteger inOut;      //
@property (copy, nonatomic) NSString *realAmount;
@property (assign, nonatomic) PCCoinOperationState state;
@property (copy, nonatomic) NSString *stateDesc;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *userId;

/// 解仓时间
@property (nonatomic, copy) NSString *transferTime;

/// 申购币种
@property (nonatomic, copy) NSString *subSymbol;

/// 标题
@property (nonatomic, copy) NSString *subTitle;

/// 备注
@property (nonatomic, copy) NSString *remark;

@end

NS_ASSUME_NONNULL_END
