//
//  P2PHistoryModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "P2PHistoryModel.h"
#import "CommonUtil.h"
#import "P2PPayWayEntity.h"

@implementation P2PHistoryModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){

        self.adId = [self stringParser:@"adId" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.buySellValue = [self stringParser:@"buySellValue" json:json];
        self.buyUserId = [self stringParser:@"buyUserId" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.doneTime = [self stringParser:@"doneTime" json:json];
        self.expireTime = [self stringParser:@"expireTime" json:json];
        self.isAdSell = [self intParser:@"isAdSell" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.sellUserId = [self stringParser:@"sellUserId" json:json];
        self.state = [self intParser:@"state" json:json];
        self.stateValue = [self stringParser:@"stateValue" json:json];
        self.tolPrice = [self stringParser:@"tolPrice" json:json];
        self.chatTopic = [self stringParser:@"chatTopic" json:json];
        self.currencySign = [self stringParser:@"currencySign" json:json];

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
    [_adId release];
    [_amount release];
    [_buySell release];
    [_buySellValue release];
    [_buyUserId release];
    [_createTime release];
    [_doneTime release];
    [_expireTime release];
    [_orderId release];
    [_price release];
    [_sellUserId release];
    [_stateValue release];
    [_tolPrice release];
    [super dealloc];
}
@end
