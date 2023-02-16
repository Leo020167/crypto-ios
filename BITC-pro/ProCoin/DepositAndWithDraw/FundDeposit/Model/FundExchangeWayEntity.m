//
//  FundExchangeWayEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundExchangeWayEntity.h"

@implementation FundExchangeWayEntity

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.receiptTypeLogo = [self stringParser:@"receiptTypeLogo" json:json];
        self.receiptTypeValue = [self stringParser:@"receiptTypeValue" json:json];
        self.receiptDesc = [self stringParser:@"receiptDesc" json:json];
        self.receiptId = [self stringParser:@"receiptId" json:json];
        self.qrCode = [self stringParser:@"qrCode" json:json];
        self.qrContent = [self stringParser:@"qrContent" json:json];
        self.receiptType = [self integerParser:@"receiptType" json:json];
        self.bankName = [self stringParser:@"bankName" json:json];
        self.receiptNo = [self stringParser:@"receiptNo" json:json];
        self.receiptName = [self stringParser:@"receiptName" json:json];
        self.isSelect = NO;
    }
    return self;
}

- (void)dealloc
{
    [_receiptTypeLogo release];
    [_receiptTypeValue release];
    [_receiptDesc release];
    [_receiptId release];
    [_qrCode release];
    [_qrContent release];
    [_bankName release];
    [_receiptNo release];
    [_receiptName release];
    [super dealloc];
}

@end
