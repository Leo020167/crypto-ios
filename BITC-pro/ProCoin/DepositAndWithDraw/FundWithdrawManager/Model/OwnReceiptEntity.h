//
//  OwnReceiptEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/7.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"

//bankBranch = "";
//bankName = 1223213123;
//isActive = 0;
//isDefault = 0;
//isRecommend = 0;
//receiptId = 25;
//receiptName = 12312313;
//receiptNo = 213123123123;
//receiptType = 3;
//receiptTypeLogo = "http://192.168.0.66/crpm/images/pay/bankPay.png";
//receiptTypeValue = "\U94f6\U884c\U5361";
//synSign = b9461e025d12e2591d627ce095335323;
//synTime = 0;
//synVersion = 0;
//userId = 5;
//verifySql = 1;
//verifySqlTime = 0;

@interface OwnReceiptEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *receiptId;
@property (copy, nonatomic) NSString *receiptName;
@property (copy, nonatomic) NSString *receiptNo;
@property (assign, nonatomic) NSInteger receiptType;
@property (copy, nonatomic) NSString *receiptTypeLogo;
@property (copy, nonatomic) NSString *receiptTypeValue;
@property (copy, nonatomic) NSString *bankName;
@property (assign, nonatomic) BOOL isDefault;

@end


