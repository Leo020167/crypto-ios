//
//  AppPurchases.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPurchases : TJRBaseEntity

@property (nonatomic, copy) NSString *transactionIdentifier;
@property (nonatomic, copy) NSString *base64EncodedString;
@property (nonatomic, copy) NSString *productIdentifier;
@property (assign) BOOL feedback;
@property (nonatomic, copy) NSString *transactionDate;
@property (nonatomic, copy) NSString *notifyTime;
@property (nonatomic, copy) NSString *myUserId;
@property (assign) int times;

@property(nonatomic, copy) NSString *localizedDescription;
@property(nonatomic, copy) NSString *localizedTitle;
@property(nonatomic, retain) NSDecimalNumber *price;
@end
