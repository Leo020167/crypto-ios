//
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-12.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import "PrivateChatSQL.h"
#import "TJRDatabase.h"
#import "CommonUtil.h"
#import "UserInfoSQL.h"
#import "PrivateChatDataEntity.h"
#import "CircleChatEntity.h"
#import "CircleChatEntity.h"
#import "CircleSQL.h"
#import "CircleSocket.h"
#import "UserInfoSQL.h"

@implementation PrivateChatSQL{
}

+ (void)createPrivateChatSQL:(PrivateChatDataEntity*)item {

    NSString *insertStr = [NSString stringWithFormat:@"REPLACE INTO private_topic(chat_user_id,chat_create_time,chat_topic,say,chat_mark,chat_news,isPush, my_user_id) values ('%@','%@','%@','%@','%@',%d,%d,'%@')",item.userId,item.createTime,item.chatTopic,item.content,@(item.mark),0,1,ROOTCONTROLLER_USER.userId];

    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        [db executeUpdate:insertStr];
    }];
    [UserInfoSQL insertOrUpdateUserInfoWithUserId:item.userId userName:item.name userLevel:item.userLevel headerUrl:item.headurl];//更新用户信息
}

+ (void)updatePrivateTopic:(NSString*)chatTopic isPush:(BOOL)isPush{
    if (TTIsStringWithAnyText(chatTopic)) {
        NSString *sql = [NSString stringWithFormat:@"update private_topic set isPush='%d' where chat_topic='%@' and my_user_id='%@';",isPush,chatTopic,ROOTCONTROLLER_USER.userId];
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            BOOL success = [db executeUpdate:sql];
            if (!success) {
            NSLog(@"更新私聊出错:%@",sql);
            }
        }];
    }
}

+ (void)deletePrivateTopic:(NSString*)chatTopic{
    if (TTIsStringWithAnyText(chatTopic)) {
        NSString *sql = [NSString stringWithFormat:@"delete from private_topic where chat_topic='%@' and my_user_id='%@';",chatTopic,ROOTCONTROLLER_USER.userId];
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            BOOL success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"删除私聊出错:%@",sql);
            }
        }];
    }
}




+ (void)updatePrivateTopicNews:(NSString*)chatTopic chatNews:(NSInteger)chatNews{
    if (TTIsStringWithAnyText(chatTopic)) {
        NSString *sql = [NSString stringWithFormat:@"update private_topic set chat_news='%@' where chat_topic='%@' and my_user_id='%@';",@(chatNews),chatTopic,ROOTCONTROLLER_USER.userId];
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            BOOL success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"更新私聊出错:%@",sql);
            }
        }];
    }
}

+ (void)updatePrivateTopicNewsInArrayForNoDB:(NSArray *)chatArray {
    
    if (chatArray && (chatArray.count > 0)) {

        for (CircleChatEntity *item in chatArray) {
            if (TTIsStringWithAnyText(item.chatTopic)) {
                PrivateChatDataEntity *data = [CircleSocket shareCircleSocket].privateDetail[item.chatTopic];
                if (data && ![item.userId isEqualToString:ROOTCONTROLLER_USER.userId] && !data.bInChat) {
                    data.chatNews++;
                    [PrivateChatSQL updatePrivateTopicNews:item.chatTopic chatNews:data.chatNews];
                }
            }
        }
    }
}


+ (void)insertChatList:(NSArray *)chatArray {

    if (chatArray && (chatArray.count > 0)) {

        for (CircleChatEntity *item in chatArray) {
            if (TTIsStringWithAnyText(item.chatTopic)) {
                CircleChatEntity *entity = [CircleSQL queryPrivateChatTheLatestOneWithChatTopic:item.chatTopic];
                PrivateChatDataEntity *data = [CircleSocket shareCircleSocket].privateDetail[item.chatTopic];
                if (data && (entity.mark != 0) && !(item.mark == entity.mark) && ![item.userId isEqualToString:ROOTCONTROLLER_USER.userId] && !data.bInChat) {
                    data.chatNews++;
                    [PrivateChatSQL updatePrivateTopicNews:item.chatTopic chatNews:data.chatNews];
                }
            }
            [UserInfoSQL insertOrUpdateUserInfoWithUserId:item.userId userName:item.userName userLevel:0 headerUrl:item.headUrl];
            
            [PrivateChatSQL replaceChatSQL:item];
            [CircleSQL replaceIntoPrivateChat:item];
        }
    }
}

+ (void)replaceChatSQL:(CircleChatEntity*)item {
    if (!TTIsStringWithAnyText(item.chatTopic)) return;
    
    NSArray* arr = [item.chatTopic componentsSeparatedByString:@"-"];
    NSString* chatUserId = item.userId;
    if (arr.count == 2) {
        if ([[arr firstObject] isEqualToString:ROOTCONTROLLER_USER.userId]) {
            chatUserId = [arr lastObject];
        }else if ([[arr lastObject] isEqualToString:ROOTCONTROLLER_USER.userId]) {
            chatUserId = [arr firstObject];
        }
    }
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        int totalCount = 0;
        TJRFMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select count(*) from private_topic where chat_topic='%@' and my_user_id='%@'",item.chatTopic,ROOTCONTROLLER_USER.userId]];
        if ([rs next]) {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
        
        if (totalCount) {
            NSString *insertStr = [NSString stringWithFormat:@"update private_topic set chat_user_id='%@',chat_create_time='%@',say='%@',chat_mark='%@',isPush='%d' where chat_topic='%@' and my_user_id='%@'",chatUserId,item.createTime,item.say,@(item.mark),item.isPush,item.chatTopic,ROOTCONTROLLER_USER.userId];
            
            [db executeUpdate:insertStr];
        
        }else{
            NSString *insertStr = [NSString stringWithFormat:@"insert into private_topic(chat_user_id,chat_create_time,chat_topic,say,chat_mark,isPush,chat_news, my_user_id) values ('%@','%@','%@','%@','%@',%d,%d,'%@')",chatUserId,item.createTime,item.chatTopic,item.say,@(item.mark),item.isPush,0,ROOTCONTROLLER_USER.userId];
            
            [db executeUpdate:insertStr];
        }
    }];
    
}


+ (NSArray *)queryPrivateChatInfo {

    NSString *sql = [NSString stringWithFormat:@"SELECT *,p.chat_topic,p.isPush FROM (private_topic p LEFT JOIN private_chat c ON p.chat_topic = c.chat_topic and c.my_user_id='%@') LEFT JOIN user_info u on p.chat_user_id = u.info_user_id where p.my_user_id='%@' and (c.chat_delete=0 or c.chat_delete is null)  group by p.chat_topic order by p.chat_create_time desc;",ROOTCONTROLLER_USER.userId,ROOTCONTROLLER_USER.userId];
    

    __block NSMutableArray *array = [NSMutableArray array];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        if (!rs) return;
        @try {
            while ([rs next]) {
                PrivateChatDataEntity *item = [[PrivateChatDataEntity alloc] initWithResultSet:rs];
                [array addObject:item];
                RELEASE(item);
            }
        } @catch(NSException *exception) {
            NSLog(@"解析私聊数据库出错 - 私聊列表:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];

    return array;
}

+ (PrivateChatDataEntity*)getPrivateTopic:(NSString*)chatTopic{
    
    if (TTIsStringWithAnyText(chatTopic)) {

        NSString *sql = [NSString stringWithFormat:@"SELECT *,p.chat_topic,p.isPush,u.info_user_name FROM (private_topic p LEFT JOIN private_chat c ON p.chat_topic = c.chat_topic and c.my_user_id='%@' and p.chat_topic='%@') LEFT JOIN user_info u on p.chat_user_id = u.info_user_id where p.my_user_id='%@' and (c.chat_delete=0 or c.chat_delete is null)  group by p.chat_topic order by p.chat_create_time desc;",chatTopic,ROOTCONTROLLER_USER.userId,ROOTCONTROLLER_USER.userId]; //除非自己重写逻辑，否则请不要修改
        
        __block PrivateChatDataEntity *item = nil;
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            
            TJRFMResultSet *rs = [db executeQuery:sql];
            if (!rs) return;
            @try {
                while ([rs next]) {
                    item = [[[PrivateChatDataEntity alloc] initWithResultSet:rs]autorelease];
                }
            } @catch(NSException *exception) {
                NSLog(@"解析私聊数据库出错 - 私聊列表:%@", exception.debugDescription);
            } @finally {
                if (rs) {
                    [rs close];
                }
            }
        }];
        return item;
    }
    return nil;
}

/** 获取一条聊天室信息*/
+ (PrivateChatDataEntity *)getSinglePrivateChatDataWithChatTopic:(NSString *)chatTopic
{
    __block PrivateChatDataEntity *item = nil;
    if (TTIsStringWithAnyText(chatTopic)){
        NSString *sql = [NSString stringWithFormat:@"select * from private_topic where chat_topic = '%@'",chatTopic];
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            TJRFMResultSet *rs = [db executeQuery:sql];
            if ([rs next]) {
                item = [[[PrivateChatDataEntity alloc] init] autorelease];
                item.chatTopic = [rs stringForColumn:@"chat_topic"];
                item.chatNews  = [rs unsignedLongLongIntForColumn:@"chat_news"];
            }
            [rs close];
        }];
    }
    return item;
}

@end
