//
//  PrivateChatDataEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/12/9.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "UserInfo.h"

#define SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT                @"SocketNotifacationKeyPrivateChat"//私聊聊天信息
#define SOCKET_NOTIFACATION_KEY_PRIVATE_USERINFO            @"SocketNotifacationKeyPrivateUserInfo"//私聊聊天信息里的用户信息的Key
#define SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT_CLEAR          @"SocketNotifacationKeyPrivateChatClear"//私聊里消息清空Key


@interface PrivateChatDataEntity : UserInfo

@property(nonatomic, copy) NSString* chatTopic;     // chatTopic号
@property(nonatomic, assign) NSInteger chatNews;	// 聊天新消息数(存数据库)
@property(nonatomic, copy) NSString* content;       //聊天文本
@property(nonatomic, copy) NSString* createTime;	//更新的时间
@property(nonatomic, assign) BOOL isPush;
@property (nonatomic, assign) NSUInteger mark;      //标识
@property (nonatomic, copy) NSString *sayType;
@property(nonatomic, assign) BOOL bInChat;	//是否进入聊天界面

#pragma mark - 从内存中获取私聊的基本数据
+ (PrivateChatDataEntity *)chatDataWithChatTopic:(NSString*)chatTopic;

- (id)initWithJson:(NSDictionary *)json;

- (void)updateWithJson:(NSDictionary *)json;

- (id)initWithResultSet:(TJRFMResultSet *)rs;

- (NSComparisonResult)compareChatTimeByDes:(PrivateChatDataEntity *)otherObject;
@end
