//
//  StoreRecordModel.h
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

//amount = "100.00000000";
//createTime = 1576747268;
//inOut = 1;
//isDone = 0;
//recordId = 13;
//remark = "\U8f6c\U5165USDT";
//storeSymbol = USDT;
//storeType = "in_capital";
//targetSymbol = USDT;
//userId = 500021;

typedef NS_ENUM(NSInteger ,StoreTransferDirection){
    StoreTransferDirectionOut = -1,
    StoreTransferDirectionIn = 1,
};


@interface StoreRecordModel : TJRBaseEntity

@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, assign) NSInteger inOut;
@property (nonatomic, assign) StoreTransferDirection isDone;
@property (nonatomic, copy) NSString *recordId;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *storeSymbol;
@property (nonatomic, copy) NSString *storeType;
@property (nonatomic, copy) NSString *targetSymbol;
@property (nonatomic, copy) NSString *userId;
@end

