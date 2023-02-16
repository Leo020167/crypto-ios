//
//  AppInfoParser.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-10-15.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRAppInfoParser.h"

@implementation TJRAppInfoParser
- (TJRAppInfo *)parser:(NSDictionary *)json {
    [self setJson:json];
    
    TJRAppInfo *item = [[[TJRAppInfo alloc] init] autorelease];
    item.bugMsg = [self stringParser:@"bugMsg"];
    item.platform = [self stringParser:@"platform"];
    item.downloadUrl = [self stringParser:@"downloadUrl"];
    item.identifyCode = [self stringParser:@"identifyCode"];
    item.versionNum = [self intParser:@"version"];
    item.isForce = [self boolParser:@"isForce"];//1代表强制更新
    item.updateTime = [self stringParser:@"updateTime"];
    
    return item;
}


- (TJRPlacard *)parserPlacard:(NSDictionary *)json {
    [self setJson:json];
    TJRPlacard *item = [[TJRPlacard alloc] init];
    item.content = [self stringParser:@"content"];
    item.placardTime = [self stringParser:@"noticeTime"];
    item.title = [self stringParser:@"title"];
    return [item autorelease];
}
@end
