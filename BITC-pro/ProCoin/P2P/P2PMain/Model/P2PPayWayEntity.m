//
//  P2PPayWayEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "P2PPayWayEntity.h"


@implementation P2PPayWayEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.bankName = [self stringParser:@"bankName" json:json];
        self.paymentId = [self stringParser:@"paymentId" json:json];
        self.receiptName = [self stringParser:@"receiptName" json:json];
        self.receiptLogo = [self stringParser:@"receiptLogo" json:json];
        self.receiptType = [self stringParser:@"receiptType" json:json];
        self.receiptTypeValue = [self stringParser:@"receiptTypeValue" json:json];
        self.receiptNo = [self stringParser:@"receiptNo" json:json];
        self.qrCode = [self stringParser:@"qrCode" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_qrCode release];
    [_receiptNo release];
    [_paymentId release];
    [_receiptLogo release];
    [_receiptType release];
    [_receiptTypeValue release];
    [super dealloc];
}


@end
