//
//  FollowOrderInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/30.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FollowOrderInfoEntity.h"

@implementation FollowOrderInfoEntity


- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.followHeadUrl = [self stringParser:@"copyHeadUrl" json:json];
        self.followName = [self stringParser:@"copyName" json:json];
        self.followUid = [self stringParser:@"copyUid" json:json];
        self.market = [self stringParser:@"market" json:json];
        self.marketCny = [self stringParser:@"marketCny" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.tolBalance = [self stringParser:@"tolBalance" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_followHeadUrl release];
    [_followName release];
    [_followUid release];
    [_market release];
    [_marketCny release];
    [_orderId release];
    [_profit release];
    [_profitRate release];
    [_userId release];
    [_tolBalance release];
    [super dealloc];
}



@end
