//
//  UserInfo.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-5-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"
extern NSString *const UserInfo_TableName;	/* 表名 */
extern NSString *const UserInfo_UserId;	/* 用户Id字段名 */
extern NSString *const UserInfo_UserLervel;	/* 用户权限字段名 */
extern NSString *const UserInfo_HeaderUrl;	/* 用户头像字段名 */
extern NSString *const UserInfo_MaXHeaderUrl;	/* 用户大头像字段名 */
extern NSString *const UserInfo_UserName;	/* 用户名字段名 */

@class TJRFMResultSet;
@interface UserInfo : TJRBaseEntity
@property (copy, nonatomic) NSString *userId;// 登录用户ID
@property (copy, nonatomic) NSString *name;// 用户名
@property (copy, nonatomic) NSString *headurl;// 头像路径
@property (copy, nonatomic) NSString *maxHeadUrl;
@property (assign, nonatomic) NSInteger userLevel;      //用户权限(0为普通，1为认证)

- (id)initWithResultSet:(TJRFMResultSet *)rs;

/**
	创建一个UserInfo,不用释放
	@param userId 用户id
	@param userLevel 用户权限
	@param headerUrl 用户头像地址
	@returns
 */
+ (UserInfo *)createWithUserId:(NSString *)userId userName:(NSString *)userName userLevel:(NSInteger)userLevel headerUrl:(NSString *)headerUrl;
@end
