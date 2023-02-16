//
//  PersonalMainFollowModel.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/7.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonalMainFollowModel : NSObject

/// 跟单账户类型 0数字货币 1国际期货 2外汇
@property (nonatomic, copy) NSString *accountType;

@property (nonatomic, copy) NSString *createTime;

/// 跟单持续天数
@property (nonatomic, copy) NSString *duration;

/// 大V的uid
@property (nonatomic, copy) NSString *dvUid;

/// 跟单类型的id
@property (nonatomic, copy) NSString *id;

/// 跟单限额
@property (nonatomic, copy) NSString *limit;

/// 注：设置带单亏损补贴（%），10=%10，请四算时记得
@property (nonatomic, copy) NSString *lossRate;

/// 注：设置带单盈利分成（%），10=%10，请四算时记得
@property (nonatomic, copy) NSString *profitRate;

/// 备注
@property (nonatomic, copy) NSString *remark;

/// 更新时间
@property (nonatomic, copy) NSString *updateTime;

@property (nonatomic, assign) NSInteger row;

/// 最大绑定倍数
@property (nonatomic, assign) NSInteger maxMultiNum;

/// 最小绑定倍数
@property (nonatomic, assign) NSInteger minMultiNum;

/// 当前绑定
@property (nonatomic, assign) NSInteger isBind;

/// 花费token
@property (nonatomic, copy) NSString *tokenAmount;

/// 到期时间
@property (nonatomic, copy) NSString *expireTime;

@end

NS_ASSUME_NONNULL_END
