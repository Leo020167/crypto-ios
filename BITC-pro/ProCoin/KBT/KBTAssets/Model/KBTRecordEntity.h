//
//  KBTRecordEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

//amount = "156.9";
//createTime = 1565776824;
//inOut = 1;
//tradeId = 0;
//tradeType = 3;
//tradeTypeDesc = "\U80fd\U529b\U503c\U5151\U6362\U83b7\U5f97";
//userId = 14;

@interface KBTRecordEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *createTime;
@property (assign, nonatomic) NSInteger inOut;
@property (copy, nonatomic) NSString *tradeId;
@property (assign, nonatomic) NSInteger tradeType;
@property (copy, nonatomic) NSString *tradeTypeDesc;
@property (copy, nonatomic) NSString *userId;

@end


