//
//  CDFollowBalanceInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CDFollowBalanceInfoEntity.h"

@implementation CDFollowBalanceInfoEntity


- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.nextUsableBalance = [self stringParser:@"nextUsableBalance" json:json];
        self.profit = [self stringParser:@"profit" json:json];
        self.totalBalance = [self stringParser:@"totalBalance" json:json];
        self.usableBalance = [self stringParser:@"usableBalance" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.userName = [self stringParser:@"userName" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_nextUsableBalance release];
    [_profit release];
    [_totalBalance release];
    [_usableBalance release];
    [_userId release];
    [_userName release];
    [super dealloc];
}


@end
