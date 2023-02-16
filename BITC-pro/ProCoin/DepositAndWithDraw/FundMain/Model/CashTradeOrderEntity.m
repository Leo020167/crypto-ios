//
//  CashTradeOrderEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/24.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CashTradeOrderEntity.h"

@implementation CashTradeOrderEntity

//@property (copy, nonatomic) NSString *buySell;          //1为充值和购买，-1为提现和卖出
//@property (copy, nonatomic) NSString *symbol;           //币种
//@property (copy, nonatomic) NSString *stateDesc;        //状态描述
//@property (copy, nonatomic) NSString *balanceCash;      //充值的金额
//@property (copy, nonatomic) NSString *priceCash;        //买入某币的买入价
//@property (copy, nonatomic) NSString *createTime;       //创建时间

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.buySell = [self stringParser:@"buySell" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.stateDesc = [self stringParser:@"stateDesc" json:json];
        self.state = [self integerParser:@"state" json:json];
        self.balanceCny = [self stringParser:@"balanceCny" json:json];
        self.priceCny = [self stringParser:@"priceCny" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.orderCashId = [self stringParser:@"orderCashId" json:json];
        self.chatTopic = [self stringParser:@"chatTopic" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_buySell release];
    [_symbol release];
    [_stateDesc release];
    [_balanceCny release];
    [_priceCny release];
    [_createTime release];
    [_orderCashId release];
    [_chatTopic release];
    [super dealloc];
}
@end
