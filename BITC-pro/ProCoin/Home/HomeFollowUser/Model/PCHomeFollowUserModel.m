//
//  PCHomeFollowUserModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/23.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCHomeFollowUserModel.h"

@implementation PCHomeFollowUserModel

//@property (copy, nonatomic) NSString *correctRate;
//@property (copy, nonatomic) NSString *days;
//@property (copy, nonatomic) NSString *headUrl;
//@property (copy, nonatomic) NSString *monthProfit;
//@property (copy, nonatomic) NSString *totalProfit;
//@property (copy, nonatomic) NSString *userId;
//@property (copy, nonatomic) NSString *userName;
- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.correctRate = [self stringParser:@"correctRate" json:json];
        self.days = [self stringParser:@"days" json:json];
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.monthProfit = [self stringParser:@"monthProfit" json:json];
        self.totalProfit = [self stringParser:@"totalProfit" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.expireTime = [self stringParser:@"expireTime" json:json];
        self.isExpireTime = [self boolParser:@"isExpireTime" json:json];
        self.subIsFee = [self boolParser:@"subIsFee" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_correctRate release];
    [_days release];
    [_headUrl release];
    [_monthProfit release];
    [_totalProfit release];
    [_userId release];
    [_userName release];
    [_expireTime release];
    [super dealloc];
}

@end
