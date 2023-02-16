//
//  TJRBaseParserJson.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseParserJson.h"
#import "TTGlobalCore.h"
#import "RCLabel.h"

NSString *const TJRVoice = @"[tjr_voice]";
NSString *const TJRImage = @"[tjr_img]";

@implementation TJRBaseParserJson

+ (RTLabelComponentsStructure *)extractTextStyle:(NSString *)data {
    return [RCLabel extractTextStyle:data];
}

- (void)setJson:(NSDictionary *)json {
	jsonDic = (json && [json isKindOfClass:[NSDictionary class]]) ? json : nil;
}

- (BOOL)jsonHasKey:(id)key {
	return key && jsonDic && ![jsonDic isKindOfClass:[NSNull class]] && [[jsonDic allKeys] containsObject:key];
}

- (BOOL)jsonHasValue:(id)key {
    BOOL isHas =  key && jsonDic && ![jsonDic isKindOfClass:[NSNull class]];
    if (isHas) {
        NSString *value = [jsonDic objectForKey:key];
        isHas = TTIsStringWithAnyText(value);
    }
    return isHas;
}

/**
	解析int类型
	@param name  jsonKey
	@returns 
 */
- (int)intParser:(NSString *)name {
    id tempObj = jsonDic[name];
    if([tempObj isKindOfClass:[NSNumber class]]) {
        return [tempObj intValue];
    }
	return [[self stringParser:name] intValue];
}

- (NSInteger)integerParser:(NSString *)name {
    return [[self stringParser:name] integerValue];
}

- (NSString *)stringParser:(NSString *)name {
	if (![self jsonHasKey:name] || ![jsonDic objectForKey:name]) {
		return @"";
	}

	if ([[jsonDic objectForKey:name] isKindOfClass:[NSString class]]) {
		NSString *object = [jsonDic objectForKey:name];

		if (!object || (object.length == 0)) {
			return @"";
		}
    }else if ([[jsonDic objectForKey:name] isKindOfClass:[NSNull class]]) {
        return @"";
    }

	return [NSString stringWithFormat:@"%@", [jsonDic objectForKey:name]];
}

- (float)floatParser:(NSString *)name {
    id tempObj = jsonDic[name];
    if([tempObj isKindOfClass:[NSNumber class]]) {
        return [tempObj floatValue];
    }
	return [[self stringParser:name] floatValue];
}

- (double)doubleParser:(NSString *)name {
    id tempObj = jsonDic[name];
    if([tempObj isKindOfClass:[NSNumber class]]) {
        return [tempObj doubleValue];
    }
	return [[self stringParser:name] doubleValue];
}

- (long)longParser:(NSString *)name {
    id tempObj = jsonDic[name];
    if([tempObj isKindOfClass:[NSNumber class]]) {
        return [tempObj longValue];
    }
	return (long)[[self stringParser:name] longLongValue];
}

- (long long)longlongParser:(NSString *)name {
    id tempObj = jsonDic[name];
    if([tempObj isKindOfClass:[NSNumber class]]) {
        return [tempObj longLongValue];
    }
	return [[self stringParser:name] longLongValue];
}

- (BOOL)boolParser:(NSString *)name {
    id tempObj = jsonDic[name];
    if([tempObj isKindOfClass:[NSNumber class]]) {
        return [tempObj boolValue];
    }
	return [[self stringParser:name] boolValue];
}

// =======================================================================================================================================================

- (BOOL)jsonHasKey:(id)key json:(NSDictionary *)json {
	return json && ![json isKindOfClass:[NSNull class]] && [[json allKeys] containsObject:key];
}

- (NSString *)stringParser:(NSDictionary *)json name:(NSString *)name {
	if (![self jsonHasKey:name json:json] || ![json objectForKey:name]) {
		return @"";
	}
    if ([[json objectForKey:name] isKindOfClass:[NSString class]]) {
        NSString *object = [json objectForKey:name];
        if (!object || (object.length == 0)) {
            return @"";
        }
    }else if ([[json objectForKey:name] isKindOfClass:[NSNull class]]) {
        return @"";
    }

	return [NSString stringWithFormat:@"%@", [json objectForKey:name]];
}

- (NSInteger)integerParser:(NSDictionary *)json name:(NSString *)name {
    return [[self stringParser:json name:name] integerValue];
}

- (int)intParser:(NSDictionary *)json name:(NSString *)name {
	return [[self stringParser:json name:name] intValue];
}

- (float)floatParser:(NSDictionary *)json name:(NSString *)name {
	return [[self stringParser:json name:name] floatValue];
}

- (double)doubleParser:(NSDictionary *)json name:(NSString *)name {
	return [[self stringParser:json name:name] doubleValue];
}

- (long)longParser:(NSDictionary *)json name:(NSString *)name {
	return (long)[[self stringParser:json name:name] longLongValue];
}

- (BOOL)boolParser:(NSDictionary *)json name:(NSString *)name {
	return [[self stringParser:json name:name] boolValue];
}

// =======================================================================================================================================================
#pragma 基类解析返回数据是否成功
- (BOOL)parseBaseIsOk:(NSDictionary *)json {
	if (!json) {
		return NO;
	}

	if (![json isKindOfClass:[NSDictionary class]]) {
		return NO;
	}
    
    if (json.count<=0) {
        return NO;
    }
    
    if (![json.allKeys containsObject:@"success"]) {
        return true;
    }

	BOOL isOK = FALSE;
	for (NSString *key in json) {
		if ([key isEqualToString:@"success"]) {
			isOK = [self boolParser:json name:@"success"];
		}
	}

	return isOK;
}

#pragma 基类解析pagesize
- (NSInteger)parsePageSize:(NSDictionary *)json size:(NSInteger)size{
	if (!json) {
		return 0;
	}
    
	if (![json isKindOfClass:[NSDictionary class]]) {
		return 0;
	}
	for (NSString *key in json) {
		if ([key isEqualToString:@"pageSize"]) {
			size = [self integerParser:json name:@"pageSize"];
		}
	}
    
	return size;
}

@end

