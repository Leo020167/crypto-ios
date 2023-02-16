//
//  CircleBaseDataEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/12/9.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "CircleBaseDataEntity.h"
#import "CircleSocket.h"
#import "TJRDatabase.h"
#import "CircleMemberEntity.h"

@implementation CircleBaseDataEntity

/**
 *  从内存中获取圈子的基本数据
 *
 *  @param circleNum 圈号
 *
 *  @return return value description
 */
+ (CircleBaseDataEntity *)circleBaseDataWithCircleId:(NSString*)circleId {
	if (TTIsStringWithAnyText(circleId)) {
		NSString *key = [NSString stringWithFormat:@"%@", circleId];
		return [CircleSocket shareCircleSocket].circleDetail[key];
	}
	return nil;
}

- (id)initWithJson:(NSDictionary *)json {
	self = [super init];

	if (self && json) {
		self.circleId    = [self stringParser:@"circleId" json:json];// 圈号
		self.userId       = [self stringParser:@"userId" json:json];// 用户id
		self.role         = [self integerParser:@"role" json:json];	// 用户角色,0普通用户,10是圈主,5是管理员
        self.roleName    = [self stringParser:@"roleName" json:json];
		self.chatNews     = [self integerParser:@"chatNews" json:json];	// 聊天新消息数
		self.showNews      = [self integerParser:@"showAmount" json:json];	// 微访谈新消息数
        self.articleNews    = [self integerParser:@"articleAmount" json:json];   // 文章新消息数
		self.applyNews    = [self integerParser:@"newApplyAmount" json:json];// 新成员申请新消息数
		self.sortTime   = [self stringParser:@"newTime" json:json];
        
	}
	return self;
}

- (void)updateWithJson:(NSDictionary *)json {
	if (json) {
		if ([self jsonHasKey:@"circleId" json:json]) {
			self.circleId = [self stringParser:@"circleId" json:json];	// 圈号
		}

		if ([self jsonHasKey:@"userId" json:json]) {
			self.userId = [self stringParser:@"userId" json:json];	// 用户id
		}

		if ([self jsonHasKey:@"role" json:json]) {
			self.role = [self integerParser:@"role" json:json];	// 用户角色,0普通用户,10是圈主,5是管理员
		}
        
        if ([self jsonHasKey:@"roleName" json:json]) {
            self.roleName = [self stringParser:@"roleName" json:json];    // 角色
        }

		if ([self jsonHasKey:@"chatNews" json:json]) {
			self.chatNews = [self integerParser:@"chatNews" json:json];	// 聊天新消息数
		}

		if ([self jsonHasKey:@"showAmount" json:json]) {
			self.showNews = [self integerParser:@"showAmount" json:json];	// 微访谈新消息数
		}
        
        if ([self jsonHasKey:@"articleAmount" json:json]) {
            self.articleNews = [self integerParser:@"articleAmount" json:json];    // 文章新消息数
        }

		if ([self jsonHasKey:@"newApplyAmount" json:json]) {
			self.applyNews = [self integerParser:@"newApplyAmount" json:json];	// 新成员申请新消息数
		}

		if ([self jsonHasKey:@"chatName" json:json]) {
			self.chatName = [self stringParser:@"chatName" json:json];	// 聊天室名称
		}

		if ([self jsonHasKey:@"newTime" json:json]) {
			self.sortTime   = [self stringParser:@"newTime" json:json];
		}
	}
}

- (id)initWithResultSet:(TJRFMResultSet *)rs {
	self = [super init];

	if (self && rs) {
        self.circleId = [rs stringForColumn:@"circle_id"];    // 圈号
        self.chatName = [rs stringForColumn:@"circle_chat_name"];// 圈名
        self.sortTime = [rs stringForColumn:@"circle_sort_time"];
        self.role = [rs intForColumn:@"circle_user_role"];
        self.chatNews = [rs intForColumn:@"chat_news_count"];
        self.userId = [rs stringForColumn:@"my_user_id"];
	}
	return self;
}

/**
 *  当前权限是否是圈主或管理员
 *
 *  @return return value description
 */
- (BOOL)isHostOrAdministrator {
    return self.role == CRICLE_ROLE_ROOT || self.role == CRICLE_ROLE_ADMIN;
}

- (void)dealloc {
    
    [_sortTime release];
    RELEASE(_roleName);
    RELEASE(_circleId);
    RELEASE(_userId);
	RELEASE(_chatName);
	[super dealloc];
}

@end
