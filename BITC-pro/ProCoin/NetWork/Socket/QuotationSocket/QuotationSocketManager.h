//
//  QuotationSocketManager.h
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseManager.h"
#import "QuotationSocket.h"

#define ShareTimeDataCount  @"720"

NS_ASSUME_NONNULL_BEGIN

@interface QuotationSocketManager : TJRBaseManager

#pragma mark - 获取当前价，买卖档/real?symbol=btc&depth=10
+ (NSString *)sendCoinQuotationRealWithSymbol:(NSString *)symbol depth:(NSInteger)depth;

#pragma mark - 获取分时图的全部数据
+ (NSString *)sendCoinQuotationShareTimeWithSymbol:(NSString *)symbol pageSize:(NSString *)pageSize;

#pragma mark - 获取首页行情数据
//String sortField(1：symbol,2：价格,3：涨跌幅), int sortType(0：无，1：逆序，2：正序)   tab (1:BYY  2:火币)
+ (NSString *)sendHomeMarktetDataWithSortField:(NSString *)sortField sortType:(NSString *)sortType tab:(NSString *)tab symbols:(NSString *)symbols;

#pragma mark - 获取K线数据
+ (NSString *)sendCoinQuotationKLineFifteenMinutesWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type;

+ (NSString *)sendCoinQuotationKLineOneHourWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type;

+ (NSString *)sendCoinQuotationKLineFourHourWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type;

+ (NSString *)sendCoinQuotationKLineOneDayWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type;

+ (NSString *)sendCoinQuotationKLineWeekWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type;

+ (NSString *)sendCoinQuotationKLineMonthWithSymbol:(NSString *)symbol timestamp:(NSString *)timestamp type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
