//
//  QuotationSocketManager.m
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "QuotationSocketManager.h"

@implementation QuotationSocketManager

#pragma mark - 获取当前价，买卖档/real?symbol=btc&depth=10
+ (NSString *)sendCoinQuotationRealWithSymbol:(NSString *)symbol depth:(NSInteger)depth
{
    return [self fetchUrlParamSocket:@"/real"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"depth" value:[NSString stringWithFormat:@"%@",@(depth)]],nil];
}

#pragma mark - 获取分时的全部数据
+ (NSString *)sendCoinQuotationShareTimeWithSymbol:(NSString *)symbol pageSize:(NSString *)pageSize
{
    return [self fetchUrlParamSocket:@"/minuteLine/get"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"pageSize" value:pageSize],nil];
}

#pragma mark - 获取首页行情数据
+ (NSString *)sendHomeMarktetDataWithSortField:(NSString *)sortField sortType:(NSString *)sortType tab:(NSString *)tab symbols:(NSString *)symbols
{
    return [self fetchUrlParamSocket:@"/marketData"
                           statement:
            [BasicNameValuePair setName:@"sortField" value:sortField],
            [BasicNameValuePair setName:@"sortType" value:sortType],
            [BasicNameValuePair setName:@"tab" value:tab],
            [BasicNameValuePair setName:@"symbols" value:symbols],nil];
}

#pragma mark - 获取K线数据
+ (NSString *)sendCoinQuotationKLineFifteenMinutesWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type
{
    return [self fetchUrlParamSocket:@"/kline/15min"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"timestamp" value:timestamp],
            [BasicNameValuePair setName:@"type" value:type],nil];
}

+ (NSString *)sendCoinQuotationKLineOneHourWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type
{
    return [self fetchUrlParamSocket:@"/kline/hour"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"timestamp" value:timestamp],
            [BasicNameValuePair setName:@"type" value:type],nil];
}

+ (NSString *)sendCoinQuotationKLineFourHourWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type
{
    return [self fetchUrlParamSocket:@"/kline/4hour"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"timestamp" value:timestamp],
            [BasicNameValuePair setName:@"type" value:type],nil];
}

+ (NSString *)sendCoinQuotationKLineOneDayWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type
{
    return [self fetchUrlParamSocket:@"/kline/day"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"timestamp" value:timestamp],
            [BasicNameValuePair setName:@"type" value:type],nil];
}

+ (NSString *)sendCoinQuotationKLineWeekWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type
{
    return [self fetchUrlParamSocket:@"/kline/week"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"timestamp" value:timestamp],
            [BasicNameValuePair setName:@"type" value:type],nil];
}

+ (NSString *)sendCoinQuotationKLineMonthWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type
{
    return [self fetchUrlParamSocket:@"/kline/month"
                           statement:
            [BasicNameValuePair setName:@"symbol" value:symbol],
            [BasicNameValuePair setName:@"timestamp" value:timestamp],
            [BasicNameValuePair setName:@"type" value:type],nil];
}



@end
