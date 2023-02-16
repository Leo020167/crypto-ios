//
//  InfluencerRankEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"






@interface InfluencerRankEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *correctRate;
@property (copy, nonatomic) NSString *days;
@property (copy, nonatomic) NSString *headUrl;
@property (copy, nonatomic) NSString *monthProfit;
@property (copy, nonatomic) NSString *totalProfit;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *userId;

/// 最大跟单倍数
@property (nonatomic, assign) NSInteger maxMultiNum;

@end


