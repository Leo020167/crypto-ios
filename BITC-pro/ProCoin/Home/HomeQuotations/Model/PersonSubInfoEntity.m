//
//  PersonSubInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/9/16.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "PersonSubInfoEntity.h"

@implementation PersonSubInfoEntity


//@property (assign, nonatomic) BOOL isOpenBuy;           //是否能认购
//@property (assign, nonatomic) BOOL isOpenTrade;         //是否能交易
//@property (copy, nonatomic) NSString *timeTips;         //时间提示语
//@property (copy, nonatomic) NSString *countDownTimestamp;   //结束时间


- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.holdAmount = [self stringParser:@"holdAmount" json:json];
        self.myEquityLevel = [self stringParser:@"myEquityLevel" json:json];
        self.myEquityTip = [self stringParser:@"myEquityTip" json:json];
        self.repoAmount = [self stringParser:@"repoAmount" json:json];
        self.subUrl = [self stringParser:@"subUrl" json:json];
        self.isOpenBuy = [self boolParser:@"isOpenBuy" json:json];
        self.isOpenTrade = [self boolParser:@"isOpenTrade" json:json];
        self.timeTips = [self stringParser:@"timeTips" json:json];
        self.coinSubState = [self stringParser:@"coinSubState" json:json];
        self.btnText = [self stringParser:@"btnText" json:json];
        self.countDownTimestamp = [self stringParser:@"countDownTimestamp" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_holdAmount release];
    [_myEquityLevel release];
    [_myEquityTip release];
    [_repoAmount release];
    [_subUrl release];
    [_timeTips release];
    [_coinSubState release];
    [_btnText release];
    [_countDownTimestamp release];
    [super dealloc];
}

@end
