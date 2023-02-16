//
//  CoinTradeGearEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CoinTradeGearEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *depthRate;

@end


