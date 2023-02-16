//
//  UserParser.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UserParser.h"

@implementation UserParser

#pragma parser User json

- (TJRUser *)parserMyInfoJson:(NSDictionary *)json {
    if (!json) return nil;
    TJRUser *user = [[TJRUser alloc] init];
    [self parserMyInfoJson:json user:user];
    return [user autorelease];
}

//方便已有对象时更新对象
- (void)parserMyInfoJson:(NSDictionary *)json user:(TJRUser *)user{
    [self setJson:json];
    
    if ([json objectForKey:@"userId"])
        user.userId = [self stringParser:json name:@"userId"];// 登录用户ID
    
    if ([json objectForKey:@"phone"])
        user.userAccount = [self stringParser:json name:@"phone"]; // 登录用户账号
    
    if ([json objectForKey:@"birthday"])
        user.birthday = [self stringParser:json name:@"birthday"]; // 生日日期

    if ([json objectForKey:@"type"])
        user.type = [self stringParser:json name:@"type"]; // 登录方式，sinawb代表是微博，qq代表腾讯QQ，mb代表手机
    
    if ([json objectForKey:@"userName"])
        user.name = [self stringParser:json name:@"userName"]; // 用户名
    
    if ([json objectForKey:@"sex"])
        user.sex = [self stringParser:json name:@"sex"]; // 性别，0代表女性，1代表男性
    
    if ([json objectForKey:@"headUrl"])
        user.headurl = [self stringParser:json name:@"headUrl"]; // 头像路径
    
    if ([json objectForKey:@"describes"])
        user.selfDescription = [self stringParser:json name:@"describes"]; // 自我描述

    if ([json objectForKey:@"idCertify"])
        user.idCertify = [self integerParser:json name:@"idCertify"];
    
    if ([json objectForKey:@"otcCertify"])
        user.otcCertify = [self boolParser:json name:@"otcCertify"];
    
    if ([json objectForKey:@"userRealName"])
        user.userRealName = [self stringParser:json name:@"userRealName"];
    
    if ([json objectForKey:@"ethAddress"])
        user.ethAddress = [self stringParser:json name:@"ethAddress"];
    
    if ([json objectForKey:@"payPass"])
        user.payPass = [self stringParser:json name:@"payPass"];
    
    if([json objectForKey:@"openCopy"])
        user.openFollow = [self integerParser:json name:@"openCopy"];
    
    if([json objectForKey:@"countryCode"]){
        user.countryCode = [self stringParser:json name:@"countryCode"];
    }
    
    if([json objectForKey:@"email"]){
        user.email = [self stringParser:json name:@"email"];
    }
}


@end
