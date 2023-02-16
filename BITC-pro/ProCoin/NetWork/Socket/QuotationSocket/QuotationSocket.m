//
//  QuotationSocket.m
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "QuotationSocket.h"
#import "CommonUtil.h"
#import "NetWorkManage.h"

static QuotationSocket *quotationSocket = nil;

@interface QuotationSocket()



@end

@implementation QuotationSocket

+ (QuotationSocket *)shareQuotationSocket
{
    static dispatch_once_t quotationSocketOnceToken;
    dispatch_once(&quotationSocketOnceToken, ^{
        quotationSocket = [[QuotationSocket alloc] init];
    });
    return quotationSocket;
}



- (instancetype)init
{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quotationSocketOpen) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [super dealloc];
}

- (void)quotationSocketClose
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[self fullDisconnectedToServerNotificationName] object:nil];
}

- (void)quotationSocketOpen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[self fullConnectedToServerNotificationName] object:nil];
}


#pragma mark - 注册关键通知
- (NSString *)fullConnectedToServerNotificationName
{
    return [NSString stringWithFormat:@"%@_%@",MHSocketDidConnectedToServerNotification,NSStringFromClass([self class])];
}

- (NSString *)fullDisconnectedToServerNotificationName
{
    return [NSString stringWithFormat:@"%@_%@",MHSocketDisconnectedToServerNotification,NSStringFromClass([self class])];
}

/** 注册连接上服务器消息通知*/
- (void)registerNotificationOfDidConnectedToServer:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:[self fullConnectedToServerNotificationName] object:nil];
}

/** 注册用户断开连接通知*/
- (void)registerNotificationOfDisconnectedToServer:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:[self fullDisconnectedToServerNotificationName] object:nil];
}

#pragma mark - 取消关键通知
/** 注销所有socket注册的方法，不包括其他自行注册的通知*/
- (void)cancelAllNotifcationOfSocket:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self fullConnectedToServerNotificationName] object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self fullDisconnectedToServerNotificationName] object:nil];
}


@end
