//
//  CircleChatEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/12/2.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "CircleChatEntity.h"
#import "TJRDatabase.h"
#import "CommonUtil.h"
#import "MLEmojiLabel.h"


@implementation CircleChatEntity
- (id)initWithJson:(NSDictionary *)json {
    self = [super initWithJson:json];
    if (self && json) {

        self.circleId = [self stringParser:@"circleId" json:json];	// 圈号
        self.createTime = [self stringParser:@"createTime" json:json];// 创建时间
        self.mark = [self integerParser:@"mark" json:json];//标识
        self.verifi = [self stringParser:@"verify" json:json];
        self.isPush = [self boolParser:@"isPush" json:json];
        self.roleName = [self stringParser:@"roleName" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.userName = [self stringParser:@"name" json:json];
        self.chatTopic = [self stringParser:@"chatTopic" json:json];
        if (!TTIsStringWithAnyText(_circleId)) {
            self.circleId = [self stringParser:@"chatTopic" json:json];
        }
        
        NSString* say = [self stringParser:@"say" json:json];// 聊天内容
        if ([[say componentsSeparatedByString:@"="] count]>1) {
            NSString* type = [[say componentsSeparatedByString:@"="] firstObject];
            self.sayType = type;// 聊天内容的类型
        }
        self.say = [[say componentsSeparatedByString:[NSString stringWithFormat:@"%@=",self.sayType]]lastObject];
    }
    return self;
}


- (id)initWithResultSet:(TJRFMResultSet *)rs {
    self = [super init];
    if (self && rs) {

//        self.circleId = [rs stringForColumn:@"circle_id"];
        self.createTime = [rs stringForColumn:@"chat_create_time"];
        self.mark = [rs unsignedLongLongIntForColumn:@"chat_mark"];
        self.say = [rs stringForColumn:@"say"];
        self.sayType = [rs stringForColumn:@"say_type"];
        self.isRead = [rs boolForColumn:@"is_read"];
        self.chatTopic = [rs stringForColumn:@"chat_topic"];
        
//        self.roleName = [rs stringForColumn:@"role_name"];
        
        self.userName = [rs stringForColumn:@"info_user_name"];
        self.userId = [rs stringForColumn:@"info_user_id"];
        self.headUrl = [rs stringForColumn:@"info_header_url"];
    }
    return self;
}

/**
 *  按最新聊天mark,进行倒序排序
 *
 *  @param otherObject
 *
 *  @return
 */
- (NSComparisonResult)compareKeysByDes:(CircleChatEntity *)otherObject {
    if (self.mark < otherObject.mark) {
        return NSOrderedDescending;
    } else if (self.mark > otherObject.mark) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

/**
 *  去除参数，方便显示
 *
 *  @param content
 *
 *  @return 简化后的字符
 */
+ (NSString*)simpleForAtParam:(NSString*)content{
    
    NSMutableDictionary* atDic = [[[NSMutableDictionary alloc]init]autorelease];

    NSString* str = [CircleChatEntity simpleForAtParam:content atDic:atDic];

    return str;
}

+ (NSString*)simpleForAtParam:(NSString*)content atDic:(NSMutableDictionary*)atDic{
    
    NSArray* arr = [MLEmojiLabel findParam:content];
    
    for (NSTextCheckingResult* result in arr) {
        
        NSString* rStr = [content substringWithRange:result.range];
        NSString *format = @"(?<=\\()(.+?)(?=\\))";
        NSRegularExpression *utlRegex = [NSRegularExpression regularExpressionWithPattern:format options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSTextCheckingResult *b = [[utlRegex matchesInString:rStr options:0 range:NSMakeRange(0, [rStr length])] firstObject];
        NSString* name = [NSString stringWithFormat:@"%@",[rStr substringWithRange:b.range]];
        
        [atDic setObject:rStr forKey:name];
    }
    NSString* str = content;
    for (NSString* key in [atDic allKeys]) {
        NSString* value = [NSString stringWithFormat:@"%@",[atDic objectForKey:key]];
        str = [str stringByReplacingOccurrencesOfString:value withString:key];
    }
    return str;
}

- (void)dealloc {
    RELEASE(_chatTopic);
    RELEASE(_userId);
    RELEASE(_userName);
    RELEASE(_headUrl);
    RELEASE(_roleName);
    RELEASE(_verifi);
    RELEASE(_chatRoomName);
    RELEASE(_createTime);
    RELEASE(_say);
    RELEASE(_sayType);
    [super dealloc];
}

@end
