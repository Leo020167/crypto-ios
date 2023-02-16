//
//  NetWorkManage+User.h
//  TJRtaojinroad
//
//  Created by taojinroad on 10/16/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage.h"

@interface NetWorkManage (User)

/** 获取个人主页页面信息*/
- (void)reqPersonalHomepageInfo:(id)delegate targetUid:(NSString *)targetUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 更新个人信息(名称、性别，描述，头像)*/
- (void)reqMyHomeUploadMyInfoWithFile:(id)delegate name:(NSString *)name selfDescription:(NSString *)selfDescription sex:(NSString *)sex birthday:(NSString *)birthday headFileName:(NSString *)headFileName finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
- (void)reqMyHomeUploadMyInfo:(id)delegate name:(NSString *)name selfDescription:(NSString *)selfDescription sex:(NSString *)sex birthday:(NSString *)birthday headFileName:(NSString *)headFileName finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取我的消息*/
- (void)reqUserMyMsg:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 修改密码*/
- (void)reqModifyPassword:(id)delegate oldPwd:(NSString *)old newPwd:(NSString *)newPwd finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 身份验证*/
- (void)reqUserCheckIdentity:(id)delegate phone:(NSString *)phone smsCode:(NSString *)smsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置支付密码*/
- (void)reqUserSetPayPass:(id)delegate payPass:(NSString *)payPass configPayPass:(NSString *)configPayPass oldPhone:(NSString *)oldPhone oldSmsCode:(NSString *)oldSmsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 更换手机验证第2步*/
- (void)reqUserChangePhoneTwo:(id)delegate newPhone:(NSString *)newPhone newCountryCode:(NSString *)newCountryCode newSmsCode:(NSString *)newSmsCode oldPhone:(NSString *)oldPhone oldSmsCode:(NSString *)oldSmsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取实名认证信息*/
- (void)reqUserGetIdentityAuthen:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 提交实名认证*/
- (void)reqUserIdentitySubmit:(id)delegate name:(NSString *)name certNo:(NSString *)certNo frontImgUrl:(NSString *)frontImgUrl backImgUrl:(NSString *)backImgUrl  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 我的学分*/
- (void)reqGetMyCoin:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end
