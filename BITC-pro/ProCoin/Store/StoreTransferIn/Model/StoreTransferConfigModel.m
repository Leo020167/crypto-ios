//
//  StoreTransferConfigModel.m
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "StoreTransferConfigModel.h"

@implementation StoreTransferConfigModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super init]){
        self.amount = [self stringParser:@"amount" json:json];
        self.minInAmount = [self stringParser:@"minInAmount" json:json];
        self.storeSymbol = [self stringParser:@"storeSymbol" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_minInAmount release];
    [_storeSymbol release];
    [super dealloc];
}

@end
