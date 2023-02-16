//
//  UserInfoSQL.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-5-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UserInfoSQL.h"
#import "TJRDatabase.h"

@implementation UserInfoSQL

#pragma mark - 以sql条件来查询用户信息

/**
 *   生成联表查询语句
 *   select [result] from [tableName] s Left Join user_info u on s.[userIdName] = u.user_id [ where condition]
 *   @param result 结果字段,如果是所有结果就为*
 *   @param userIdName 在目标表中userId字段名
 *   @param tableName 目标表名
 *   @param condition 查询条件就可有可无(不用加where的)
 *   @returns sql语句
 */
+ (NSString *)createSqlWithResult:(NSString *)result userIdName:(NSString *)userIdName tableName:(NSString *)tableName condition:(NSString *)condition {
	NSMutableString *sql = [NSMutableString stringWithFormat:@" select %@ from %@ s Left Join %@ u on s.%@ = u.%@", result, tableName, UserInfo_TableName, userIdName, UserInfo_UserId];

	if (TTIsStringWithAnyText(condition)) {
		[sql appendFormat:@" where %@;", condition];
	}
	return sql;
}

/**
 *    从UserInfo表里解析用户头像,如果没有值就返回旧头像
 *    @param rs 结果集
 *    @param oldHeaderUrl  旧头像字段名
 *    @returns 头像
 */
+ (NSString *)getHeaderUrlFromUserInfo:(TJRFMResultSet *)rs oldHeaderUrl:(NSString *)oldHeaderUrl {
	/* @throw NSException *exception; */
	if (!rs) return nil;

	NSString *headerUrl = [rs stringForColumn:UserInfo_HeaderUrl];

	if (TTIsStringWithAnyText(headerUrl)) {
		return headerUrl;
	} else {
		return TTIsStringWithAnyText(oldHeaderUrl) ?[rs stringForColumn:oldHeaderUrl] : nil;
	}
}

/**
 *    从UserInfo表里解析用户名,如果没有值就返回旧用户名
 *    @param rs 结果集
 *    @param oldUserName  旧用户名字段名
 *    @returns 用户名
 */
+ (NSString *)getUserNameFromUserInfo:(TJRFMResultSet *)rs oldUserName:(NSString *)oldUserName {
	/* @throw NSException *exception; */
	if (!rs) return nil;

	NSString *userName = [rs stringForColumn:UserInfo_UserName];

	if (TTIsStringWithAnyText(userName)) {
		return userName;
	} else {
		return TTIsStringWithAnyText(oldUserName) ?[rs stringForColumn:oldUserName] : nil;
	}
}

/**
 *    从UserInfo表里解析用户权限
 *    @param rs  结果集
 *    @returns 用户权限
 */
+ (NSInteger)getUserLevelFromUserInfo:(TJRFMResultSet *)rs {
	if (!rs) return 0;

	return [rs intForColumn:UserInfo_UserLervel];
}

/**
 *    以sql条件来查询用户信息
 *    @param userIdName 你的表中这个字段的名称
 *    @param tableName  你的表名
 *    @param condition  查询条件就可有可无(不用加where)
 *    select * from user_info where user_id in (select distinct userId from XXXXXX where XXXXXX)
 *    @returns 不存在用户信息的话就返回没数据的dictionary,否则就是该用户信息的Dictionary(用户Id为key)
 */
+ (NSMutableDictionary *)queryUserInfoWithUserIdName:(NSString *)userIdName tableName:(NSString *)tableName condition:(NSString *)condition {
	if (!TTIsStringWithAnyText(userIdName) || !TTIsStringWithAnyText(tableName)) return [NSMutableDictionary dictionary];

	NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where %@ in ", UserInfo_TableName, UserInfo_UserId];
	[sql appendFormat:@"(select distinct %@ from %@", userIdName, tableName];

	if (TTIsStringWithAnyText(condition)) {
		[sql appendFormat:@" where %@", condition];
	}
	[sql appendString:@")"];
    
    __block TJRFMResultSet *rs = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        rs = [db executeQuery:sql];
    }];
	return [self convertToUserInfo:rs];
}

#pragma mark - 以用户的Id查询用户信息

/**
 *    以用户的Id查询用户信息
 *    @param userId  用户id
 *    @returns 不存在用户信息的话就返回没数据的dictionary,否则就是该用户信息的Dictionary(用户Id为key)
 */
+ (NSMutableDictionary *)queryUserInfoWithUserId:(NSString *)userId, ...{
	if (!TTIsStringWithAnyText(userId) || ![userId isKindOfClass:[NSString class]]) return [NSMutableDictionary dictionary];

	NSString *arg = nil;
	va_list argList;
	NSMutableString *params = [NSMutableString string];

	if (userId) {
		va_start(argList, userId);
		[params appendString:userId];

		while ((arg = va_arg(argList, NSString *))) {
			if (!arg || ((NSNull *)arg == [NSNull null]) || !TTIsStringWithAnyText(arg)) break;
			[params appendFormat:@",%@", arg];
		}

		va_end(argList);
	}

    __block TJRFMResultSet *rs = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ in (%@)", UserInfo_TableName, UserInfo_UserId, params];
        rs = [db executeQuery:sql];
    }];
    
	return [self convertToUserInfo:rs];
}

#pragma mark - 以封装了一堆用户id的array来查询用户信息

/**
 *    以封装了一堆用户id的array来查询用户信息
 *    @param array  封装用户id的array
 *    @returns 不存在用户信息的话就返回没数据的dictionary,否则就是该用户信息的Dictionary(用户Id为key)
 */
+ (NSMutableDictionary *)queryUserInfoWithUserIdArray:(NSArray *)array {
	if (!array || (array.count == 0) || ![array isKindOfClass:[NSArray class]]) return [NSMutableDictionary dictionary];

	NSMutableString *params = nil;

	for (NSString *info in array) {
		if (params) {
			[params appendFormat:@",%@", info];
		} else {
			params = [NSMutableString stringWithString:info];
		}
	}

	if (!params) return nil;

    __block TJRFMResultSet *rs = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ in (%@)", UserInfo_TableName, UserInfo_UserId, params];
        rs = [db executeQuery:sql];
    }];
	
	return [self convertToUserInfo:rs];
}

#pragma mark - 批量插入或修改用户信息

/**
 *    批量插入或修改用户信息,当数量达到或超过20个时会开启事务来加快速度
 *    @param infoArray
 */
+ (void)insertOrUpdateUserInfoWithUserInfoArray:(NSArray *)infoArray {
	if (!infoArray || (infoArray.count == 0) || ![infoArray isKindOfClass:[NSArray class]]) return;

    if (infoArray.count>=10) {
        [self insertOrUpdateUserInfoMore:infoArray];
    }else{
        for (UserInfo *info in infoArray) {
            [self insertOrUpdateUserInfo:info, nil];
        }
    }
}

/**
 *    插入或修改用户信息
 *    @param userId 用户Id
 *    @param userLevel 用户权限
 *    @param headerUrl  用户头像地址
 */
+ (void)insertOrUpdateUserInfoWithUserId:(NSString *)userId userName:(NSString *)userName userLevel:(NSInteger)userLevel headerUrl:(NSString *)headerUrl {
	if (!TTIsStringWithAnyText(userId)) return;

	UserInfo *userInfo = [UserInfo createWithUserId:userId userName:userName userLevel:userLevel headerUrl:headerUrl];
	[self insertOrUpdateUserInfo:userInfo, nil];
}

#pragma mark - 插入或修改用户信息

/**
 *    插入或修改用户信息
 *    (自动判断,数量最好不要超过20个.否则会比较慢.如果超过20个,可以封装到一个array里,调用insertOrUpdateUserInfoWithUserInfoArray方法)
 *    @param userInfo,...  用户信息,以nil结束
 */
+ (void)insertOrUpdateUserInfoMore:(NSArray *)argList{
    if (!argList) return;

    __block NSMutableArray *arr = [NSMutableArray array];
    
    for (UserInfo *arg in argList) {
        if (!arg || ((NSNull *)arg == [NSNull null]) || !TTIsStringWithAnyText(arg.userId)) break;
        NSString *sql = [self createUserInfoSQL:arg];
        if (TTIsStringWithAnyText(sql)) {
            [arr addObject:sql];
        }
    }
    if (arr && arr.count) {
        [[TJRDatabase shareFMDatabaseQueue] inTransaction:^(TJRFMDatabase *db, BOOL *rollback) {
            for (NSString *sql in arr) {
                [db executeUpdate:sql];
            }
            *rollback = NO;
        }];
    }
}


+ (void)insertOrUpdateUserInfo:(UserInfo *)userInfo, ...{
	if (!userInfo || ![userInfo isKindOfClass:[UserInfo class]] || !TTIsStringWithAnyText(userInfo.userId)) return;

	UserInfo *arg = nil;
	va_list argList;

	va_start(argList, userInfo);
	NSString *sql = [self createUserInfoSQL:userInfo];
     if (TTIsStringWithAnyText(sql)) {
         [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
             [db executeUpdate:sql];
         }];
     }

    __block NSMutableArray *arr = [NSMutableArray array];
    
	while ((arg = va_arg(argList, UserInfo *))) {
		if (!arg || ((NSNull *)arg == [NSNull null]) || !TTIsStringWithAnyText(arg.userId)) break;
		NSString *sql = [self createUserInfoSQL:arg];
        if (TTIsStringWithAnyText(sql)) {
            [arr addObject:sql];
            
        }
	}
    
    if (arr && arr.count) {
        if (arr.count>=10) {
            [[TJRDatabase shareFMDatabaseQueue] inTransaction:^(TJRFMDatabase *db, BOOL *rollback) {
                for (NSString *sql in arr) {
                    [db executeUpdate:sql];
                }
                *rollback = NO;
            }];
        }else{
            [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
                for (NSString *sql in arr) {
                    [db executeUpdate:sql];
                }
            }];
        }
    }
	va_end(argList);
}

#pragma mark - 自动判断并生成插入或修改的sql语句

/**
 *    自动判断并生成插入或修改的sql语句
 *    @param userInfo  用户信息
 *    @returns sql语句
 */
+ (NSString *)createUserInfoSQL:(UserInfo *)userInfo {
    if (!userInfo || !TTIsStringWithAnyText(userInfo.userId)) {
        return nil;
    }
	BOOL isHas = [self isHasUserInfoWithUserId:userInfo.userId];

	if (isHas) {/* 用户存在生成修改语句 */
		NSMutableString *valueString = [NSMutableString string];
		[valueString appendFormat:@"%@=%ld", UserInfo_UserLervel, (long)userInfo.userLevel];

		if (TTIsStringWithAnyText(userInfo.name)) {
			[valueString appendFormat:@",%@='%@'", UserInfo_UserName, userInfo.name];
		}

		if (TTIsStringWithAnyText(userInfo.headurl)) {
			[valueString appendFormat:@",%@='%@'", UserInfo_HeaderUrl, userInfo.headurl];
		}

		if (TTIsStringWithAnyText(userInfo.maxHeadUrl)) {
			[valueString appendFormat:@",info_max_header_url='%@'", userInfo.maxHeadUrl];
		}
		return [NSString stringWithFormat:@"update %@ set %@ where %@='%@'", UserInfo_TableName, valueString, UserInfo_UserId, userInfo.userId];
	} else {/* 用户不存在生成插入语句 */
		NSMutableString *nameString = [NSMutableString string];
		NSMutableString *valueString = [NSMutableString string];
		[nameString appendString:UserInfo_UserId];
		[valueString appendFormat:@"'%@'", userInfo.userId];

		[nameString appendFormat:@",%@", UserInfo_UserLervel];
		[valueString appendFormat:@",%ld", (long)userInfo.userLevel];

		if (TTIsStringWithAnyText(userInfo.name)) {
			[nameString appendFormat:@",%@", UserInfo_UserName];
			[valueString appendFormat:@",'%@'", userInfo.name];
		}

		if (TTIsStringWithAnyText(userInfo.headurl)) {
			[nameString appendFormat:@",%@", UserInfo_HeaderUrl];
			[valueString appendFormat:@",'%@'", userInfo.headurl];
		}

		if (TTIsStringWithAnyText(userInfo.maxHeadUrl)) {
			[nameString appendString:@",info_max_header_url"];
			[valueString appendFormat:@",'%@'", userInfo.maxHeadUrl];
		}
		return [NSString stringWithFormat:@"insert or ignore into %@(%@) values (%@)", UserInfo_TableName, nameString, valueString];
	}
}

#pragma mark - 按用户id删除用户信息

/**
 *    按用户id删除用户信息
 *    @param userId,...
 */
+ (void)deleteUserInfoWithUserId:(NSString *)userId, ...{
	if (!TTIsStringWithAnyText(userId) || ![userId isKindOfClass:[NSString class]]) return;

	NSString *arg = nil;
	va_list argList;
	NSMutableString *params = [NSMutableString string];

	if (userId) {
		va_start(argList, userId);
		[params appendString:userId];

		while ((arg = va_arg(argList, NSString *))) {
			if (!arg || ((NSNull *)arg == [NSNull null]) || !TTIsStringWithAnyText(arg)) break;
			[params appendFormat:@",%@", arg];
		}

		va_end(argList);
	}
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ in (%@)", UserInfo_TableName, UserInfo_UserId, params];
        [db executeUpdate:sql];
    }];
	
}

#pragma mark - 将用户id封装到一个array里来批量删除

/**
 *    将用户id封装到一个array里来批量删除
 *    @param array 封装用户id的array
 */
+ (void)deleteUserInfoWithUserIdArray:(NSArray *)array {
	if (!array || ![array isKindOfClass:[NSArray class]] || (array.count == 0)) return;

	NSMutableString *params = nil;

	for (NSString *userId in array) {
		if (params) {
			[params appendFormat:@",%@", userId];
		} else {
			params = [NSMutableString stringWithString:userId];
		}
	}

	if (params) {
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ in (%@)", UserInfo_TableName, UserInfo_UserId, params];
            [db executeUpdate:sql];
        }];
		
	}
}

#pragma mark - 判断当前UserId是否存在

/**
 *    判断当前UserId是否存在
 *    @param userId  用户id
 *    @returns 存在为YES,不存在为NO
 */
+ (BOOL)isHasUserInfoWithUserId:(NSString *)userId {
	if (!TTIsStringWithAnyText(userId)) return NO;

    __block BOOL result = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@='%@'", UserInfo_UserId, UserInfo_TableName, UserInfo_UserId, userId];
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        @try {
            while ([rs next]) {
                NSString *user_id = [rs stringForColumn:UserInfo_UserId];
                
                if (TTIsStringWithAnyText(user_id) && [user_id isEqualToString:userId]) {
                    result = YES;
                    break;
                }
            }
        } @catch(NSException *exception) {
            NSLog(@"解析股友圈数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) [rs close];
        }
    }];

	return result;
}

#pragma mark - 解析查询出来的用户信息

/**
 *    解析查询出来的用户信息
 *    @param rs
 *    @returns
 */
+ (NSMutableDictionary *)convertToUserInfo:(TJRFMResultSet *)rs {
	if (!rs) return [NSMutableDictionary dictionary];

	@try {
		NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionary];

		while ([rs next]) {
			UserInfo *info = [UserInfo new];
			info.userId = [rs stringForColumn:UserInfo_UserId];
			info.name = [rs stringForColumn:UserInfo_UserName];
			info.userLevel = [rs intForColumn:UserInfo_UserLervel];
			info.headurl = [rs stringForColumn:UserInfo_HeaderUrl];
			info.maxHeadUrl = [rs stringForColumn:@"info_max_header_url"];
			[userInfoDictionary setObject:info forKey:info.userId];
			RELEASE(info);
		}

		return userInfoDictionary;
	} @catch(NSException *exception) {
		NSLog(@"解析股友圈数据库出错:%@", exception.debugDescription);
	} @finally {
		if (rs) [rs close];
	}

	return nil;
}

@end
