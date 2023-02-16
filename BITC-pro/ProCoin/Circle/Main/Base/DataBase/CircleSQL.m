//
//  CircleSQL.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/26.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "CircleSQL.h"
#import "CommonUtil.h"
#import "TJRDatabase.h"
#import "VeDateUtil.h"
#import "UserInfoSQL.h"
#import "CircleEntity.h"
#import "CircleChatEntity.h"
#import "CircleBaseDataEntity.h"
#import "CircleChatExtendEntity.h"
#import "CircleSocket.h"
#import "PrivateChatDataEntity.h"
#import "CircleSettingRemindEntity.h"

static dispatch_queue_t queue;

@implementation CircleSQL

#pragma mark - 用于数据库插入修改所用的线程
+ (dispatch_queue_t)dataBaseQueue {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.taojin.circle.dataBaseQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark - 使用异步线程执行代码块
/**
 * 使用异步线程执行代码块
 *
 * @param block
 */
+ (void)otherQueueToDo:(void (^)(void))block {
    dispatch_async([CircleSQL dataBaseQueue], ^{
        if (block) block();
    });
}

#pragma mark - 清除所有圈子数据
/**
 *  清除所有圈子数据
 */
+ (void)clearAllCircle {
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"delete from %@", @"circle"];
        [db executeUpdate:sql];
        
        sql = [NSString stringWithFormat:@"delete from %@", @"circle_chat"];
        [db executeUpdate:sql];
    }];
}

/**
 *  退出圈子
 *
 *  @param circleId 圈号
 */
+ (void)exitCircleWithCircleId:(NSString*)circleId {
    if (!TTIsStringWithAnyText(circleId)) return;
//  删除圈子的基本信息(内存)
    NSString *key = [NSString stringWithFormat:@"%@", circleId];
    [[CircleSocket shareCircleSocket].circleDetail removeObjectForKey:key];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from circle_my where circle_id='%@' and my_user_id='%@'",circleId, ROOTCONTROLLER_USER.userId];
        [db executeUpdate:sql];
    }];
    
}

/**
 *  清空聊天记录
 *
 *  @param circleNum 圈号
 */
+ (BOOL)clearCircleChatWithCircleId:(NSString*)circleId {
    if (!TTIsStringWithAnyText(circleId)) return NO;
    
    __block BOOL b = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from circle_chat where circle_id='%@'", circleId];
        b = [db executeUpdate:sql];
    }];
    
    return b;
}

+ (BOOL)clearPrivateChatWithChatTopic:(NSString*)chatTopic {
    if (!TTIsStringWithAnyText(chatTopic)) return NO;
    
    __block BOOL b = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from private_chat where chat_topic='%@'",chatTopic];
        b = [db executeUpdate:sql];
    }];
    
    return b;
}

#pragma mark - 查询圈数据
/**
 *  查询圈数据
 *
 *  @return 数组里为CircleEntity
 */
+ (NSArray *)queryCircleInfo {
    
    __block NSMutableArray *array = [NSMutableArray array];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM (circle a LEFT JOIN circle_chat c ON a.circle_id = c.circle_id and c.my_user_id='%@') LEFT JOIN user_info u on u.info_user_id=c.chat_user_id LEFT JOIN circle_my q where q.my_user_id='%@' and a.circle_id=q.circle_id and (c.chat_delete=0 or c.chat_delete is null) GROUP BY a.circle_id;",ROOTCONTROLLER_USER.userId,ROOTCONTROLLER_USER.userId];
        
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (rs){
            @try {
                while ([rs next]) {
                    CircleEntity *item = [[CircleEntity alloc] initWithResultSet:rs];
                    [array addObject:item];
                    RELEASE(item);
                }

            } @catch(NSException *exception) {
                NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
            } @finally {
                if (rs) {
                    [rs close];
                }
            }
        }else{
            array = nil;
        }
    }];
    return array;
}

/**
 *  更新圈头像
 *
 *  @param circleId
 *  @param logoUrl
 */
+ (void)updateCircleLogo:(NSString *)circleId logo:(NSString *)logoUrl {
    if (TTIsStringWithAnyText(circleId) && TTIsStringWithAnyText(logoUrl)) {
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"update circle set circle_logo='%@' where circle_id='%@';",logoUrl,circleId];
            BOOL success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"更新圈头像出错:%@",sql);
            }
        }];
    }
}

/**
 *  获取用户所在的圈子聊天的消息数
 *
 *  @return 数组里为CircleBaseDataEntity
 */
+ (CircleBaseDataEntity *)queryCircleChatNewsWithCircleId:(NSString*)circleId {
    
    __block CircleBaseDataEntity *item = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from circle_my where circle_id='%@' and my_user_id='%@';", circleId, ROOTCONTROLLER_USER.userId];
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        @try {
            while ([rs next]) {
                item = [[CircleBaseDataEntity alloc] initWithResultSet:rs];
            }
        } @catch(NSException *exception) {
            NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    return item;
}


#pragma mark - 更新用户圈子信息
/**
 *  更新用户圈子信息,使用replace into(多个)
 *
 *  @param circleArray
 */
+ (void)replaceIntoCircleInfoWithArray:(NSArray *)circleArray {
    if (circleArray && (circleArray.count > 0)) {
        if (circleArray.count >= 50) {
            [[TJRDatabase shareFMDatabaseQueue] inTransaction:^(TJRFMDatabase *db, BOOL *rollback) {
                for (CircleEntity *item in circleArray) {
                    NSString *executeSQL = [NSString stringWithFormat:@"REPLACE INTO circle(circle_id,create_user_id,circle_name,brief,create_time,circle_bg,circle_logo,syn_mark)values(?,?,?,?,?,?,?,?)"];
                    NSArray *arguments = @[item.circleId,item.createUserId,item.circleName,item.brief,item.createTime,
                                           item.circleBg,item.circleLogo,@(item.synMark)];
                    
                    NSString *sql = [NSString stringWithFormat:@"select * from circle_my where circle_id='%@' and my_user_id='%@'",item.circleId, ROOTCONTROLLER_USER.userId];
                    
                    TJRFMResultSet *rs = [db executeQuery:sql];
                    BOOL hasCircle = false;
                    if (rs) {
                        @try {
                            while ([rs next]) {
                                hasCircle = true;
                                break;
                            }
                        } @catch(NSException *exception) {
                            
                        } @finally {
                            if (rs) {
                                [rs close];
                            }
                        }
                    }
                    NSString* myCircleSQL = [NSString stringWithFormat:@"INSERT INTO circle_my(circle_id,my_user_id,circle_sort_time)values('%@','%@','%@')",item.circleId,ROOTCONTROLLER_USER.userId,@"0"];
                    if (!hasCircle) [db executeUpdate:myCircleSQL];
                    BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
                    if (!success) {
                        NSLog(@"圈子信息入库出错:%@",executeSQL);
                    }
                }
                *rollback = false;
            }];
        } else {
            for (CircleEntity *item in circleArray) {
                [CircleSQL replaceIntoCircleInfo:item];
            }
        }
    }
}

/**
 *  更新用户圈子信息,使用replace into(单个)
 *
 *  @param item
 */
+ (void)replaceIntoCircleInfo:(CircleEntity *)item {

    NSString *executeSQL = [NSString stringWithFormat:@"REPLACE INTO circle(circle_id,create_user_id,circle_name,brief,create_time,circle_bg,circle_logo,syn_mark)values(?,?,?,?,?,?,?,?)"];
    NSArray *arguments = @[item.circleId,item.createUserId,item.circleName,item.brief,item.createTime,
                           item.circleBg,item.circleLogo,@(item.synMark)];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
        if (!success) {
            NSLog(@"圈子信息入库出错:%@",executeSQL);
        }
    }];
}

#pragma mark - 更新我加入的圈子信息,所在圈子权限(单个)
/**
 *  更新我加入的圈子信息,所在圈子权限,使用replace into(单个)
 *
 *  @param item
 */
+ (void)replaceIntoMyCircle:(CircleBaseDataEntity *)item {
    
    NSString *executeSQL = [NSString stringWithFormat:@"REPLACE INTO circle_my(circle_id,my_user_id,circle_user_role,chat_news_count)values(?,?,?,?)"];
    
    NSArray *arguments = @[item.circleId,ROOTCONTROLLER_USER.userId,[NSString stringWithFormat:@"%@",@(item.role)],[NSString stringWithFormat:@"%@",@(item.chatNews)]];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
        if (!success) {
            NSLog(@"圈子信息入库出错:%@",executeSQL);
        }
    }];
}

#pragma mark - 更新我加入的圈子信息,所在圈子权限(多个)
/**
 *  更新我加入的圈子信息,所在圈子权限(多个)
 *
 *  @param circleArray
 */
+ (void)replaceIntoMyCircleWithArray:(NSArray *)roleArray {
    if (roleArray && (roleArray.count > 0)) {
        
        BOOL isTRansaction = roleArray.count > 50;
        if (isTRansaction) {
            [[TJRDatabase shareFMDatabaseQueue] inTransaction:^(TJRFMDatabase *db, BOOL *rollback) {
                for (CircleBaseDataEntity *item in roleArray) {
                    NSString *sql = [NSString stringWithFormat:@"update circle_my set circle_user_role=%@ where circle_id='%@' and my_user_id='%@';",
                                      @(item.role), item.circleId, ROOTCONTROLLER_USER.userId];;
                    if (TTIsStringWithAnyText(sql)) {
                        BOOL success = [db executeUpdate:sql];
                        if (!success) {
                            NSLog(@"更新用户所在圈子权限出错:%@",sql);
                        }
                    }
                }
                *rollback = NO;
            }];
        }else{
            for (CircleBaseDataEntity *item in roleArray) {
                [CircleSQL replaceIntoMyCircle:item];
            }
        }
    }
}

/**
 *  更新用户所在圈子聊天消息条数
 *
 *  @param item
 */
+ (void)updateUserNewsChat:(CircleBaseDataEntity *)item {
    NSString *sql = [NSString stringWithFormat:@"update circle_my set chat_news_count=%@ where circle_id='%@' and my_user_id='%@';",
                     @(item.chatNews), item.circleId, item.userId];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        if (TTIsStringWithAnyText(sql)) {
            BOOL success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"更新用户所在圈子聊天消息条数出错:%@",sql);
            }
        }
    }];
}



#pragma mark - 更新用户聊天信息
/**
 *  更新用户聊天信息,使用replace into(多个)
 *
 *  @param circleArray
 */
+ (void)replaceIntoCircleChatWithArray:(NSArray *)chatArray {
    if (chatArray && (chatArray.count > 0)) {
        BOOL isTRansaction = chatArray.count >= 10;
        if (isTRansaction) {
            [[TJRDatabase shareFMDatabaseQueue] inTransaction:^(TJRFMDatabase *db, BOOL *rollback) {
                for (CircleChatEntity *item in chatArray) {
                    
                    NSString *executeSQL = [NSString stringWithFormat:@"REPLACE INTO circle_chat(circle_id,chat_user_id,chat_create_time,say,chat_mark,say_type,my_user_id,is_read,role_name)values(?,?,?,?,?,?,?,?,?)"];
                    NSArray *arguments = @[item.circleId,item.userId,item.createTime,item.say,[NSString stringWithFormat:@"%@",@(item.mark)],item.sayType,ROOTCONTROLLER_USER.userId,[NSNumber numberWithBool:item.isRead],item.roleName];
                    
                    BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
                    if (!success) {
                        NSLog(@"聊天信息入库出错:%@",executeSQL);
                    }
                }
                *rollback = NO;
            }];
        }else{
            for (CircleChatEntity *item in chatArray) {
                [CircleSQL replaceIntoCircleChat:item];
            }
        }
    }
}

/**
 *  更新用户聊天信息,使用replace into(单个)
 *
 *  @param item
 */
+ (void)replaceIntoCircleChat:(CircleChatEntity *)item {
    
    NSString *executeSQL = [NSString stringWithFormat:@"REPLACE INTO circle_chat(circle_id,chat_user_id,chat_create_time,say,chat_mark,say_type,my_user_id,is_read,role_name)values(?,?,?,?,?,?,?,?,?)"];
    NSArray *arguments = @[item.circleId,item.userId,item.createTime,item.say,[NSString stringWithFormat:@"%@",@(item.mark)],item.sayType,ROOTCONTROLLER_USER.userId,[NSNumber numberWithBool:item.isRead],item.roleName];

    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
        if (!success) {
            NSLog(@"聊天信息入库出错:%@",executeSQL);
        }
    }];
}

+ (void)replaceIntoPrivateChat:(CircleChatEntity *)item {
    
    NSString *executeSQL = [NSString stringWithFormat:@"REPLACE INTO private_chat(chat_topic,chat_user_id,chat_create_time,say,chat_mark,say_type,my_user_id,is_push,is_read)values(?,?,?,?,?,?,?,?,?)"];
    NSArray *arguments = @[[NSString stringWithFormat:@"%@",item.chatTopic],
                           item.userId,item.createTime,item.say,
                           [NSString stringWithFormat:@"%@",@(item.mark)],item.sayType,
                           ROOTCONTROLLER_USER.userId,
                           [NSNumber numberWithBool:item.isPush],
                           [NSNumber numberWithBool:item.isRead]];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
        if (!success) {
            NSLog(@"聊天信息入库出错:%@",executeSQL);
        }
    }];
}


#pragma mark - 查询某个圈子的一条聊天数据
/**
 *  查询某个圈子的一条聊天数据
 *
 *  @param circleId 圈号
 *
 *  @return 圈聊天Entity
 */
+ (CircleChatExtendEntity *)queryCircleChatWithCircleId:(NSString*)circleId mark:(NSUInteger)mark{
    if (!TTIsStringWithAnyText(circleId)) return nil;
    
    __block CircleChatExtendEntity *item = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"circle_chat" condition:[NSString stringWithFormat:@"circle_id='%@' and my_user_id='%@' and chat_delete=0 and chat_mark='%lu' limit 1", circleId,ROOTCONTROLLER_USER.userId,(unsigned long)mark]];
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        @try {
            while ([rs next]) {
                item = [[CircleChatExtendEntity alloc] initWithResultSet:rs];
            }
        } @catch(NSException *exception) {
            NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    
    return item;
}

+ (CircleChatExtendEntity *)queryCircleChatWithChatTopic:(NSString*)chatTopic mark:(NSUInteger)mark{
    if (!TTIsStringWithAnyText(chatTopic)) return nil;
    
    __block CircleChatExtendEntity *item = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"private_chat" condition:[NSString stringWithFormat:@"chat_topic='%@' and my_user_id='%@' and chat_delete=0 and chat_mark='%lu' limit 1",  chatTopic,ROOTCONTROLLER_USER.userId,(unsigned long)mark]];
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        @try {
            while ([rs next]) {
                item = [[CircleChatExtendEntity alloc] initWithResultSet:rs];
            }
        } @catch(NSException *exception) {
            NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    
    return item;
}



#pragma mark - 查询某个圈子的最新一条聊天数据
/**
 *  查询某个圈子的最新一条聊天数据
 *
 *  @param circleId 圈号
 *
 *  @return 圈聊天Entity
 */
+ (CircleChatEntity *)queryCircleChatTheLatestOneWithCircleId:(NSString*)circleId {
    if (!TTIsStringWithAnyText(circleId)) return nil;
    
    __block CircleChatEntity *item = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"circle_chat" condition:[NSString stringWithFormat:@"circle_id='%@' and my_user_id='%@' and chat_delete=0 order by chat_mark DESC limit 1", circleId,ROOTCONTROLLER_USER.userId]];
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        @try {
            while ([rs next]) {
                item = [[[CircleChatEntity alloc] initWithResultSet:rs] autorelease];
            }
        } @catch(NSException *exception) {
            NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    return item;
}

+ (CircleChatEntity *)queryPrivateChatTheLatestOneWithChatTopic:(NSString*)chatTopic {
    if (!TTIsStringWithAnyText(chatTopic)) return nil;
    
    __block CircleChatEntity *item = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"private_chat" condition:[NSString stringWithFormat:@"chat_topic='%@' and my_user_id='%@' and chat_delete=0 order by chat_mark DESC limit 1",  chatTopic,ROOTCONTROLLER_USER.userId]];
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        @try {
            while ([rs next]) {
                item = [[CircleChatEntity alloc] initWithResultSet:rs];
            }
        } @catch(NSException *exception) {
            NSLog(@"解析私聊数据库出错 - 最新一条记录:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    return item;
}


#pragma mark - 查询某个圈子的一些聊天数据
/**
 *  查询某个圈子的一些聊天数据
 *
 *  @param circleID 圈号
 *  @param mark      为0查询最新的,不为0时,和gOrl有关
 *  @param gOrl      当mark不为0时,true为查询比mark大的数据,false为查询比mark小的数据
 *  @param length    查询结果条数
 *
 *  @return 聊天数据Array,结果以聊天时间升序排列,为nil表示出错
 */
+ (NSArray *)queryCircleChatWithCircleId:(NSString*)circleId mark:(NSUInteger)mark greaterOrLessMark:(BOOL)gOrl length:(NSInteger)length {
    NSString *condition = nil;

    if (mark > 0) {
        condition = [NSString stringWithFormat:@"circle_id='%@' and chat_mark%@%@ and my_user_id='%@' and chat_delete=0 order by chat_mark %@ limit %@", circleId, gOrl ? @">" : @"<", @(mark),ROOTCONTROLLER_USER.userId, gOrl ? @"ASC" : @"DESC", @(length)];
    } else {
        condition = [NSString stringWithFormat:@"circle_id='%@' and my_user_id='%@' and chat_delete=0 order by chat_mark DESC limit %@", circleId, ROOTCONTROLLER_USER.userId, @(length)];
    }
    NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"circle_chat" condition:condition];

    __block NSMutableArray *array = nil;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        array = [NSMutableArray array];
        @try {
            while ([rs next]) {
                CircleChatEntity *item = [[CircleChatEntity alloc] initWithResultSet:rs];
                if ((mark > 0) && gOrl) {
                    [array addObject:item];    // 升序查询,结果不用做操作
                } else {
                    [array insertObject:item atIndex:0];// 倒序查询出来的结果是倒序的
                }
                RELEASE(item);
            }
        } @catch(NSException *exception) {
            NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    return array;
}

+ (NSArray *)queryPrivateChatWithChatTopic:(NSString*)chatTopic mark:(NSUInteger)mark greaterOrLessMark:(BOOL)gOrl length:(NSUInteger)length {
    NSString *condition = nil;
    
    if (mark > 0) {
        condition = [NSString stringWithFormat:@"chat_topic='%@' and chat_mark%@%@ and my_user_id='%@' and chat_delete=0 order by chat_mark %@ limit %@", chatTopic, gOrl ? @">" : @"<", @(mark),ROOTCONTROLLER_USER.userId, gOrl ? @"ASC" : @"DESC", @(length)];
    } else {
        condition = [NSString stringWithFormat:@"chat_topic='%@' and my_user_id='%@' and chat_delete=0 order by chat_mark DESC limit %@", chatTopic,ROOTCONTROLLER_USER.userId, @(length)];
    }
    NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"private_chat" condition:condition];

    __block NSMutableArray *array = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        array = [NSMutableArray array];
        @try {
            while ([rs next]) {
                CircleChatEntity *item = [[CircleChatEntity alloc] initWithResultSet:rs];
                
                if ((mark > 0) && gOrl) {
                    [array addObject:item];    // 升序查询,结果不用做操作
                } else {
                    [array insertObject:item atIndex:0];// 倒序查询出来的结果是倒序的
                }
                RELEASE(item);
            }
        } @catch(NSException *exception) {
            NSLog(@"解析私聊数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    
    return array;
}

#pragma mark - 查询某个圈子的所有包含图片的聊天数据
/**
 *  查询某个圈子的所有包含图片的聊天数据
 *
 *  @param circleId 圈号
 *
 *  @return 聊天数据Array,结果以聊天时间升序排列,为nil表示出错
 */
+ (NSArray *)queryCircleChatPictureWithCircleId:(NSString*)circleId{
    NSString *condition = nil;
    
    condition = [NSString stringWithFormat:@"circle_id='%@' and my_user_id='%@' and say_type='%@' and chat_delete=0 order by chat_mark DESC", circleId,ROOTCONTROLLER_USER.userId,CIRCLE_CHAT_TYPE_IMG];
    
    NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"circle_chat" condition:condition];

    __block NSMutableArray *array = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        array = [NSMutableArray array];
        @try {
            while ([rs next]) {
                CircleChatEntity *item = [[CircleChatEntity alloc] initWithResultSet:rs];
                [array insertObject:item atIndex:0];// 倒序查询出来的结果是倒序的
                RELEASE(item);
            }
        } @catch(NSException *exception) {
            NSLog(@"解析圈子数据库出错:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    return array;
}

+ (NSArray *)queryPrivateChatPictureWithChatTopic:(NSString*)chatTopic{
    NSString *condition = nil;
    
    condition = [NSString stringWithFormat:@"chat_topic='%@' and my_user_id='%@' and say_type='%@' and chat_delete=0 order by chat_mark DESC", chatTopic, ROOTCONTROLLER_USER.userId,CIRCLE_CHAT_TYPE_IMG];
    
    NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"chat_user_id" tableName:@"private_chat" condition:condition];

    __block NSMutableArray *array = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) return;
        
        array = [NSMutableArray array];
        @try {
            while ([rs next]) {
                CircleChatEntity *item = [[CircleChatEntity alloc] initWithResultSet:rs];
                [array insertObject:item atIndex:0];// 倒序查询出来的结果是倒序的
                RELEASE(item);
            }
        } @catch(NSException *exception) {
            NSLog(@"解析私聊数据库出错 - 私聊图片记录:%@", exception.debugDescription);
        } @finally {
            if (rs) {
                [rs close];
            }
        }
    }];
    return array;
}

//
/**
 *  删除某一条聊天数据
 *
 *  @param item
 */
+ (void)delectCircleChatWithCircleId:(NSString*)circleId mark:(NSUInteger)mark{
    
    NSString *executeSQL = [NSString stringWithFormat:@"update circle_chat set circle_id=? where circle_id=? and chat_mark=? and my_user_id=?"];
    
    NSArray *arguments = @[[NSNumber numberWithBool:true], circleId, [NSString stringWithFormat:@"%@",@(mark)], ROOTCONTROLLER_USER.userId];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
        if (!success) {
            NSLog(@"删除信息出错:%@",executeSQL);
        }
    }];
    
}

+ (void)delectPrivateChatWithChatTopic:(NSString*)chatTopic mark:(NSUInteger)mark{
    
    NSString *executeSQL = [NSString stringWithFormat:@"update private_chat set chat_topic=? where chat_mark=? and chat_topic=? and my_user_id=?"];
    
    NSArray *arguments = @[[NSNumber numberWithBool:true], chatTopic,[NSString stringWithFormat:@"%@",@(mark)],ROOTCONTROLLER_USER.userId];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
        if (!success) {
            NSLog(@"删除信息出错:%@",executeSQL);
        }
    }];
    
}

/**
 *  获取圈子设置数据
 */
+ (CircleSettingRemindEntity *)queryCircleSettingWithCircleId:(NSString *)circleId {
    
    __block CircleSettingRemindEntity *remindItem = [[[CircleSettingRemindEntity alloc]init] autorelease];

    NSString *sqlStr = [NSString stringWithFormat:@"select * from circle_setting_remind where my_user_id='%@' and circle_id='%@'",ROOTCONTROLLER_USER.userId,circleId];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        TJRFMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            remindItem.circleId = [rs stringForColumn:@"circle_id"];
            remindItem.chatRemind = [rs longLongIntForColumn:@"chat_remind"];
        }
        [rs close];
    }];
    return remindItem;
}

/**
 *  更新圈子设置数据
 */
+ (void)updateCircleSetting:(NSString *)circleId chatRemind:(NSInteger)chatRemind
{
    NSString *selectCountStr = [NSString stringWithFormat:@"select count(*) from circle_setting_remind where my_user_id='%@' and circle_id='%@'",ROOTCONTROLLER_USER.userId,circleId];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSInteger count = 0;
        TJRFMResultSet *rs = [db executeQuery:selectCountStr];
        if ([rs next])
            count = [rs intForColumnIndex:0];
        [rs close];
        //不存在
        if (count == 0){
            if(TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){
                NSString *insertStr = [NSString stringWithFormat:@"insert into circle_setting_remind(my_user_id,circle_id,chat_remind)values('%@','%@',%@)",ROOTCONTROLLER_USER.userId,circleId,@(chatRemind)];
                [db executeUpdate:insertStr];
            }
        }else{
            //更新数据库
            if(TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){
                NSString *updateStr = [NSString stringWithFormat:@"update circle_setting_remind set chat_remind=%@ where my_user_id='%@' and circle_id = '%@'",@(chatRemind),ROOTCONTROLLER_USER.userId,circleId];
                [db executeUpdate:updateStr];
            }
        }
    }];
    
}


/**
 *  更新圈子的排序时间
 *
 *  @param circleId 圈号
 *  @param userId    用户Id
 *  @param sortTime  排序时间
 */
+ (void)updateSortTimeSQLWithCircleId:(NSString*)circleId sortTime:(NSString*)sortTime {
    
    if (sortTime > 0 && TTIsStringWithAnyText(circleId) > 0) {
        NSString *sql = [NSString stringWithFormat:@"update circle_my set circle_sort_time='%@' where circle_id='%@' and my_user_id='%@' and (circle_sort_time<%@ or circle_sort_time is null);",  sortTime, circleId, ROOTCONTROLLER_USER.userId, sortTime];
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            BOOL success =[db executeUpdate:sql];
            if (!success) {
                NSLog(@"更新圈子的排序时间出错:%@",sql);
            }
            FMDBQuickCheck(![db hadError]);
        }];
        
    }
}

/**
 *  更新圈子聊天已读
 *
 *  @param sql sql description
 */
+ (void)updateCircleChatRead:(CircleChatEntity*)item {
    
    if(TTIsStringWithAnyText(item.circleId) && item.mark > 0){
        NSString *executeSQL = [NSString stringWithFormat:@"update circle_chat set is_read=? where circle_id=? and chat_mark=? and my_user_id=?"];
        NSArray *arguments = @[[NSNumber numberWithBool:true],
                               [NSString stringWithFormat:@"%@",item.circleId],
                               [NSString stringWithFormat:@"%@",@(item.mark)],
                               ROOTCONTROLLER_USER.userId];
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
            if (!success) {
                NSLog(@"更新信息出错:%@",executeSQL);
            }
        }];
        
    }
}

+ (void)updatePrivateChatRead:(CircleChatEntity*)item {
    
    if(TTIsStringWithAnyText(item.chatTopic) && item.mark > 0){
        NSString *executeSQL = [NSString stringWithFormat:@"update private_chat set is_read=? where chat_topic=? and chat_mark=? and my_user_id=?"];
        NSArray *arguments = @[[NSNumber numberWithBool:true],
                               [NSString stringWithFormat:@"%@",item.chatTopic],
                               [NSString stringWithFormat:@"%@",@(item.mark)],
                               ROOTCONTROLLER_USER.userId];
        
        [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
            BOOL success = [db executeUpdate:executeSQL withArgumentsInArray:arguments];
            if (!success) {
                NSLog(@"更新信息出错:%@",executeSQL);
            }
        }];
        
    }
}


@end
