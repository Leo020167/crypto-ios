//
//  NetWorkManage+User.m
//  TJRtaojinroad
//
//  Created by taojinroad on 10/16/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage+User.h"
#import "CommonUtil.h"

#define URL_API_USER_HOME_PAGE                          @"user/homePage"
#define URL_API_USER_MY_COIN                            @"user/myCoin"
#define URL_API_USER_UPDATE_INFO                        @"user/updateUserInfo"
#define URL_API_USER_SECURITY_UPDATE_PASS               @"user/security/updateUserPass"
#define URL_API_USER_SECURITY_PAY_PASS                  @"user/security/setPayPass"
#define URL_API_USER_SECURITY_CHECKIDENTITY             @"user/security/checkIdentity"
#define URL_API_USER_SECURITY_CHANGEPHONETWO            @"user/security/changePhoneTwo"

#define URL_API_MSESSAGE_FIND                           @"message/find"

#define URL_API_USER_IDENTITY_GET                       @"identity/get"
#define URL_API_USER_IDENTITY_SUBMIT                    @"identity/submit"


@implementation NetWorkManage (User)


#pragma mark - 拼接user的URL
- (NSString *)fullUserUrl:(NSString *)apiUrl {
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}


/** 获取个人主页页面信息*/
- (void)reqPersonalHomepageInfo:(id)delegate targetUid:(NSString *)targetUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullUserUrl:URL_API_USER_HOME_PAGE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"targetUid" value:targetUid], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 更新个人信息(名称、性别，描述，头像)*/
- (void)reqMyHomeUploadMyInfoWithFile:(id)delegate name:(NSString *)name selfDescription:(NSString *)selfDescription sex:(NSString *)sex birthday:(NSString *)birthday headFileName:(NSString *)headFileName finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    [taojinHttpBase uploadFileToServer:[self fullUserUrl:URL_API_USER_UPDATE_INFO]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"userName" value:name],
                                       [BasicNameValuePair setName:@"birthday" value:birthday],
                                       [BasicNameValuePair setName:@"describes" value:selfDescription],
                                       [BasicNameValuePair setName:@"sex" value:sex], nil]
                                files:[self fetchUrlFiles:
                                       [BasicNameValuePair setName:@"headUrlFile" value:headFileName], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];

}

- (void)reqMyHomeUploadMyInfo:(id)delegate name:(NSString *)name selfDescription:(NSString *)selfDescription sex:(NSString *)sex birthday:(NSString *)birthday headFileName:(NSString *)headFileName finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    if(!checkIsStringWithAnyText(name)){
        name = @"";
    }
    if(!checkIsStringWithAnyText(selfDescription)){
        selfDescription = @"";
    }
    if(!checkIsStringWithAnyText(sex)){
        sex = @"0";
    }
    if(!checkIsStringWithAnyText(birthday)){
        birthday = @"";
    }
    if(!checkIsStringWithAnyText(headFileName)){
        headFileName = @"";
    }
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_UPDATE_INFO]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"userName" value:name],
                                        [BasicNameValuePair setName:@"birthday" value:birthday],
                                        [BasicNameValuePair setName:@"describes" value:selfDescription],
                                        [BasicNameValuePair setName:@"sex" value:sex],
                                        [BasicNameValuePair setName:@"headUrl" value:headFileName], nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    
}

/** 获取我的消息*/
- (void)reqUserMyMsg:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_MSESSAGE_FIND]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo], nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 修改密码*/
- (void)reqModifyPassword:(id)delegate oldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_SECURITY_UPDATE_PASS]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"oldUserPass" value:oldPwd],
                                       [BasicNameValuePair setName:@"newUserPass" value:newPwd],
                                       [BasicNameValuePair setName:@"configUserPass" value:newPwd],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 身份验证*/
- (void)reqUserCheckIdentity:(id)delegate phone:(NSString *)phone smsCode:(NSString *)smsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_SECURITY_CHECKIDENTITY]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"phone" value:phone],
                                       [BasicNameValuePair setName:@"smsCode" value:smsCode],
                                       [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                       [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 设置支付密码*/
- (void)reqUserSetPayPass:(id)delegate payPass:(NSString *)payPass configPayPass:(NSString *)configPayPass oldPhone:(NSString *)oldPhone oldSmsCode:(NSString *)oldSmsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {

    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_SECURITY_PAY_PASS]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"payPass" value:payPass],
                                       [BasicNameValuePair setName:@"configPayPass" value:configPayPass],
                                       [BasicNameValuePair setName:@"oldPhone" value:oldPhone],
                                       [BasicNameValuePair setName:@"oldSmsCode" value:oldSmsCode],
                                       [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                       [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 更换手机验证第2步*/
- (void)reqUserChangePhoneTwo:(id)delegate newPhone:(NSString *)newPhone newCountryCode:(NSString *)newCountryCode newSmsCode:(NSString *)newSmsCode oldPhone:(NSString *)oldPhone oldSmsCode:(NSString *)oldSmsCode dragImgKey:(NSString *)dragImgKey locationx:(NSInteger)locationx finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_SECURITY_CHANGEPHONETWO]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"newPhone" value:newPhone],
                                       [BasicNameValuePair setName:@"newCountryCode" value:newCountryCode],
                                       [BasicNameValuePair setName:@"newSmsCode" value:newSmsCode],
                                       [BasicNameValuePair setName:@"oldPhone" value:oldPhone],
                                       [BasicNameValuePair setName:@"oldSmsCode" value:oldSmsCode],
                                       [BasicNameValuePair setName:@"dragImgKey" value:dragImgKey],
                                       [BasicNameValuePair setName:@"locationx" value:[NSString stringWithFormat:@"%@", @(locationx)]],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 获取实名认证信息*/
- (void)reqUserGetIdentityAuthen:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_IDENTITY_GET]
                               params:[self fetchUrlParam:nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 提交实名认证*/
- (void)reqUserIdentitySubmit:(id)delegate name:(NSString *)name certNo:(NSString *)certNo frontImgUrl:(NSString *)frontImgUrl backImgUrl:(NSString *)backImgUrl  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed {
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_IDENTITY_SUBMIT]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"name" value:name],
                                       [BasicNameValuePair setName:@"certNo" value:certNo],
                                       [BasicNameValuePair setName:@"frontImgUrl" value:frontImgUrl],
                                       [BasicNameValuePair setName:@"backImgUrl" value:backImgUrl],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


/** 我的学分*/
- (void)reqGetMyCoin:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    
    [taojinHttpBase doHttpPOSTForJson:[self fullUserUrl:URL_API_USER_MY_COIN]
                               params:[self fetchUrlParam:nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


@end
