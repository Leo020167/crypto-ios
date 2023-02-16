//
//  CircleEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/27.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "CircleEntity.h"
#import "TJRDatabase.h"
#import "CircleChatEntity.h"

@implementation CircleEntity

- (id)initWithJson:(NSDictionary *)json {
    self = [super initWithJson:json];
    if (self && json) {
        self.circleId = [self stringParser:@"circleId" json:json];	// 圈号
        self.circleName = [self stringParser:@"circleName" json:json];// 圈名
        self.circleLogo = [self stringParser:@"circleLogo" json:json];// 圈logo
        self.createUserId = [self stringParser:@"userId" json:json];// 创建人UserId
        self.brief = [self stringParser:@"brief" json:json];// 圈介绍
        self.synMark = [self longlongParser:@"synMark" json:json];
        self.memberAmount = [self stringParser:@"memberAmount" json:json];
        self.speakStatus = [self integerParser:@"speakStatus" json:json];
        self.joinMode = [self integerParser:@"joinMode" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];// 创建时间
        self.circleBg = [self stringParser:@"circleBg" json:json];
        self.createUserName = [self stringParser:@"userName" json:json];
        self.createUserHeadurl = [self stringParser:@"headUrl" json:json];
        self.reviewState = [self integerParser:@"reviewState" json:json];
    }
    return self;
}

- (id)initWithResultSet:(TJRFMResultSet *)rs {
    self = [super init];
    if (self && rs) {
        self.circleId = [rs stringForColumn:@"circle_id"];    // 圈号
        self.circleName = [rs stringForColumn:@"circle_name"];// 圈名
        self.circleLogo = [rs stringForColumn:@"circle_logo"];// 圈logo
        self.createUserId = [rs stringForColumn:@"create_user_id"];// 创建人UserId
        self.brief = [rs stringForColumn:@"brief"];// 圈介绍
        self.createTime = [rs stringForColumn:@"create_time"];// 创建时间
        self.synMark = [rs unsignedLongLongIntForColumn:@"syn_mark"];
        
        //连表查询内容
        self.chatLast = [rs stringForColumn:@"say"];
        self.chatLastMark = [rs unsignedLongLongIntForColumn:@"chat_mark"];
        self.chatUserId = [rs stringForColumn:@"chat_user_id"];
        self.chatTime = [rs stringForColumn:@"chat_create_time"];
        self.chatUserName = [rs stringForColumn:@"info_user_name"];
        self.chatLastSayType = [rs stringForColumn:@"say_type"];
        
        self.sortTime = [rs unsignedLongLongIntForColumn:@"chat_create_time"];//以聊天信息作为排序时间，目前只包含聊天信息
        
//        NSString* time = [rs stringForColumn:@"circle_sort_time"];
//        NSLog(@"time:%@",time);
//        self.sortTime = [rs unsignedLongLongIntForColumn:@"circle_sort_time"];
        
    }
    return self;
}

/**
 *  将一条聊天数据加入到圈子里
 *
 *  @param chatEntity 聊天数据
 */
- (void)addTheLastOneChatData:(CircleChatEntity *)chatEntity {
    if (chatEntity && [chatEntity.circleId isEqualToString:self.circleId]) {
        self.chatLast = chatEntity.say;
        self.chatTime = chatEntity.createTime;
        self.chatUserName = chatEntity.userName;
        self.chatLastMark = chatEntity.mark;
        self.chatLastSayType = chatEntity.sayType;
        NSUInteger sortTime = [chatEntity.createTime longLongValue];
        if (self.sortTime < sortTime) {
            self.sortTime = sortTime;
        }
    }
}

/**
 *  将数组中最新的聊天数据加入到圈子里
 *
 *  @param chatEntity 聊天数据
 */
- (void)addTheLastOneChatDataFromArray:(NSArray *)array {
    if (!array || array.count == 0) return;
    CircleChatEntity *chatEntity = [array firstObject];
    if (chatEntity && [chatEntity.circleId isEqualToString:self.circleId] && chatEntity.mark > self.chatLastMark) {
        self.chatLast = chatEntity.say;
        self.chatTime = chatEntity.createTime;
        self.chatUserName = chatEntity.userName;
        self.chatLastMark = chatEntity.mark;
        self.chatLastSayType = chatEntity.sayType;
        NSUInteger sortTime = [chatEntity.createTime longLongValue];
        if (self.sortTime < sortTime) {
            self.sortTime = sortTime;
        }
    }
}

/**
 *  按圈子最新时间,进行倒序排序
 *
 *  @param otherObject
 *
 *  @return
 */
- (NSComparisonResult)compareCircleTimeByDes:(CircleEntity *)otherObject {

    if (self.sortTime < otherObject.sortTime) {
        return NSOrderedDescending;
    } else if (self.sortTime > otherObject.sortTime) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}


- (void)dealloc {
    [_circleBg release];
    RELEASE(_circleLogo);
    RELEASE(_chatLastSayType);
    RELEASE(_chatUserId);
    RELEASE(_chatUserName);
    RELEASE(_chatLast);
    RELEASE(_circleName);// 圈名
    RELEASE(_brief);// 圈介绍
    RELEASE(_createTime);// 创建时间
    [super dealloc];
}

@end
