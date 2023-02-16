//
//  ShareToWeixin.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-4-15.
//  Copyright (c) 2018年 蓝跳蚤. All rights reserved.
//

#import "ShareToWeixin.h"
#import "CommonUtil.h"
#import "TTCacheManager.h"
#import "TJRBaseViewController.h"
#import "ShareButton.h"
#import <WXApiObject.h>
#import <WXApi.h>

@interface ShareToWeixin()

@end

@implementation ShareToWeixin

static BOOL isRegisterApp;


#pragma mark - 检测微信是否能够分享

/**
 *    检测微信是否能够分享
 *    @returns
 */
+ (BOOL)checkWXCanShare {
	if (!isRegisterApp) {
		[WXApi registerApp:WXAppId];// 向微信注册
		isRegisterApp = YES;
	}

	BOOL isWXAppInstalled = [WXApi isWXAppInstalled];	// 检查微信是否已被用户安装

	if (!isWXAppInstalled) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享微信失败" message:@"您没有安装微信,请先安装微信" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"确定") otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return NO;
	}

	BOOL isWXAppSupportApi = [WXApi isWXAppSupportApi];	// 判断当前微信的版本是否支持OpenApi

	if (!isWXAppSupportApi) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享微信失败" message:@"您微信版本太低,不支持分享,请安装更高版本的微信" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"确定") otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return NO;
	}

	return isWXAppInstalled && isWXAppSupportApi;
}

#pragma mark - 发送文本消息给微信

/**
 *    发送文本消息给微信
 *    @param text 内容
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendTextContentWithText:(NSString *)text isSession:(BOOL)isSession {
	if (!isRegisterApp) {
		[WXApi registerApp:WXAppId];// 向微信注册
		isRegisterApp = YES;
	}

	SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
	req.bText = YES;
	req.text = text;
	req.scene = isSession ? WXSceneSession : WXSceneTimeline;
	[WXApi sendReq:req];
}

#pragma mark - 发送Photo消息给微信

/**
 *    发送Photo消息给微信
 *    @param image 要发的图片
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendImageContentWithImage:(UIImage *)image isSession:(BOOL)isSession {
	if (!isRegisterApp) {
        if (!image) return;
		[WXApi registerApp:WXAppId];// 向微信注册
		isRegisterApp = YES;
	}

	WXMediaMessage *message = [WXMediaMessage message];
	[message setThumbImage:image];	// 图片Icon

	WXImageObject *ext = [WXImageObject object];
	ext.imageData = UIImagePNGRepresentation(image);
	message.mediaObject = ext;
	SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
	req.bText = NO;
	req.message = message;
	req.scene = isSession ? WXSceneSession : WXSceneTimeline;
	[WXApi sendReq:req];
}

#pragma mark - 发送Music消息给微信

/**
 *    发送Music消息给微信
 *    @param title 标题
 *    @param description 描述
 *    @param musicImageName 音乐图片
 *    @param musicUrl 音乐网页
 *    @param musicDataUrl
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendMusicContentWithTitle:(NSString *)title description:(NSString *)description musicImageName:(NSString *)musicImageName musicUrl:(NSString *)musicUrl musicDataUrl:(NSString *)musicDataUrl isSession:(BOOL)isSession {
	if (!isRegisterApp) {
		[WXApi registerApp:WXAppId];// 向微信注册
		isRegisterApp = YES;
	}

	WXMediaMessage *message = [WXMediaMessage message];
	message.title = title;
	message.description = description;
	[message setThumbImage:[UIImage imageNamed:musicImageName]];
	WXMusicObject *ext = [WXMusicObject object];
	ext.musicUrl = musicUrl;
	ext.musicDataUrl = musicDataUrl;
	message.mediaObject = ext;
	SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
	req.bText = NO;
	req.message = message;
	req.scene = isSession ? WXSceneSession : WXSceneTimeline;
	[WXApi sendReq:req];
}

#pragma mark - 发送News消息给微信

/**
 *     发送News消息给微信
 *    @param title 标题
 *    @param description 描述
 *    @param newsImageName 新闻图片
 *    @param webpageUrl 新闻网页
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendNewsContentWithTitle:(NSString *)title description:(NSString *)description newsImageName:(NSString *)newsImageName webpageUrl:(NSString *)webpageUrl isSession:(BOOL)isSession {
	if (!isRegisterApp) {
		[WXApi registerApp:WXAppId];    // 向微信注册
		isRegisterApp = YES;
	}
    
	WXMediaMessage *message = [WXMediaMessage message];
	message.title = title;
	message.description = description;
	UIImage *iconImage;

	if (!newsImageName || (newsImageName.length == 0)) {
        // 没有图片时,就用App的Icon
		iconImage = [UIImage imageNamed:@"AppIcon57x57"];
	} else {
        
        NSData *data = [TTCacheManager dataForURL:newsImageName];
        if (data) {
            iconImage = [UIImage imageWithData:data];
        }else{
            // 图片为App的本地文件
            NSString *filePath = [[NSBundle mainBundle] pathForResource:newsImageName ofType:@"png"];
            if (!filePath) {
                filePath = [CommonUtil TTPathForDocumentsResourceEtag:newsImageName];
            }
            iconImage = [UIImage imageWithContentsOfFile:filePath];
        }
	}

	[message setThumbImage:iconImage];
	WXWebpageObject *ext = [WXWebpageObject object];
	ext.webpageUrl = webpageUrl;
	message.mediaObject = ext;
	SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
	req.bText = NO;
	req.message = message;
	req.scene = isSession ? WXSceneSession : WXSceneTimeline;
	[WXApi sendReq:req];
}


- (void)dealloc {
    RELEASE(_shareUrl);
    RELEASE(_detailText);
    [super dealloc];
}


@end

