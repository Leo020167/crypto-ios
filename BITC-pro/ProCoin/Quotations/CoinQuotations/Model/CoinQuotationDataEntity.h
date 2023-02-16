//
//  CoinQuotationDataEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/25.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CoinQuotationDataEntity : TJRBaseEntity

@property (assign, nonatomic) CGFloat amount;           //成交数量
@property (copy, nonatomic) NSString *amountString;     //成交数量字符串(用NSString解析，避免跟之前框架数据结构冲突)
@property (copy, nonatomic) NSString *amt;              //涨跌数字
@property (assign, nonatomic) CGFloat balance;          //成交金额
@property (assign, nonatomic) CGFloat high;             //今日最高价
@property (copy, nonatomic) NSString *highString;       //今日最高价字符串(用NSString解析，避免跟之前框架数据结构冲突)
@property (copy, nonatomic) NSString *last;             //当前价格
@property (copy, nonatomic) NSString *lastCny;          //当前价格描述
@property (assign, nonatomic) CGFloat low;              //今日最低价
@property (copy, nonatomic) NSString *lowString;        //今日最低价字符串(用NSString解析，避免跟之前框架数据结构冲突)
@property (assign, nonatomic) CGFloat open;             //今日开盘价
@property (copy, nonatomic) NSString *openString;       //今日开盘价字符串
@property (assign, nonatomic) CGFloat preClose;         //昨日收盘价
@property (copy, nonatomic) NSString *timeStamp;        //最后更新时间
@property (copy, nonatomic) NSString *rate;             //涨幅
@property (copy, nonatomic) NSString *symbol;           //币种
@property (copy, nonatomic) NSString *tip;              //行情数据来源
@property (assign, nonatomic) NSInteger priceDecimals;              //后台控制的价格小数位数
@property (assign, nonatomic) NSInteger amountDecimals;             //后台控制的数量小数位数

@property (copy, nonatomic) NSString *openMarketStr;
@property (copy, nonatomic) NSString *currency;
@property (copy, nonatomic) NSString *name;
@end


