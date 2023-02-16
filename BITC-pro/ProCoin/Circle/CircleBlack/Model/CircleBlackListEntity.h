//
//  CircleMemberEntity.h
//  Tjrv
//
//  Created by taojinroad on 2019/2/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface CircleBlackListEntity : TJRBaseEntity

@property (nonatomic, copy) NSString *circleId;    // 圈号
@property (nonatomic, copy) NSString* blackId;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* headUrl;
@end

NS_ASSUME_NONNULL_END
