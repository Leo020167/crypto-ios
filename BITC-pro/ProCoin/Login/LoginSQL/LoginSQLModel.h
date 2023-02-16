//
//  LoginSQLModel.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginSQLModel : NSObject

//存储登陆信息
+ (BOOL) insertLoginInfo:(TJRUser*)user;

//更新数据库登陆信息
+ (BOOL) updateLoginInfo:(TJRUser*)user;

//获取登陆信息
+ (TJRUser*) selectLoginInfo;

//清除登陆信息
+ (BOOL)deleteLoginInfo;

//更新新浪登陆的token
+ (BOOL)updateSinaToken:(NSString*)token;
@end
