//
//  SinaWeiboLogin.h
//  TJRtaojinroadHD
//
//  Created by taojinroad on 14-11-13.
//  Copyright (c) 2014年 taojinroad. All rights reserved.
//

#import "TJRBaseObj.h"
#import "TJRUser.h"
#import <WeiboSDK.h>

@protocol SinaWeiboLoginDelegate <NSObject>

@optional
- (void)sinaWeiboLoginFinish:(NSString *)openId accessToken:(NSString*)accessToken;
- (void)sinaweiboLogInDidCancel;
- (void)sinaweiboLogInDidFailWithError;
- (void)sinaweiboAccessTokenInvalidOrExpired;
@end

@interface SinaWeiboLogin : TJRBaseObj<WeiboSDKDelegate>
@property (copy, nonatomic) NSString *sinaWeiboAccessToken;/* 接口调用凭证 */
@property (assign, nonatomic) NSInteger sinaWeiboExpiresIn;/* access_token接口调用凭证超时时间，单位（秒） */
@property (copy, nonatomic) NSString *sinaWeiboRefreshToken;	/* 用户刷新access_token */
@property (copy, nonatomic) NSString *sinaWeiboOpenId;	/* 用户id(微博用户唯一) */
@property (assign, nonatomic) id <SinaWeiboLoginDelegate> delegate;

- (void)login;

@end
