//
//  TradeConfigInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/23.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TradeConfigInfoEntity.h"

@implementation TradeConfigInfoEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.holdCash = [self stringParser:@"holdCash" json:json];
        self.holdCoin = [self stringParser:@"holdCoin" json:json];
        self.holdUsdt = [self stringParser:@"holdUsdt" json:json];
        self.tolCash = [self stringParser:@"tolCash" json:json];
        self.tolUsdt = [self stringParser:@"tolUsdt" json:json];
        self.frozenUsdt = [self stringParser:@"frozenUsdt" json:json];
        self.randomNum = [self stringParser:@"randomNum" json:json];
        self.usdtRate = [self stringParser:@"usdtRate" json:json];
        self.usdtRateWithdraw = [self stringParser:@"usdtRateWithdraw" json:json];
        self.noticeMsg = [self stringParser:@"noticeMsg" json:json];
        self.minFollowBalance = [self stringParser:@"minCopyBalance" json:json];
        self.followFeeTip = [self stringParser:@"copyFeeTip" json:json];
        self.minFollowAppendBalance = [self stringParser:@"minCopyAppendBalance" json:json];
    }
    return self;
}


- (void)dealloc
{
    [_holdCash release];
    [_holdCoin release];
    [_holdUsdt release];
    [_tolCash release];
    [_tolUsdt release];
    [_frozenUsdt release];
    [_randomNum release];
    [_usdtRate release];
    [_usdtRateWithdraw release];
    [_noticeMsg release];
    [_minFollowBalance release];
    [_followFeeTip release];
    [_minFollowAppendBalance release];
    [super dealloc];
}
@end
