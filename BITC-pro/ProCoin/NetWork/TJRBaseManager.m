//
//  TJRBaseManager.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-12-26.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseManager.h"
#import "SSKeychain.h"
#import "CommonUtil.h"
#import "LanguageManager.h"

@implementation TJRBaseManager

- (id)init {
	self = [super init];

	if (self) {
		taojinHttpBase = [[HttpBase alloc] init];
        [TJRBaseManager createDriverUUID];
	}
	return self;
}

/**
 *    生成用户的UUID
 *    @returns
 */
+ (NSString *)createDriverUUID {
    if (!driverUUID) {
        NSError *error = nil;
        NSString *service = @"DriverUUID";
        NSString *account = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *UUID = [SSKeychain passwordForService:service account:account error:&error];
        
        if ([error code] == SSKeychainErrorNotFound || !TTIsStringWithAnyText(UUID)) {
            CFUUIDRef puuid = CFUUIDCreate(nil);
            CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
            UUID = (NSString *)CFStringCreateCopy(NULL, uuidString);
            CFRelease(puuid);
            CFRelease(uuidString);
            BOOL success = [SSKeychain setPassword:UUID forService:service account:account];
            if (!success) {
                //            NSAssert(success == YES, @"保存UUID失败." );
            }
        }
        driverUUID = [UUID copy];
    }
    return driverUUID;
}

+ (NSString *)createParams:(NSMutableString*)params {
    
    NSString *driverUUID = [TJRBaseManager createDriverUUID];
    
    if (TTIsStringWithAnyText(driverUUID)) {
        if (TTIsStringWithAnyText(params)) {
            [params appendString:@"&"];
        }
        
        [params appendFormat:@"uniqkeyid=%@",driverUUID];
        [params appendFormat:@"&platform=%@",@"iphone"];
        [params appendFormat:@"&version=%@",TJRAppVersion];
        [params appendFormat:@"&bundleId=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
        [params appendFormat:@"&apiKey=%@",RedzAPIKey];
        //[params appendFormat:@"&lang=%@",[LanguageManager abridgeCode]];
        
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId) && [params rangeOfString:@"&userId="].location == NSNotFound) {
            [params appendFormat:@"&userId=%@",ROOTCONTROLLER_USER.userId];
        }
        
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.token)) {
            [params appendFormat:@"&token=%@",ROOTCONTROLLER_USER.token];
        }
    }
    //追加MD5的key排序签名
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init]autorelease];
    NSArray* arr = [params componentsSeparatedByString:@"&"];
    for (NSString *var in arr) {
        NSArray* pArr = [var componentsSeparatedByString:@"="];
        if(pArr.count > 1){
            NSString* key = [pArr firstObject];
            NSString* value = [pArr lastObject];
            if (TTIsStringWithAnyText(value)) {
                [dic setObject:value forKey:key];
            }
        }
    }
    
    NSArray *keys = [dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *values = [[[NSMutableString alloc] init]autorelease];
    for (NSString *key in sortedArray) {
        NSString* value = [BasicNameValuePair decodeURLString:[dic objectForKey:key]];
        [values appendString:value];
    }
    NSString* sign = [CommonUtil getMD5:[NSString stringWithFormat:@"%@%@",values,RedzAPISecret]];
    [params appendFormat:@"&%@",[BasicNameValuePair getPairString:[BasicNameValuePair setName:@"sign" value:sign.uppercaseString]]];
    
    NSString *result;
    
    if (params) result = [NSString stringWithString:params];
    else result = nil;

    return params;
}

/**
 *    @brief  拼接文件参数，以文件名为key,文件名唯一
 *    @param  statement  可变参数,以nil为结束符
 *    @return NSDictionary 包含数据的字典
 */
- (NSDictionary *)fetchUrlFiles:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION {
    BasicNameValuePair *arg = nil;
    va_list argList;

    NSMutableDictionary* dictionary = [[[NSMutableDictionary alloc]init]autorelease];
    
    if (statement) {
        va_start(argList, statement);
        
        [dictionary setObject:statement.value forKey:statement.name];
        
        //追加可变的参数
        while ((arg = va_arg(argList, BasicNameValuePair *))) {
            if (!arg) break;
            
            [dictionary setObject:arg.value forKey:arg.name];
        }
        
        va_end(argList);
    }

    return dictionary;
}

/**
 *	@brief	拼接网络参数
 *
 *	@param  statement   可变参数,以nil为结束符(必须要)
 *
 *	@return
 */
- (NSString *)fetchUrlParam:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION {
    BasicNameValuePair *arg = nil;
    va_list argList;
    NSMutableString *params = nil;
    
    if (statement) {
        if([statement.value isKindOfClass:[NSString class]]){
            va_start(argList, statement);
            NSString *value = [NSString stringWithString:statement.value];
            params = [[[NSMutableString alloc] initWithFormat:@"%@=%@", statement.name, value]autorelease];
            
            while ((arg = va_arg(argList, BasicNameValuePair *))) {
                if (!arg) break;
                NSString *val = [NSString stringWithString:arg.value];
                [params appendFormat:@"&%@=%@", arg.name, val];
            }
            
            va_end(argList);
        }
    }else{
        params = [[[NSMutableString alloc] init] autorelease];
    }
    
    return [TJRBaseManager createParams:params];
}

+ (NSString *)fetchUrlParamSocket:(NSString *)header statement:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION {
    BasicNameValuePair *arg = nil;
    va_list argList;
    NSMutableString *params = nil;
    
    if (statement) {
        va_start(argList, statement);
        NSString *value = [NSString stringWithString:statement.value];
        params = [[[NSMutableString alloc] initWithFormat:@"%@=%@", statement.name, value]autorelease];
        
        while ((arg = va_arg(argList, BasicNameValuePair *))) {
            if (!arg) break;
            NSString *val = [NSString stringWithString:arg.value];
            [params appendFormat:@"&%@=%@", arg.name, val];
        }
        //[params appendFormat:@"&lang=%@",[LanguageManager abridgeCode]];
        va_end(argList);
    }
    if(params == nil){
        params = [NSMutableString string] ;
    }
    return [NSString stringWithFormat:@"%@?%@",header,[TJRBaseManager createParams:params]];
}

- (NSString *)fetchUrlWithoutParam:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION {
    BasicNameValuePair *arg = nil;
    va_list argList;
    NSMutableString *params = nil;
    
    if (statement) {
        va_start(argList, statement);
        NSString *value = [NSString stringWithString:statement.value];
        params = [[NSMutableString alloc] initWithFormat:@"%@=%@", statement.name, value];
        
        while ((arg = va_arg(argList, BasicNameValuePair *))) {
            if (!arg) break;
            NSString *val = [NSString stringWithString:arg.value];
            [params appendFormat:@"&%@=%@", arg.name, val];
        }
        //[params appendFormat:@"&lang=%@",[LanguageManager abridgeCode]];
        va_end(argList);
    }else{
        params = [[NSMutableString alloc] init];
    }
    NSString *result;
    
    if (params) result = [NSString stringWithString:params];
    else result = nil;
    TT_RELEASE_SAFELY(params);
    return result;
}

/**
 *  没有参数,直接调用url
 *
 *  @param url url description
 *  @param delegate delegate description
 *  @param httpFinish httpFinish description
 *  @param httpFaild httpFaild description
 */
- (void)doHttpGETForUrl:(NSString *)url delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild {
    [taojinHttpBase doHttpGETForJson:url params:nil delegate:delegate httpFinish:httpFinish httpFaild:httpFaild];
}

- (void)dealloc {
    RELEASE(driverUUID);
	TT_RELEASE_SAFELY(taojinHttpBase);
	[super dealloc];
}

@end

