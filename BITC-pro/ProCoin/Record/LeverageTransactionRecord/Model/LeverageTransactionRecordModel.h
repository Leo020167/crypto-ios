//
//  LeverageTransactionRecordModel.h
//  BYY
//
//  Created by Hay on 2019/12/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

@interface LeverageTransactionRecordModel : TJRBaseEntity

@property (copy, nonatomic) NSString *buySellStr;
@property (copy, nonatomic) NSString *multiNum;
@property (copy, nonatomic) NSString *openCostPrice;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *profit;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSString *userId;

@end

