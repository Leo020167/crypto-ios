//
//  LoginBase.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "LoginBase.h"
#import "CommonUtil.h"
#import "iToast.h"
#import "UserParser.h"
#import "TJRUser.h"
#import "LoginSQLModel.h"
#import "Encryption.h"
#import "NetWorkManage+Security.h"

@interface LoginBase ()
{
    BOOL bReqFinished;
}
@end

@implementation LoginBase

- (id)init{
    self = [super init];
    if (self) {
        bReqFinished = YES;
    }
    return self;
}


#pragma mark - 根据type登陆
/**
 密码登录
 @param account 用户账号
 @param password 用户密码
 */
- (void)loginByPwd:(NSString*)account andPassword:(NSString*)password smsCode:(NSString*)smsCode dragImgKey:(NSString*)dragImgKey locationx:(NSInteger)locationx{
    
    self.currentAccount = account;
    self.currentPassword = password;
    self.currentType = LoginAccountTypePhone;

    if (bReqFinished) {
        if ([_lbDelegate respondsToSelector:@selector(LBRequestStart)])
            [_lbDelegate LBRequestStart];
        
        NSString* psw = password;
        psw = [CommonUtil getMD5:password];
        
        [[NetWorkManage shareSingleNetWork] reqLogin:self accountPhone:account userPass:psw smsCode:smsCode dragImgKey:dragImgKey locationx:locationx finishedCallback:@selector(requestLoginFinished:) failedCallback:@selector(requestLoginFailed:)];
        bReqFinished = NO;
        
    }
    
    
}

/**
 第三方账号登陆
 @param account 用户账号
 @param thirdType 类型
 */
- (void)loginByThird:(NSString*)account thirdType:(NSString*)thirdType{
    
    self.currentAccount = account;
    self.currentType = thirdType;
    
    if (bReqFinished) {
        if ([_lbDelegate respondsToSelector:@selector(LBRequestStart)])
            [_lbDelegate LBRequestStart];
        
        [[NetWorkManage shareSingleNetWork] reqThirdLogin:self account:account thirdType:thirdType finishedCallback:@selector(requestLoginFinished:) failedCallback:@selector(requestLoginFailed:)];
        
        bReqFinished = NO;
        
    }
}


- (void)requestLoginFinished:(id)result{
    
    bReqFinished = YES;
    
    if ([_lbDelegate respondsToSelector:@selector(LBRequestFinished)])
        [_lbDelegate LBRequestFinished];
    
    UserParser *userParser = [[[UserParser alloc] init] autorelease];
    if ([userParser parseBaseIsOk:result]) {
        
        NSDictionary* dic = [result objectForKey:@"data"];
        if ([[dic allKeys] containsObject:@"user"]) {
            
            if ([dic objectForKey:@"user"]) {
                //该账号已经有ID
                TJRUser *user = [userParser parserMyInfoJson:[dic objectForKey:@"user"]];
                
                NSString *token = [dic objectForKey:@"token"];
                user.token = token.length>0?token:@"";
                
                if (user.userId.length > 0) {
                    
                    user.type = self.currentType;
                    user.userAccount = self.currentAccount;
                    user.password = self.currentPassword;
                    user.phone = dic[@"user"][@"phone"];
                    user.email = dic[@"user"][@"email"];
                    [LoginSQLModel insertLoginInfo:user];
                    
                    [LoginBase setRootLoginUser:user];
                    //进入对应页面
                    if ([_lbDelegate respondsToSelector:@selector(LBLoginInto:)])
                        [_lbDelegate LBLoginInto:user];
                    
                }else{
                    [self showToast:NSLocalizedStringForKey(@"不存在该用户")];
                    [self logout];
                    return;
                }
            }

        }
    }else{
        NSString* str = @"";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        NSString* code = [NSString stringWithFormat:@"%@",[result objectForKey:@"code"]];
        if (![code isEqualToString:@"40016"]) {
            if (str.length>0) {
                [self showToast:str];
            }else{
                [self showToast:NSLocalizedStringForKey(@"登录失败!")];
            }
        }
        if ([_lbDelegate respondsToSelector:@selector(LBNeedCode:)]) {
            [_lbDelegate LBNeedCode:code];
        }
    }
}

- (void)requestLoginFailed:(id)result{
    bReqFinished = YES;
    if ([_lbDelegate respondsToSelector:@selector(LBRequestFaild)])
        [_lbDelegate LBRequestFaild];
    
    [self showToast:NSLocalizedStringForKey(@"登录失败!")];
}


//NO 表示没有数据
- (BOOL)getUserLoginInfoFromSQL{
    BOOL success = NO;
    
    TJRUser *user = [[LoginSQLModel selectLoginInfo] retain];
    if (user.userId.length > 0) {
        success = YES;
        [LoginBase setRootLoginUser:user];
    }
    [user release];
    
    return success;
}

/**
 唯一地方设置生成user
 */
+ (void)setRootLoginUser:(TJRUser*)user{
    if (user!=NULL) {
        ((TJRAppDelegate *)[[UIApplication sharedApplication] delegate]).rootController.user = user;
    }
}

+ (TJRUser*)getRootLoginUser{
    if ([[((TJRAppDelegate *)[[UIApplication sharedApplication] delegate])rootController] user] == NULL) {
        TJRUser *user = [[TJRUser alloc]init];
        [LoginBase setRootLoginUser:user];
    }
    return ROOTCONTROLLER_USER;
}

- (void)showToast:(NSString *)text {
    if (text.length>0) {
        UIViewController *topVC = [ROOTCONTROLLER getCurrentTopViewControllerView];

        [[[[iToast makeText:text] setGravity:iToastGravityBottom] setDuration:1500] show:topVC.view];
    }
}

#pragma mark - 退出登陆
- (void)logout
{
    [ROOTCONTROLLER clean];
    
    if ([_lbDelegate respondsToSelector:@selector(LBLoginOut)])
        [_lbDelegate LBLoginOut];
}

- (void)dealloc {
    [_currentAccount release];
    [_currentPassword release];
    [_currentType release];
    [super dealloc];
}

@end
