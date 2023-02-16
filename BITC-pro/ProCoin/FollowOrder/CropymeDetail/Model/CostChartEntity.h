//
//  CostChartEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/13.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CostChartEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;           //数量
@property (copy, nonatomic) NSString *fromPrice;        //价格区间
@property (copy, nonatomic) NSString *toPrice;          //价格区间
@property (copy, nonatomic) NSString *price;            //价格
@property (copy, nonatomic) NSString *rate;             //比例

@end


