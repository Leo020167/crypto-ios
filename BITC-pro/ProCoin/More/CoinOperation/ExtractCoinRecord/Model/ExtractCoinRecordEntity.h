//
//  ExtractCoinRecordEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface ExtractCoinRecordEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *stateDesc;
@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *fee;
@property (copy, nonatomic) NSString *dwId;
@property (assign, nonatomic) NSInteger state;
@property (assign, nonatomic) NSInteger inOut;

@end

