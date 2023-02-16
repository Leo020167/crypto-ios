//
//  FollowOrderInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/30.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface FollowOrderInfoEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *followHeadUrl;
@property (copy, nonatomic) NSString *followName;
@property (copy, nonatomic) NSString *followUid;
@property (copy, nonatomic) NSString *market;               //市值
@property (copy, nonatomic) NSString *marketCny;            //市值描述
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *profit;               //收益
@property (copy, nonatomic) NSString *profitRate;           //收益率
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *tolBalance;           //跟单总投入

@end


