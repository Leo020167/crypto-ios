//
//  AppInfo.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-10-15.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRAppInfo.h"

@implementation TJRAppInfo
- (void)dealloc {
    [_bugMsg release];
    [_downloadUrl release];
    [_identifyCode release];
    [_platform release];
    [_updateTime release];
    [super dealloc];
}
@end

@implementation TJRPlacard
- (void)dealloc {
    [_content release];
    [_title release];
    [_placardTime release];
    [super dealloc];
}
@end
