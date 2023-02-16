//
//  CircleSocket.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/26.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseSocket.h"
#import "TJRCircleManager.h"

extern NSString *const CircleNotifyKeyReceive;
extern NSString *const CircleNotifyKeySuccess;
extern NSString *const CircleNotifyKeyType;

typedef NS_ENUM (NSUInteger, CircleSocketMsgType) {	/* 圈子发送数据类型 */
	CircleSocketConnect,
    CircleSocketCircleHome,
    CircleSocketCircleRoom,
};

typedef NS_ENUM (NSUInteger, ReceiveModelType) {	/* socket接收数据类型 */

    ReceiveModelSysTjrPush              = 10, // 官方推送              
    ReceiveModelCircleList              = 3100,// 用户订阅的圈子的最新信息返回码
    ReceiveModelCircleMoreData          = 204,// 圈子资料(成员列表，成员申请管理)
    ReceiveModelCircleApplyList         = 205,// 圈子申请列表
    ReceiveModelMemberList              = 206,// 成员列表
    ReceiveModelDelInfoRecord           = 207,// 删除一条资料
    ReceiveModelSearchByCircleNum       = 209,// 根据圈号查找圈子
    ReceiveModelSearchCircleBaseInfo    = 210,// 根据圈号查找的圈子信息
    ReceiveModelCircleRoleList          = 3200,// 用户在圈子角色
    ReceiveModelCircleNews              = 212,// 用户圈子新消息回总
    ReceiveModelCircleChatName          = 223,// 聊天室名称
    ReceiveModelCircleSettingData       = 3600,//圈子配置信息(成员申请数、消息免打扰等等)
    ReceiveModelCircleSpeakStatus       = 3500,// 圈子禁言状态
    ReceiveModelCircleLogout            = 3400,// 用户退出/被圈主被出
    ReceiveModelPrivateChatRecord       = 2300,// 私聊聊天一条记录信息返回码
    ReceiveModelCircleChatRecord        = 3000,// 圈子聊天一条记录信息返回码
    ReceiveModelPushDynamicsTip         = 2500,// 推送动态点赞、评论消息提示更新
    ReceiveModelHomeSubRecord           = 3001,// 首页用户相关信息
    ReceiveModelPushRecordList          = 5000,// Push推送列表，包括首页信息以及私聊列表
};

@interface CircleSocket : TJRBaseSocket {
    BOOL isCanSend;//标记socket当前是否可以发送 获取数据
    BOOL isSaveFinish;
    NSMutableArray *circleArray;//保存查询到的圈子一些基本数据
    BOOL isPostNotification;
    BOOL isCloseTimer;
    BOOL isDisconnect;
}
@property (nonatomic, copy) NSString *baseUrlParameters;
@property (nonatomic, retain) NSMutableDictionary *circleDetail;//保存圈子的基本信息,聊天数,资讯数等
@property (nonatomic, retain) NSMutableDictionary *privateDetail;//保存私聊的基本信息,聊天数等

/**
 *    初始化圈子socket,使用单例
 *    @returns 当前类
 */
+ (CircleSocket *)shareCircleSocket;

/**
 *  发送聊天内容
 *
 *  @param str   发送内容
 */
- (void)sendMSG:(NSString *)str;

/**
 *  心跳包连接
 */
- (void)ping;

/**
 *  获取通知的key，格式：CircleNotifacationKey-ReceiveModelType
 *
 *  @param type  socket唯一码标志
 *  @return key
 */

+ (NSString*)circleNotifacationKey:(ReceiveModelType)type;
@end
