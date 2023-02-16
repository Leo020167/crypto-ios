//
//  PCTransferRecordModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCTransferRecordModel : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *fromAccountType;
@property (copy, nonatomic) NSString *toAccountType;
@property (copy, nonatomic) NSString *transferId;
@property (copy, nonatomic) NSString *typeValue;
@property (copy, nonatomic) NSString *userId;

@end

NS_ASSUME_NONNULL_END
