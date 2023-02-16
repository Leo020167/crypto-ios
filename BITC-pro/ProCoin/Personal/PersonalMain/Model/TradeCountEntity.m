//
//  TradeCountEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/11.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TradeCountEntity.h"

@implementation TradeCountEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.num = [self stringParser:@"num" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.profit = [self stringParser:@"profit" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_num release];
    [_symbol release];
    [_profit release];
    [super dealloc];
}

@end
