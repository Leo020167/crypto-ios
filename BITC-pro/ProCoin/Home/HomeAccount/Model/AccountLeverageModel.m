//
//  AccountLeverageModel.m
//  BYY
//
//  Created by Hay on 2020/1/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "AccountLeverageModel.h"

@implementation AccountLeverageModel

//@property (copy, nonatomic) NSString *buySellStr;
//@property (copy, nonatomic) NSString *multiNum;
//@property (copy, nonatomic) NSString *orderId;
//@property (copy, nonatomic) NSString *profit;
//@property (copy, nonatomic) NSString *rate;
//@property (copy, nonatomic) NSString *symbol;
//@property (copy, nonatomic) NSString *time;
//@property (copy, nonatomic) NSString *userId;

- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.buySellStr = [self stringParser:@"buySellStr" json:json];
        self.multiNum = [self stringParser:@"multiNum" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.rate = [self stringParser:@"rate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.time = [self stringParser:@"time" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_buySellStr release];
    [_multiNum release];
    [_orderId release];
    [_profit release];
    [_rate release];
    [_symbol release];
    [_time release];
    [_userId release];
    [super dealloc];
}
@end
