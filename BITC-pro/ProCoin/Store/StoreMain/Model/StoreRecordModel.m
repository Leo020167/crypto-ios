//
//  StoreRecordModel.m
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "StoreRecordModel.h"

@implementation StoreRecordModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.inOut = [self integerParser:@"inOut" json:json];
        self.isDone = [self integerParser:@"isDone" json:json];
        self.recordId = [self stringParser:@"recordId" json:json];
        self.remark = [self stringParser:@"remark" json:json];
        self.storeSymbol = [self stringParser:@"storeSymbol" json:json];
        self.storeType = [self stringParser:@"storeType" json:json];
        self.targetSymbol = [self stringParser:@"targetSymbol" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_createTime release];
    [_recordId release];
    [_remark release];
    [_storeSymbol release];
    [_storeType release];
    [_targetSymbol release];
    [_userId release];
    [super dealloc];
}



@end
