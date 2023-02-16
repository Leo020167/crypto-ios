//
//  WithdrawWayEnity.h
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"


@interface WithdrawWayEnity : TJRBaseEntity

@property (copy, nonatomic) NSString *receiptLogo;                  //交易方式logo
@property (copy, nonatomic) NSString *receiptTypeValue;             //交易方式名称,如:支付宝，微信，银行卡
@property (assign, nonatomic) NSInteger receiptType;                // 收款方式:1支付宝，2微信，3银行卡
@property (copy, nonatomic) NSString *receiptDesc;                  //交易描述，如：推荐使用

@end


