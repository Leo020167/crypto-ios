//
//  P2PConfirmOrderModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "P2PConfirmOrderModel.h"
#import "P2PPayWayEntity.h"
#import "CommonUtil.h"

@implementation P2PConfirmOrderModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.adId = [self stringParser:@"adId" json:json];
        self.alertTip = [self stringParser:@"alertTip" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.buySell = [self stringParser:@"buySell" json:json];
        self.buySellValue = [self stringParser:@"buySellValue" json:json];
        self.buyUserId = [self stringParser:@"buyUserId" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.paySecondTime = [self stringParser:@"paySecondTime" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.sellUserId = [self stringParser:@"sellUserId" json:json];
        self.showRealName = [self stringParser:@"showRealName" json:json];
        self.showUserId = [self stringParser:@"showUserId" json:json];
        self.showUserLogo = [self stringParser:@"showUserLogo" json:json];
        self.showUserName = [self stringParser:@"showUserName" json:json];
        self.state = [self intParser:@"state" json:json];
        self.stateValue = [self stringParser:@"stateValue" json:json];
        self.stateTip = [self stringParser:@"stateTip" json:json];
        self.tolPrice = [self stringParser:@"tolPrice" json:json];
        self.currencySign = [self stringParser:@"currencySign" json:json];
        
        NSString* payWayJson = [self stringParser:@"showPayWay" json:json];
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
    [_alertTip release];
    [_amount release];
    [_buySell release];
    [_buySellValue release];
    [_buyUserId release];
    [_createTime release];
    [_orderId release];
    [_paySecondTime release];
    [_price release];
    [_sellUserId release];
    [_showRealName release];
    [_showUserId release];
    [_showUserLogo release];
    [_showUserName release];
    [_stateTip release];
    [_tolPrice release];
    [_payWayArray release];
    [super dealloc];
}
@end
