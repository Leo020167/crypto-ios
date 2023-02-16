//
//  PCHomeFollowUserModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/23.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCHomeFollowUserModel : TJRBaseEntity

//correctRate = "89.89";
//days = 22;
//headUrl = "http://file.cropyme.com:16678/procoin/user/image/20200217042901910155088.jpg";
//monthProfit = "4347.89";
//totalProfit = "576765.89";
//userId = 500034;
//userName = "\U9752";
@property (copy, nonatomic) NSString *correctRate;
@property (copy, nonatomic) NSString *days;
@property (copy, nonatomic) NSString *headUrl;
@property (copy, nonatomic) NSString *monthProfit;
@property (copy, nonatomic) NSString *totalProfit;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *expireTime;           //过期时间戳
@property (assign, nonatomic) BOOL isExpireTime;            //是否过期，0为未过期，1为过期
@property (assign, nonatomic) BOOL subIsFee;                //是否收费订阅


@end

NS_ASSUME_NONNULL_END
