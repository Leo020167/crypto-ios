//
//  CDFollowBalanceInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CDFollowBalanceInfoEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *nextUsableBalance;        //下笔可用
@property (copy, nonatomic) NSString *profit;                   //盈利
@property (copy, nonatomic) NSString *totalBalance;             //总投入
@property (copy, nonatomic) NSString *usableBalance;            //可用
@property (copy, nonatomic) NSString *userId;                   //用户userid
@property (copy, nonatomic) NSString *userName;                 //用户名

@end

