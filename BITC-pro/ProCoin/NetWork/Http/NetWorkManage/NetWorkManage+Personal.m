//
//  NetWorkManage+Personal.m
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage+Personal.h"


#define URL_API_PERSONAL_HOME              @"personal/home"
#define URL_API_PERSONAL_TREND_CHART       @"personal/trendChart"
#define URL_API_PERSONAL_CONSOLE           @"personal/console"

@implementation NetWorkManage (Personal)

- (NSString *)fullApiBaseUrlPersonal:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}


#pragma mark - 关注某人
- (void)reqFollowUser:(id)delegate followUid:(NSString *)followUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlPersonal:@"attention/add"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"attentionUid" value:followUid],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 取关某人
- (void)reqCancelFollowUser:(id)delegate followUid:(NSString *)followUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlPersonal:@"attention/cancel"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"attentionUid" value:followUid],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 订阅/续费某人
- (void)reqSubscribeUser:(id)delegate attentionUid:(NSString *)attentionUid num:(NSString *)num finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlPersonal:@"attention/add"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"attentionUid" value:attentionUid],
                                       [BasicNameValuePair setName:@"num" value:num],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取工作台数据
- (void)reqPersonConsoleData:(id)delegate userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlPersonal:URL_API_PERSONAL_CONSOLE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"userId" value:userId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 个人主页数据
- (void)reqPersonalMainData:(id)delegate targetUid:(NSString *)targetUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlPersonal:URL_API_PERSONAL_HOME]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"targetUid" value:targetUid],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取图形数据 type（1：个人业绩 2：跟单人气 3：交易次数，4：累计盈亏）
- (void)reqPersonalLineChartData:(id)delegate targetUid:(NSString *)targetUid timeType:(NSString *)timeType type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlPersonal:URL_API_PERSONAL_TREND_CHART]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"targetUid" value:targetUid],
                                      [BasicNameValuePair setName:@"timeType" value:timeType],
                                      [BasicNameValuePair setName:@"type" value:type],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end
