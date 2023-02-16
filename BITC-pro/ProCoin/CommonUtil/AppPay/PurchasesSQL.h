//
//  PurchasesSQL.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPurchases.h"

@interface PurchasesSQL : NSObject
- (BOOL)replaceSql:(NSString*)transactionIdentifier base64EncodedString:(NSString*)base64EncodedString productIdentifier:(NSString*)productIdentifier feedback:(BOOL)feedback transactionDate:(NSString*)transactionDate notifyTime:(NSString*)notifyTime times:(int)times myUserId:(NSString*)myUserId;
- (AppPurchases*)selectItemSQl;
- (BOOL)updateSQL:(NSString*)transactionIdentifier feedback:(BOOL)feedback;
- (BOOL)updateNotifyTimeSQL:(NSString*)transactionIdentifier notifyTime:(NSString*)notifyTime times:(int)times;
@end
