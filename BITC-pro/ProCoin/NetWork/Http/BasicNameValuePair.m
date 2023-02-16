//
//  BasicNameValuePair.m
//  tjr-taojinroad
//
//  Created by taojinroad on 12-8-24.
//  Copyright (c) 2017年 REDZ. All rights reserved.
//

#import "BasicNameValuePair.h"

@implementation BasicNameValuePair
@synthesize name;
@synthesize value;

/**
 *    @brief    网络参数拼接(不需要释放)
 *
 *    @param     name     参数名(key)
 *    @param     value     参数值(value)
 *
 *    @return
 */
+ (BasicNameValuePair *)setName:(NSString *)name value:(id)value {
    
    BasicNameValuePair *valuePair  = [[[BasicNameValuePair alloc] init] autorelease];

    valuePair.name = name;
    valuePair.value = value;
    
    if ([value isKindOfClass:[NSString class]]) {
        
        if (valuePair.value == nil || ((NSString*)valuePair.value).length == 0) valuePair.value = @"";
        valuePair.value = [BasicNameValuePair encodeToPercentEscapeString:valuePair.value];
        
    } else if ([value isKindOfClass:[NSNumber class]]){
        
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        valuePair.value = [numberFormatter stringFromNumber:(NSNumber*)value];
        [numberFormatter release];
        
    }else if ([value isKindOfClass:[NSArray class]]) {
        
        if (valuePair.value == nil || ((NSArray*)valuePair.value).count == 0) valuePair.value = [NSArray array];
        NSMutableArray* array = [[[NSMutableArray alloc]init]autorelease];
        for (NSString* string in (NSArray*)valuePair.value) {
            [array addObject:[BasicNameValuePair encodeToPercentEscapeString:string]];
        }
        valuePair.value = array;
        
    }else if ([value isKindOfClass:[NSDictionary class]]) {
        
        if (valuePair.value == nil || ((NSArray*)valuePair.value).count == 0) valuePair.value = [NSDictionary dictionary];
        NSMutableDictionary* dictionary = [[[NSMutableDictionary alloc]init]autorelease];
        for (NSString* key in ((NSMutableDictionary*)valuePair.value).allKeys) {
            NSString* string = [((NSMutableDictionary*)valuePair.value) objectForKey:key];
            [dictionary setObject:[BasicNameValuePair encodeToPercentEscapeString:string] forKey:key];
        }
        valuePair.value = dictionary;
    }
    
    return valuePair;
}


+ (NSString *)encodeToPercentEscapeString:(NSString *)input {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)input,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
    
    return outputStr;
}

+ (NSString*)decodeURLString:(NSString*)input{
    
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)input, CFSTR(""),kCFStringEncodingUTF8);
    [result autorelease];
    
    return result;
}

+ (NSString*)getPairString:(BasicNameValuePair *)statement{
    
    NSString *result = nil;
    
    if ([statement.value isKindOfClass:[NSString class]]) {
        NSString *value = [NSString stringWithString:statement.value];
        NSMutableString* params = [[NSMutableString alloc] initWithFormat:@"%@=%@", statement.name, value];
        
        if (params) result = [NSString stringWithString:params];
        else result = nil;
        TT_RELEASE_SAFELY(params);
    }
    return result;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(name);
    TT_RELEASE_SAFELY(value);
    [super dealloc];
}
@end
