//
//  HomeMineDataEntity.m
//  Cropyme
//
//  Created by Hay on 2019/7/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "HomeMineDataEntity.h"

@implementation HomeMineDataEntity

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.fansCount = [self stringParser:@"fansCount" json:json];
        self.followCount = [self stringParser:@"followCount" json:json];
        self.followNum = [self stringParser:@"copyNum" json:json];
        self.byyAmount = [self stringParser:@"byyAmount" json:json];
        self.usdtBalance = [self stringParser:@"usdtBalance" json:json];
        self.abilityValue = [self stringParser:@"abilityValue" json:json];
        self.openFollow = [self integerParser:@"openCopy" json:json];
        self.predictProfitShare = [self stringParser:@"predictProfitShare" json:json];
        self.totalProfitShare = [self stringParser:@"totalProfitShare" json:json];
        self.score = [self stringParser:@"score" json:json];
        self.shareUrl = [self stringParser:@"shareUrl" json:json];
        self.latestMsgTitle = [self stringParser:@"latestMsgTitle" json:json];
        self.helpCenterUrl = [self stringParser:@"helpCenterUrl" json:json];
        self.aboutUsUrl = [self stringParser:@"aboutUsUrl" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.applyCoinUrl = [self stringParser:@"applyCoinUrl" json:json];
        self.equityLevel = [self stringParser:@"equityLevel" json:json];
        self.coinApplyTip = [self stringParser:@"coinApplyTip" json:json];
        self.msgCount = [self integerParser:@"msgCount" json:json];
        self.usdtAmount = [self stringParser:@"usdtAmount" json:json];
    }
    return self;
}



- (void)dealloc
{
    [_fansCount release];
    [_followCount release];
    [_followNum release];
    [_byyAmount release];
    [_usdtBalance release];
    [_abilityValue release];
    [_predictProfitShare release];
    [_totalProfitShare release];
    [_score release];
    [_shareUrl release];
    [_latestMsgTitle release];
    [_helpCenterUrl release];
    [_aboutUsUrl release];
    [_symbol release];
    [_applyCoinUrl release];
    [_equityLevel release];
    [_coinApplyTip release];
    [super dealloc];
}
@end
