//
//  AccountAssetsInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/9/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "AccountAssetsInfoEntity.h"

@implementation AccountAssetsInfoEntity

//@property (copy, nonatomic) NSString *frozenAmount;
//@property (copy, nonatomic) NSString *lockAmount;
//@property (copy, nonatomic) NSString *totalAmount;
//@property (copy, nonatomic) NSString *totalCny;
//@property (copy, nonatomic) NSString *holdAmount;

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.frozenAmount = [self stringParser:@"frozenAmount" json:json];
        self.lockAmount = [self stringParser:@"lockAmount" json:json];
        self.totalAmount = [self stringParser:@"totalAmount" json:json];
        self.totalCny = [self stringParser:@"totalCny" json:json];
        self.holdAmount = [self stringParser:@"holdAmount" json:json];
        self.equityLevel = [self stringParser:@"equityLevel" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_frozenAmount release];
    [_lockAmount release];
    [_totalAmount release];
    [_totalCny release];
    [_holdAmount release];
    [_equityLevel release];
    [super dealloc];
}

@end
