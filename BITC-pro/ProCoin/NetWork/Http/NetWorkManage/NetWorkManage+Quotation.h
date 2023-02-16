//
//  NetWorkManage+Quotation.h
//  ProCoin
//
//  Created by Hay on 2020/4/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (Quotation)

/** 自选行情、数字货币行情、股指期货行情*/
- (void)reqMarketQuotationData:(id)delegate tab:(NSString *)tab sortField:(NSString *)sortField sortType:(NSString *)sortType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 分时历史数据*/
- (void)reqShareTimeHistoryData:(id)delegate symbol:(NSString *)symbol timestamp:(NSString *)timestamp pageSize:(NSString *)pageSize finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取实时行情数据*/
- (void)reqQuotationRealData:(id)delegate symbol:(NSString *)symbol depth:(NSString *)depth klineType:(NSString *)klineType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取K线数据*/
- (void)reqQuotationKLineData:(id)delegate symbol:(NSString *)symbol timestamp:(NSString *)timestamp pageSize:(NSString *)pageSize kLineType:(NSString *)kLineType type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取5日分时*/
- (void)reqFiveDayShareTimeData:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end


