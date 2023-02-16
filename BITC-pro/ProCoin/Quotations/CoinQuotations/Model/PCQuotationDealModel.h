//
//  PCQuotationDealModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/26.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCQuotationDealModel : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *buySell;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *time;

@end

NS_ASSUME_NONNULL_END
