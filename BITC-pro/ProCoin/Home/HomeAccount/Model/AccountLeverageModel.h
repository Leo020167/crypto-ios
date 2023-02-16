//
//  AccountLeverageModel.h
//  BYY
//
//  Created by Hay on 2020/1/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface AccountLeverageModel : TJRBaseEntity

//buySellStr = "\U770b\U6da8(\U505a\U591a)";
//multiNum = 5;
//orderId = 43910;
//profit = "0.3215";
//rate = "10.71";
//symbol = "ADA/USDT";
//time = 0;
//userId = 500021;

@property (copy, nonatomic) NSString *buySellStr;
@property (copy, nonatomic) NSString *multiNum;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *profit;
@property (copy, nonatomic) NSString *rate;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSString *userId;


@end

