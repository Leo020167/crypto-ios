//
//  FollowOrderRecordEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FollowOrderRecordEntity.h"

@implementation FollowOrderRecordEntity



- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.followHeadUrl = [self stringParser:@"copyHeadUrl" json:json];
        self.followName = [self stringParser:@"copyName" json:json];
        self.followUid = [self stringParser:@"copyUid" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.doneTime = [self stringParser:@"doneTime" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_followHeadUrl release];
    [_followName release];
    [_followUid release];
    [_orderId release];
    [_profit release];
    [_profitRate release];
    [_userId release];
    [_doneTime release];
    [super dealloc];
}

@end
