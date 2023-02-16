//
//  MineDelegateInfoModel.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/29.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineDelegateInfoModel : NSObject

/// 代理类型 0普通用户 1代理 -1 管理员
@property (nonatomic, assign) NSInteger agentType;

/// xx
@property (nonatomic, copy) NSString *sumCommission;

/// 等级id
@property (nonatomic, copy) NSString *levelId;

/// 升级费用
@property (nonatomic, copy) NSString *upgradeAmout;

/// 升级后的名称
@property (nonatomic, copy) NSString *upgradeName;

/// 是否显示升级按钮
@property (nonatomic, assign) BOOL upgradeFlag;

/// 总邀请人数
@property (nonatomic, copy) NSString *sumMyAdd;

/// 可邀请人数
@property (nonatomic, copy) NSString *remainInviteCount;

/// 当前代理等级
@property (nonatomic, copy) NSString *levelName;

/// 今日新增用户数量
@property (nonatomic, copy) NSString *todayAdd;

/// 昨日新增用户数量
@property (nonatomic, copy) NSString *yesterdayAdd;

/// 今日佣金
@property (nonatomic, copy) NSString *todayCommission;

/// 昨日佣金
@property (nonatomic, copy) NSString *yesterdayCommission;

/// 今日交易额
@property (nonatomic, copy) NSString *todayTrade;

/// 昨日交易额
@property (nonatomic, copy) NSString *yesterdayTrade;

/// 用户id
@property (nonatomic, copy) NSString *userId;

/// 邀请码
@property (nonatomic, copy) NSString *inviteCode;

@end

NS_ASSUME_NONNULL_END
