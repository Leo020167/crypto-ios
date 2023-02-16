//
//  AccountStoreModel.m
//  BYY
//
//  Created by Hay on 2019/12/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "AccountStoreModel.h"

@implementation AccountStoreModel

//@property (nonatomic, copy) NSString *amount;
//@property (nonatomic, copy) NSString *amountSymbol;
//@property (nonatomic, copy) NSString *amountTip;
//@property (nonatomic, copy) NSString *profit;
//@property (nonatomic, copy) NSString *profitSymbol;
//@property (nonatomic, copy) NSString *profitTip;
//@property (nonatomic, copy) NSString *storeSymbol;
//@property (nonatomic, copy) NSString *userId;

- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super init]){
        self.amount = [self stringParser:@"amount" json:json];
        self.amountSymbol = [self stringParser:@"amountSymbol" json:json];
        self.amountTip = [self stringParser:@"amountTip" json:json];
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
    [_profit release];
    [_profitSymbol release];
    [_profitTip release];
    [_storeSymbol release];
    [_userId release];
    [super dealloc];
}

@end
