//
//  TYMineModel.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/2.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYMineModel : NSObject

@end

@interface TYMineCommunityModel : NSObject

/// 可兑换数量
@property (nonatomic, copy) NSString *inviteCodePrice;

/// 社区人数
@property (nonatomic, copy) NSString *teamCount;

/// 邀请码数量
@property (nonatomic, copy) NSString *inviteCount;

/// 总佣金
@property (nonatomic, copy) NSString *sumAmount;

/// 邀请列表
@property (nonatomic, strong) NSArray *inviteList;

@end

@interface TYMineCommunityListModel : NSObject

/// 邀请码
@property (nonatomic, copy) NSString *inviteCode;

/// 0 未使用 1已使用
@property (nonatomic, assign) NSInteger status;


/// 下级id，status为0 不显示
@property (nonatomic, copy) NSString *inviteUserId;

/// 返佣，status为0 不显示
@property (nonatomic, copy) NSString *amount;

@end

NS_ASSUME_NONNULL_END
