//
//  NetWorkManage+Quotation.m
//  ProCoin
//
//  Created by Hay on 2020/4/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NetWorkManage+Quotation.h"



@implementation NetWorkManage (Quotation)

- (NSString *)fullApiQuotationUrl:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://market.%@/procoin-market/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 自选行情、数字货币行情、股指期货行情
- (void)reqMarketQuotationData:(id)delegate tab:(NSString *)tab sortField:(NSString *)sortField sortType:(NSString *)sortType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiQuotationUrl:@"quote/marketData"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"tab" value:tab],
                                      [BasicNameValuePair setName:@"sortField" value:sortField],
                                      [BasicNameValuePair setName:@"sortType" value:sortType],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 分时历史数据
- (void)reqShareTimeHistoryData:(id)delegate symbol:(NSString *)symbol timestamp:(NSString *)timestamp pageSize:(NSString *)pageSize finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiQuotationUrl:@"quote/getMinuteLine"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"timestamp" value:timestamp],
                                      [BasicNameValuePair setName:@"pageSize" value:pageSize],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取实时行情数据
- (void)reqQuotationRealData:(id)delegate symbol:(NSString *)symbol depth:(NSString *)depth klineType:(NSString *)klineType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiQuotationUrl:@"quote/real"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"depth" value:depth],
                                      [BasicNameValuePair setName:@"klineType" value:klineType],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取K线数据
- (void)reqQuotationKLineData:(id)delegate symbol:(NSString *)symbol timestamp:(NSString *)timestamp pageSize:(NSString *)pageSize kLineType:(NSString *)kLineType type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiQuotationUrl:@"quote/kline"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"timestamp" value:timestamp],
                                      [BasicNameValuePair setName:@"pageSize" value:pageSize],
                                      [BasicNameValuePair setName:@"klineType" value:kLineType],
                                      [BasicNameValuePair setName:@"type" value:type],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取5日分时
- (void)reqFiveDayShareTimeData:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiQuotationUrl:@"quote/getMinute5DayLine"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}
@end
