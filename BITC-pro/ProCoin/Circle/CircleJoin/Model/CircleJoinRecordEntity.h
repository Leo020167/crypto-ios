//
//  CircleJoinRecordEntity.h
//  Tjrv
//
//  Created by taojinroad on 2019/2/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"

typedef enum
{
    CANCEL_APPLY = -1,                          //已拒绝
    HAVE_APPLY,                                 //未处理
    PASS_APPLY                                  //已通过
    
}JOINAPPLYSTATE;

NS_ASSUME_NONNULL_BEGIN

@interface CircleJoinRecordEntity : TJRBaseEntity

@property (nonatomic, copy) NSString *circleId;    // 圈号
@property (nonatomic, copy) NSString *applyId;
@property (nonatomic, copy) NSString* handleUserName;
@property (nonatomic, copy) NSString* handleUid;
@property (nonatomic, copy) NSString* createTime;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* headUrl;
@property (nonatomic, copy) NSString* reason;
@property (nonatomic, assign) NSInteger status;
@end

NS_ASSUME_NONNULL_END
