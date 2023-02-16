//
//  CircleChatEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/12/2.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseEntity.h"

#define CIRCLE_CHAT_TYPE_IMG            @"[img]"
#define CIRCLE_CHAT_TYPE_VOICE          @"[voice]"
#define CIRCLE_CHAT_TYPE_TEXT           @"[text]"
#define CIRCLE_CHAT_TYPE_SYSTEM         @"[tip]"
#define CIRCLE_CHAT_TYPE_JSON           @"[default_json]"
#define CIRCLE_CHAT_TYPE_LOCAL          @"[local]"

@interface CircleChatEntity : TJRBaseEntity

@property (nonatomic, copy) NSString *circleId;	// 圈号
@property (nonatomic, copy) NSString *chatRoomName;// 聊天室名
@property (nonatomic, copy) NSString *createTime;// 创建时间
@property (nonatomic, assign) NSUInteger mark;//标识
@property (nonatomic, copy) NSString *say;// 聊天内容
@property (nonatomic, copy) NSString *sayType;// 聊天内容的类型，图片img ，文字text，语言voice等等
@property (copy, nonatomic) NSString *verifi;//20位随机码
@property (nonatomic, assign) BOOL isPush;
@property (assign, nonatomic) BOOL isRead;//是否已读。
@property (nonatomic, copy) NSString* roleName;	// 角色名称
@property (nonatomic, copy) NSString* chatTopic;    // 私聊房间号

@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* headUrl;

- (id)initWithResultSet:(TJRFMResultSet *)rs;

- (id)initWithJson:(NSDictionary *)json;

/**
 *  按最新聊天mark,进行倒序排序
 *
 *  @param otherObject
 *
 *  @return
 */
- (NSComparisonResult)compareKeysByDes:(CircleChatEntity *)otherObject;

/**
 *  显示时去除@后的参数
 *
 *  @param content
 *
 *  @return 简化后的@字符串
 */
+ (NSString*)simpleForAtParam:(NSString*)content;
+ (NSString*)simpleForAtParam:(NSString*)content atDic:(NSMutableDictionary*)atDic;
@end
