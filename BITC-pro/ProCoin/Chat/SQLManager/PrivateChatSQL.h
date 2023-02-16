//
//  PrivateChatSQL.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrivateChatDataEntity;
@class CircleChatEntity;

@interface PrivateChatSQL : NSObject

+ (void)createPrivateChatSQL:(PrivateChatDataEntity*)item;
+ (void)updatePrivateTopic:(NSString*)chatTopic isPush:(BOOL)isPush;
+ (void)deletePrivateTopic:(NSString*)chatTopic;
+ (void)replaceChatSQL:(CircleChatEntity*)item;
+ (void)updatePrivateTopicNewsInArrayForNoDB:(NSArray *)chatArray;
+ (void)insertChatList:(NSArray *)chatArray;
+ (void)updatePrivateTopicNews:(NSString*)chatTopic chatNews:(NSInteger)chatNews;
+ (NSArray *)queryPrivateChatInfo;
+ (PrivateChatDataEntity*)getPrivateTopic:(NSString*)chatTopic;
/** 获取一条聊天室信息*/
+ (PrivateChatDataEntity *)getSinglePrivateChatDataWithChatTopic:(NSString *)chatTopic;
@end
