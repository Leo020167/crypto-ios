//
//  PCQuotationDealModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/26.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCQuotationDealModel.h"

@implementation PCQuotationDealModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.time = [self stringParser:@"time" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_buySell release];
    [_price release];
    [_time release];
    [super dealloc];
}

@end
