//
//  AppPurchases.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "AppPurchases.h"

@implementation AppPurchases

- (void)dealloc {
    [_base64EncodedString release];
    [_transactionDate release];
    [_transactionIdentifier release];
    [_productIdentifier release];
    [_notifyTime release];
    [_myUserId release];
    
    [_localizedDescription release];
    [_localizedTitle release];
    [_price release];
    [super dealloc];
}

@end
