//
//  AccountAssetsInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/9/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface AccountAssetsInfoEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *frozenAmount;
@property (copy, nonatomic) NSString *lockAmount;
@property (copy, nonatomic) NSString *totalAmount;
@property (copy, nonatomic) NSString *totalCny;
@property (copy, nonatomic) NSString *holdAmount;
@property (copy, nonatomic) NSString *equityLevel;          //权益说明

@end


