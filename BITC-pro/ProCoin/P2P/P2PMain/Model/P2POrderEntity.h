//
//  P2POrderEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"

@interface P2POrderEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *adId;
@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *buySell;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *dealAmount;
@property (assign, nonatomic) NSInteger isOnline;
@property (assign, nonatomic) NSInteger isPayAli;
@property (assign, nonatomic) NSInteger isPayBank;
@property (assign, nonatomic) NSInteger isPayWx;
@property (copy, nonatomic) NSString *frozenAmount;
@property (copy, nonatomic) NSString *limitRate;
@property (copy, nonatomic) NSString *maxCny;               
@property (copy, nonatomic) NSString *minCny;
@property (copy, nonatomic) NSString *orderNum;
@property (assign, nonatomic) NSInteger synVersion;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *timeLimit;
@property (copy, nonatomic) NSString *updateTime;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userLogo;
@property (copy, nonatomic) NSString *userName;

@property (retain, nonatomic) NSMutableArray* payWayArray;

/// 币种符号
@property (nonatomic, copy) NSString *currencySign;

/// 要显示符号
@property (nonatomic, copy) NSString *currencyType;

@end


