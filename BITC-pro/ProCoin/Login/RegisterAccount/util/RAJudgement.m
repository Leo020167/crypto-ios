//
//  RAJudgement.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-31.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "RAJudgement.h"
#import "LoginBase.h"
#import "CommonUtil.h"
#import "UserParser.h"
#import "NetWorkManage+Security.h"

#define kRegexRegisterUserName @"^[\u4E00-\u9FA5A-Za-z0-9_]+$"
#define kRegexRegisterAccount  @"[1+][0-9]{10}"
#define kRegexSecurityCode	   @"^[0-9]*$"
#define kRegexPassWord		   @"^([A-Z]|[a-z]|[0-9]|[`~!@#$%^&*()+=|{}':;',\\\\[\\\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“'。，、？]).{5,}"
#define kRegexPassWordNumLetter     @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$"

#define kDelayTime			   60

@implementation RAJudgement
@synthesize raDelegate;
@synthesize securityCodeBtn;
@synthesize myTimer;

- (void)dealloc {
	[myTimer invalidate];
	self.myTimer = nil;
	[myTimer release];
	[securityCodeBtn release];
	[super dealloc];
}

/**
 *  判断用户名是否符合规则：昵称不能包含特殊字符，可以是汉字，数字和字母
 *  @returns 是否正确
 */
- (BOOL)judgeUserName:(NSString *)userName {
	BOOL correct = NO;

	if (userName.length == 0) {
		if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"请输入用户名!")];
    }  else {
		NSPredicate *pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kRegexRegisterUserName];
		// 利用正则表达式检查账号是否合格
		if ([pred evaluateWithObject:userName]) {
			correct = YES;
		} else {
			if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"昵称不能包含特殊字符!")];
		}
	}
	return correct;
}

/**
 *  判断手机号码是否符合规则
 *  @returns 是否正确
 */
- (BOOL)judgePhoneNum:(NSString *)phoneNum {
    
	BOOL correct = NO;

	if (phoneNum.length == 0) {
		if (raDelegate && [raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"请输入手机号码")];
	} else {
        correct = YES;
//        NSPredicate *pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kRegexRegisterAccount];
//        // 利用正则表达式检查账号是否合格
//        if ([pred evaluateWithObject:phoneNum]) {
//            correct = YES;
//        } else {
//            if (raDelegate && [raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:@"手机号码格式不正确!"];
//        }
	}

	return correct;
}

/**
 *  判断验证码是否符合规则：数字
 *  @returns 是否正确
 */
- (BOOL)judgeSecurityCode:(NSString *)code {
	BOOL correct = NO;

	if (code.length == 0) {
		[raDelegate RAShowToast:NSLocalizedStringForKey(@"请输入验证码")];
	} else {
		NSPredicate *pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kRegexSecurityCode];
		// 利用正则表达式检查验证码格式是否正确
		if ([pred evaluateWithObject:code]) {
			correct = YES;
		} else {
			if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"验证码为数字!")];
		}
	}
	return correct;
}

/**
 *   判断密码是否符合规则：8-18位字母加数字混合规则
 *   @param  password1 passwrod2
 *   @returns 是否正确
 */
- (BOOL)judgePassword:(NSString *)password1 andPassword2:(NSString *)password2 {
    
    BOOL correct = NO;
    if ((password1.length == 0) || (password2.length == 0)) {
        if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"请输入密码")];
    } else {
        if ([password1 isEqualToString:password2]) {
            //NSPredicate *pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kRegexPassWordNumLetter];
            // 利用正则表达式检查密码是否正确
            //if ([pred evaluateWithObject:password1]) {
            if (password1.length >= 8 && password1.length <= 16 ) {
                correct = YES;
            } else {
                if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"密码必须为8到16位!")];
            }
        } else {
            if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"两次密码不一样!")];
        }
    }
    return correct;
}

/**
 *   判断密码是否符合规则：6-15位英文数字组合
 *   @param  password1 passwrod2
 *   @returns 是否正确
 */
//- (BOOL)judgePassword:(NSString *)password1 andPassword2:(NSString *)password2 {
//    BOOL correct = NO;
//
//    if ((password1.length == 0) || (password2.length == 0)) {
//        if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:NSLocalizedStringForKey(@"请输入密码")];
//    } else {
//        if ([password1 isEqualToString:password2]) {
//            NSPredicate *pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kRegexPassWord];
//            // 利用正则表达式检查密码是否正确
//            if ([pred evaluateWithObject:password1]) {
//                correct = YES;
//            } else {
//                if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:@"密码为不少于6位字符!"];
//            }
//        } else {
//            if ([raDelegate respondsToSelector:@selector(RAShowToast:)]) [raDelegate RAShowToast:@"两次密码不一样!"];
//        }
//    }
//    return correct;
//}



#pragma mark - 获取手机验证码
/**
 *   获取验证码，并且锁定发送验证码按钮
 *   @param codeBtn 验证码按钮
 *   @param phoneNum 接受验证码的手机号码
 *   @param countryCode 国家或地区区号
 */
- (void)getSecurityCodeAndControlBtn:(UIButton *)codeBtn phoneNum:(NSString *)phoneNum dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx countryCode:(NSString *)countryCode
{
	self.securityCodeBtn = codeBtn;
	[securityCodeBtn setEnabled:NO];
    
	[securityCodeBtn setTitleColor:RGBA(102, 102, 102, 1) forState:UIControlStateNormal];
    [securityCodeBtn setBackgroundColor:RGBA(238, 238, 238, 1)];
    securityCodeBtn.layer.borderColor = RGBA(238, 238, 238, 1).CGColor;
    securityCodeBtn.layer.borderWidth = 1;
    
	timeCounter = kDelayTime;
	self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDownTheGetSecurityCodeBtn) userInfo:nil repeats:YES];
	if ([raDelegate respondsToSelector:@selector(RAShowHud)]) [raDelegate RAShowHud];
    [[NetWorkManage shareSingleNetWork] reqGetPhoneSMSCode:self phone:phoneNum dragImgKey:dragImgKey locationx:locationx countryCode:countryCode finishedCallback:@selector(reqPhoneSecurityCodeFinished:) failedCallback:@selector(reqPhoneSecurityCodeFailed:)];
}

// 请求验证码成功
- (void)reqPhoneSecurityCodeFinished:(NSDictionary *)jsonDic {
	BOOL success = [[jsonDic objectForKey:@"success"]boolValue];
	NSString *message = [jsonDic objectForKey:@"msg"];
    NSString *code = [NSString stringWithFormat:@"%@", [jsonDic objectForKey:@"code"]];
	if (success) {
        
	} else {
		[myTimer invalidate];
		[self displaySecurityCodeBtn];
	}
	if ([raDelegate respondsToSelector:@selector(RAHideHud)]) [raDelegate RAHideHud];
    if ([raDelegate respondsToSelector:@selector(RAReqFinish:message:)]) [raDelegate RAReqFinish:code message:message];
}

// 请求验证码失败
- (void)reqPhoneSecurityCodeFailed:(NSDictionary *)jsonDic {
	[myTimer invalidate];
	[self displaySecurityCodeBtn];
	if ([raDelegate respondsToSelector:@selector(RAHideHud)]) [raDelegate RAHideHud];
}

//按钮倒计时文本
- (void)countDownTheGetSecurityCodeBtn {
	if (timeCounter) {
		NSString *str = [NSString stringWithFormat:NSLocalizedStringForKey(@"剩余 %ld 秒"), (long)timeCounter];
		[securityCodeBtn setTitle:str forState:UIControlStateNormal];
		timeCounter--;
	} else {
		[self displaySecurityCodeBtn];
		[myTimer invalidate];
		timeCounter = kDelayTime;
	}
}

// 恢复按钮可用
- (void)displaySecurityCodeBtn {
	[securityCodeBtn setEnabled:YES];

	[securityCodeBtn setTitle:NSLocalizedStringForKey(@"重新获取") forState:UIControlStateNormal];
    [securityCodeBtn setTitleColor:RGBA(35,35,35, 1) forState:UIControlStateNormal];
    [securityCodeBtn setBackgroundColor:RGBA(256,256,256,1)];
    securityCodeBtn.layer.borderColor = RGBA(35, 35, 35, 1).CGColor;

	if ([raDelegate respondsToSelector:@selector(RAEnable)]) [raDelegate RAEnable];
}

- (void)close {
	[self.myTimer invalidate];
	self.myTimer = nil;
}

+ (BOOL)isContainNull:(NSString *)str {
	BOOL contain = NO;
	NSRange range1 = [str rangeOfString:@"null"];
	NSRange range2 = [str rangeOfString:@"NULL"];

	if ((range1.length > 0) || (range2.length > 0)) contain = YES;
	return contain;
}

@end
