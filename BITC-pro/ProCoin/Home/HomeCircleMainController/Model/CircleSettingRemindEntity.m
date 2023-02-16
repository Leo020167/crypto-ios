//
//  CircleSettingRemindEntity.m
//  TJRtaojinroad
//
//  Created by Hay on 16/1/12.
//  Copyright © 2016年 淘金路. All rights reserved.
//

#import "CircleSettingRemindEntity.h"
#import "TJRDatabase.h"

@implementation CircleSettingRemindEntity

- (id)init
{
    self = [super init];
    if(self){
        //默认都开启
        self.chatRemind = 0;
    }
    return  self;
}

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    
    if (self && json) {
        self.chatRemind = [self integerParser:@"chatRe" json:json];
    }
    return self;
}

- (id)initWithResultSet:(TJRFMResultSet *)rs {
    self = [super init];
    if (self && rs) {
        self.circleId = [rs stringForColumn:@"circle_id"];
        self.chatRemind = [rs intForColumn:@"chat_remind"];
    }
    return self;
}

- (void)dealloc{
    [_circleId release];
    [super dealloc];
}

@end
