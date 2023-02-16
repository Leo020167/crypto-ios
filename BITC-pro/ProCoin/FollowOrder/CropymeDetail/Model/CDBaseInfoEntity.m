//
//  CDBaseInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/8.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CDBaseInfoEntity.h"

@implementation CDBaseInfoEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.predictProfitShare = [self stringParser:@"predictProfitShare" json:json];
        self.totalFollowBalance = [self stringParser:@"totalCopyBalance" json:json];
        self.totalProfitShare = [self stringParser:@"totalProfitShare" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_predictProfitShare release];
    [_totalFollowBalance release];
    [_totalProfitShare release];
    [super dealloc];
}

@end
