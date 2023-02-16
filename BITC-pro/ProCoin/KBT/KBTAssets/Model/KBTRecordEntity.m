//
//  KBTRecordEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTRecordEntity.h"

;

@implementation KBTRecordEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.inOut = [self integerParser:@"inOut" json:json];
        self.tradeId = [self stringParser:@"tradeId" json:json];
        self.tradeType = [self integerParser:@"tradeType" json:json];
        self.tradeTypeDesc = [self stringParser:@"tradeTypeDesc" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_createTime release];
    [_tradeId release];
    [_tradeTypeDesc release];
    [_userId release];
    [super dealloc];
}

@end
