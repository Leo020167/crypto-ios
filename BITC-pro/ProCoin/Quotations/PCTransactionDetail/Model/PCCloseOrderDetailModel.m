//
//  PCCloseOrderDetailModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/27.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCCloseOrderDetailModel.h"

@implementation PCCloseOrderDetailModel



- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.closeBail = [self stringParser:@"closeBail" json:json];
        self.closePrice = [self stringParser:@"closePrice" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.closeHand = [self stringParser:@"closeHand" json:json];
        self.closeFee = [self stringParser:@"closeFee" json:json];
        self.closeTime = [self stringParser:@"closeTime" json:json];
        self.profitShare = [self stringParser:@"profitShare" json:json];
        self.lossShare = [self stringParser:@"lossShare" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_closeBail release];
    [_closePrice release];
    [_profit release];
    [_closeHand release];
    [_closeFee release];
    [_closeTime release];
    [_profitShare release];
    [_lossShare release];
    [super dealloc];
}

@end
