//
//  CDCostBaseEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CDCostBaseEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *amountDecimals;           //数量小数位数
@property (copy, nonatomic) NSString *avgCostPrice;             //平均成本价
@property (copy, nonatomic) NSString *price;                    //现价
@property (copy, nonatomic) NSString *priceDecimals;            //价格小数位数
@property (copy, nonatomic) NSString *profitRate;               //收益
@property (copy, nonatomic) NSString *symbol;                   //币种
@property (copy, nonatomic) NSString *totalAmount;              //总数量

@end


