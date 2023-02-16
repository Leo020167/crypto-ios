//
//  OTCTradeEntity.h
//  Cropyme
//
//  Created by Hay on 2019/9/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

@class OTCReceiptEntity;

@interface OTCTradeEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *headUrl;
@property (copy, nonatomic) NSString *maxCny;
@property (copy, nonatomic) NSString *minCny;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSArray<OTCReceiptEntity *> *receiptTypeArr;            //收款方式数组


@end


@interface OTCReceiptEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *receiptTypeLogo;
@property (copy, nonatomic) NSString *receiptTypeValue;
@property (copy, nonatomic) NSString *receiptType;
@property (copy, nonatomic) NSString *receiptId;
@property (copy, nonatomic) NSString *receiptDesc;

@end
