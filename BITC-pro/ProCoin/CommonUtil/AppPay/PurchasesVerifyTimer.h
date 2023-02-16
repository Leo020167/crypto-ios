//
//  PurchasesVerifyTimer.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VerifyTimerDelegate <NSObject>
@optional
- (void)reqBeanFinished;
- (void)reqBeanBegin;
- (void)reqBeanFalid:(NSString*)resultStatus msg:(NSString*)msg;

@end

@interface PurchasesVerifyTimer : NSObject
{
    id<VerifyTimerDelegate>delegate;
}
@property (nonatomic, assign) id<VerifyTimerDelegate> delegate;

+(PurchasesVerifyTimer*)shareVerifyTimer;

- (void)startVerify;

#pragma mark - 验证买入凭据
- (void)verifyPruchase:(NSString*)transactionIdentifier base64EncodedString:(NSString*)base64EncodedString productIdentifier:(NSString*)productIdentifier transactionDate:(NSString*)transactionDate times:(int)times;
@end
