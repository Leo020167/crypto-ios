//
//  NetWorkManage+Security.h
//  Perval
//
//  Created by taojinroad on 18/05/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage.h"

@interface NetWorkManage (Security)

/** 重要请求，app能否成功获取数据都要这个接口支持，在app启动必须调用*/
#pragma mark - 动态获取DNS，app里面所有网络接口都需要这个*/
- (void)reqAppDynamicDNS:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 手机号码使用密码登陆
- (void)reqLogin:(id)delegate accountPhone:(NSString *)accountPhone userPass:(NSString *)userPass smsCode:(NSString *)smsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 第三方账号登陆
- (void)reqThirdLogin:(id)delegate account:(NSString *)account thirdType:(NSString *)thirdType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 注册用户
- (void)reqRegisterNewUser:(id)delegate countryCode:(NSString *)countryCode phone:(NSString *)phone smsCode:(NSString *)smsCode sex:(NSString *)sex userName:(NSString *)userName userPass:(NSString *)userPass inviteCode:(NSString *)inviteCode headUrl:(NSString *)headUrl describes:(NSString*)describes dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取国家地区列表
- (void)reqCountryCodeInfoList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 第三方账号绑定手机号码
- (void)reqBindPhone:(id)delegate phoneAccount:(NSString *)phoneAccount thirdType:(NSString *)thirdType account:(NSString *)account name:(NSString *)name  headUrl:(NSString *)headUrl sex:(NSString *)sex vcode:(NSString *)vcode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed ;

#pragma mark - 原有手机账号绑定第三方账号
- (void)reqBindThird:(id)delegate userId:(NSString *)userId thirdType:(NSString *)thirdType   account:(NSString *)account name:(NSString *)name  headUrl:(NSString *)headUrl sex:(NSString *)sex finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed ;

#pragma mark - 解除第三方绑定
- (void)reqDeleteThirdBind:(id)delegate thirdType:(NSString *)thirdType userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取绑定的第三方关联信息
- (void)reqThirdInfo:(id)delegate userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - Push token
- (void)reqPushToken:(id)delegateObj userId:(NSString *)userId token:(NSString *)token finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 退出登录
- (void)reqLogout:(id)delegate userId:(NSString *)userId pushToken:(NSString *)pushToken finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed ;

#pragma mark - 获取手机验证码
- (void)reqGetPhoneSMSCode:(id)delegate phone:(NSString *)phone dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx countryCode:(NSString *)countryCode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 忘记密码
- (void)reqForgotPasswordUpdatePwd:(id)delegate smsCode:(NSString *)smsCode phone:(NSString *)phone userPass:(NSString *)userPass dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取广告信息
- (void)reqADInfo:(id)delegateObj userId:(NSString *)userId token:(NSString *)token finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取拖动图片
- (void)reqGetPuzzlePic:(id)delegateObj finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 验证拖动图片
- (void)reqCheckPuzzlePic:(id)delegateObj dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取邮箱验证码
- (void)reqGetEmailCode:(id)delegateObj emailStr:(NSString *)emailStr finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 校验邮箱验证码
- (void)reqCheckEmailCode:(id)delegateObj emailStr:(NSString *)emailStr emailCode:(NSString *)emailCode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 更新邮箱
- (void)reqUpdateEmail:(id)delegateObj emailStr:(NSString *)emailStr emailCode:(NSString *)emailCode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end
