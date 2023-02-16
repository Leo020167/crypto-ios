//
//  P2PPaymentEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "P2PPaymentEntity.h"


@implementation P2PPaymentEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.paymentId = [self stringParser:@"paymentId" json:json];
        self.receiptLogo = [self stringParser:@"receiptLogo" json:json];
        self.receiptType = [self stringParser:@"receiptType" json:json];
        self.receiptTypeValue = [self stringParser:@"receiptTypeValue" json:json];
        self.receiptNo = [self stringParser:@"receiptNo" json:json];
        self.receiptName = [self stringParser:@"receiptName" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.qrCode = [self stringParser:@"qrCode" json:json];
        self.bankName = [self stringParser:@"bankName" json:json];
    }
    return self;
}


- (void)dealloc
{
    [_bankName release];
    [_paymentId release];
    [_receiptLogo release];
    [_receiptType release];
    [_receiptTypeValue release];
    [_receiptNo release];
    [_userId release];
    [_qrCode release];
    [_receiptName release];
    [super dealloc];
}


@end
