//
//  SinaWeiboLogin.m
//  TJRtaojinroadHD
//
//  Created by taojinroad on 14-11-13.
//  Copyright (c) 2014年 taojinroad. All rights reserved.
//

#import "SinaWeiboLogin.h"

@implementation SinaWeiboLogin

- (id)init{
    self = [super init];
    if (self) {
        [WeiboSDK enableDebugMode:NO];
        [WeiboSDK registerApp:SinaWeiboAppKey];
    }
    return self;
}

/**
 *   微博登陆
 */
- (void)login {
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = SinaWeiboRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}


#pragma mark - SinaWeibo Delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
    }
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    // 登录
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        switch (response.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:
            {
                self.sinaWeiboOpenId = [(WBAuthorizeResponse *)response userID];
                self.sinaWeiboAccessToken = [(WBAuthorizeResponse *)response accessToken];
                
                if (_delegate && [_delegate respondsToSelector:@selector(sinaWeiboLoginFinish:accessToken:)]) {
                    [_delegate sinaWeiboLoginFinish:_sinaWeiboOpenId accessToken:_sinaWeiboAccessToken];
                }
                break;
            }
            case WeiboSDKResponseStatusCodeUserCancel:
            case WeiboSDKResponseStatusCodeUserCancelInstall:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(sinaweiboLogInDidCancel)]) {
                    [_delegate sinaweiboLogInDidCancel];
                }
                break;
            }
            case WeiboSDKResponseStatusCodeSentFail:
            case WeiboSDKResponseStatusCodeShareInSDKFailed:
            case WeiboSDKResponseStatusCodeUnsupport:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(sinaweiboLogInDidFailWithError)]) {
                    [_delegate sinaweiboLogInDidFailWithError];
                }
                break;
            }
            case WeiboSDKResponseStatusCodeAuthDeny:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(sinaweiboAccessTokenInvalidOrExpired)]) {
                    [_delegate sinaweiboAccessTokenInvalidOrExpired];
                }
                break;
            }
            default:
                break;
        }
    }
    
    // 分享
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:response.statusCode],@"errCode",LoginAccountTypeSinaWeibo,@"thirdType", nil];
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:@"ShareResp" object:nil userInfo:dic]];

    }

}

@end
