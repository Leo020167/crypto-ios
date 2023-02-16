//
//  CircleMemberEntity.h
//  Tjrv
//
//  Created by taojinroad on 2019/2/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"

#define CRICLE_ROLE_ILLEGAL             -1      // 无效
#define CRICLE_ROLE_MEMBER              0       // 成员
#define CRICLE_ROLE_ADMIN               10      // 管理员
#define CRICLE_ROLE_ROOT                20      // 圈主

NS_ASSUME_NONNULL_BEGIN

@interface CircleMemberEntity : TJRBaseEntity

@property (nonatomic, copy) NSString *circleId;    // 圈号
@property (nonatomic, copy) NSString* createTime;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* headUrl;
@property (nonatomic, assign) NSInteger role;
@end

NS_ASSUME_NONNULL_END
