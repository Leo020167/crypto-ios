//
//  PCAccountModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/18.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCAccountModel.h"

@implementation PCAccountModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.accountType = [self stringParser:@"accountType" json:json];
        self.assets = [self stringParser:@"assets" json:json];
        self.assetsCny = [self stringParser:@"assetsCny" json:json];
        self.eableBail = [self stringParser:@"eableBail" json:json];
        self.frozenAmount = [self stringParser:@"frozenAmount" json:json];
        self.frozenBail = [self stringParser:@"frozenBail" json:json];
        self.holdAmount = [self stringParser:@"holdAmount" json:json];
        self.openBail = [self stringParser:@"openBail" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.riskRate = [self stringParser:@"riskRate" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.disableAmount = [self stringParser:@"disableAmount" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_accountType release];
    [_assets release];
    [_assetsCny release];
    [_eableBail release];
    [_frozenAmount release];
    [_frozenBail release];
    [_holdAmount release];
    [_openBail release];
    [_profit release];
    [_riskRate release];
    [_userId release];
    [_entrustArr release];
    [_openArr release];
    [super dealloc];
}

@end



@implementation PCAccountSymbolModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.symbol = [self stringParser:@"symbol" json:json];
        self.frozenAmount = [self stringParser:@"frozenAmount" json:json];
        self.holdAmount = [self stringParser:@"holdAmount" json:json];
        self.usdtAmount = [self stringParser:@"usdtAmount" json:json];
        self.sumAmount = [self stringParser:@"sumAmount" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_sumAmount release];
    [_frozenAmount release];
    [_usdtAmount release];
    [_holdAmount release];
    [_userId release];
    [_symbol release];
    [super dealloc];
}

@end

