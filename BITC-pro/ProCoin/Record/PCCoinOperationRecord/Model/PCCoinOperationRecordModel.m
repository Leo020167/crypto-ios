//
//  PCCoinOperationRecordModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/9.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCCoinOperationRecordModel.h"

@implementation PCCoinOperationRecordModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.address = [self stringParser:@"address" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.chainType = [self stringParser:@"chainType" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.dwId = [self stringParser:@"dwId" json:json];
        self.fee = [self stringParser:@"fee" json:json];
        self.inOut = [self integerParser:@"inOut" json:json];
        self.realAmount = [self stringParser:@"realAmount" json:json];
        self.state = (PCCoinOperationState)[self integerParser:@"state" json:json];
        self.stateDesc = [self stringParser:@"stateDesc" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.subSymbol = [self stringParser:@"subSymbol" json:json];
        self.subTitle = [self stringParser:@"subTitle" json:json];
        self.transferTime = [self stringParser:@"transferTime" json:json];
        
    }
    return self;
    
}


- (void)dealloc
{
    [_address release];
    [_amount release];
    [_chainType release];
    [_createTime release];
    [_dwId release];
    [_fee release];
    [_realAmount release];
    [_stateDesc release];
    [_symbol release];
    [_userId release];
    [super dealloc];
}
@end

@implementation PCCoinSubscribeRecordModel

- (instancetype)initWithJson:(NSDictionary *)json {
    if(self = [super initWithJson:json]){
        self.title = [self stringParser:@"title" json:json];
        self.count = [self stringParser:@"count" json:json];
        self.time = [self stringParser:@"time" json:json];
        self.luckyCount = [self stringParser:@"luckyCount" json:json];
        self.stateDesc = [self stringParser:@"stateDesc" json:json];
        self.paidAmount = [self stringParser:@"paidAmount" json:json];
        self.unpaidAmount = [self stringParser:@"unpaidAmount" json:json];
        self.tradeTime = [self stringParser:@"tradeTime" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
    }
    return self;
}

- (void)dealloc {
    [_title release];
    [_count release];
    [_time release];
    [_luckyCount release];
    [_stateDesc release];
    [_paidAmount release];
    [_unpaidAmount release];
    [_tradeTime release];
    [_symbol release];
    [super dealloc];
}
@end


