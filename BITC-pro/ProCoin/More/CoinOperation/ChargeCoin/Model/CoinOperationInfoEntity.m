//
//  CoinOperationInfoEntity.m
//  Cropyme
//
//  Created by Hay on 2019/9/11.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinOperationInfoEntity.h"

@implementation CoinOperationInfoEntity

//@property (copy, nonatomic) NSString *address;
//@property (copy, nonatomic) NSString *amount;
//@property (copy, nonatomic) NSArray *chainTypes;
//@property (copy, nonatomic) NSString *inOutTip;
//@property (copy, nonatomic) NSString *withdrawFee;

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.address = [self stringParser:@"address" json:json];
        self.amount = [self stringParser:@"amount" json:json];
        self.inOutTip = [self stringParser:@"inOutTip" json:json];
        self.withdrawFee = [self stringParser:@"withdrawFee" json:json];
        self.chainTypes = [NSArray arrayWithArray:[json objectForKey:@"chainTypes"]];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.minWithdrawAmt = [self stringParser:@"minWithdrawAmt" json:json];
        self.maxWithdrawDecimals = [self integerParser:@"maxWithdrawDecimals" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_address release];
    [_amount release];
    [_chainTypes release];
    [_inOutTip release];
    [_withdrawFee release];
    [_symbol release];
    [_minWithdrawAmt release];
    [super dealloc];
}
@end

@implementation CoinChargeConfigAddress
- (void)dealloc
{
    [_address release];
    [_symbol release];
    [_chainType release];
    [super dealloc];
}

@end


@implementation CoinChargeConfigEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"addressList":[CoinChargeConfigAddress class]};
}

- (void)dealloc
{
    [_availableAmount release];
    [_addressList release];
    [_minChargeAmount release];
    [super dealloc];
}
@end



