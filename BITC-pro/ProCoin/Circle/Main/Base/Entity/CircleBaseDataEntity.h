//
//  CircleBaseDataEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/12/9.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseEntity.h"

@interface CircleBaseDataEntity : TJRBaseEntity

@property(nonatomic, copy) NSString *circleId;	// 圈号
@property(nonatomic, copy) NSString *userId;	// 用户id
@property(nonatomic, assign) NSInteger role;// 用户角色(和CircleUserIdentity对应),0普通用户,10是圈主,5是管理员
@property(nonatomic, copy) NSString *roleName;// 用户角色
@property(nonatomic, assign) NSInteger chatNews;	// 聊天新消息数(存数据库)
@property(nonatomic, assign) NSInteger showNews;// 微访谈新消息数
@property(nonatomic, assign) NSInteger articleNews;// 文章新消息数
@property(nonatomic, assign) NSInteger applyNews;	// 新成员申请新消息数
@property(nonatomic, copy) NSString *chatName;	//聊天室名称
@property(nonatomic, copy) NSString *sortTime;	
@property(nonatomic, assign) BOOL bInChat;	//是否进入聊天界面


#pragma mark - 从内存中获取圈子的基本数据
+ (CircleBaseDataEntity *)circleBaseDataWithCircleId:(NSString*)circleId;

- (void)updateWithJson:(NSDictionary *)json;

- (id)initWithResultSet:(TJRFMResultSet *)rs;

#pragma mark - 当前权限是否是圈主或管理员
- (BOOL)isHostOrAdministrator;

@end
