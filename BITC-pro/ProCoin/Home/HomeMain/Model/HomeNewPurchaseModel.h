//
//  HomeNewPurchaseModel.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/29.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeNewPurchaseModel : NSObject

/// 数字货币申购id
@property (nonatomic, copy) NSString *id;

/// 数字货币交易对名称
@property (nonatomic, copy) NSString *symbol;

/// 本轮开始时间
@property (nonatomic, copy) NSString *startTime;

/// 本轮结束时间
@property (nonatomic, copy) NSString *endTime;

/// 上市交易时间
@property (nonatomic, copy) NSString *tradeTime;

/// 上市解仓时间
@property (nonatomic, copy) NSString *liftBanTime;

/// 申购总量
@property (nonatomic, copy) NSString *allSum;

/// 本次已申购数量
@property (nonatomic, copy) NSString *alCount;

/// 本次可申购数量
@property (nonatomic, copy) NSString *sum;

/// 兑换比例，如设置成100，则表示1新币=100USDT
@property (nonatomic, copy) NSString *rate;

/// 标题
@property (nonatomic, copy) NSString *title;

/// 项目简介
@property (nonatomic, copy) NSString *summary;

/// 发起人简介
@property (nonatomic, copy) NSString *authorSummary;

/// 项目详情
@property (nonatomic, copy) NSString *content;

/// 最小申购数量
@property (nonatomic, copy) NSString *min;

/// 最小申购数量
@property (nonatomic, copy) NSString *max;

/// 状态：0 待开始，1 申购中，2 已结束
@property (nonatomic, assign) NSInteger state;

/// 我的账户余额
@property (nonatomic, copy) NSString *userCount;

/// 图片
@property (nonatomic, copy) NSString *image;

/// 项目参与条件
@property (nonatomic, copy) NSString *condition;

/// 风险提示
@property (nonatomic, copy) NSString *warning;

/// 不支持的国家和地区
@property (nonatomic, copy) NSString *expCountry;

/// 申购说明
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *timeStr;


@end

@interface HomeNewPurchaseListModel : NSObject

/// 数字货币交易对名称
@property (nonatomic, copy) NSString *symbol;

/// 图片
@property (nonatomic, copy) NSString *image;

/// 状态：0 待开始，1 申购中，2 已结束
@property (nonatomic, assign) NSInteger state;

/// 名称
@property (nonatomic, copy) NSString *summary;

/// id
@property (nonatomic, copy) NSString *id;

/// 本轮开始时间
@property (nonatomic, copy) NSString *startTime;

/// 本轮结束时间
@property (nonatomic, copy) NSString *endTime;

/// 本轮已申购
@property (nonatomic, copy) NSString *alAmount;

/// 本轮可申购总量
@property (nonatomic, copy) NSString *amount;

/// 申购总量
@property (nonatomic, copy) NSString *sumAmount;

@end

NS_ASSUME_NONNULL_END
