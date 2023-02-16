//
//  AccountStoreModel.h
//  BYY
//
//  Created by Hay on 2019/12/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

//amount = "0.00000000";
//amountSymbol = USDT;
//amountTip = "USDT\U672c\U91d1";
//profit = "0.00000000";
//profitSymbol = USDT;
//profitTip = "USDT\U6536\U76ca(\U5e74\U531618.23%\U9884\U671f)";
//storeSymbol = USDT;
//userId = 500021;


@interface AccountStoreModel : TJRBaseEntity

@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *amountSymbol;
@property (nonatomic, copy) NSString *amountTip;
@property (nonatomic, copy) NSString *profit;
@property (nonatomic, copy) NSString *profitSymbol;
@property (nonatomic, copy) NSString *profitTip;
@property (nonatomic, copy) NSString *storeSymbol;
@property (nonatomic, copy) NSString *userId;

@end


