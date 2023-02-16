//
//  TJRBaseEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-2-26.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJRFMDatabase;
@interface TJRBaseEntity : NSObject

- (id)initWithJson:(NSDictionary *)json;

- (BOOL)jsonHasKey:(id)key json:(NSDictionary *)json;
- (BOOL)jsonHasValue:(id)key json:(NSDictionary *)json;
- (int)intParser:(NSString *)name json:(NSDictionary *)json;
- (NSInteger)integerParser:(NSString *)name json:(NSDictionary *)json;
- (NSString *)stringParser:(NSString *)name json:(NSDictionary *)json;
- (float)floatParser:(NSString *)name json:(NSDictionary *)json;
- (double)doubleParser:(NSString *)name json:(NSDictionary *)json;
- (long)longParser:(NSString *)name json:(NSDictionary *)json;
- (long long)longlongParser:(NSString *)name json:(NSDictionary *)json;
- (BOOL)boolParser:(NSString *)name json:(NSDictionary *)json;

- (NSDictionary *)toDictionary;	// 将entity整个转换成Dictionary
- (NSString *)toJsonString;		// 将entity整个转换成jsonString

/**
 *  @brief  对数据库执行insert into,这个方法方便,key和value对应,没有其他作用
 *
 *  @param db         * 数据库
 *  @param tableName  * 表名
 *
 *  @return 执行结果
 */
- (BOOL)insertIntoWithDataBase:(TJRFMDatabase *)db tableName:(NSString *)tableName keyAndValues:keyValues, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *  @brief  对数据库执行REPLACE INTO,这个方法方便,key和value对应,没有其他作用
 *
 *  @param db         * 数据库
 *  @param tableName  * 表名
 *
 *  @return 执行结果
 */
- (BOOL)replaceIntoWithDataBase:(TJRFMDatabase *)db tableName:(NSString *)tableName keyAndValues:keyValues, ...NS_REQUIRES_NIL_TERMINATION;
@end

