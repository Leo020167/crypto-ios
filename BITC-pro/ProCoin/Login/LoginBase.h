//
//  LoginBase.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>




@protocol LoginBaseDelegate <NSObject>

@optional
- (void)LBRequestStart;
- (void)LBRequestFinished;
- (void)LBRequestFaild;
- (void)LBLoginInto:(TJRUser*)user;
- (void)LBLoginOut;
- (void)LBPageToRegister;
- (void)LBNeedCode:(NSString*)code;
@end

@interface LoginBase : NSObject{

}
@property (assign, nonatomic) id <LoginBaseDelegate>lbDelegate;
@property (copy, nonatomic) NSString *currentAccount;
@property (copy, nonatomic) NSString *currentPassword;
@property (copy, nonatomic) NSString *currentType;

/**
 用手机号码和密码登陆
 @param phoneNum 手机号码
 @param password 密码
 */
- (void)loginByPwd:(NSString*)account andPassword:(NSString*)password smsCode:(NSString*)smsCode dragImgKey:(NSString*)dragImgKey locationx:(NSInteger)locationx;

/**
 第三方账号登陆
 @param account 用户账号
 @param thirdType 类型
 */
- (void)loginByThird:(NSString*)account thirdType:(NSString*)thirdType;

//NO 表示没有数据
- (BOOL)getUserLoginInfoFromSQL;

/**
 唯一地方设置生成user
 */
+ (void)setRootLoginUser:(TJRUser*)user;
+ (TJRUser*)getRootLoginUser;

@end
