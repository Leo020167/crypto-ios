//
//  CoinSubscribeEntity.h
//  Cropyme
//
//  Created by Hay on 2019/9/6.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CoinSubscribeEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *mySubAmount;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *priceCny;
@property (copy, nonatomic) NSString *produceAmount;
@property (copy, nonatomic) NSString *subId;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *originSymbol;
@property (copy, nonatomic) NSString *totalAmount;
@property (copy, nonatomic) NSArray *balanceList;

@end


