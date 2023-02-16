//
//  ExtractCoinDataEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "ExtractCoinDataEntity.h"

@implementation ExtractCoinDataEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.amount = [self stringParser:@"amount" json:json];
        self.maxWithdrawDecimals = [self stringParser:@"maxWithdrawDecimals" json:json];
        self.minWithdrawAmt = [self stringParser:@"minWithdrawAmt" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.withdrawFee = [self stringParser:@"withdrawFee" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_amount release];
    [_maxWithdrawDecimals release];
    [_minWithdrawAmt release];
    [_symbol release];
    [_withdrawFee release];
    [super dealloc];
}
@end



@implementation CoinWithdrawConfigAddress

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"addressId": @"id"};
}

- (void)dealloc
{
    [_address release];
    [_remark release];
    [_symbol release];
    [_chainType release];
    [_addressId release];
    [super dealloc];
}

@end


@implementation CoinWithdrawConfigEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"addressList":[CoinWithdrawConfigAddress class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"addressId": @"id"};
}

- (void)dealloc
{
    [_availableAmount release];
    [_addressList release];
    [_fee release];
    [_frozenAmount release];
    [super dealloc];
}
@end
