//
//  PrivateChatDataEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/12/9.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "PrivateChatDataEntity.h"
#import "CircleSocket.h"
#import "TJRDatabase.h"


@implementation PrivateChatDataEntity

#pragma mark - 从内存中获取私聊的基本数据
+ (PrivateChatDataEntity *)chatDataWithChatTopic:(NSString*)chatTopic{
	if (TTIsStringWithAnyText(chatTopic)) {
		NSString *key = [NSString stringWithFormat:@"%@", chatTopic];
		return [CircleSocket shareCircleSocket].privateDetail[key];
	}
	return nil;
}

- (id)init {
    self = [super init];
    
    if (self) {
    }
    return self;
}


- (id)initWithJson:(NSDictionary *)json {
	self = [super init];

	if (self && json) {
		self.chatTopic  = [self stringParser:@"chatTopic" json:json];
		self.userId   = [self stringParser:@"userId" json:json];
		self.headurl  = [self stringParser:@"headurl" json:json];
        self.name  = [self stringParser:@"name" json:json];
		self.createTime  = [self stringParser:@"createTime" json:json];
        self.isPush  = [self boolParser:@"isPush" json:json];
        self.content  = [self stringParser:@"say" json:json];
        self.mark  = [self integerParser:@"mark" json:json];
    }
	return self;
}

- (void)updateWithJson:(NSDictionary *)json {
	if (json) {
		if ([self jsonHasKey:@"chatTopic" json:json]) {
			self.chatTopic = [self stringParser:@"chatTopic" json:json];
		}

		if ([self jsonHasKey:@"userId" json:json]) {
			self.userId = [self stringParser:@"userId" json:json];
		}

		if ([self jsonHasKey:@"chatNews" json:json]) {
			self.chatNews = [self integerParser:@"chatNews" json:json];	// 聊天新消息数
		}

        if ([self jsonHasKey:@"say" json:json]) {
            self.content = [self stringParser:@"say" json:json];
        }
        
        if ([self jsonHasKey:@"createTime" json:json]) {
            self.createTime = [self stringParser:@"createTime" json:json];
        }
        
        if ([self jsonHasKey:@"isPush" json:json]) {
            self.isPush = [self boolParser:@"isPush" json:json];
        }
        
        if ([self jsonHasKey:@"mark" json:json]) {
            self.mark = [self integerParser:@"mark" json:json];
        }
	}
}

- (id)initWithResultSet:(TJRFMResultSet *)rs {
	self = [super init];

	if (self && rs) {

        self.chatTopic = [rs stringForColumn:@"chat_topic"];
		self.userId    = [rs stringForColumn:@"info_user_id"];
		self.createTime  = [rs stringForColumn:@"chat_create_time"];
        self.content  = [rs stringForColumn:@"say"];
        self.isPush  = [rs boolForColumn:@"isPush"];
        self.mark  = [rs unsignedLongLongIntForColumn:@"chat_mark"];
        self.headurl  = [rs stringForColumn:@"info_header_url"];
        self.name  = [rs stringForColumn:@"info_user_name"];
        self.sayType  = [rs stringForColumn:@"say_type"];
        self.chatNews  = [rs unsignedLongLongIntForColumn:@"chat_news"];

	}
	return self;
}

- (NSComparisonResult)compareChatTimeByDes:(PrivateChatDataEntity *)otherObject {
    
    if ([self.createTime integerValue] < [otherObject.createTime integerValue]) {
        return NSOrderedDescending;
    } else if ([self.createTime integerValue] > [otherObject.createTime integerValue]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (void)dealloc {
    [_sayType release];
    [_content release];
    [_createTime release];
    [_chatTopic release];
	[super dealloc];
}

@end
