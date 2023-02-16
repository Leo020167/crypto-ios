//
//  AccountAssetsEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "AccountAssetsEntity.h"

@implementation AccountAssetsEntity





- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.todayProfit = [self stringParser:@"todayProfit" json:json];
        self.tolAssetsCny = [self stringParser:@"tolAssetsCny" json:json];
        self.tolAssets = [self stringParser:@"tolAssets" json:json];
        self.tolProfit = [self stringParser:@"tolProfit" json:json];
        self.usdtBalance = [self stringParser:@"usdtBalance" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_todayProfit release];
    [_tolAssetsCny release];
    [_tolAssets release];
    [_tolProfit release];
    [_usdtBalance release];
    [super dealloc];
    
}

@end
