//
//  PCTransferAccountModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/21.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

//accountName = "\U6570\U5b57\U8d27\U5e01\U8d26\U6237";
//accountType = digital;

@interface PCTransferAccountModel : TJRBaseEntity

@property (copy, nonatomic) NSString *accountType;          //账户类型
@property (copy, nonatomic) NSString *accountName;          //账户类型名称

@end

NS_ASSUME_NONNULL_END
