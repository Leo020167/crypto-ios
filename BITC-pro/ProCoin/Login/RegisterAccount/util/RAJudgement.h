//
//  RAJudgement.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-31.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//  主要处理文本的格式判断是否符合规则

#import <Foundation/Foundation.h>
#import "TJRBaseViewController.h"
#import "NetWorkManage.h"

@protocol RAJudgementDelegate <NSObject>

@required
- (void)RAShowToast:(NSString *)message;
@optional
- (void)RAShowHud;
- (void)RAHideHud;
- (void)RAReqFinish:(NSString*)code message:(NSString *)message;
- (void)RAEnable;
@end

@interface RAJudgement : NSObject {
	UIButton *securityCodeBtn;
	NSTimer *myTimer;
	NSInteger timeCounter;
}

@property (assign, nonatomic)   id <RAJudgementDelegate> raDelegate;
@property (retain, nonatomic)   UIButton *securityCodeBtn;
@property (retain, nonatomic)   NSTimer *myTimer;
/**
 *  判断用户名是否符合规则：2-5个中文字符
 *  @returns 是否正确
 */
- (BOOL)judgeUserName:(NSString *)userName;

/**
 *  判断手机号码是否符合规则
 *  @returns 是否正确
 */
- (BOOL)judgePhoneNum:(NSString *)phoneNum;

/**
 *  判断验证码是否符合规则：4位数字
 *  @returns 是否正确
 */
- (BOOL)judgeSecurityCode:(NSString *)code;



/**
 *   判断密码是否符合规则：6-15位英文数字组合
 *   @param  password1 passwrod2
 *   @returns 是否正确
 */
//- (BOOL)judgePassword:(NSString *)password1 andPassword2:(NSString *)password2;

/**
 *   判断密码是否符合规则：8-18位字母加数字混合规则
 *   @param  password1 passwrod2
 *   @returns 是否正确
 */
- (BOOL)judgePassword:(NSString *)password1 andPassword2:(NSString *)password2;




#pragma mark - 获取手机验证码
/**
 *  获取验证码，并且锁定发送验证码按钮
 *  @param codeBtn 验证码按钮
 *  @param phoneNum 接受验证码的手机号码
 *   @param countryCode 国家或地区区号
 */
- (void)getSecurityCodeAndControlBtn:(UIButton *)codeBtn phoneNum:(NSString *)phoneNum dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx countryCode:(NSString *)countryCode;

+ (BOOL)isContainNull:(NSString *)str;

- (void)close;
@end
