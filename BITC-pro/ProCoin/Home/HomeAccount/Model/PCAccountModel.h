//
//  PCAccountModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/18.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"
#import "PCHomeUserFollowOrderInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCAccountModel : TJRBaseEntity


@property (copy, nonatomic) NSString *accountType;      //账户类型
@property (copy, nonatomic) NSString *assets;           //账户总资产
@property (copy, nonatomic) NSString *assetsCny;        //账户总资产(人民币值)
@property (copy, nonatomic) NSString *eableBail;        //可用保证金
@property (copy, nonatomic) NSString *frozenAmount;     //冻结数量
@property (copy, nonatomic) NSString *frozenBail;       //冻结保证金
@property (copy, nonatomic) NSString *holdAmount;       //持有数量
@property (copy, nonatomic) NSString *openBail;         //持仓保证金
@property (copy, nonatomic) NSString *profit;           //未实现盈亏
@property (copy, nonatomic) NSString *riskRate;         //风险率
@property (copy, nonatomic) NSString *userId;           //用户id
@property (copy, nonatomic) NSArray *entrustArr;        //委托订单列表
@property (copy, nonatomic) NSArray *openArr;           //开仓订单列表

/// 1国际期货 2外汇 3数字
@property (nonatomic, assign) NSInteger type;

/// 跟单冻结资产
@property (nonatomic, copy) NSString *disableAmount;

@property (nonatomic, strong) PCHomeUserFollowOrderInfoModel *dvModel;

/// 跟单列表
@property (nonatomic, strong) NSArray *openList;

/// 餘額幣種列表
@property (nonatomic, strong) NSArray *symbolList;

@end

/// SymbolList
@interface PCAccountSymbolModel : TJRBaseEntity


@property (copy, nonatomic) NSString *symbol;      //幣種
@property (copy, nonatomic) NSString *holdAmount;           //
@property (copy, nonatomic) NSString *usdtAmount;        //
@property (copy, nonatomic) NSString *frozenAmount;     //冻结数量
@property (copy, nonatomic) NSString *sumAmount;       //
@property (copy, nonatomic) NSString *userId;           //用户id

@end

NS_ASSUME_NONNULL_END
