//
//  CircleSQL.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/26.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CircleEntity,CircleChatEntity,CircleBaseDataEntity,CircleChatExtendEntity,CircleSettingRemindEntity;

#define CIRCLESQL_QUERY_MAX 20

@interface CircleSQL : NSObject

#pragma mark - 使用异步线程执行代码块
+ (void)otherQueueToDo:(void (^)(void))block;

#pragma mark - 清除所有圈子数据
+ (void)clearAllCircle;

#pragma mark - 退出圈子
+ (void)exitCircleWithCircleId:(NSString*)circleId;

#pragma mark - 圈子清空聊天记录
+ (BOOL)clearCircleChatWithCircleId:(NSString*)circleId;

#pragma mark - 私聊清空聊天记录
+ (BOOL)clearPrivateChatWithChatTopic:(NSString*)chatTopic;

#pragma mark - 查询圈数据
+ (NSArray *)queryCircleInfo;

#pragma mark - 更新圈头像
+ (void)updateCircleLogo:(NSString *)circleId logo:(NSString *)logoUrl;

#pragma mark -  获取用户所在的圈子聊天的消息数
+ (CircleBaseDataEntity *)queryCircleChatNewsWithCircleId:(NSString*)circleId;

#pragma mark - 更新用户圈子信息,使用replace into(多个)
+ (void)replaceIntoCircleInfoWithArray:(NSArray *)circleArray;

#pragma mark - 更新用户圈子信息,使用replace into(单个)
+ (void)replaceIntoCircleInfo:(CircleEntity *)item;

#pragma mark - 更新我加入的圈子信息,所在圈子权限(单个)
+ (void)replaceIntoMyCircle:(CircleBaseDataEntity *)item;

#pragma mark - 更新我加入的圈子信息,所在圈子权限(多个)
+ (void)replaceIntoMyCircleWithArray:(NSArray *)roleArray;

#pragma mark - 更新用户所在圈子聊天消息条数
+ (void)updateUserNewsChat:(CircleBaseDataEntity *)item;

#pragma mark - 更新用户聊天信息,使用replace into(多个)
+ (void)replaceIntoCircleChatWithArray:(NSArray *)chatArray;

#pragma mark - 更新用户聊天信息,使用replace into(单个)
+ (void)replaceIntoCircleChat:(CircleChatEntity *)item;

#pragma mark - 更新私聊信息,使用replace into(单个)
+ (void)replaceIntoPrivateChat:(CircleChatEntity *)item;

#pragma mark - 查询某个圈子的一条聊天数据
+ (CircleChatExtendEntity *)queryCircleChatWithCircleId:(NSString*)circleId mark:(NSUInteger)mark;

#pragma mark - 查询某个私聊的一条聊天数据
+ (CircleChatExtendEntity *)queryCircleChatWithChatTopic:(NSString*)chatTopic mark:(NSUInteger)mark;

#pragma mark - 查询某个圈子的最新一条聊天数据
+ (CircleChatEntity *)queryCircleChatTheLatestOneWithCircleId:(NSString*)circleId ;

#pragma mark - 查询某个私聊的最新一条聊天数据
+ (CircleChatEntity *)queryPrivateChatTheLatestOneWithChatTopic:(NSString*)chatTopic;

#pragma mark - 查询某个圈子的一些聊天数据
+ (NSArray *)queryCircleChatWithCircleId:(NSString*)circleId mark:(NSUInteger)mark greaterOrLessMark:(BOOL)gOrl length:(NSInteger)length;

#pragma mark - 查询某个私聊的一些聊天数据
+ (NSArray *)queryPrivateChatWithChatTopic:(NSString*)chatTopic mark:(NSUInteger)mark greaterOrLessMark:(BOOL)gOrl length:(NSUInteger)length;

#pragma mark - 查询某个圈子的所有包含图片的聊天数据
+ (NSArray *)queryCircleChatPictureWithCircleId:(NSString*)circleId;

#pragma mark - 查询某个私聊的所有包含图片的聊天数据
+ (NSArray *)queryPrivateChatPictureWithChatTopic:(NSString*)chatTopic;

#pragma mark - 删除某一条聊天数据
+ (void)delectCircleChatWithCircleId:(NSString*)circleId mark:(NSUInteger)mark;
+ (void)delectPrivateChatWithChatTopic:(NSString*)chatTopic mark:(NSUInteger)mark;

#pragma mark - 获取圈子设置数据
+ (CircleSettingRemindEntity *)queryCircleSettingWithCircleId:(NSString *)circleId;

#pragma mark - 更新圈子设置数据
+ (void)updateCircleSetting:(NSString *)circleId chatRemind:(NSInteger)chatRemind;

#pragma mark - 更新圈子的排序时间
+ (void)updateSortTimeSQLWithCircleId:(NSString*)circleId sortTime:(NSString*)sortTime;

#pragma mark - 更新圈子聊天已读
+ (void)updateCircleChatRead:(CircleChatEntity*)item;
+ (void)updatePrivateChatRead:(CircleChatEntity*)item;

@end
