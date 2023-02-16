//
//  AccountAssetsEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface AccountAssetsEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *todayProfit;
@property (copy, nonatomic) NSString *tolAssetsCny;
@property (copy, nonatomic) NSString *tolAssets;
@property (copy, nonatomic) NSString *tolProfit;
@property (copy, nonatomic) NSString *usdtBalance;

@end


