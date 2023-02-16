//
//  PCTransferAccountModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/21.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransferAccountModel.h"

@implementation PCTransferAccountModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.accountType = [self stringParser:@"accountType" json:json];
        self.accountName = [self stringParser:@"accountName" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_accountType release];
    [_accountName release];
    [super dealloc];
}

@end
