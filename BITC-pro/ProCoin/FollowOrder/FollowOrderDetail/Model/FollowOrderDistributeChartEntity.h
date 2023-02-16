//
//  FollowOrderDistributeChartEntity.h
//  Cropyme
//
//  Created by Hay on 2019/7/25.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface FollowOrderDistributeChartEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *balance;          //金额
@property (copy, nonatomic) NSString *rate;             //所占比例
@property (copy, nonatomic) NSString *symbol;           //币种
@property (copy, nonatomic) NSString *amount;           //数量

@end


