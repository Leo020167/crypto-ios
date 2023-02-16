//
//  QuotationCoinBaseEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"


@interface QuotationCoinBaseEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *priceCNY;
@property (copy, nonatomic) NSString *rate;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *originSymbol;
@property (copy, nonatomic) NSString *unitSymbol;
@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *tip;          //提示该币种的来源
@property (copy, nonatomic) NSString *marketType;   //币种类型

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *openMarketStr;
@property (copy, nonatomic) NSString *currency;
@end

