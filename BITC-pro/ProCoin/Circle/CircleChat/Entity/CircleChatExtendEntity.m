//
//  CircleChatExtendEntity.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12/7/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatExtendEntity.h"

@implementation CircleChatExtendEntity

- (void)dealloc{
    [_voiceLength release];
    [_componentsDictionary release];
    [_timeFormat release];
    [super dealloc];
}


+ (CircleChatExtendEntity*)toExtendEntity:(CircleChatEntity*)entity{
    CircleChatExtendEntity *item = [[[CircleChatExtendEntity alloc]init]autorelease];
    item.sayType = entity.sayType;
    item.createTime = entity.createTime;
    item.userId = entity.userId;
    item.userName = entity.userName;
    item.mark = entity.mark;
    item.verifi = entity.verifi;
    item.headUrl = entity.headUrl;
    item.isRead = entity.isRead;
    item.roleName = entity.roleName;
    item.chatTopic = entity.chatTopic;
    item.circleId = entity.circleId;
    item.isPush = entity.isPush;
    
    NSString* say = entity.say;
    if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_IMG]) {
        if ([[say componentsSeparatedByString:@","] count]>2) {
            say = [[entity.say componentsSeparatedByString:@","] firstObject];
            NSString* height = [[entity.say componentsSeparatedByString:@","] objectAtIndex:1];
            NSString* width = [[entity.say componentsSeparatedByString:@","] lastObject];
            item.imgSize = CGSizeMake([width floatValue], [height floatValue]);
        }else{
            item.imgSize = CGSizeMake(120, 120);
        }
    }
    
    if ([item.sayType isEqualToString:CIRCLE_CHAT_TYPE_VOICE]) {
        if ([[say componentsSeparatedByString:@","] count]>1) {
            say = [[entity.say componentsSeparatedByString:@","] firstObject];
            NSString* length = [[entity.say componentsSeparatedByString:@","] lastObject];
            item.voiceLength = length;
        }else{
            item.voiceLength = @"6";
        }
    }
    
    item.say = say;
    
    return item;
}
@end
