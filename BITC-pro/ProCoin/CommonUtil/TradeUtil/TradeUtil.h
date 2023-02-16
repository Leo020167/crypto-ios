//
//  TradeUtil.h
//  TJRtaojinroad
//
//  Created by taojinroad on 7/7/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GearCount       5               //档位数，目前5档数据

@interface TradeUtil : NSObject


/** 根据交易对symbol返回原始symbol*/
+ (NSString *)originSymbolAccquireBySymbol:(NSString *)symbol;

/** 根据交易对symbol返回计价单位*/
+ (NSString *)unitSymbolAccquireBySymbol:(NSString *)symbol;

/** 保持浮点精度返回所需要小数位数的字符串 直接切断，不进行四舍五入*/
+ (NSString *)stringRoundDownFloatValue:(CGFloat)value dotBits:(NSInteger)dotBit;

/** 为价格字符串添加人民币符号*/
+ (NSString *)stringByAppendingRMBSymbolString:(NSString *)priceString;

/** 为大于0的价格数字字符加上+符号*/
+ (NSString *)stringByAppendingPlusSymbolString:(NSString *)priceString;


/** 格式化传入的数字,返回以K为单位的数字(传入的数字要大于等于10000，否则将直接返回该数字)*/
+ (NSString *)stringByFormatKWithNumber:(CGFloat)number;

/** 返回一个字符的小数位数*/
+ (NSInteger)decimalBitByStringValue:(NSString *)floatString;

/** 根据行情数字正负返回行情数字颜色*/
+ (UIColor *)textColorWithQuotationNumber:(CGFloat)quotationNum;

/**千位格式化数字，decimal:保留小数位数*/
+ (NSString*)tradeBankFormatter:(NSString*)assets decimal:(NSInteger)decimal;

+ (NSString*)tradeBankFormatter:(NSString*)assets;

@end
