//
//  CostChartEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/13.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CostChartEntity.h"

//@property (copy, nonatomic) NSString *amount;           //数量
//@property (copy, nonatomic) NSString *fromPrice;        //价格区间
//@property (copy, nonatomic) NSString *toPrice;          //价格区间
//@property (copy, nonatomic) NSString *price;            //价格
//@property (copy, nonatomic) NSString *rate;             //比例

@implementation CostChartEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.fromPrice = [self stringParser:@"fromPirce" json:json];
        self.toPrice = [self stringParser:@"toPirce" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.rate = [self stringParser:@"rate" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_fromPrice release];
    [_toPrice release];
    [_price release];
    [_rate release];
    [super dealloc];
}

@end
