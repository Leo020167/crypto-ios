//
//  VeDateUtil.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-8-31.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VeDateUtil : NSObject

#pragma mark - 将字符串时间转换成NSDate
+ (NSDate *)stringDataToNSDate:(NSString *)str;

#pragma mark - 将NSDate时间转换成字符串 格式：yyyyMMddHHmmss
+ (NSString *)dateToString:(NSDate *)date;

#pragma mark - 获取两个日期之间的自然天数
+ (NSInteger)calcDaysFromBegin:(NSDate *)startDate toDate:(NSDate *)endDate;

#pragma mark - 两天相差的秒数(含负数)
+ (NSInteger)componentsSecondsBetweenTwoDaysStr:(NSString *)startDate endDate:(NSString *)endDate;

#pragma 两天相差的时间
+ (NSInteger)componentsTwoDays:(NSDate *)startDate toDate:(NSDate *)endDate;

#pragma 两天相差的分钟时间数
+ (NSInteger)componentsTwoTimeMins:(NSDate *)startDate toDate:(NSDate *)endDate;

#pragma  取得日期與時間的各項整數型資料
+(NSDateComponents*)initWithChinaTimezone:(NSDate *)date;

#pragma 时间 NSDate 转 int (总秒数)
+(NSInteger)getStringHHMMSSToInt:(NSDate *)date;

#pragma 得到星期几 格式:星期X (例如 星期一)
+(NSString* )getWeekStr:(NSDate *)date;

#pragma 时间 NSDate 转 NSString 格式: HH:mm
+(NSString* )getDateToHHmm:(NSDate *)date;

#pragma 时间 NSDate 转 NSString 格式: MM:dd YY
+(NSString* )getStringDateMMddYY:(NSDate *)date;

#pragma 时间 NSDate 转 NSString 格式: YYMM 如:201205
+(NSString*) getDateToYYMMWithoutStr:(NSDate *)date;

#pragma 时间 NSDate 转 NSString 格式: MMddHHmmss
+(NSString* )getDateToMMddHHmmss:(NSDate *)date;

#pragma 时间 NSDate 转 NSString 格式: MMddHHmm
+(NSString* )getDateToMMddHHmm:(NSDate *)date;

#pragma 时间 NSDate 转 NSString 格式: 今天 10:30 
+(NSString*)getCustomizeTimeFormat:(NSDate*) hDate;

#pragma 时间 NSDate 转 NSString 格式: 今天 10:30, XXXX年XX月XX日 XX:XX
+ (NSString *)getCustomizeTimeLongFormat:(NSDate *)hDate;

#pragma 时间 NSDate 转 NSString 格式: 今天 XX 10:30
+(NSString*)getCustomizeTimeFormatForH:(NSDate*) hDate;

#pragma 时间 NSString 转 NSString 格式: 今天 10:30 
+(NSString*)dateFormatter:(NSString*)str;

#pragma 时间 NSString 转 NSString 格式: 今天 10:30, XXXX年XX月XX日 XX:XX
+ (NSString *)dateLongFormatter:(NSString *)str;

#pragma 时间 NSDate 转 中国时区NSDate 
+ (NSDate*)dateToLocaleDate:(NSDate*)date;

#pragma 时间 NSString 转 NSString 格式: YYYY年MM月dd日  输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterToChinaDay:(NSString*)str;

#pragma 时间 NSString 转 NSString 格式: YYYY-MM-dd  输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterToSimpleDay:(NSString*)str;

#pragma 时间 NSString 转 NSString 格式: YYYY-MM-dd  HH:mm  输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterToDayBaseDate:(NSString*)str;

#pragma 时间 NSString 转 NSString 格式: HH:mm  输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterToSimpleTime:(NSString*)str;

#pragma mark - 截取时间
+ (NSString *)cutStringTime:(NSString *)time keepHour:(BOOL)keepHour keepMinute:(BOOL)keepMinute keepSecond:(BOOL)keepSecond;

#pragma mark - 截取时间
+ (NSString *)cutStringTime:(NSString *)time stytle:(NSString *)stytle keepHour:(BOOL)keepHour keepMinute:(BOOL)keepMinute keepSecond:(BOOL)keepSecond;

#pragma mark - 以自定样式分割时间(如以-  2012-01-01)(输入为整型时间)
+ (NSString *)getStringIntToDate:(NSUInteger)time stytle:(NSString *)stytle keepHead:(BOOL)keeyHead;

#pragma mark - 以自定样式分割时间(如以-  2012-01-01)(可自定输入类型如inputStytle为@"-",那输入的时间就是2012-01-01)
+ (NSString *)getStringIntToDate:(NSString *)time inputStytle:(NSString *)inputStytle stytle:(NSString *)stytle keepHead:(BOOL)keeyHead;

+ (NSString *)getTimeForMMDD:(NSString *)time;

#pragma mark - 长整型时间.格式化为(2012-01-01 15:25)
+ (NSString *)getLongDateToYYYYMMDDHHMM:(NSString *)time;
#pragma mark - 长整型时间.格式化为(2012-01-01 15:25:00)
+ (NSString *)getLongDateToYYYYMMDDHHMMSS:(NSString *)time;
#pragma mark - String型时间.格式化为(01-01 15:25)
+ (NSString *)getStringDateToMMDDHHMM:(NSString *)time;
#pragma 时间 NSString 转 NSString 格式: YYYY年MM月dd日 HH:mm  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToYYYYMMDDHHMM:(NSString*)str;
#pragma mark - 将日期转换成YYYY年MM月dd日  输入格式:yyyyMMdd
+ (NSString *)dateFormatterToYYYYMMDD:(NSString*)str;
#pragma mark - 将日期转换成MM月dd日  输入格式:yyyy-MM-dd
+ (NSString *)dateFormatterToMMDD:(NSString*)str;
#pragma 时间 NSString 转 NSString 格式: MMddHHmm  输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterWithyyyyMMddHHmmToMMddHHmm:(NSString*)str;
+(NSString*)dateFormatterWithyyyyMMddHHmmToMM_dd_HH_mm:(NSString*)str;

#pragma 时间 例子:输入20120510转换返回2012年5月
+ (NSString *)getLongDateToYYMMWithStr:(NSString *)str;

#pragma 时间 例子:输入格式为20120510转换返回201205
+ (NSString *)getLongDateToYYMMWithoutStr:(NSString *)str;

#pragma 时间 例子:输入20120510122310转换返回日期201205
+ (NSString *)getLongAllDateToYYMMWithoutStr:(NSString *)str;

#pragma 时间 例子:输入20120510122310转换返回日期20120510
+ (NSString *)getLongAllDateToYYMMDDWithoutStr:(NSString *)str;

#pragma 时间 例子:输入20120510转换返回日期10
+ (NSString *)getLongDateToDDWithoutStr:(NSString *)str;

#pragma 时间 例子:输入20120510122310转换返回日期10
+ (NSString *)getLongAllDateToDDWithoutStr:(NSString *)str;

#pragma 时间 例子:输入20120510转换返回日期5月10日
+ (NSString *)getLongDateToMMDDWithStr:(NSString *)str;

#pragma 返回指定string是否今天日期
+(BOOL)isToday:(NSString *)str;

/**
 获取某个日期几个月后的日期
 @param date 计算前的日期
 @param month  月数
 @returns
 */
+ (NSString *)getLastDayWithDate:(NSString *)date month:(NSInteger)month;

#pragma mark - 获取某个日期相隔几天的日期(过去时间的为负,未来时间为正,0就是现在的时间)
+ (NSString *)getLastDayWithDate:(NSString *)date day:(NSInteger)day;

#pragma -mark 获取当前时间之前或之后几天的日期(过去时间的为负,未来时间为正,0就是现在的时间)
+ (NSString *)getLastDayWithDay:(int)day;

#pragma mark - 获取当前时间(20140101111111)
+ (NSString *)getNowTime;

#pragma mark - 一个时间和现在相差多少秒(返回正数)
+ (NSInteger)componentsSecondNowWithDate:(NSString *)date;
#pragma mark - 一个时间和现在相差多少秒(返回正负数)
+ (NSInteger)componentsSecondNowWithDateContainNegative:(NSString *)date;

#pragma mark - 获取从1970年到当前的毫秒数
+ (NSString *)currentDateTimeIntervalToString;

/**
 *  以特定的Key,保存当前的毫秒数
 *
 *  @param key
 */
+ (void)saveNowDateTimeIntervalWithKey:(NSString *)key;

/**
 *  以特定的Key,计算当前时间和保存的时间毫秒数差
 *
 *  @param key key description
 *
 *  @return 毫秒数差
 */
+ (NSTimeInterval)currentNowTimeIntervalWithKey:(NSString *)key;

#pragma 时间 NSString 转 NSString 格式: MM/dd HH:mm  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToCircleGame:(NSString *)str;

#pragma 时间戳 转 时间 输出格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToTimeInterval:(NSString *)str;

#pragma 时间 NSString 转 NSString 格式: yyyyMMdd HH:mm:ss  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterForTrade:(NSString *)str;

#pragma mark - 截取时间 输入格式:HHmmss 输出格式:HH:mm:ss (少一位时,自动前面补0)
/**
 *  截取时间 
 *
 *  @param time 输入格式:HHmmss(少一位时,自动前面补0)
 *
 *  @return return 输出格式:HH:mm:ss
 */
+ (NSString *)cutStringTimeToHHmmss:(NSString *)time;

#pragma mark - 获取日期前后的月份日期，正数是以后n个月，负数是前n个月
+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month;

#pragma mark - 获取当前月份有多少天
+ (NSInteger)getDateMonthLength:(NSDate *)date;

#pragma mark - 格式化日期(自己控制输入-输出格式)
/**
 *  格式化日期(自己控制输入-输出格式)
 *
 *  @param date      要格式化的日期
 *  @param inStytle  格式化前的输入格式(如:yyyyMMddHHmmss)
 *  @param outStytle 目标格式(如:yyyyMMdd HH:mm:ss)
 *
 *  @return return value description
 */
+ (NSString *)formatterDate:(NSString *)date inStytle:(NSString *)inStytle outStytle:(NSString *)outStytle;

/**
 *  格式化日期(自己控制输入-输出格式)
 *
 *  @param date      要格式化的日期
 *  @param inStytle  格式化前的输入格式(如:yyyyMMddHHmmss)
 *  @param outStytle 目标格式(如:yyyyMMdd HH:mm:ss)
 *  @param isTimestamp 输入的date是否为时间戳格式
 *  @return return value description
 */
+ (NSString *)formatterDate:(NSString *)date inStytle:(NSString *)inStytle outStytle:(NSString *)outStytle isTimestamp:(BOOL)isTimestamp;


#pragma mark - 根据时间格式为yyyy-MM-dd HH:mm:ss转化成几小时前，几天前
+ (NSString *)getAnyTimeFromDateFormat:(NSString *)time;

/**
 *  @brief  转换时间,今天的时间显示10:30,昨天和前天的显示昨天,前天,不带时间,
 *          七天内的显示星期几,再超过显示2014-12-01
 *
 *  @param str <#str description#>
 *
 *  @return <#return description#>
 */
+ (NSString *)sortTimeDateFormatter:(NSString *)str;


#pragma mark - 传入秒数获得D天h小时M分s秒
+ (NSString *)getDayHourMinuteSecondFromSeconds:(NSInteger)senconds;

#pragma mark - 传入秒数获得天、小时、分、秒分别存放的字典 （只能传入正数）
/**
 *  day     :  天
 *  hour    :  小时
 *  minute  :  分
 *  sencond :  秒
 */
+ (NSDictionary *)getDayHourMinuteSecondDictionaryFromSeconds:(NSInteger)senconds;

#pragma mark - 传入秒数获得小时、分、秒分别存放的字典 （只能传入正数）
/**
 *  hour    :  小时
 *  minute  :  分
 *  sencond :  秒
 */
+ (NSDictionary *)getHourMinuteSecondDictionaryFromSeconds:(NSInteger)senconds;

@end
