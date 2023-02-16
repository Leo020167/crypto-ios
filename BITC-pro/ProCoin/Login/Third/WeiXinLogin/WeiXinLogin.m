//
//  WeiXinLogin.m
//  TJRtaojinroad
//
//  Created by 影孤清 on 14-9-5.
//  Copyright (c) 2014年 BPerval. All rights reserved.
//

#import "WeiXinLogin.h"
#import "iToast.h"
#import "NetWorkManage+Third.h"
#import "TJRBaseViewController.h"
static int WeixinState = 0;	// 微信登陆标志,预防非法登陆

@implementation WeiXinLogin

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/**
 *    检测微信是否安装,是否支持OpenApi
 *    @returns
 */
+ (BOOL)checkWXCanShare {

	BOOL isWXAppInstalled = [WXApi isWXAppInstalled];	// 检查微信是否已被用户安装

	if (!isWXAppInstalled) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"微信授权失败" message:@"您没有安装微信,请先安装微信" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return NO;
	}

	BOOL isWXAppSupportApi = [WXApi isWXAppSupportApi];	// 判断当前微信的版本是否支持OpenApi

	if (!isWXAppSupportApi) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"微信授权失败" message:@"您微信版本太低,不支持微信登陆,请安装更高版本的微信" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return NO;
	}

	return isWXAppInstalled && isWXAppSupportApi;
}

+ (BOOL)checkWXAppInstalled {

    BOOL isWXAppInstalled = [WXApi isWXAppInstalled];	// 检查微信是否已被用户安装
    
    if (!isWXAppInstalled) {
        return NO;
    }
    
    BOOL isWXAppSupportApi = [WXApi isWXAppSupportApi];	// 判断当前微信的版本是否支持OpenApi
    
    if (!isWXAppSupportApi) {
        return NO;
    }
    
    return isWXAppInstalled && isWXAppSupportApi;
}

/**
 *    判断当前微信的版本是否支持OpenApi
 *    @returns
 */
+ (BOOL)checkWXCanOpenApi {
    
    BOOL isWXAppSupportApi = [WXApi isWXAppSupportApi];
    
    if (!isWXAppSupportApi) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"微信授权失败" message:@"您微信版本太低,不支持微信登陆,请安装更高版本的微信" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    return isWXAppSupportApi;
}

/**
 *    微信登陆
 */
- (void)weixinLogin {
	if ( [WXApi isWXAppInstalled] && ![WeiXinLogin checkWXCanOpenApi]) return;

    if (TTIsStringWithAnyText(_weixinRefreshToken) && TTIsStringWithAnyText(_weixinAccessToken)) {    /* 用户信息存在 */
        [self checkWeiXinTokenWithOpenId:_weixinOpenId accessToken:_weixinRefreshToken];
        return;
    }

	SendAuthReq *req = [[[SendAuthReq alloc] init] autorelease];
	req.scope = @"snsapi_userinfo";
	WeixinState = arc4random() % 10000000;
	req.state = [NSString stringWithFormat:@"WeiXinState%d", WeixinState];
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }else if (self.delegate && [self.delegate isKindOfClass:[TJRBaseViewController class]]) { // 用户没有安装微信
        TJRBaseViewController *vc = (TJRBaseViewController *)self.delegate;
        TJRAppDelegate *appDelegate = (TJRAppDelegate *)[[UIApplication sharedApplication] delegate];
        [WXApi sendAuthReq:req viewController:vc delegate:appDelegate];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"微信授权失败" message:@"您没有安装微信,请先安装微信" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

/**
 *    添加微信授权结束后的回调通知
 */
- (void)addWeixinNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinResq:) name:@"WeixinResp" object:nil];
}

/**
 *   移除微信授权结束后的回调通知
 */
- (void)removeWeixinNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeixinResp" object:nil];
}

/**
 *    微信授权结束后回调通知
 *    @param notification
 */
- (void)weixinResq:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;
	SendAuthResp *req = [userInfo objectForKey:@"Resp"];

	int errCode = req.errCode;
	NSString *state = req.state;
	NSString *selfState = [NSString stringWithFormat:@"WeiXinState%d", WeixinState];

	self.weixinCode = req.code;

	if (errCode == 0) {	/* 用户同意 */
		if ([selfState isEqual:state]) {// 正确登陆
			[self getAccessTokenWithCode:_weixinCode];
		} else {// 非法登陆
            [self showToast:@"非法微信登陆"];
		}
	} else if (errCode == -4) {	/* 用户拒绝授权 */
        [self showToast:@"你已拒绝微信授权"];
	} else if (errCode == -2) {	/* 用户取消 */
        [self showToast:@"取消登录"];
	}
}

/**
 *    判断Access_token是否过期
 *    @param openId 用户唯一凭证
 *    @param token  Access_token
 */
- (void)checkWeiXinTokenWithOpenId:(NSString *)openId accessToken:(NSString *)token {
	if (_delegate && [_delegate respondsToSelector:@selector(weiXinLoginStart:)]) {
		[_delegate weiXinLoginStart:0];
	}
	[[NetWorkManage shareSingleNetWork] weixinCheckAccessToken:self weixinOpenId:openId weixinAccessToken:token httpFinish:@selector(weixinCheckFinish:) httpFalid:nil];
}

/**
 *    判断Access_token是否过期
 *    @param json
 *
 *    正确的Json返回结果：
 *    "errcode":0,"errmsg":"ok"
 *
 *    错误的Json返回示例:
 *    "errcode":40003,"errmsg":"invalid openid"
 */
- (void)weixinCheckFinish:(NSDictionary *)json {
	NSInteger errCode = -1;

	if (json) errCode = [[json objectForKey:@"errcode"] integerValue];

	if (errCode == 0) {	/* token没有过期 */
        if (_delegate && [_delegate respondsToSelector:@selector(weiXinLoginFinish:accessToken:)]) {
            [_delegate weiXinLoginFinish:_weixinOpenId accessToken:_weixinAccessToken];
        }
	} else {
		[self refreshAccessTokenWithRefreshToken:_weixinRefreshToken];
	}
}

/**
 *    用refresh_token获取Access_token
 *    @param refreshToken
 */
- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken {
	if (_delegate && [_delegate respondsToSelector:@selector(weiXinLoginStart:)]) {
		[_delegate weiXinLoginStart:0];
	}
	[[NetWorkManage shareSingleNetWork] weixinRefreshToken:self refreshToken:refreshToken httpFinish:@selector(weixinGetTokenFinish:) httpFalid:nil];
}

/**
 *    网络获取Token,使用weixinCode
 *    @param weixinCode
 */
- (void)getAccessTokenWithCode:(NSString *)weixinCode {
	if (_delegate && [_delegate respondsToSelector:@selector(weiXinLoginStart:)]) {
		[_delegate weiXinLoginStart:0];
	}
	[[NetWorkManage shareSingleNetWork] weixinGetAccessToken:self weixinCode:weixinCode httpFinish:@selector(weixinGetTokenFinish:) httpFalid:nil];
}

/**
 *   微信获取token网络成功
 *   @param json
 *   成功返回样例:
 *   "access_token":"ACCESS_TOKEN",	接口调用凭证
 *   "expires_in":7200,   access_token接口调用凭证超时时间，单位（秒）
 *   "refresh_token":"REFRESH_TOKEN",	用户刷新access_token
 *   "openid":"OPENID",  授权用户唯一标识
 *   "scope":"SCOPE"    用户授权的作用域，使用逗号（,）分隔
 *   错误返回样例：
 *   "errcode":40030,"errmsg":"invalid refresh_token"
 *
 */
- (void)weixinGetTokenFinish:(NSDictionary *)json {
	BOOL falid = !json || [json.allKeys containsObject:@"errcode"];

	if (falid) {// 重新授权
		[self weixinLogin];
	} else {
		NSString* refresh_token = [json objectForKey:@"refresh_token"];
		NSString* openid = [json objectForKey:@"openid"];
		NSString* weiXinAccessToken = [json objectForKey:@"access_token"];
        
        self.weixinRefreshToken = refresh_token;
        self.weixinAccessToken = weiXinAccessToken;
        self.weixinOpenId = openid;

		if (_delegate && [_delegate respondsToSelector:@selector(weiXinLoginFinish:accessToken:)]) {
			[_delegate weiXinLoginFinish:openid accessToken:weiXinAccessToken];
		}
	}
    
}

- (void)showToast:(NSString *)text {
	[[[[iToast makeText:text] setGravity:iToastGravityBottom] setDuration:1500] show:ROOTCONTROLLER.navigationController.view];
}

- (void)dealloc {

	RELEASE(_weixinCode);
	RELEASE(_weixinAccessToken);
	RELEASE(_weixinRefreshToken);
	RELEASE(_weixinOpenId);
	[super dealloc];
}

@end

