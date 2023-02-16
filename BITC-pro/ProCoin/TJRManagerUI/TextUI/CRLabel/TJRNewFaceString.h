//
//  TJRNewFaceString.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-12-26.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

#define StringType_Url			@"StringType_Url"
#define StringType_Face			@"StringType_Face"
#define StringType_Fullcode		@"StringType_Fullcode"
#define StringType_StockName	@"StringType_StockName"
#define StringType_StockInfo	@"StringType_StockInfo"
#define StringType_Topic        @"StringType_Topic"

@interface TJRNewFaceString : NSObject
/**
 生成文字的Html
 @param text 文字
 @param color 文字颜色
 @param textSize  文字大小
 @returns
 */
+ (NSString *)faceTextHtml:(NSString *)text color:(NSString *)color textSize:(NSInteger)textSize;

/**
 生成Url的Html
 @param url url文字
 @param color url文字颜色
 @param textSize  url文字大小
 @returns
 */
+ (NSString *)faceUrlHtml:(NSString *)url color:(NSString *)color textSize:(NSInteger)textSize;

/**
 生成可点击Fullcode的Html
 @param name fullcode
 @param data 点击参数
 @param color fullcode颜色
 @param textSize  fullcode文字大小
 @returns
 */
+ (NSString *)faceFullcodeHtml:(NSString *)name data:(NSString *)data color:(NSString *)color textSize:(NSInteger)textSize;

/**
 *    生成可点击Topic的Html
 *    @param topic 话题
 *    @param data 点击参数
 *    @param color fullcode颜色
 *    @param textSize  fullcode文字大小
 *    @returns
 */
+ (NSString *)faceTopicHtml:(NSString *)topic data:(NSString *)data color:(NSString *)color textSize:(NSInteger)textSize;

/**
 生成表情图片的Html(带宽高和偏移量)
 @param image 表情图片名
 @param width 表情宽
 @param height 表情高
 @param xPadding x方向偏移量
 @param yPadding  y方向偏移量
 @returns
 */
+ (NSString *)faceImageHtmlWithImageSizeAndPadding:(NSString *)image imageSize:(CGSize)imageSize padding:(CGPoint)padding;

/**
 生成表情图片的Html(带宽高)
 @param image 表情图片名
 @param width 表情宽
 @param height  表情高
 @returns
 */
+ (NSString *)faceImageHtmlWithImageSize:(NSString *)image imageSize:(CGSize)imageSize;

/**
 生成表情图片的Html(依文字大小来)
 @param image 表情图片名
 @param textSize  文字大小
 @returns
 */
+ (NSString *)faceImageHtmlWithTextSize:(NSString *)image textSize:(NSInteger)textSize;


/**
 *    将输入文字生成html语句(图片大小不用设置,图片大小和文字大小差不多)
 *    @param text 内容
 *    @param textSize 文字字体大小
 *    @param textColor 文字字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @param urlSize url字体大小
 *    @param urlColor url字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @returns html语句
 */
+ (NSString *)spliceAllStringForHtmlWithString:(NSString *)text textSize:(int)textSize textColor:(NSString *)textColor urlSize:(int)urlSize urlColor:(NSString *)urlColor;
/**
 *    将输入文字生成html语句(图片大小要自己设置)
 *    @param text 内容
 *    @param textSize 文字字体大小
 *    @param textColor 文字字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @param imageSize 图片的大小
 *    @param imagePaddingPoint 图片的X Y padding值
 *    @param urlSize url字体大小
 *    @param urlColor url字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @returns html语句
 */
+ (NSString *)spliceAllStringForHtmlWithString:(NSString *)text textSize:(int)textSize imageSize:(CGSize)imageSize imagePaddingPoint:(CGPoint)paddingPoint textColor:(NSString *)textColor urlSize:(int)urlSize urlColor:(NSString *)urlColor;

/**
 *    将输入文字生成html语句
 *    @param text 内容
 *    @param isSpliceFullcode 是否标识出文字里的股票
 *    @param textSize 文字字体大小
 *    @param textColor 文字字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @param imageSize 图片的大小
 *    @param imagePaddingPoint 图片的X Y padding值
 *    @param urlSize url字体大小
 *    @param urlColor url字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @returns html语句
 */
+ (NSString *)spliceAllStringForHtmlWithString:(NSString *)text
									  textSize:(NSInteger)textSize
									 imageSize:(CGSize)imageSize
							 imagePaddingPoint:(CGPoint)paddingPoint
									 textColor:(NSString *)textColor
									   urlSize:(NSInteger)urlSize
									  urlColor:(NSString *)urlColor
                                 isSpliceTopic:(BOOL)isSpliceTopic
                                     topicSize:(NSInteger)topicSize
                                    topicColor:(NSString *)topicColor
							  isSpliceFullcode:(BOOL)isSpliceFullcode
								  fullcodeSize:(NSInteger)fullcodeSize
								 fullcodeColor:(NSString *)fullcodeColor;

/**
	区分文字里面的六连数字(六连数字当作股票代码,是否是真股票就后面判断)
	@param string
 */
+ (void)checkStockDmFromString:(NSString *)string;
#pragma mark - 测试方法
+ (NSString *)testDMWithString:(NSString *)text;
+ (void)faceStringRelease;

/*=====================================================以下方法自己添加,按需要来==============================================================================*/
#pragma mark - 股友吧,主题页面专用
+ (NSString *)faceStringForTalkieTalkiePlazaForDetail:(NSString *)say textColor:(NSString *)textColor;
#pragma mark - 股友吧,解析前面200个符
+ (NSString *)faceStringForTalkieTalkiePlaza:(NSString *)say isCutHeader:(BOOL)isCutHeader isSpliceFullcode:(BOOL)isSpliceFullcode textColor:(NSString *)textColor;
#pragma mark - 广场帖子评论
+ (NSString *)faceStringForTalkieTalkiePlazaComment:(NSString *)say;



#pragma mark - 好友圈所用


#pragma mark - 好友圈帖子内容
+ (NSString *)faceStringForNewFriend:(NSString *)say;

#pragma mark - 股友吧和好友圈帖子评论
+ (NSString *)faceStringForNewFriendComment:(NSString *)say;
@end

