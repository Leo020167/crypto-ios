//
//  StoreTransferOutConfigModel.h
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

//amount = "200.00000000";
//amountSymbol = USDT;
//amountTip = "USDT\U672c\U91d1";
//frozenAmount = "0.00000000";
//holdAmount = "200.00000000";
//profit = "0.00000000";
//profitSymbol = USDT;
//profitTip = "USDT\U6536\U76ca";
//storeSymbol = USDT;
//userId = 500021;


@interface StoreTransferOutConfigModel : TJRBaseEntity

@property (nonatomic, copy) NSString *amount;           //显示之前转入的币种可转出总数量
@property (nonatomic, copy) NSString *amountSymbol;     //转入币种
@property (nonatomic, copy) NSString *amountTip;        //币种文字
@property (nonatomic, copy) NSString *frozenAmount;     //冻结数量
@property (nonatomic, copy) NSString *holdAmount;       //可转出数量
@property (nonatomic, copy) NSString *profit;           //收益数量
@property (nonatomic, copy) NSString *profitSymbol;     //收益币种
@property (nonatomic, copy) NSString *profitTip;        //收益显示文字
@property (nonatomic, copy) NSString *storeSymbol;      //当前转出的symbol
@property (nonatomic, copy) NSString *userId;           //用户id


@end


