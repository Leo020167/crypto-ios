//
//  UserInfo.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-5-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UserInfo.h"
#import "TJRFMResultSet.h"

NSString *const UserInfo_TableName    = @"user_info";/* 表名 */
NSString *const UserInfo_UserId       = @"info_user_id";/* 用户Id字段名 */
NSString *const UserInfo_UserLervel   = @"info_user_level";	/* 用户权限字段名 */
NSString *const UserInfo_HeaderUrl    = @"info_header_url";	/* 用户头像字段名 */
NSString *const UserInfo_MaXHeaderUrl = @"info_max_header_url";	/* 用户大头像字段名 */
NSString *const UserInfo_UserName     = @"info_user_name";	/* 用户名字段名 */

@implementation UserInfo

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self && json) {
        if ([self jsonHasKey:@"user_id" json:json]) {
            self.userId = [self stringParser:@"user_id" json:json];// 登录用户ID
        }
        if ([self jsonHasKey:@"name" json:json]) {
            self.name = [self stringParser:@"name" json:json];// 用户名
        }
        if ([self jsonHasKey:@"headurl" json:json]) {
            self.headurl = [self stringParser:@"headurl" json:json];// 头像路径
        }
        if ([self jsonHasKey:@"maxHeadUrl" json:json]) {
            self.maxHeadUrl = [self stringParser:@"maxHeadUrl" json:json];
        }
        if ([self jsonHasKey:@"userLevel" json:json]) {
            self.userLevel = [self integerParser:@"userLevel" json:json];
        } else if ([self jsonHasKey:@"isVip" json:json]) {//用户权限(0为普通，1为认证)
            self.userLevel = [self integerParser:@"isVip" json:json];
        }
    }
    return self;
}

- (id)initWithResultSet:(TJRFMResultSet *)rs {
    self = [super init];
    if (self && rs) {
        self.name = [rs stringForColumn:UserInfo_UserName];
        self.userId = [rs stringForColumn:UserInfo_UserId];
        self.headurl = [rs stringForColumn:UserInfo_HeaderUrl];
        self.userLevel = [rs longLongIntForColumn:UserInfo_UserLervel];
        self.maxHeadUrl = [rs stringForColumn:UserInfo_MaXHeaderUrl];
    }
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
    }
    return self;
}

/**
 创建一个UserInfo,不用释放
 @param userId 用户id
 @param userLevel 用户权限
 @param headerUrl 用户头像地址
 @returns
 */
+ (UserInfo *)createWithUserId:(NSString *)userId userName:(NSString *)userName userLevel:(NSInteger)userLevel headerUrl:(NSString *)headerUrl {
    UserInfo *info = [[UserInfo new] autorelease];
    info.userId = userId;
    info.userLevel = userLevel;
    info.headurl = headerUrl;
    info.name = userName;
    return info;
}

- (void)dealloc {
    RELEASE(_userId);
    RELEASE(_name);
    RELEASE(_headurl);
    RELEASE(_maxHeadUrl);
    [super dealloc];
}
@end
