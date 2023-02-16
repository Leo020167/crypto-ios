//
//  NetWorkManage+Security.m
//  Perval
//
//  Created by taojinroad on 18/05/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage+Security.h"
#import "CommonUtil.h"

#define URL_API_SECURITY_DYNAMIC_DNS                @"security/getDynamicDns"
#define URL_API_SECURITY_LOGIN                      @"security/login"
#define URL_API_SECURITY_LOGIN_VCODE                @"security/login_vcode"
#define URL_API_SECURITY_LOGIN_THIRD                @"security/login_third"
#define URL_API_SECURITY_REGISTER                   @"security/register"
#define URL_API_SECURITY_BIND_PHONE                 @"security/bind_phone"
#define URL_API_USER_BINE_THIRD                     @"user/bind_third"
#define URL_API_USER_INFO_THIRD                     @"user/info_third"
#define URL_API_USER_DEL_BIND_THIRD                 @"user/del_bind_third"

#define URL_API_UPLOAD_USERLOGO                     @"upload/userLogo"
#define URL_API_SMS_GET                             @"sms/get"
#define URL_API_SMS_PHONE_VERIFY                    @"sms_phone/verify"
#define URL_API_SECURITY_FORGET_PASS                @"security/forgetPass"
#define URL_API_SECURITY_OUTDRAGIMG                 @"security/outDragImg"
#define URL_API_SECURITY_CHECKDRAGIMG               @"security/checkDragImg"

#define URL_API_APPLE_TOKEN_CANCEL                  @"apple/cancel"
#define URL_API_APPLE_TOKEN_UPLOAD                  @"apple/upload"

#define URL_API_ACT_BOOT_PAGE                       @"config/bootPage"

#define URL_API_EMAIL_GET                           @"email/get"
#define URL_API_USER_CHECKEMAILCODE                 @"user/security/checkEmailCode"
#define URL_API_USER_UPDATEEMAIL                    @"user/security/updateEmail"

@implementation NetWorkManage (Security)


#pragma mark - 拼接sign的URL
- (NSString *)fullSecurityUrl:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

/** 特殊情况接口，单独开一个方法获取其链接*/
- (NSString *)fullSpecialSecurityUrl:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://upload.%@/procoin-file/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}


/** 重要请求，app能否成功获取数据都要这个接口支持，在app启动必须调用*/
#pragma mark - 动态获取DNS，app里面所有网络接口都需要这个*/
- (void)reqAppDynamicDNS:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullSpecialSecurityUrl:URL_API_SECURITY_DYNAMIC_DNS]
                                params:[self fetchUrlParam:nil]
                                delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 手机号码使用密码登陆
- (void)reqLogin:(id)delegate accountPhone:(NSString *)accountPhone userPass:(NSString *)userPass smsCode:(NSString *)smsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    if ([accountPhone containsString:@"@"]) {
        
            [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_LOGIN]
                                      params:[self fetchUrlParam:[BasicNameValuePair setName:@"phone" value:@""],
                                              [BasicNameValuePair setName:@"email" value:accountPhone],
                                              [BasicNameValuePair setName:@"userPass" value:userPass],
                                              [BasicNameValuePair setName:@"smsCode" value:smsCode],
                                              [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                              [BasicNameValuePair setName:@"type" value:@"2"],
                                              [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                                    delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    }else{
        [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_LOGIN]
                                  params:[self fetchUrlParam:
                                          [BasicNameValuePair setName:@"phone" value:accountPhone],
                                          [BasicNameValuePair setName:@"userPass" value:userPass],
                                          [BasicNameValuePair setName:@"smsCode" value:smsCode],
                                          [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                          [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                                delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    }
}

#pragma mark - 第三方账号登陆
- (void)reqThirdLogin:(id)delegate account:(NSString *)account thirdType:(NSString *)thirdType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    NSString* sign = [CommonUtil getRSA64SignString:account];
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_LOGIN_THIRD]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"account" value:sign],
                                       [BasicNameValuePair setName:@"third_type" value:thirdType], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 注册用户
- (void)reqRegisterNewUser:(id)delegate countryCode:(NSString *)countryCode phone:(NSString *)phone smsCode:(NSString *)smsCode sex:(NSString *)sex userName:(NSString *)userName userPass:(NSString *)userPass inviteCode:(NSString *)inviteCode headUrl:(NSString *)headUrl describes:(NSString*)describes dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {

    if ([phone containsString:@"@"]) {
        [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_REGISTER]
                                    params:[self fetchUrlParam:
                                            [BasicNameValuePair setName:@"type" value:@"2"],
                                            [BasicNameValuePair setName:@"email" value:phone],
                                            [BasicNameValuePair setName:@"phone" value:@""],
                                            [BasicNameValuePair setName:@"userName" value:userName],
                                            [BasicNameValuePair setName:@"sex" value:sex],
                                            [BasicNameValuePair setName:@"smsCode" value:smsCode],
                                            [BasicNameValuePair setName:@"userPass" value:userPass],
                                            [BasicNameValuePair setName:@"configUserPass" value:userPass],
                                            [BasicNameValuePair setName:@"inviteCode" value:inviteCode],
                                            [BasicNameValuePair setName:@"headUrl" value:headUrl],
                                            [BasicNameValuePair setName:@"describes" value:describes],
                                            [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                            [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                                  delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    }else{
        [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_REGISTER]
                                    params:[self fetchUrlParam:
                                            [BasicNameValuePair setName:@"phone" value:phone],
                                            [BasicNameValuePair setName:@"userName" value:userName],
                                            [BasicNameValuePair setName:@"sex" value:sex],
                                            [BasicNameValuePair setName:@"smsCode" value:smsCode],
                                            [BasicNameValuePair setName:@"userPass" value:userPass],
                                            [BasicNameValuePair setName:@"configUserPass" value:userPass],
                                            [BasicNameValuePair setName:@"inviteCode" value:inviteCode],
                                            [BasicNameValuePair setName:@"headUrl" value:headUrl],
                                            [BasicNameValuePair setName:@"describes" value:describes],
                                            [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                            [BasicNameValuePair setName:@"countryCode" value:countryCode],
                                            [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                                  delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    }
}

#pragma mark - 获取国家地区列表
- (void)reqCountryCodeInfoList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullSecurityUrl:@"config/countryCodeInfoList"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 第三方账号绑定手机号码并注册
- (void)reqBindPhone:(id)delegate phoneAccount:(NSString *)phoneAccount thirdType:(NSString *)thirdType account:(NSString *)account name:(NSString *)name  headUrl:(NSString *)headUrl sex:(NSString *)sex vcode:(NSString *)vcode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {

    NSString* sign = [CommonUtil getRSA64SignString:account];
    NSString* str  = [NSString stringWithFormat:@"{\"phone\":\"%@\",\"vcode\":\"%@\"}",phoneAccount,vcode];
    NSString* signVcode = [CommonUtil getRSA64SignString:str];
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_BIND_PHONE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"account_phone" value:phoneAccount],
                                       [BasicNameValuePair setName:@"account" value:sign],
                                       [BasicNameValuePair setName:@"sex" value:sex],
                                       [BasicNameValuePair setName:@"nickname" value:name],
                                       [BasicNameValuePair setName:@"head_url" value:headUrl],
                                       [BasicNameValuePair setName:@"sign_vcode" value:signVcode],
                                       [BasicNameValuePair setName:@"third_type" value:thirdType], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 原有手机账号绑定第三方账号
- (void)reqBindThird:(id)delegate userId:(NSString *)userId thirdType:(NSString *)thirdType   account:(NSString *)account name:(NSString *)name  headUrl:(NSString *)headUrl sex:(NSString *)sex finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    NSString* sign = [CommonUtil getRSA64SignString:account];
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_USER_BINE_THIRD]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"account" value:sign],
                                       [BasicNameValuePair setName:@"sex" value:sex],
                                       [BasicNameValuePair setName:@"nickname" value:name],
                                       [BasicNameValuePair setName:@"head_url" value:headUrl],
                                       [BasicNameValuePair setName:@"third_type" value:thirdType], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 解除第三方绑定
- (void)reqDeleteThirdBind:(id)delegate thirdType:(NSString *)thirdType userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_USER_DEL_BIND_THIRD]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"third_type" value:thirdType],
                                       [BasicNameValuePair setName:@"user_id" value:userId], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取绑定的第三方关联信息
- (void)reqThirdInfo:(id)delegate userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_USER_INFO_THIRD]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"user_id" value:userId], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 上传Push token
- (void)reqPushToken:(id)delegateObj userId:(NSString *)userId token:(NSString *)token finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_APPLE_TOKEN_UPLOAD]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"userId" value:userId],
                                       [BasicNameValuePair setName:@"appleToken" value:token], nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 退出登录
- (void)reqLogout:(id)delegate userId:(NSString *)userId pushToken:(NSString *)pushToken finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {

    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_APPLE_TOKEN_CANCEL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"userId" value:userId],
                                       [BasicNameValuePair setName:@"appleToken" value:pushToken], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取手机验证码
- (void)reqGetPhoneSMSCode:(id)delegate phone:(NSString *)phone dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx countryCode:(NSString *)countryCode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    if ([phone containsString:@"@"]) {
        [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SMS_GET]
                                   params:[self fetchUrlParam:
                                           [BasicNameValuePair setName:@"sendAddr" value:phone],
                                           [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                           [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]], [BasicNameValuePair setName:@"type" value:@"2"], nil]
                                 delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    }else{
        [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SMS_GET]
                                   params:[self fetchUrlParam:
                                           [BasicNameValuePair setName:@"sendAddr" value:phone],
                                           [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                           [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],
                                           [BasicNameValuePair setName:@"countryCode" value:countryCode], [BasicNameValuePair setName:@"type" value:@"1"], nil]
                                 delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    }
}


#pragma mark - 忘记密码
- (void)reqForgotPasswordUpdatePwd:(id)delegate smsCode:(NSString *)smsCode phone:(NSString *)phone userPass:(NSString *)userPass dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_FORGET_PASS]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"phone" value:phone],
                                       [BasicNameValuePair setName:@"smsCode" value:smsCode],
                                       [BasicNameValuePair setName:@"userPass" value:userPass],
                                       [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                       [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取广告信息
- (void)reqADInfo:(id)delegateObj userId:(NSString *)userId token:(NSString *)token finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_ACT_BOOT_PAGE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"userId" value:userId],
                                       [BasicNameValuePair setName:@"token" value:token],nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取拖动图片
- (void)reqGetPuzzlePic:(id)delegateObj finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSpecialSecurityUrl:URL_API_SECURITY_OUTDRAGIMG]
                               params:[self fetchUrlParam:nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 验证拖动图片
- (void)reqCheckPuzzlePic:(id)delegateObj dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_SECURITY_CHECKDRAGIMG]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                       [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 获取邮箱验证码
- (void)reqGetEmailCode:(id)delegateObj emailStr:(NSString *)emailStr finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_EMAIL_GET]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"email" value:emailStr],nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 校验邮箱验证码
- (void)reqCheckEmailCode:(id)delegateObj emailStr:(NSString *)emailStr emailCode:(NSString *)emailCode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_USER_CHECKEMAILCODE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"email" value:emailStr],
                                       [BasicNameValuePair setName:@"code" value:emailCode],nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 更新邮箱
- (void)reqUpdateEmail:(id)delegateObj emailStr:(NSString *)emailStr emailCode:(NSString *)emailCode finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullSecurityUrl:URL_API_USER_UPDATEEMAIL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"email" value:emailStr],
                                       [BasicNameValuePair setName:@"code" value:emailCode],nil]
                             delegate:delegateObj httpFinish:cbFinished httpFaild:cbFailed];
}



@end
