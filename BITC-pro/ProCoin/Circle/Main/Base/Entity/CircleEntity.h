//
//  CircleEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/27.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseEntity.h"

@class TJRFMResultSet;
@class CircleChatEntity;


#define CIRCLE_PUSH_KEY                                 @"CirclePushKey"//本地push的key
#define CIRCLE_MODEL_KEY                                @"CircleModelKey"//圈子key
#define CIRCLE_PAGENAME_KEY                             @"CirclePageNameKey"//记录跳转页面

#define CIRCLE_USER_DELETE_THE_LAST_CHAT                @"CircleUserDeleteTheLastChat"//用户删除最新一条聊天数据时的通知Key

#define SOCKET_NOTIFACATION_KEY_CIRCLE                  @"SocketNotifacationKeyCircle"//圈信息要更新的Key
#define SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT             @"SocketNotifacationKeyCircleChat"//聊天信息每条都会推
#define SOCKET_NOTIFACATION_KEY_CIRCLE_USERINFO         @"SocketNotifacationKeyCircleUserInfo"//聊天信息里的用户信息的Key
#define SOCKET_NOTIFACATION_KEY_CIRCLE_ROLE_CHANGE      @"SocketNotifacationKeyCircleRoleChange"//圈子里用户的权限发生变化更新的Key
#define SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT_CLEAR       @"SocketNotifacationKeyCircleChatClear"//圈子里消息清空Key
#define SOCKET_NOTIFACATION_KEY_CIRCLE_LOGO             @"SocketNotifacationKeyCircleLogo"//圈子logo更新的Key
#define SOCKET_NOTIFACATION_KEY_CIRCLE_BASEDATAENTITY   @"SocketNotifacationKeyCircleBaseDataEntity"//圈子实体的Key

@interface CircleEntity : TJRBaseEntity

@property (nonatomic, copy) NSString             *circleId;// 圈号
@property (nonatomic, copy) NSString             *circleName;// 圈名
@property (nonatomic, copy) NSString             *brief;// 圈介绍
@property (nonatomic, copy) NSString             *circleLogo;// 圈头像
@property (nonatomic, copy) NSString             *createTime;// 创建时间
@property (nonatomic, copy) NSString             *circleBg;
@property (nonatomic, assign) NSUInteger         synMark;//圈子中mark，后台记录
@property (nonatomic, copy) NSString             *memberAmount;
@property (nonatomic, assign) NSInteger          joinMode;//joinMode：0：需确认（默认），1：无需确认
@property (nonatomic, assign) NSInteger          speakStatus;//speakStatus(0为允许发言，1为禁止发言)
@property (nonatomic, assign) NSInteger          reviewState;//reviewState：0：审核中，1：审核通过，2：审核不通过

@property (nonatomic, copy) NSString             *createUserId;
@property (nonatomic, copy) NSString             *createUserName;
@property (nonatomic, copy) NSString             *createUserHeadurl;

@property (nonatomic, copy) NSString             *chatUserName;
@property (nonatomic, copy) NSString             *chatUserId;
@property (nonatomic, copy) NSString             *chatTime;// 聊天数据的时间

@property (nonatomic, copy) NSString             *chatLast;// 聊天数据最新一条
@property (nonatomic, assign) NSUInteger         chatLastMark;// 聊天数据最新一条的mark
@property (nonatomic, copy) NSString             *chatLastSayType;// 代表聊天的类型

@property (nonatomic, assign) NSUInteger         sortTime;// 圈子内所有数据(聊天等)最新时间


- (id)initWithResultSet:(TJRFMResultSet *)rs;

- (void)addTheLastOneChatData:(CircleChatEntity *)chatEntity;

- (void)addTheLastOneChatDataFromArray:(NSArray *)array;

- (NSComparisonResult)compareCircleTimeByDes:(CircleEntity *)otherObject;

@end
