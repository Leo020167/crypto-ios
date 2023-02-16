//
//  UserInfoSQL.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-5-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface UserInfoSQL : NSObject

/**
 *    生成联表查询语句
 *    select [result] from [tableName] s Left Join user_info u where s.[userIdName] = u.user_id [condition]
 *    @param result 结果字段,如果是所有结果就为*
 *    @param userIdName 在目标表中userId字段名
 *    @param tableName 目标表名
 *    @param condition 查询条件就可有可无(不用加where的)
 *    @returns sql语句
 */
+ (NSString *)createSqlWithResult:(NSString *)result userIdName:(NSString *)userIdName tableName:(NSString *)tableName condition:(NSString *)condition;

/**
 *    从UserInfo表里解析用户头像,如果没有值就返回旧头像
 *    @param rs 结果集
 *    @param oldHeaderUrl  旧头像字段名
 *    @returns 头像
 */
+ (NSString *)getHeaderUrlFromUserInfo:(TJRFMResultSet *)rs oldHeaderUrl:(NSString *)oldHeaderUrl;

/**
 *    从UserInfo表里解析用户名,如果没有值就返回旧用户名
 *    @param rs 结果集
 *    @param oldUserName  旧用户名字段名
 *    @returns 用户名
 */
+ (NSString *)getUserNameFromUserInfo:(TJRFMResultSet *)rs oldUserName:(NSString *)oldUserName;

/**
 *    从UserInfo表里解析用户权限
 *    @param rs  结果集
 *    @returns 用户权限
 */
+ (NSInteger)getUserLevelFromUserInfo:(TJRFMResultSet *)rs;

/**
 *    以sql条件来查询用户信息
 *    @param userIdName 你的表中这个字段的名称
 *    @param tableName 你的表名
 *    @param condition  查询条件就可有可无(不用加where)
 *    @returns 不存在用户信息的话就返回没数据的dictionary,否则就是该用户信息的Dictionary(用户Id为key)
 */
+ (NSMutableDictionary *)queryUserInfoWithUserIdName:(NSString *)userIdName tableName:(NSString *)tableName condition:(NSString *)condition;

/**
 *    以用户的Id查询用户信息
 *    @param userId  用户id
 *    @returns 不存在用户信息的话就返回没数据的dictionary,否则就是该用户信息的Dictionary(用户Id为key)
 */
+ (NSMutableDictionary *)queryUserInfoWithUserId:(NSString *)userId, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *   以封装了一堆用户id的array来查询用户信息
 *   @param array  封装用户id的array
 *   @returns 不存在用户信息的话就返回没数据的dictionary,否则就是该用户信息的Dictionary(用户Id为key)
 */
+ (NSMutableDictionary *)queryUserInfoWithUserIdArray:(NSArray *)array;

/**
 *   批量插入或修改用户信息,当数量达到或超过20个时会开启事务来加快速度
 *   @param infoArray
 */
+ (void)insertOrUpdateUserInfoWithUserInfoArray:(NSArray *)infoArray;

/**
 *   插入或修改用户信息
 *   @param userId 用户Id
 *   @param userName 用户名
 *   @param userLevel 用户权限
 *   @param headerUrl  用户头像地址
 */
+ (void)insertOrUpdateUserInfoWithUserId:(NSString *)userId userName:(NSString *)userName userLevel:(NSInteger)userLevel headerUrl:(NSString *)headerUrl;

/**
 *    插入或修改用户信息
 *    (自动判断,数量最好不要超过20个.否则会比较慢.如果超过20个,可以封装到一个array里,调用insertOrUpdateUserInfoWithUserInfoArray方法)
 *    @param userInfo,...  用户信息,以nil结束
 */
+ (void)insertOrUpdateUserInfo:(UserInfo *)userInfo, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *   判断当前UserId是否存在
 *   @param userId  用户id
 *   @returns 存在为YES,不存在为NO
 */
+ (BOOL)isHasUserInfoWithUserId:(NSString *)userId;

/**
 *    按用户id删除用户信息
 *    @param userId,...
 */
+ (void)deleteUserInfoWithUserId:(NSString *)userId, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *   将用户id封装到一个array里来批量删除
 *   @param array 封装用户id的array
 */
+ (void)deleteUserInfoWithUserIdArray:(NSArray *)array;
@end
