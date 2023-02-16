//
//  PCHomeUserFollowOrderInfoModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/27.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCHomeUserFollowOrderInfoModel.h"

@implementation PCHomeUserFollowOrderInfoModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.dvUid = [self stringParser:@"dvUid" json:json];
        self.isOpen = [self boolParser:@"isOpen" json:json];
        self.multiple = [self stringParser:@"multiple" json:json];
        self.dvUserName = [self stringParser:@"dvUserName" json:json];
        self.dvHeadUrl = [self stringParser:@"dvHeadUrl" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_dvUid release];
    [_multiple release];
    [_dvUserName release];
    [_dvHeadUrl release];
    [_userId release];
    [super dealloc];
}

@end
