//
//  VeDateUtil.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-8-31.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import "VeDateUtil.h"

@implementation VeDateUtil

#pragma mark - 将字符串时间转换成NSDate
+ (NSDate *)stringDataToNSDate:(NSString *)str {
    if (TTIsStringWithAnyText(str)) {
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        
        // 转换时区
//        NSTimeZone *timezone = [[[NSTimeZone alloc] initWithName:@"GMT"]autorelease];
//        [dateformat setTimeZone:timezone];
        
        NSDate *date = [dateformat dateFromString:str];
        RELEASE(dateformat);
        return date;
    }
    return nil;
}


#pragma mark - 将NSDate时间转换成字符串 格式：yyyyMMddHHmmss
+ (NSString *)dateToString:(NSDate *)date {
    
    NSDateFormatter *dateformat = [[[NSDateFormatter alloc] init]autorelease];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    // 转换时区
//    NSTimeZone *timezone = [[[NSTimeZone alloc] initWithName:@"GMT"]autorelease];
//    [dateformat setTimeZone:timezone];

    return [dateformat stringFromDate:date];
}


#pragma mark - 两天相差的秒数(含负数)
+ (NSInteger)componentsSecondsBetweenTwoDaysStr:(NSString *)startDate endDate:(NSString *)endDate
{
    if(startDate.length <= 0 || endDate.length <= 0){
        return 0;
    }
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *startDateTemp = [dateformat dateFromString:startDate];
    NSDate *endDateTemp = [dateformat dateFromString:endDate];
    [dateformat release];

    NSInteger intervalTime = [endDateTemp timeIntervalSince1970] - [startDateTemp timeIntervalSince1970];
    
    return intervalTime;
}


/**
 获取两个日期之间的自然天数，例如：
 开始时间：
 2012-03-19 23:00
 结束时间：
 2012-03-20 01:00
 这算是一天的时间。
 */
#pragma mark - 获取两个日期之间的自然天数
+ (NSInteger)calcDaysFromBegin:(NSDate *)startDate toDate:(NSDate *)endDate{
    
    NSTimeZone *timezone = [[[NSTimeZone alloc] initWithName:@"GMT"] autorelease];
    
    NSInteger unitFlags = NSCalendarUnitDay| NSCalendarUnitMonth | NSCalendarUnitYear;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [cal setTimeZone:timezone];
    NSDateComponents *comps = [cal components:unitFlags fromDate:startDate];
    NSDate *newBegin  = [cal dateFromComponents:comps];
    [cal release];
    
    NSCalendar *cal2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [cal2 setTimeZone:timezone];
    NSDateComponents *comps2 = [cal2 components:unitFlags fromDate:endDate];
    NSDate *newEnd  = [cal2 dateFromComponents:comps2];
    [cal2 release];
    
    NSTimeInterval interval = [newEnd timeIntervalSinceDate:newBegin];
    NSInteger beginDays=((NSInteger)interval)/(3600*24);
    
    return beginDays;
}

#pragma 相差的时间天数(标准时间)
+ (NSInteger)componentsTwoDays:(NSDate *)startDate toDate:(NSDate *)endDate {
	// 获取startDate与endDate 之间相隔几天
    double intervalTime = fabs([startDate timeIntervalSinceReferenceDate] - [endDate timeIntervalSinceReferenceDate]);
    NSInteger days = intervalTime/60/60/24;
    
	return days;
}

#pragma 两天相差的分钟时间数
+ (NSInteger)componentsTwoTimeMins:(NSDate *)startDate toDate:(NSDate *)endDate {
    
	NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
	NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	NSTimeZone *timezone = [[[NSTimeZone alloc] initWithName:@"GMT"] autorelease];
    
	[calendar setTimeZone:timezone];
	NSDateComponents *comps = [calendar components:unitFlags fromDate:startDate];
    NSInteger startMins = [comps minute];
    NSInteger startHours = [comps hour];
	NSInteger startDays = [comps day];
	NSInteger startyear = [comps year];
	NSInteger startmonth = [comps month];
	comps = [calendar components:unitFlags fromDate:endDate];
    NSInteger endsMins = [comps minute];
    NSInteger endsHours = [comps hour];
	NSInteger endsDays = [comps day];
	NSInteger endsyear = [comps year];
	NSInteger endsmonth = [comps month];
    
	return (endsMins - startMins) + (endsHours - startHours) * 60 + (endsDays - startDays) * 24 * 60  + (endsmonth - startmonth) * 30 * 24 * 60 + (endsyear - startyear) * 365 * 24 * 60;
}

#pragma  取得日期與時間的各項整數型資料
#pragma int year=[comps year];
#pragma int week = [comps weekday];
#pragma int month = [comps month];
#pragma int day = [comps day];
#pragma int hour = [comps hour];
#pragma int min = [comps minute];
#pragma int sec = [comps second];

+ (NSDateComponents *)initWithChinaTimezone:(NSDate *)date {
	NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
	NSTimeZone *timezone = [[[NSTimeZone alloc] initWithName:@"GMT"] autorelease];
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];

	[calendar setTimeZone:timezone];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	comps = [calendar components:unitFlags fromDate:date];
	return comps;
}

#pragma 时间 NSDate 转 int (总秒数)
+ (NSInteger)getStringHHMMSSToInt:(NSDate *)date {
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger hour = [comps hour];
	NSInteger min = [comps minute];
	NSInteger sec = [comps second];

	return hour * 60 * 60 + min * 60 + sec;
}

#pragma 得到星期几 格式:星期X (例如 星期一)
+ (NSString *)getWeekStr:(NSDate *)date {
	NSString *nowweekstr = @"";
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger week = [comps weekday];

	// 將星期的數字轉為字串
	switch (week) {
        case 1:
            nowweekstr = @"星期日";
            break;
            
		case 2:
			nowweekstr = @"星期一";
			break;

		case 3:
			nowweekstr = @"星期二";
			break;

		case 4:
			nowweekstr = @"星期三";
			break;

		case 5:
			nowweekstr = @"星期四";
			break;

		case 6:
			nowweekstr = @"星期五";
			break;

		case 7:
			nowweekstr = @"星期六";
			break;
	}

	return nowweekstr;
}

#pragma 时间 NSDate 转 NSString 格式: MM:dd YY
+ (NSString *)getDateToHHmm:(NSDate *)date {
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger hour = [comps hour];
	NSInteger min = [comps minute];
	NSString *hourStr = [NSString stringWithFormat:@"%ld", (long)hour];
	NSString *minStr = [NSString stringWithFormat:@"%ld", (long)min];

	if (hour < 10) {
		hourStr = [NSString stringWithFormat:@"0%ld", (long)hour];
	}

	if (min < 10) {
		minStr = [NSString stringWithFormat:@"0%ld", (long)min];
	}
	return [NSString stringWithFormat:@"%@:%@", hourStr, minStr];
}

#pragma 时间 NSDate 转 NSString 格式: MM:dd YY
+ (NSString *)getStringDateMMddYY:(NSDate *)date {
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
    
    NSString *monStr = [NSString stringWithFormat:@"%ld", (long)month];
    NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
    
    if (month < 10) {
        monStr = [NSString stringWithFormat:@"0%ld", (long)month];
    }
    
    if (day < 10) {
        dayStr = [NSString stringWithFormat:@"0%ld", (long)day];
    }

	return [NSString stringWithFormat:@"%@-%@ %ld", monStr, dayStr, (long)year];
}

#pragma 时间 NSDate 转 NSString 格式: YYMM
+ (NSString *)getDateToYYMMWithoutStr:(NSDate *)date {
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSString *monthStr;

	if (month < 10) {
		monthStr = [NSString stringWithFormat:@"0%ld", (long)month];
	} else {
		monthStr = [NSString stringWithFormat:@"%ld", (long)month];
	}
	NSString *yearStr = [NSString stringWithFormat:@"%ld", (long)year];

	return [NSString stringWithFormat:@"%@%@", yearStr, monthStr];
}

#pragma 时间 NSDate 转 NSString 格式: MMddHHmmss
+ (NSString *)getDateToMMddHHmmss:(NSDate *)date {
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	NSInteger hour = [comps hour];
	NSInteger min = [comps minute];
	NSInteger sec = [comps second];
	NSString *hourStr = [NSString stringWithFormat:@"%ld", (long)hour];
	NSString *minStr = [NSString stringWithFormat:@"%ld", (long)min];
	NSString *secStr = [NSString stringWithFormat:@"%ld", (long)sec];

	if (hour < 10) {
		hourStr = [NSString stringWithFormat:@"0%ld", (long)hour];
	}

	if (min < 10) {
		minStr = [NSString stringWithFormat:@"0%ld", (long)min];
	}

	if (sec < 10) {
		secStr = [NSString stringWithFormat:@"0%ld", (long)sec];
	}
	return [NSString stringWithFormat:@"%ld-%ld %@:%@:%@", (long)month, (long)day, hourStr, minStr, secStr];
}

#pragma 时间 NSDate 转 NSString 格式: MMddHHmm
+ (NSString *)getDateToMMddHHmm:(NSDate *)date {
	NSDateComponents *comps = [self initWithChinaTimezone:date];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	NSInteger hour = [comps hour];
	NSInteger min = [comps minute];
	NSString *hourStr = [NSString stringWithFormat:@"%ld", (long)hour];
	NSString *minStr = [NSString stringWithFormat:@"%ld", (long)min];
    NSString *monStr = [NSString stringWithFormat:@"%ld", (long)month];
    NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
    
	if (hour < 10) {
		hourStr = [NSString stringWithFormat:@"0%ld", (long)hour];
	}

	if (min < 10) {
		minStr = [NSString stringWithFormat:@"0%ld", (long)min];
	}
    
    if (month < 10) {
        monStr = [NSString stringWithFormat:@"0%ld", (long)month];
    }
    
    if (day < 10) {
        dayStr = [NSString stringWithFormat:@"0%ld", (long)day];
    }
	return [NSString stringWithFormat:@"%@-%@ %@:%@", monStr, dayStr, hourStr, minStr];
}

#pragma 时间 NSDate 转 NSString 格式: 今天 10:30
+ (NSString *)getCustomizeTimeFormat:(NSDate *)hDate {
	NSString *timeFormat = @"";

	if (hDate == nil) return timeFormat;

	NSDate *nDate = [self dateToLocaleDate:[NSDate date]];
	NSInteger days = [self calcDaysFromBegin:hDate toDate:nDate];

	if (days == 0) {		// 今天
		timeFormat = [NSString stringWithFormat:@"今天 %@", [self getDateToHHmm:hDate]];
	} else if (days == 1) {	// 昨天
		timeFormat = [NSString stringWithFormat:@"昨天 %@", [self getDateToHHmm:hDate]];
	} else if (days == 2) {	// 前天
		timeFormat = [NSString stringWithFormat:@"前天 %@", [self getDateToHHmm:hDate]];
    } else if (days >= 365) {
		timeFormat = [self getStringDateMMddYY:hDate];
	} else {
        timeFormat = [self getDateToMMddHHmm:hDate];
	}
	return timeFormat;
}

#pragma 时间 NSDate 转 NSString 格式: 今天 10:30, 星期X, XXXX年XX月XX日 XX:XX
+ (NSString *)getCustomizeTimeLongFormat:(NSDate *)hDate {
    NSString *timeFormat = @"";
    
    if (hDate == nil) return timeFormat;
    
    NSDate *nDate = [self dateToLocaleDate:[NSDate date]];
    NSInteger days = [self calcDaysFromBegin:hDate toDate:nDate];
    
    if (days == 0) {		// 今天
        timeFormat = [NSString stringWithFormat:@"今天 %@", [self getDateToHHmm:hDate]];
    } else if (days == 1) {	// 昨天
        timeFormat = [NSString stringWithFormat:@"昨天 %@", [self getDateToHHmm:hDate]];
    } else if (days == 2) {	// 前天
        timeFormat = [NSString stringWithFormat:@"前天 %@", [self getDateToHHmm:hDate]];
    } else if (days > 2 && days <= 7) {	// 前天到7天内
        timeFormat = [NSString stringWithFormat:@"%@ %@", [self getWeekStr:hDate], [self getDateToHHmm:hDate]];
    }else {
        timeFormat = [self dateFormatterToYYYYMMDDHHMM:[VeDateUtil dateToString:hDate]];
    }
    return timeFormat;
}

#pragma 时间 NSDate 转 NSString 格式: 今天 XX 10:30
+ (NSString *)getCustomizeTimeFormatForH:(NSDate *)hDate {
	NSString *timeFormat = @"";

	if (hDate == nil) return timeFormat;

	NSDate *nDate = [self dateToLocaleDate:[NSDate date]];
	NSInteger days = [self calcDaysFromBegin:hDate toDate:nDate];
	NSInteger k = [self getStringHHMMSSToInt:hDate];

	if (days == 0) {// 今天
		timeFormat = @"今天";

		if ((k > 0) && (k < 6 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 凌晨", [self getDateToHHmm:hDate]];
		else if ((k >= 6 * 60 * 60) && (k < 9 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 早晨", [self getDateToHHmm:hDate]];
		else if ((k >= 9 * 60 * 60) && (k < 14 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 中午", [self getDateToHHmm:hDate]];
		else if ((k >= 14 * 60 * 60) && (k < 19 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 下午", [self getDateToHHmm:hDate]];
		else timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 晚上", [self getDateToHHmm:hDate]];
	} else if (days == 1) {	// 昨天
		timeFormat = [NSString stringWithFormat:@"昨天 %@", [self getDateToHHmm:hDate]];
		timeFormat = @"昨天";

		if ((k > 0) && (k < 6 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 凌晨", [self getDateToHHmm:hDate]];
		else if ((k >= 6 * 60 * 60) && (k < 9 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 早晨", [self getDateToHHmm:hDate]];
		else if ((k >= 9 * 60 * 60) && (k < 14 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 中午", [self getDateToHHmm:hDate]];
		else if ((k >= 14 * 60 * 60) && (k < 19 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 下午", [self getDateToHHmm:hDate]];
		else timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 晚上", [self getDateToHHmm:hDate]];
	} else if (days == 2) {	// 前天
		timeFormat = [NSString stringWithFormat:@"前天 %@", [self getDateToHHmm:hDate]];
		timeFormat = @"前天";

		if ((k > 0) && (k < 6 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 凌晨", [self getDateToHHmm:hDate]];
		else if ((k >= 6 * 60 * 60) && (k < 9 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 早晨", [self getDateToHHmm:hDate]];
		else if ((k >= 9 * 60 * 60) && (k < 14 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 中午", [self getDateToHHmm:hDate]];
		else if ((k >= 14 * 60 * 60) && (k < 19 * 60 * 60)) timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 下午", [self getDateToHHmm:hDate]];
		else timeFormat = [NSString stringWithFormat:@"%@%@%@", timeFormat, @" 晚上", [self getDateToHHmm:hDate]];
	} else if (days >= 365) {
		timeFormat = [self getStringDateMMddYY:hDate];
	} else {
		timeFormat = [self getDateToMMddHHmm:hDate];
	}
	return timeFormat;
}

#pragma 时间 NSString 转 NSString 格式: 今天 10:30
+ (NSString *)dateFormatter:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:@"GMT"];
	[dateformat setTimeZone:timezone];
	// 转换时区
	NSDate *theDate = [dateformat dateFromString:str];

	NSString *finalStr = [self getCustomizeTimeFormat:theDate];
	[dateformat release];
	[timezone release];
	return finalStr;
}

#pragma 时间 NSString 转 NSString 格式: 今天 10:30, XXXX年XX月XX日 XX:XX
+ (NSString *)dateLongFormatter:(NSString *)str {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:@"GMT"];
    [dateformat setTimeZone:timezone];
    // 转换时区
    NSDate *theDate = [dateformat dateFromString:str];
    
    NSString *finalStr = [self getCustomizeTimeLongFormat:theDate];
    [dateformat release];
    [timezone release];
    return finalStr;
}

#pragma 时间 NSDate 转 中国时区NSDate
+ (NSDate *)dateToLocaleDate:(NSDate *)date {
	NSTimeZone *zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:date];
	NSDate *localeDate = [date dateByAddingTimeInterval:interval];

	return localeDate;
}

#pragma 时间 NSString 转 NSString 格式: YYYY年MM月dd日  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToChinaDay:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyy年MM月dd日"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 NSString 转 NSString 格式: YYYY-MM-dd  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToSimpleDay:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyy-MM-dd"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 NSString 转 NSString 格式: YYYY-MM-dd  HH:mm  输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterToDayBaseDate:(NSString*)str
{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:str];
    [dateformat setDateFormat:@"yyyy-MM-dd  HH:mm"];
    NSString *finalStr = [dateformat stringFromDate:theDate];
    [dateformat release];
    return finalStr;
}

#pragma 时间 NSString 转 NSString 格式: HH:mm   输入格式:yyyyMMddHHmmss
+(NSString*)dateFormatterToSimpleTime:(NSString*)str
{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:str];
    [dateformat setDateFormat:@"HH:mm"];
    NSString *finalStr = [dateformat stringFromDate:theDate];
    [dateformat release];
    return finalStr;
}

#pragma mark - 截取时间
+ (NSString *)cutStringTime:(NSString *)time keepHour:(BOOL)keepHour keepMinute:(BOOL)keepMinute keepSecond:(BOOL)keepSecond {
	NSDateFormatter *format = [[NSDateFormatter alloc] init];

	[format setDateFormat:@"HH:mm:ss"];
	NSDate *date = [format dateFromString:time];
	NSMutableString *str = [[NSMutableString alloc] init];

	if (keepHour) [str appendString:@"HH"];

	if (keepMinute) {
		if (str.length > 0) [str appendString:@":"];
		[str appendString:@"mm"];
	}

	if (keepSecond) {
		if (str.length > 0) [str appendString:@":"];
		[str appendString:@"ss"];
	}
	[format setDateFormat:str];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);
	TT_RELEASE_SAFELY(str);
	return result;
}

#pragma mark - 截取时间
+ (NSString *)cutStringTime:(NSString *)time stytle:(NSString *)stytle keepHour:(BOOL)keepHour keepMinute:(BOOL)keepMinute keepSecond:(BOOL)keepSecond {
	NSDateFormatter *format = [[NSDateFormatter alloc] init];

	[format setDateFormat:@"HH:mm:ss"];
	NSDate *date = [format dateFromString:time];
	NSMutableString *str = [[NSMutableString alloc] init];

	if (keepHour) [str appendString:@"HH"];

	if (keepMinute) {
		if (str.length > 0) [str appendString:stytle];
		[str appendString:@"mm"];
	}

	if (keepSecond) {
		if (str.length > 0) [str appendString:stytle];
		[str appendString:@"ss"];
	}
	[format setDateFormat:str];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);
	TT_RELEASE_SAFELY(str);
	return result;
}

#pragma mark - 以自定样式分割时间(如以-  2012-01-01)(输入为整型时间)
+ (NSString *)getStringIntToDate:(NSUInteger)time stytle:(NSString *)stytle keepHead:(BOOL)keeyHead {
	if (time <= 10000000) return @"";

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyyMMdd"];
	NSDate *date = [format dateFromString:[NSString stringWithFormat:@"%@", @(time)]];
	NSMutableString *str = [[NSMutableString alloc] init];

	if (keeyHead) [str appendString:@"yyyy"];
	else [str appendString:@"yy"];
	[str appendFormat:@"%@MM%@dd", stytle, stytle];
	[format setDateFormat:str];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);
	TT_RELEASE_SAFELY(str);

	if (result && (result.length > 0)) return result;
	else return @"";
}

#pragma mark - 以自定样式分割时间(如以-  2012-01-01)(可自定输入类型如inputStytle为@"-",那输入的时间就是2012-01-01)
+ (NSString *)getStringIntToDate:(NSString *)time inputStytle:(NSString *)inputStytle stytle:(NSString *)stytle keepHead:(BOOL)keeyHead {
	if (!time) return @"";

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd", inputStytle, inputStytle]];
	NSDate *date = [format dateFromString:time];
	NSMutableString *str = [[NSMutableString alloc] init];

	if (keeyHead) [str appendString:@"yyyy"];
	else [str appendString:@"yy"];
	[str appendFormat:@"%@MM%@dd", stytle, stytle];
	[format setDateFormat:str];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);
	TT_RELEASE_SAFELY(str);

	if (result && (result.length > 0)) return result;
	else return @"";
}

+ (NSString *)getTimeForMMDD:(NSString *)time {
	if (!time) return @"";

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyyMMdd"];
	NSDate *date = [format dateFromString:time];
	[format setDateFormat:@"MM-dd"];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);

	if (result && (result.length > 0)) return result;
	else return @"";
}

#pragma mark - 长整型时间.格式化为(2012-01-01 15:25)
+ (NSString *)getLongDateToYYYYMMDDHHMM:(NSString *)time {
	if (!time || (time.length < 5) || ([time longLongValue] < 20001017145843)) return @"";	// 20121017145843

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *date = [format dateFromString:[NSString stringWithFormat:@"%@", time]];
	NSString *str = @"yyyy-MM-dd HH:mm";
	[format setDateFormat:str];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);

	if (result && (result.length > 0)) return result;
	else return @"";
}

#pragma mark - 长整型时间.格式化为(2012-01-01 15:25:00)
+ (NSString *)getLongDateToYYYYMMDDHHMMSS:(NSString *)time {
    if (!time || (time.length < 5) || ([time longLongValue] < 20001017145843)) return @"";	// 20121017145843
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [format dateFromString:[NSString stringWithFormat:@"%@", time]];
    NSString *str = @"yyyy-MM-dd HH:mm:ss";
    [format setDateFormat:str];
    NSString *result = [format stringFromDate:date];
    TT_RELEASE_SAFELY(format);
    
    if (result && (result.length > 0)) return result;
    else return @"";
}

#pragma mark - String型时间.格式化为(01-01 15:25)
+ (NSString *)getStringDateToMMDDHHMM:(NSString *)time {
	if (!time || (time.length < 5) || ([time longLongValue] < 20001017145843)) return @"";	// 20121017145843

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *date = [format dateFromString:[NSString stringWithFormat:@"%@", time]];
	NSString *str = @"MM-dd HH:mm";
	[format setDateFormat:str];
	NSString *result = [format stringFromDate:date];
	TT_RELEASE_SAFELY(format);

	if (result && (result.length > 0)) return result;
	else return @"";
}

#pragma mark - 时间 NSString 转 NSString 格式: YYYY年MM月dd日 HH:mm  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToYYYYMMDDHHMM:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyy年MM月dd日 HH:mm"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma mark - 将日期转换成YYYY年MM月dd日  输入格式:yyyyMMdd
+ (NSString *)dateFormatterToYYYYMMDD:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMdd"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyy年MM月dd日"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma mark - 将日期转换成MM月dd日  输入格式:yyyy-MM-dd
+ (NSString *)dateFormatterToMMDD:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyy-MM-dd"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"MM月dd日"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 NSString 转 NSString 格式: MMddHHmm  输入格式:yyyyMMddHHmm
+ (NSString *)dateFormatterWithyyyyMMddHHmmToMMddHHmm:(NSString *)str {
	NSDateFormatter *dateformat = nil;

	@try {
		if (!str || (str.length == 0)) return nil;

		dateformat = [[NSDateFormatter  alloc] init];
		[dateformat setDateFormat:@"yyyyMMddHHmm"];
		NSDate *theDate = [dateformat dateFromString:str];
		[dateformat setDateFormat:@"MMddHHmm"];
		NSString *finalStr = [dateformat stringFromDate:theDate];
		return finalStr;
	}
	@catch(NSException *exception) {
		return nil;
	}

	@finally {
		RELEASE(dateformat);
	}
}

+ (NSString *)dateFormatterWithyyyyMMddHHmmToMM_dd_HH_mm:(NSString *)str {
	NSDateFormatter *dateformat = nil;

	@try {
		if (!TTIsStringWithAnyText(str)) return @"";

		dateformat = [[NSDateFormatter  alloc] init];
		[dateformat setDateFormat:@"yyyyMMddHHmm"];
		NSDate *theDate = [dateformat dateFromString:str];
		[dateformat setDateFormat:@"MM-dd HH:mm"];
		NSString *finalStr = [dateformat stringFromDate:theDate];
		return finalStr;
	}
	@catch(NSException *exception) {
		return @"";
	}

	@finally {
		RELEASE(dateformat);
	}
}

#pragma 时间 例子:输入20120510转换返回2012年5月
+ (NSString *)getLongDateToYYMMWithStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMdd"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyy年MM月"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 例子:输入格式为20120510转换返回201205
+ (NSString *)getLongDateToYYMMWithoutStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMdd"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyyMM"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 例子:输入20120510122310转换返回日期201205
+ (NSString *)getLongAllDateToYYMMWithoutStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyyMM"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 例子:输入20120510122310转换返回日期20120510
+ (NSString *)getLongAllDateToYYMMDDWithoutStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"yyyyMMdd"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 例子:输入20120510转换返回日期10
+ (NSString *)getLongDateToDDWithoutStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMdd"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"dd"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 例子:输入20120510122310转换返回日期10
+ (NSString *)getLongAllDateToDDWithoutStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"dd"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 时间 例子:输入20120510转换返回日期5月10日
+ (NSString *)getLongDateToMMDDWithStr:(NSString *)str {
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];

	[dateformat setDateFormat:@"yyyyMMdd"];
	NSDate *theDate = [dateformat dateFromString:str];
	[dateformat setDateFormat:@"MM月dd日"];
	NSString *finalStr = [dateformat stringFromDate:theDate];
	[dateformat release];
	return finalStr;
}

#pragma 返回指定string是否今天日期
+ (BOOL)isToday:(NSString *)str {
	if (str.length > 0) {
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"yyyyMMddHHmmss"];
		NSDate *date = [format dateFromString:str];
		NSDate *nDate = [self dateToLocaleDate:[NSDate date]];
		NSInteger days = [self calcDaysFromBegin:date toDate:nDate];

		if (days == 0) {// 今天
			return YES;
		}
	}
	return NO;
}

#pragma mark - 获取某个日期几个月后的日期
+ (NSString *)getLastDayWithDate:(NSString *)date month:(NSInteger)month {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
	[dateformat setDateFormat:@"yyyyMMdd"];
	NSDate *theDate = [dateformat dateFromString:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:theDate];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:month];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:theDate options:0];
    NSString *str = [dateformat stringFromDate:newdate];
    [dateformat release];
    [calendar release];
    [adcomps release];
    return str;
}

#pragma mark - 获取某个日期相隔几天的日期(过去时间的为负,未来时间为正,0就是现在的时间)
+ (NSString *)getLastDayWithDate:(NSString *)date day:(NSInteger)day {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:theDate];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:day];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:theDate options:0];
    NSString *str = [dateformat stringFromDate:newdate];
    [dateformat release];
    [calendar release];
    [adcomps release];
    return str;
}

#pragma mark - 获取当前时间之前或之后几天的日期(过去时间的为负,未来时间为正,0就是现在的时间)
+ (NSString *)getLastDayWithDay:(int)day {
	NSTimeInterval secondsPerDay = day * 24 * 60 * 60;

	NSDate *dayDate = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDay];
	NSDateFormatter *format = [[NSDateFormatter alloc] init];

	[format setDateFormat:@"yyyyMMddHHmmss"];
	NSString *dayString = [format stringFromDate:dayDate];
	[format release];
	[dayDate release];
	return dayString;
}

#pragma mark - 获取当前时间(20140101111111)
+ (NSString *)getNowTime {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
	formatter.numberStyle = NSNumberFormatterNoStyle;
	NSDate *time = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *timeString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:time]];
	[dateFormatter release];
	return timeString;
}

#pragma mark - 一个时间和现在相差多少秒(返回正数)
+ (NSInteger)componentsSecondNowWithDate:(NSString *)date {
    if (!TTIsStringWithAnyText(date)) return NSIntegerMax;
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:date];
    NSTimeInterval second = [theDate timeIntervalSinceNow];
    RELEASE(dateformat);
    return ABS(second);
}

#pragma mark - 一个时间和现在相差多少秒(返回正负数)
+ (NSInteger)componentsSecondNowWithDateContainNegative:(NSString *)date {
    if (!TTIsStringWithAnyText(date)) return NSIntegerMax;
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:date];
    NSTimeInterval second = [theDate timeIntervalSinceNow];
    RELEASE(dateformat);
    return second;
}

#pragma mark - 获取从1970年到当前的毫秒数
+ (NSString *)currentDateTimeIntervalToString {
    NSDate *currentDate = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [currentDate timeIntervalSince1970] * 1000];
    
    return timestamp;
}

/**
 *  暂时没用
 *  以特定的Key,保存当前的毫秒数
 *
 *  @param key
 */
+ (void)saveNowDateTimeIntervalWithKey:(NSString *)key {
    if (TTIsStringWithAnyText(key)) {
        [[NSUserDefaults standardUserDefaults] setObject:[VeDateUtil currentDateTimeIntervalToString] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 *  以特定的Key,计算当前时间和保存的时间毫秒数差
 *
 *  @param key <#key description#>
 *
 *  @return 毫秒数差
 */
+ (NSTimeInterval)currentNowTimeIntervalWithKey:(NSString *)key {
    if (TTIsStringWithAnyText(key)) {
        NSString *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSTimeInterval last = TTIsStringWithAnyText(lastTime) ? [lastTime doubleValue] : 0;
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970] * 1000;
        return ABS(now - last);
    }
    return 0;
}

#pragma 时间 NSString 转 NSString 格式: MM/dd HH:mm  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToCircleGame:(NSString *)str {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:str];
    [dateformat setDateFormat:@"MM/dd HH:mm"];
    NSString *finalStr = [dateformat stringFromDate:theDate];
    [dateformat release];
    return finalStr;
}

#pragma 时间戳 转 时间 输出格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterToTimeInterval:(NSString *)str {
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[str doubleValue]];
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];

    NSString *finalStr = [dateformat stringFromDate:confromTimesp];
    [dateformat release];
    
    return finalStr;
}

#pragma 时间 NSString 转 NSString 格式: yyyy/MM/dd HH:mm:ss  输入格式:yyyyMMddHHmmss
+ (NSString *)dateFormatterForTrade:(NSString *)str {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *theDate = [dateformat dateFromString:str];
    [dateformat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *finalStr = [dateformat stringFromDate:theDate];
    [dateformat release];
    return finalStr;
}


#pragma mark - 截取时间 输入格式:HHmmss 输出格式:HH:mm:ss (少一位时,自动前面补0)
/**
 *  截取时间
 *
 *  @param time 输入格式:HHmmss(少一位时,自动前面补0)
 *
 *  @return return 输出格式:HH:mm:ss
 */
+ (NSString *)cutStringTimeToHHmmss:(NSString *)time {
    if (TTIsStringWithAnyText(time)) {
        if (time.length == 5) time = [NSString stringWithFormat:@"0%@",time];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        
        [format setDateFormat:@"HHmmss"];
        NSDate *theDate = [format dateFromString:time];
        [format setDateFormat:@"HH:mm:ss"];
        NSString *result = [format stringFromDate:theDate];
        RELEASE(format);
        return result;
    }
    return time;
}

#pragma mark - 获取日期前后的月份日期，正数是以后n个月，负数是前n个月
+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month {
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    [comps release];
    [calender release];
    
    return mDate;
}

#pragma mark - 获取当前月份有多少天
+ (NSInteger)getDateMonthLength:(NSDate *)date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSUInteger numberOfDaysInMonth = range.length;
    
    return numberOfDaysInMonth;
}

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
+ (NSString *)formatterDate:(NSString *)date inStytle:(NSString *)inStytle outStytle:(NSString *)outStytle
{
    return [VeDateUtil formatterDate:date inStytle:inStytle outStytle:outStytle isTimestamp:NO];
}

+ (NSString *)formatterDate:(NSString *)date inStytle:(NSString *)inStytle outStytle:(NSString *)outStytle isTimestamp:(BOOL)isTimestamp
{
    if(isTimestamp){
        if (TTIsStringWithAnyText(date) && TTIsStringWithAnyText(outStytle)) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:[date doubleValue]];
            [formatter setDateFormat:outStytle];
            NSString *result = [formatter stringFromDate:theDate];
            RELEASE(formatter);
            
            return result;
        }
    }else{
        if (TTIsStringWithAnyText(date) && TTIsStringWithAnyText(inStytle) && TTIsStringWithAnyText(outStytle)) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:inStytle];
            NSDate *theDate = [format dateFromString:date];
            [format setDateFormat:outStytle];
            NSString *result = [format stringFromDate:theDate];
            RELEASE(format);
            return result;
        }
    }

    return nil;
}


#pragma mark - 根据时间格式为yyyyMMddHHmmss 转化成几小时前，几天前
+ (NSString *)getAnyTimeFromDateFormat:(NSString *)timeStr
{
    //把字符串转为NSdate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *timeDate = [dateFormatter dateFromString:timeStr];
    
    //得到与当前时间差
    NSTimeInterval  timeInterval = [timeDate timeIntervalSinceNow];
    timeInterval = -timeInterval;

    NSInteger temp = 0;
    NSString *result;
    if (timeInterval < 30) {
        result = [NSString stringWithFormat:@"现在"];
    }
    else if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"1分钟内"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%@分钟前",@(temp)];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%@小时前",@(temp)];
    }
    else if((temp = temp / 24) < 8){
        result = [NSString stringWithFormat:@"%@天前",@(temp)];
    }else{
        result = [self formatterDate:timeStr inStytle:@"yyyyMMddHHmmss" outStytle:@"yyyy-MM-dd HH:mm"];
    }
    
    return result;
}

/**
 *  @brief  转换时间,今天的时间显示10:30,昨天和前天的显示昨天,前天,不带时间,
 *          七天内的显示星期几,再超过显示2014-12-01
 *
 *  @param str <#str description#> 
 *
 *  @return <#return description#> 
 */ 
+ (NSString *)sortTimeDateFormatter:(NSString *)str {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:@"GMT"];
    [dateformat setTimeZone:timezone];
        // 转换时区
    NSDate *theDate = [dateformat dateFromString:str];
    
    NSString *timeFormat = @"";
    
    if (theDate == nil) return timeFormat;
    
    NSDate *nDate = [self dateToLocaleDate:[NSDate date]];
    NSInteger days = [self calcDaysFromBegin:theDate toDate:nDate];
    
    if (days == 0) {		// 今天
        timeFormat = [self getDateToHHmm:theDate];
    } else if (days == 1) {	// 昨天
        timeFormat = @"昨天";
    } else if (days == 2) {	// 前天
        timeFormat = @"前天";
    } else if (days <= 7) {
        timeFormat = [self getWeekStr:theDate];
    } else {
        timeFormat = [self formatterDate:str inStytle:@"yyyyMMddHHmmss" outStytle:@"yyyy/MM/dd"];
        
    }
    [dateformat release];
    [timezone release];
    return timeFormat;
}

#pragma mark - 传入秒数获得D天h小时M分s秒
+ (NSString *)getDayHourMinuteSecondFromSeconds:(NSInteger)senconds
{
    NSInteger days = (senconds / 60 / 60 / 24);
    NSInteger hours = (senconds / 60 / 60 - (24 * days));
    NSInteger minutes = (senconds /60 - (24 * 60 * days) - (60 * hours));
    NSInteger seconds = (senconds - (24 * 60 * 60 * days) - (60 * 60 * hours) - (60 * minutes));
    
    NSString *daysStr;
    NSString *hoursStr;
    NSString *minutesStr;
    NSString *secondsStr;
    
    
    daysStr = [NSString stringWithFormat:@"%ld",(long)days];
    
    if (hours < 10) {
        hoursStr = [NSString stringWithFormat:@"0%ld", (long)hours];
    }else {
        hoursStr = [NSString stringWithFormat:@"%ld", (long)hours];
    }
    
    if (minutes < 10) {
        minutesStr = [NSString stringWithFormat:@"0%ld", (long)minutes];
    } else {
        minutesStr = [NSString stringWithFormat:@"%ld", (long)minutes];
    }
    
    if (seconds < 10) {
        secondsStr = [NSString stringWithFormat:@"0%ld", (long)seconds];
    } else {
        secondsStr = [NSString stringWithFormat:@"%ld", (long)seconds];
    }
    
    return [NSString stringWithFormat:@"%@天%@小时%@分%@秒", daysStr, hoursStr, minutesStr, secondsStr];
}


#pragma mark - 传入秒数获得天、小时、分、秒分别存放的字典（只能传入正数）
/**
 *  day     :  天
 *  hour    :  小时
 *  minute  :  分
 *  sencond :  秒
 */
+ (NSDictionary *)getDayHourMinuteSecondDictionaryFromSeconds:(NSInteger)senconds
{
    if (senconds <= 0) return nil;
    NSInteger days = (senconds / 60 / 60 / 24);
    NSInteger hours = (senconds / 60 / 60 - (24 * days));
    NSInteger minutes = (senconds /60 - (24 * 60 * days) - (60 * hours));
    NSInteger seconds = (senconds - (24 * 60 * 60 * days) - (60 * 60 * hours) - (60 * minutes));
    
    NSString *daysStr;
    NSString *hoursStr;
    NSString *minutesStr;
    NSString *secondsStr;
    
    
    daysStr = [NSString stringWithFormat:@"%ld",(long)days];
    
    if (hours < 10) {
        hoursStr = [NSString stringWithFormat:@"0%ld", (long)hours];
    }else {
        hoursStr = [NSString stringWithFormat:@"%ld", (long)hours];
    }
    
    if (minutes < 10) {
        minutesStr = [NSString stringWithFormat:@"0%ld", (long)minutes];
    } else {
        minutesStr = [NSString stringWithFormat:@"%ld", (long)minutes];
    }
    
    if (seconds < 10) {
        secondsStr = [NSString stringWithFormat:@"0%ld", (long)seconds];
    } else {
        secondsStr = [NSString stringWithFormat:@"%ld", (long)seconds];
    }
    
    NSDictionary *dic = @{@"day" : daysStr , @"hour" : hoursStr , @"minute" : minutesStr , @"second" : secondsStr};
    return dic;
}



@end

