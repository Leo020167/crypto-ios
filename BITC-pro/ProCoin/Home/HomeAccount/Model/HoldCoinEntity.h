//
//  HoldCoinEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface HoldCoinEntity : TJRBaseEntity

//amount = "8.98200000";
//market = "0.7400";
//marketCny = "\U2248\U00a55.18";
//profit = "0.0008";
//profitRate = "0.11";
//symbol = ADA;
//userId = 5;

@property (copy, nonatomic) NSString *amount;               //数量
@property (copy, nonatomic) NSString *costPrice;            //成本均价
@property (copy, nonatomic) NSString *frozenAmount;         //冻结数量
@property (copy, nonatomic) NSString *holdAmount;           //可用数量
@property (assign, nonatomic) BOOL hide;                    //持仓是否是小额
@property (copy, nonatomic) NSString *market;
@property (copy, nonatomic) NSString *marketCny;
@property (copy, nonatomic) NSString *profit;
@property (copy, nonatomic) NSString *profitRate;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *originSymbol;
@property (copy, nonatomic) NSString *unitSymbol;
@property (copy, nonatomic) NSString *userId;

@end


