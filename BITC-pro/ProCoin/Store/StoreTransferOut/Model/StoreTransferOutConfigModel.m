//
//  StoreTransferOutConfigModel.m
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "StoreTransferOutConfigModel.h"

@implementation StoreTransferOutConfigModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.amountSymbol = [self stringParser:@"amountSymbol" json:json];
        self.amountTip = [self stringParser:@"amountTip" json:json];
        self.frozenAmount = [self stringParser:@"frozenAmount" json:json];
        self.holdAmount = [self stringParser:@"holdAmount" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.profitSymbol = [self stringParser:@"profitSymbol" json:json];
        self.profitTip = [self stringParser:@"profitTip" json:json];
        self.storeSymbol = [self stringParser:@"storeSymbol" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_amountSymbol release];
    [_amountTip release];
    [_frozenAmount release];
    [_holdAmount release];
    [_profit release];
    [_profitSymbol release];
    [_profitTip release];
    [_storeSymbol release];
    [_userId release];
    [super dealloc];
}

@end
