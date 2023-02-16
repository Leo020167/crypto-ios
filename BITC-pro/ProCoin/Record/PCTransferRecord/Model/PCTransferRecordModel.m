//
//  PCTransferRecordModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransferRecordModel.h"

@implementation PCTransferRecordModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.fromAccountType = [self stringParser:@"fromAccountType" json:json];
        self.toAccountType = [self stringParser:@"toAccountType" json:json];
        self.transferId = [self stringParser:@"transferId" json:json];
        self.typeValue = [self stringParser:@"typeValue" json:json];
        self.userId = [self stringParser:@"typeValue" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_createTime release];
    [_fromAccountType release];
    [_toAccountType release];
    [_transferId release];
    [_typeValue  release];
    [_userId release];
    [super dealloc];
}
@end
