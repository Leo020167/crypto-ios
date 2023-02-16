//
//  TJRBaseParserJson.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTLabelComponentsStructure;

extern NSString *const TJRVoice;
extern NSString *const TJRImage;

@interface TJRBaseParserJson : NSObject{
    NSDictionary *jsonDic;
}
+ (RTLabelComponentsStructure *)extractTextStyle:(NSString *)data;
- (BOOL)jsonHasKey:(id)key;
- (BOOL)jsonHasValue:(id)key;
- (NSString *)stringParser:(NSString *)name;
- (void)setJson:(NSDictionary *)json;
- (int)intParser:(NSString *)name;
- (NSInteger)integerParser:(NSString *)name;
- (float)floatParser:(NSString *)name;
- (double)doubleParser:(NSString *)name;
- (long)longParser:(NSString *)name;
- (long long)longlongParser:(NSString *)name;
- (BOOL)boolParser:(NSString *)name;

- (NSString *)stringParser:(NSDictionary *)json name:(NSString *)name;
- (NSInteger)integerParser:(NSDictionary *)json name:(NSString *)name;
- (int)intParser:(NSDictionary *)json name:(NSString *)name;
- (float)floatParser:(NSDictionary *)json name:(NSString *)name;
- (double)doubleParser:(NSDictionary *)json name:(NSString *)name;
- (long)longParser:(NSDictionary *)json name:(NSString *)name;
- (BOOL)boolParser:(NSDictionary *)json name:(NSString *)name;
- (BOOL)jsonHasKey:(id)key json:(NSDictionary *)json;

#pragma 基类解析返回数据是否成功
- (BOOL)parseBaseIsOk:(NSDictionary *)json;
#pragma 基类解析pagesize
- (NSInteger)parsePageSize:(NSDictionary *)json size:(NSInteger)size;
@end
