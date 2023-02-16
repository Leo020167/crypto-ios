//
//  P2PPaymentEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "P2PPaymentEntity.h"


@interface P2PPaymentEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *paymentId;
@property (copy, nonatomic) NSString *receiptName;
@property (copy, nonatomic) NSString *receiptNo;
@property (copy, nonatomic) NSString *receiptType;
@property (copy, nonatomic) NSString *qrCode;
@property (copy, nonatomic) NSString *receiptLogo;
@property (copy, nonatomic) NSString *receiptTypeValue;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *bankName;
@end


