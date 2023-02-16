//
//  P2POrderEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "P2POrderEntity.h"
#import "P2PPayWayEntity.h"
#import "CommonUtil.h"

@implementation P2POrderEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.adId = [self stringParser:@"adId" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.content = [self stringParser:@"content" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.dealAmount = [self stringParser:@"dealAmount" json:json];
        self.isOnline = [self integerParser:@"isOnline" json:json];
        self.isPayAli = [self integerParser:@"isPayAli" json:json];
        self.isPayBank = [self integerParser:@"isPayBank" json:json];
        self.isPayWx = [self integerParser:@"isPayWx" json:json];
        self.frozenAmount = [self stringParser:@"frozenAmount" json:json];
        self.limitRate = [self stringParser:@"limitRate" json:json];
        self.maxCny = [self stringParser:@"maxCny" json:json];
        self.minCny = [self stringParser:@"minCny" json:json];
        self.orderNum = [self stringParser:@"orderNum" json:json];
        self.synVersion = [self integerParser:@"synVersion" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.timeLimit = [self stringParser:@"timeLimit" json:json];
        self.updateTime = [self stringParser:@"updateTime" json:json];
        self.userLogo = [self stringParser:@"userLogo" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.currencySign = [self stringParser:@"currencySign" json:json];
        self.currencyType = [self stringParser:@"currencyType" json:json];
        
        NSString* payWayJson = [self stringParser:@"payWay" json:json];
        if (TTIsStringWithAnyText(payWayJson)) {
            NSArray *list =  [CommonUtil jsonValue:payWayJson];
            NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
            for(NSDictionary *dic in list){
                P2PPayWayEntity *entity = [[[P2PPayWayEntity alloc] initWithJson:dic]autorelease];
                [array addObject:entity];
            }
            self.payWayArray = array;
        }
    }
    return self;
}

- (void)dealloc
{
    [_payWayArray release];
    [_adId release];
    [_amount release];
    [_buySell release];
    [_content release];
    [_createTime release];
    [_dealAmount release];
    [_frozenAmount release];
    [_limitRate release];
    [_maxCny release];
    [_minCny release];
    [_orderNum release];
    [_price release];
    [_timeLimit release];
    [_updateTime release];
    [_userLogo release];
    [_userId release];  
    [super dealloc];
}


@end
