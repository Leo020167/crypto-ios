//
//  FollowOrderRecordEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"

//copyHeadUrl = "http://192.168.0.66:16678/cropyme/user/image/20190615112552791484664.png";
//copyName = "\U5347**\U5347**\U5347";
//copyUid = 12;
//orderId = 33;
//profit = "0.0000";
//profitRate = "0.00";
//userId = 15;

@interface FollowOrderRecordEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *followHeadUrl;
@property (copy, nonatomic) NSString *followName;
@property (copy, nonatomic) NSString *followUid;            
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *profit;
@property (copy, nonatomic) NSString *profitRate;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *doneTime;

@end


