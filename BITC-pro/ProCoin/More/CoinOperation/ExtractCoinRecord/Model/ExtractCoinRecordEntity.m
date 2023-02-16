//
//  ExtractCoinRecordEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "ExtractCoinRecordEntity.h"


@implementation ExtractCoinRecordEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.symbol = [self stringParser:@"symbol" json:json];
        self.stateDesc = [self stringParser:@"stateDesc" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.address = [self stringParser:@"address" json:json];
        self.fee = [self stringParser:@"fee" json:json];
        self.dwId = [self stringParser:@"dwId" json:json];
        self.state = [self integerParser:@"state" json:json];
        self.inOut = [self integerParser:@"inOut" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_symbol release];
    [_stateDesc release];
    [_amount release];
    [_createTime release];
    [_address release];
    [_fee release];
    [_dwId release];
    [super dealloc];
}

@end
