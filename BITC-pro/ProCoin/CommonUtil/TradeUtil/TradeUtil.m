//
//  TradeUtil.m
//  TJRtaojinroad
//
//  Created by taojinroad on 7/7/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TradeUtil.h"
#import "CommonUtil.h"

@implementation TradeUtil

/** 根据交易对symbol返回原始symbol*/
+ (NSString *)originSymbolAccquireBySymbol:(NSString *)symbol
{
    NSRange keyRange = [symbol rangeOfString:@"/"];
    if(keyRange.location != NSNotFound){
        NSString *originSymbol = [symbol substringWithRange:NSMakeRange(0, keyRange.location)];
        return originSymbol;
    }else if(checkIsStringWithAnyText(symbol)){
        NSString *originSymbol = [NSString stringWithString:symbol];
        return originSymbol;
    }
    return @"";
}

/** 根据交易对symbol返回计价单位*/
+ (NSString *)unitSymbolAccquireBySymbol:(NSString *)symbol
{
    NSRange keyRange = [symbol rangeOfString:@"/"];
    if(keyRange.location != NSNotFound){
        NSString *unitSymbol = [symbol substringWithRange:NSMakeRange(keyRange.location + 1, symbol.length - keyRange.location - 1)];
        return unitSymbol;
    }
    return @"USDT";
}


/** 保持浮点精度返回所需要小数位数的字符串 直接切断，不进行四舍五入*/
+ (NSString *)stringRoundDownFloatValue:(CGFloat)value dotBits:(NSInteger)dotBit
{
    
    NSDecimalNumberHandler* roundingBehavior =  [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:dotBit raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal = [[[NSDecimalNumber alloc] initWithFloat:value] autorelease];
    NSDecimalNumber *roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    CGFloat result = [[NSString stringWithFormat:@"%@",roundedOunces] doubleValue];
    NSString *format = [NSString stringWithFormat:@"%%.%@f",@(dotBit)];
    return [NSString stringWithFormat:format,result];
}

/** 为价格字符串添加人民币符号*/
+ (NSString *)stringByAppendingRMBSymbolString:(NSString *)priceString
{
    if(checkIsStringWithAnyText(priceString)){
        NSString *string = [NSString stringWithString:priceString];
        return [NSString stringWithFormat:@"¥%@",string];
    }else{
        return @"";
    }
    
}

/** 为大于0的价格数字字符加上+符号*/
+ (NSString *)stringByAppendingPlusSymbolString:(NSString *)priceString
{
    if(!checkIsStringWithAnyText(priceString)){
        return @"";
    }
    if([priceString rangeOfString:@"+"].location != NSNotFound){            //有加号时不再处理
        return [NSString stringWithString:priceString];
    }
    CGFloat price = [priceString floatValue];
    if(price > 0){
        return [NSString stringWithFormat:@"+%@",priceString];
    }
    return [NSString stringWithString:priceString];
}

/** 返回一个字符的小数位数*/
+ (NSInteger)decimalBitByStringValue:(NSString *)floatString
{
    NSArray *array = [floatString componentsSeparatedByString:@"."];
    if([array count] == 2){
        NSString *str = [array lastObject];
        return str.length;
    }
    return 0;
}

/** 格式化传入的数字,返回以K为单位的数字(传入的数字要大于等于10000，否则将直接返回该数字)*/
+ (NSString *)stringByFormatKWithNumber:(CGFloat)number
{
    if(number < 10000){
        return [NSString stringWithFormat:@"%@",@(number)];
    }
    CGFloat value = (CGFloat)(number / 1000.0f);
    return [NSString stringWithFormat:@"%.2fK",value];
}

/** 根据行情数字正负返回行情数字颜色*/
+ (UIColor *)textColorWithQuotationNumber:(CGFloat)quotationNum
{
    NSString *color = [[NSUserDefaults standardUserDefaults] objectForKey:@"appColor"];
    BOOL isRed = NO;
    if ([color isEqualToString:@"red"] || color == nil) {
        isRed = YES;
    }
    if(quotationNum > 0){
        return isRed ? QuotationRedColor : QuotationGreenColor;
    }else if(quotationNum == 0){
        return QuotationGrayColor;
    }else{
        return isRed ? QuotationGreenColor : QuotationRedColor;
    }
}


//+ (NSString*)tradeFormatter:(NSString*)assets{
//
//    CGFloat result = [assets floatValue] / 10000.0f;
//
//    if (result > 1) {
//        return [NSString stringWithFormat:@"%@",[CommonUtil formatDateForDouble:[assets doubleValue]]];
//    }else{
//        return [TradeUtil tradeBankFormatter:assets];
//    }
//
//}

+ (NSString*)tradeBankFormatter:(NSString*)assets{
    NSNumberFormatter* numberFormatter = [[[NSNumberFormatter alloc] init]autorelease];
    [numberFormatter setPositiveFormat:@"###,##0;"];

    NSString *numberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[assets doubleValue]]];
    return [NSString stringWithFormat:@"%@",numberString];
}

#pragma mark - 千位格式化数字，decimal:保留小数位数
+ (NSString*)tradeBankFormatter:(NSString*)assets decimal:(NSInteger)decimal{

    NSAssert(decimal>0, @"decimal 必须大于0");

    NSNumberFormatter* numberFormatter = [[[NSNumberFormatter alloc] init]autorelease];
    NSString* string = @"";
    for (int i=0; i<decimal; i++) {
        string = [NSString stringWithFormat:@"%@0",string];
    }
    [numberFormatter setPositiveFormat:[NSString stringWithFormat:@"###,##0.%@;",string]];

    NSString *numberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[assets doubleValue]]];
    return [NSString stringWithFormat:@"%@",numberString];
}
//
//+ (NSString*)tradeFluctuationFormatter:(NSString*)assets{
//
//    CGFloat result = [assets floatValue];
//
//    if (result > 0) {
//        return [NSString stringWithFormat:@"+%@",[TradeUtil tradeFormatter:assets]];
//    }else if (result == 0) {
//        return [NSString stringWithFormat:@"0.00"];
//    }else {
//        return [NSString stringWithFormat:@"%@",[TradeUtil tradeFormatter:assets]];
//    }
//
//}
//
//+ (NSString*)tradeFluctuationBankFormatter:(NSString*)assets{
//
//    CGFloat result = [assets floatValue];
//
//    if (result > 0) {
//        return [NSString stringWithFormat:@"+%@",[TradeUtil tradeBankFormatter:assets]];
//    }else if (result == 0) {
//        return [NSString stringWithFormat:@"0.00"];
//    }else{
//        return [NSString stringWithFormat:@"%@",[TradeUtil tradeBankFormatter:assets]];
//    }
//
//}
//
//+ (NSString *)dateFormatterTime:(NSString *)str {
//
//    NSString *finalStr = @"";
//    if (str.length >= 6) {
//        finalStr = str;
//    }else if (str.length == 5){
//        finalStr = [NSString stringWithFormat:@"0%@",str];
//    }else if (str.length == 4){
//        finalStr = [NSString stringWithFormat:@"00%@",str];
//    }else if (str.length == 3){
//        finalStr = [NSString stringWithFormat:@"000%@",str];
//    }else if (str.length == 2){
//        finalStr = [NSString stringWithFormat:@"0000%@",str];
//    }else if (str.length == 1){
//        finalStr = [NSString stringWithFormat:@"00000%@",str];
//    }
//    return finalStr;
//}
//
///**
// * @brief 数字转换，把某个数字转换成具体格式,如: 23000 转成 2.3K
// */
//+ (NSString *)numberFormatWithKString:(NSInteger)number
//{
//    if(number < 10000)
//        return [NSString stringWithFormat:@"%@",@(number)];
//    CGFloat decimal = number / 1000.0f;
//    return [NSString stringWithFormat:@"%.1fK",decimal];
//}
//
//
//#pragma mark - 匿名方法
//+ (NSString *)userSecurityProtected:(NSString *)userId
//{
//    NSMutableString *finalName = [NSMutableString string];
//    if(userId.length > 3){
//        NSString *str1 = [userId substringToIndex:1];
//        NSString *str2 = [userId substringFromIndex:userId.length - 2];
//        [finalName appendString:str1];
//        for(int i = 0; i < userId.length - 3; i++){
//            [finalName appendString:@"*"];
//        }
//        [finalName appendString:str2];
//    }else{
//        [finalName appendString:@"***"];
//    }
//    return finalName;
//}




@end
