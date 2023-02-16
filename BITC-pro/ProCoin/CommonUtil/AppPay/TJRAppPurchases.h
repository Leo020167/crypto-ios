//
//  TJRAppPurchases.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/7/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseObj.h"
#import "TJRBaseEntity.h"
#import <StoreKit/StoreKit.h>

@protocol PurchasesDelegate <NSObject>
@optional
- (void)purchasingState;

- (void)purchasesFinished;
- (void)purchasesFalid;
- (void)purchasesBegin;

- (void)productsRequestFinished;
- (void)productsRequestBegin;
@end

@interface TJRAppPurchases : TJRBaseObj
{
    int buyType;
    id<PurchasesDelegate>delegate;
}
@property (nonatomic, assign) id<PurchasesDelegate> delegate;
@property (retain, nonatomic) NSMutableArray *productArr;

- (void)productsRequest:(NSString*)productIDs;//productIDs为字符串，以逗号分隔
- (void)appPay:(NSString*)productID;
@end


