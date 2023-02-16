//
//  WeiXinLogin.h
//  TJRtaojinroad
//
//  Created by 影孤清 on 14-9-5.
//  Copyright (c) 2014年 BPerval. All rights reserved.
//

#import "TJRBaseObj.h"
#import "TJRUser.h"

@protocol WeiXinLoginDelegate <NSObject>

- (void)weiXinLoginStart:(NSInteger)code;
- (void)weiXinLoginFinish:(NSString *)openId accessToken:(NSString*)accessToken;

@end

@interface WeiXinLogin : TJRBaseObj
@property (copy, nonatomic) NSString *weixinCode;
@property (copy, nonatomic) NSString *weixinAccessToken;/* 接口调用凭证 */
@property (assign, nonatomic) NSInteger weixinExpiresIn;/* access_token接口调用凭证超时时间，单位（秒） */
@property (copy, nonatomic) NSString *weixinRefreshToken;	/* 用户刷新access_token */
@property (copy, nonatomic) NSString *weixinOpenId;	/* 用户id(微信用户唯一) */
@property (assign, nonatomic) id <WeiXinLoginDelegate> delegate;

/**
 *    检测微信是否能够分享
 *    @returns
 */
+ (BOOL)checkWXCanShare;
+ (BOOL)checkWXAppInstalled;
/**
 *    微信登陆
 *    @param userInfo 用户信息
 */
- (void)weixinLogin;

- (void)addWeixinNotification;

- (void)removeWeixinNotification;
@end

