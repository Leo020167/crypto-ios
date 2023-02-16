//
//  TJRBaseEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-2-26.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseEntity.h"
#import "CommonUtil.h"
#import <objc/runtime.h>
#import "TJRDatabase.h"

@interface NSDate (TJRDate)

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

@end

@implementation NSDate (TJRDate)

+ (NSDate *)dateWithString:(NSString *)s {
	if (!s || ((NSNull *)s == [NSNull null]) || [s isEqual:@""]) {
		return nil;
	}

	return [[self dateFormatter] dateFromString:s];
}

+ (NSString *)stringWithDate:(NSDate *)date {
	if (!date || ((NSNull *)date == [NSNull null]) || [date isEqual:@""]) {
		return nil;
	}
	return [[self dateFormatter] stringFromDate:date];
}

+ (NSDateFormatter *)dateFormatter {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return dateFormatter;
}

@end

@interface NSObject (TJRObject)

+ (id)objectWithString:(NSString *)s;
+ (NSString *)stringWithObject:(NSObject *)obj;

@end

@implementation NSObject (TJRObject)

+ (id)objectWithString:(NSString *)s {
	if (!s || ((NSNull *)s == [NSNull null]) || [s isEqual:@""]) {
		return nil;
	}
	return [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}

+ (NSString *)stringWithObject:(NSObject *)obj {
	if (!obj || ((NSNull *)obj == [NSNull null]) || [obj isEqual:@""]) {
		return nil;
	}
	NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
@implementation TJRBaseEntity

/**
 *   子类重写这个方法用来解析JSOn
 *   @param json
 *   @returns
 */
- (id)initWithJson:(NSDictionary *)json {
	self = [super init];
	if (self) {}
	return self;
}

- (BOOL)jsonHasKey:(id)key json:(NSDictionary *)json {
	return key && json && ![json isKindOfClass:[NSNull class]] && [[json allKeys] containsObject:key];
}

- (BOOL)jsonHasValue:(id)key json:(NSDictionary *)json {
	BOOL isHas =  key && json && ![json isKindOfClass:[NSNull class]];

	if (isHas) {
		NSString *value = [json objectForKey:key];
		isHas = TTIsStringWithAnyText(value);
	}
	return isHas;
}

/**
 *   解析int类型
 *   @param name  jsonKey
 *   @returns
 */
- (int)intParser:(NSString *)name json:(NSDictionary *)json {
    if (![self jsonHasKey:name json:json]) {
        return 0;
    }
    
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj intValue];
	}
	return [[self stringParser:name json:json] intValue];
}

- (NSInteger)integerParser:(NSString *)name json:(NSDictionary *)json {
    if (![self jsonHasKey:name json:json]) {
        return 0;
    }
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj integerValue];
	}
	return [[self stringParser:name json:json] integerValue];
}

- (NSString *)stringParser:(NSString *)name json:(NSDictionary *)json {
	if (![self jsonHasKey:name json:json]) {
		return @"";
	}

	if ([[json objectForKey:name] isKindOfClass:[NSString class]]) {
		NSString *object = [json objectForKey:name];

		if (!TTIsStringWithAnyText(object)) {
			return @"";
		}
		return object;
	}

	return [NSString stringWithFormat:@"%@", [json objectForKey:name]];
}

- (float)floatParser:(NSString *)name json:(NSDictionary *)json {
    if (![self jsonHasKey:name json:json]) {
        return 0.0;
    }
    
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj floatValue];
	}
	return [[self stringParser:name json:json] floatValue];
}

- (double)doubleParser:(NSString *)name json:(NSDictionary *)json {
    
    if (![self jsonHasKey:name json:json]) {
        return 0.0;
    }
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj doubleValue];
	}
	return [[self stringParser:name json:json] doubleValue];
}

- (long)longParser:(NSString *)name json:(NSDictionary *)json {
    if (![self jsonHasKey:name json:json]) {
        return 0.0;
    }
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj longValue];
	}
	return (long)[[self stringParser:name json:json] longLongValue];
}

- (long long)longlongParser:(NSString *)name json:(NSDictionary *)json {
    if (![self jsonHasKey:name json:json]) {
        return 0.0;
    }
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj longLongValue];
	}
	return [[self stringParser:name json:json] longLongValue];
}

- (BOOL)boolParser:(NSString *)name json:(NSDictionary *)json {
    if (![self jsonHasKey:name json:json]) {
        return NO;
    }
	id tempObj = json[name];

	if ([tempObj isKindOfClass:[NSNumber class]]) {
		return [tempObj boolValue];
	}
	return [[self stringParser:name json:json] boolValue];
}

- (NSDictionary *)toDictionary {
	if (self == Nil) return nil;

	unsigned int count;
	objc_property_t *properties = class_copyPropertyList(self.class, &count);
	NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
	for (int i = 0; i < count; i++) {
		objc_property_t property = properties[i];
		NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
		id objValue = [self valueForKey:key];
		if (objValue && ((NSNull *)objValue != [NSNull null])) {
			id value = [self valueForDbObjc_property_t:property dbValue:objValue];

			if (value && ((NSNull *)value != [NSNull null])) {
				[jsonDic setObject:value forKey:key];
			}
		}
		RELEASE(key);
	}
	return jsonDic;
}

- (NSString *)toJsonString {
	if (self == Nil) return @"";

	NSString *json = [CommonUtil jsonToString:[self toDictionary]];
	return json;
}

- (id)valueForDbObjc_property_t:(objc_property_t)property dbValue:(id)dbValue {
	char *type = property_copyAttributeValue(property, "T");

	switch (type[0]) {
		case 'f':	// float
			{
				return [NSNumber numberWithDouble:[dbValue floatValue]];
			}
			break;

		case 'd':	// double
			{
				return [NSNumber numberWithDouble:[dbValue doubleValue]];
			}
			break;

		case 'c':	// char
			{
				return [NSNumber numberWithDouble:[dbValue charValue]];
			}
			break;

		case 's':	// short
			{
				return [NSNumber numberWithDouble:[dbValue shortValue]];
			}
			break;

		case 'i':	// int
			{
				return [NSNumber numberWithDouble:[dbValue longValue]];
			}
			break;

		case 'l':	// long
			{
				return [NSNumber numberWithDouble:[dbValue longValue]];
			}
			break;

		case '*':	// char *
			break;

		case '@':	// ObjC object // Handle different clases in here
			{
				NSString *cls = [NSString stringWithUTF8String:type];
				cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
				cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];

				if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
					return [NSString stringWithFormat:@"%@", dbValue];
				}

				if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
					return [NSNumber numberWithDouble:[dbValue doubleValue]];
				}

				if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
					return [NSDictionary stringWithObject:dbValue];
				}

				if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
					return [NSDictionary stringWithObject:dbValue];
				}

				if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
					if ([dbValue isKindOfClass:[NSDate class]]) {
						return [NSString stringWithFormat:@"%@", [NSDate stringWithDate:dbValue]];
					} else {
						return @"";
					}
				}

				if ([NSClassFromString(cls) isSubclassOfClass:[NSValue class]]) {
					return [NSData dataWithData:dbValue];
				}
			}
			break;
	}

	return dbValue;
}

/**
 *  @brief  对数据库执行insert into,这个方法方便,key和value对应,没有其他作用
 *
 *  @param db         * 数据库
 *  @param tableName  * 表名
 *
 *  @return 执行结果
 */
- (BOOL)insertIntoWithDataBase:(TJRFMDatabase *)db tableName:(NSString *)tableName keyAndValues:keyValues, ...NS_REQUIRES_NIL_TERMINATION {
	if (!db || !TTIsStringWithAnyText(tableName) || !keyValues) return false;

	va_list argList;
	NSMutableString *params = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@(", tableName];
	NSMutableString *endString = [[NSMutableString alloc] initWithString:@")values("];
	NSMutableArray *valuesArray = [NSMutableArray new];
	va_start(argList, keyValues);
	id arg = nil;
	NSUInteger index = 1;
	[params appendFormat:@"%@", keyValues];
	[endString appendString:@"?"];
	while ((arg = va_arg(argList, id))) {
		if (!arg) break;
		if (index % 2 == 0) {
			[params appendFormat:@",%@", arg];
			[endString appendString:@",?"];
		} else {
			[valuesArray addObject:arg];
		}
		index++;
	}
	NSAssert(index % 2 == 0, @"Key和value数量不对等");
	[params appendFormat:@"%@);", endString];
	va_end(argList);
	BOOL result = [db executeUpdate:params withArgumentsInArray:valuesArray];
	[valuesArray removeAllObjects];
	RELEASE(params);
	RELEASE(endString);
	RELEASE(valuesArray);
	return result;
}

/**
 *  @brief  对数据库执行REPLACE INTO,这个方法方便,key和value对应,没有其他作用
 *
 *  @param db         * 数据库
 *  @param tableName  * 表名
 *
 *  @return 执行结果
 */
- (BOOL)replaceIntoWithDataBase:(TJRFMDatabase *)db tableName:(NSString *)tableName keyAndValues:keyValues, ...NS_REQUIRES_NIL_TERMINATION {
	if (!db || !TTIsStringWithAnyText(tableName) || !keyValues) return false;

	va_list argList;
	NSMutableString *params = [[NSMutableString alloc] initWithFormat:@"REPLACE INTO %@(", tableName];
	NSMutableString *endString = [[NSMutableString alloc] initWithString:@")values("];
	NSMutableArray *valuesArray = [NSMutableArray new];
	va_start(argList, keyValues);
	id arg = nil;
	NSUInteger index = 1;
	[params appendFormat:@"%@", keyValues];
	[endString appendString:@"?"];
	while ((arg = va_arg(argList, id))) {
		if (!arg) break;
		if (index % 2 == 0) {
			[params appendFormat:@",%@", arg];
			[endString appendString:@",?"];
		} else {
			[valuesArray addObject:arg];
		}
		index++;
	}
	NSAssert(index % 2 == 0, @"Key和value数量不对等");
	[params appendFormat:@"%@);", endString];
	va_end(argList);
	BOOL result = [db executeUpdate:params withArgumentsInArray:valuesArray];
	[valuesArray removeAllObjects];
	RELEASE(params);
	RELEASE(endString);
	RELEASE(valuesArray);
	return result;
}

- (NSString *)description {
	unsigned int count;
	const char *clasName = object_getClassName(self);
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s: %p>:[ \n", clasName, self];
	Class clas = NSClassFromString([NSString stringWithCString:clasName encoding:NSUTF8StringEncoding]);
	Ivar *ivars = class_copyIvarList(clas, &count);

	for (int i = 0; i < count; i++) {
		@autoreleasepool {
			Ivar ivar = ivars[i];
			const char *name = ivar_getName(ivar);
			// 得到类型
			NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
			NSString *key = [NSString stringWithUTF8String:name];// 获取成员变量的名字
			id value = [self valueForKey:key];
			// 确保BOOL 值输出的是YES 或 NO，这里的B是我打印属性类型得到的……
			if ([[type uppercaseString] isEqualToString:@"B"]) {
				value = (value == 0 ? @"NO" : @"YES");
			}
			[string appendFormat:@"\t%@: %@\n", [self delLine:key], value];
		}
	}
	free(ivars);
	[string appendFormat:@"]"];
	return string;
}

// 因为ivar_getName得到的是一个带有下划线的名字，去掉下划线看起来更漂亮
- (NSString *)delLine:(NSString *)string {
	if ([string hasPrefix:@"_"]) {
		return [string substringFromIndex:1];
	}
	return string;
}

@end
