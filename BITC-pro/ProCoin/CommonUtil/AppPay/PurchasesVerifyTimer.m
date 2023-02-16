//
//  PurchasesVerifyTimer.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "PurchasesVerifyTimer.h"
#import "PurchasesSQL.h"
#import "TJRBaseParserJson.h"
#import "VeDateUtil.h"

/**
 *  如果后台反馈给前端的字符不是 status == 0,前端会不断重发通知,直到超过24小时24分钟。
 *  一般情况下,25小时(每一次关闭应用超出的时间不计入内，所以实际时间会比25小时大)以内完成 10 次通知
 *  (通知的间隔频率一般是:0s,30s,2m,2m,10m,10m,1h,2h,6h,15h);
 *
 **/

@interface PurchasesVerifyTimer () {
    
    BOOL bReqFinished;
    // 产品字典
    NSMutableDictionary *_productDict;
    
    PurchasesSQL* purchasesSQL;
    
    NSTimer* timer;
}
@end

static PurchasesVerifyTimer *vTimer;

@implementation PurchasesVerifyTimer
@synthesize delegate;


+(PurchasesVerifyTimer*)shareVerifyTimer{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (vTimer == nil) {
            vTimer = [[super alloc] init];
        }
        
    });
    return vTimer;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (vTimer == nil) {
            vTimer = [[super allocWithZone:zone] init];
        }
    });
    return vTimer;
}

+(id)alloc{
    
    return vTimer;
}

-(id)init{
    
    if ((self = [super init])) {
        purchasesSQL = [[PurchasesSQL alloc]init];
        bReqFinished = YES;
    }
    return self;
}

- (void)dealloc{
    [purchasesSQL release];
    [super dealloc];
}

#pragma mark - 开启定时器
- (void)startTimer {
    if (!timer || !timer.isValid) {
        [self closeTimer];
        timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(verifyTimer) userInfo:nil repeats:YES];
    }
}

#pragma mark - 关闭定时器
- (void)closeTimer {
    @synchronized(timer) {
        if (timer && timer.isValid) {
            [timer invalidate];
            timer = nil;
        }
    }
}


- (BOOL)allowNotifyTime:(NSString*)notifyTime times:(int)times{
    
    BOOL allow = NO;
    
    NSString* time = [NSString stringWithFormat:@"%@",[VeDateUtil currentDateTimeIntervalToString]];
    long long sec = [time longLongValue]/1000 - [notifyTime longLongValue]/1000;
    if (times == 0) {
        allow = YES;        //30s后的第一次重发
    }else if (times == 1 || times == 2) {
        if (sec>= 2*60)allow = YES;
    }else if (times == 3 || times == 4) {
        if (sec>= 10*60)allow = YES;
    }else if (times == 5) {
        if (sec>= 1*60*60)allow = YES;
    }else if (times == 6) {
        if (sec>= 2*60*60)allow = YES;
    }else if (times == 7) {
        if (sec>= 3*60*60)allow = YES;
    }else if (times == 8) {
        if (sec>= 15*60*60)allow = YES;
    }
    NSLog(@"%lld",sec);
    return allow;
}

- (void)verifyTimer{
    //按 30s,2m,2m,10m,10m,1h,2h,6h,15h 验证一次，直至完成
    AppPurchases* item = [purchasesSQL selectItemSQl];
    if (item.transactionIdentifier.length>0 && !item.feedback) {
        //后台进行登记验证
        
        if (item.times>9) {
            //已经超过9次，超过24小时24分钟，支付单作废,不再请求
            [purchasesSQL updateSQL:item.transactionIdentifier feedback:YES];
        }else{
            if ([self allowNotifyTime:item.notifyTime times:item.times]) {
                int times = item.times + 1;
                [self verifyPruchase:item.transactionIdentifier base64EncodedString:item.base64EncodedString productIdentifier:item.productIdentifier transactionDate:item.transactionDate times:times];
                
                
            }
        }
    }else{
        [self closeTimer];
    }
}

- (void)startVerify{
    //应用启动时，验证一次，不计入调用次数
    AppPurchases* item = [purchasesSQL selectItemSQl];
    if (item.transactionIdentifier.length>0 && !item.feedback) {
        //后台进行登记验证
        [self verifyPruchase:item.transactionIdentifier base64EncodedString:item.base64EncodedString productIdentifier:item.productIdentifier transactionDate:item.transactionDate times:item.times];
    }else{
        [self closeTimer];
    }
}


#pragma mark - 验证买入凭据
- (void)verifyPruchase:(NSString*)transactionIdentifier base64EncodedString:(NSString*)base64EncodedString productIdentifier:(NSString*)productIdentifier transactionDate:(NSString*)transactionDate times:(int)times{
    if (base64EncodedString.length>0) {
        if (bReqFinished) {
            bReqFinished = NO;
            
            if (delegate && [delegate respondsToSelector:@selector(reqBeanBegin)]) {
                [delegate reqBeanBegin];
            }
            
           // [[NetWorkManage shareSingleNetWork] reqApplePayVerify:self userId:ROOTCONTROLLER_USER.userId transactionIdentifier:transactionIdentifier productIdentifier:productIdentifier base64EncodedString:base64EncodedString finishedCallback:@selector(requestPayDataFinished:) failedCallback:@selector(requestPayDataFalid:)];
            
            if (transactionIdentifier.length>0) {
                NSString* time = [NSString stringWithFormat:@"%@",[VeDateUtil currentDateTimeIntervalToString]];
                [purchasesSQL replaceSql:transactionIdentifier base64EncodedString:base64EncodedString productIdentifier:productIdentifier feedback:NO transactionDate:transactionDate notifyTime:time times:times myUserId:ROOTCONTROLLER_USER.userId];
            }
            
            [vTimer startTimer];
        }
    }
    
}

- (void)requestPayDataFinished:(NSDictionary *)json {
    
    bReqFinished = YES;

    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc]init]autorelease];
    BOOL isok = [parser parseBaseIsOk:json];
    if (isok) {
        
        NSString* resultStatus = [NSString stringWithFormat:@"%@",[json objectForKey:@"status"]];
        NSString* msg = [json objectForKey:@"msg"];
        if ([resultStatus isEqualToString:@"0"]) {
            //订单支付成功
            NSString* transactionIdentifier = [json objectForKey:@"transaction_id"];
            if (transactionIdentifier.length>0) {
                [purchasesSQL updateSQL:transactionIdentifier feedback:YES];
                
                if (delegate && [delegate respondsToSelector:@selector(reqBeanFinished)]) {
                    [delegate reqBeanFinished];
                }
            }
        }else{
            if (delegate && [delegate respondsToSelector:@selector(reqBeanFalid:msg:)]) {
                [delegate reqBeanFalid:resultStatus msg:msg];
            }
            
        }
    }else{
        NSString* msg = [json objectForKey:@"msg"];
        if (delegate && [delegate respondsToSelector:@selector(reqBeanFalid:msg:)]) {
            [delegate reqBeanFalid:@"-1" msg:msg];
        }
    }
    
}

- (void)requestPayDataFalid:(NSDictionary *)json {
    
    bReqFinished = YES;
    if (delegate && [delegate respondsToSelector:@selector(reqBeanFalid:msg:)]) {
        [delegate reqBeanFalid:@"-1" msg:@"网络连接失败"];
    }
}
@end
