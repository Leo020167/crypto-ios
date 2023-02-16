//
//  SearchCoinDataEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



//amount = 33127;
//price = "0.00000001";
//priceCny = "\U2248\U00a50.00";
//rate = "0.00";
//sortNum = 0;
//symbol = KBT;

@interface SearchCoinDataEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *priceCny;
@property (copy, nonatomic) NSString *rate;
@property (copy, nonatomic) NSString *sortNum;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *originSymbol;
@property (copy, nonatomic) NSString *unitSymbol;
@property (assign, nonatomic) NSInteger type;         //值为1时代表跳链接
@property (copy, nonatomic) NSString *url;          //链接地址
@property (copy, nonatomic) NSString *marketType;   //币种类型
@end

