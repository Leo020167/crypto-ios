//
//  FundExchangeWayEntity.h
//  Cropyme
//
//  Created by Hay on 2019/5/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface FundExchangeWayEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *receiptTypeLogo;                  //交易方式logo
@property (copy, nonatomic) NSString *receiptTypeValue;                 //交易方式名称,如:支付宝，微信，银行卡
@property (copy, nonatomic) NSString *receiptDesc;                      //交易描述，如：推荐使用
@property (copy, nonatomic) NSString *receiptId;                        //交易id
@property (copy, nonatomic) NSString *qrCode;                           //交易二维码
@property (copy, nonatomic) NSString *qrContent;                        //交易链接
@property (assign, nonatomic) NSInteger receiptType;                    // 收款方式:1支付宝，2微信，3银行卡
@property (copy, nonatomic) NSString *bankName;                         //银行名字
@property (copy, nonatomic) NSString *receiptNo;                        //银行账户
@property (copy, nonatomic) NSString *receiptName;                      //收款人名字
@property (assign, nonatomic) BOOL isSelect;                            //是否选中，初始化为NO

@end

