//
//  ShareToWeiboOrWeixin.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-4-15.
//  Copyright (c) 2018年 蓝跳蚤. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *    分享内容到微信
 *    @author taojinroad
 */
@interface ShareToWeixin : NSObject {
	
}

@property (copy, nonatomic) NSString *detailText;
@property (copy, nonatomic) NSString *shareUrl;

/**
 *    检测微信是否能够分享
 *    @returns
 */
+ (BOOL)checkWXCanShare;

/**
 *    发送文本消息给微信
 *    @param text 内容
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendTextContentWithText:(NSString *)text isSession:(BOOL)isSession;

/**
 *    发送Photo消息给微信
 *    @param image 要发的图片
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendImageContentWithImage:(UIImage *)image isSession:(BOOL)isSession;

/**
 *    发送Music消息给微信
 *    @param title 标题
 *    @param description 描述
 *    @param musicImageName 音乐图片
 *    @param musicUrl 音乐网页
 *    @param musicDataUrl
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendMusicContentWithTitle:(NSString *)title description:(NSString *)description musicImageName:(NSString *)musicImageName musicUrl:(NSString *)musicUrl musicDataUrl:(NSString *)musicDataUrl isSession:(BOOL)isSession;

/**
 *     发送News消息给微信
 *    @param title 标题
 *    @param description 描述
 *    @param newsImageName 新闻图片
 *    @param webpageUrl 新闻网页
 *    @param isSession YES表示发送到微信会话,NO表示发送到朋友圈
 */
+ (void)sendNewsContentWithTitle:(NSString *)title description:(NSString *)description newsImageName:(NSString *)newsImageName webpageUrl:(NSString *)webpageUrl isSession:(BOOL)isSession;




@end

