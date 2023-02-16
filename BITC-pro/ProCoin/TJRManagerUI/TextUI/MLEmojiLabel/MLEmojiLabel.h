//
//  MLEmojiLabel.h
//  MLEmojiLabel
//
//  Created by molon on 5/19/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "TTTAttributedLabel.h"


typedef NS_OPTIONS(NSUInteger, MLEmojiLabelLinkType) {
    MLEmojiLabelLinkTypeNone = -1,
    MLEmojiLabelLinkTypeURL = 0,
    MLEmojiLabelLinkTypePhoneNumber = 1,
    MLEmojiLabelLinkTypeEmail = 2,
    MLEmojiLabelLinkTypeAt = 3,
    MLEmojiLabelLinkTypePoundSign = 4,
    MLEmojiLabelLinkTypeFullcode = 5,
    MLEmojiLabelLinkTypeTjrAt = 6,
    MLEmojiLabelLongPress = 7,
};

extern NSString *const ClickLinkType;
extern NSString *const ClickLink;
extern NSString *const ClickDetail;

extern NSString *const TextFont;
extern NSString *const LinksArray;
extern NSString *const AttributedString;
extern NSString *const EmojiText;
extern NSString *const LinkAttributes;

#define CommonLinkColor RGBA(64, 181, 255, 1)

@class MLEmojiLabel;
@protocol MLEmojiLabelDelegate <NSObject>

@optional
- (void)mlEmojiLabel:(MLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link detail:(NSDictionary *)detail;
@end

@interface MLEmojiLabel : TTTAttributedLabel

@property (nonatomic, copy) NSString *emojiText;
@property (nonatomic, copy) NSString *customEmojiRegex; //自定义表情正则
@property (nonatomic, copy) NSString *customEmojiPlistName; //xxxxx.plist 格式

@property (nonatomic, assign) id<MLEmojiLabelDelegate> emojiDelegate; //点击连接的代理方法


- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth;

/**
	解析生成可显示文字的字典
	@param emojiText 目标文字
    @param textFont 文字font
	@param isNeedUrl 是否需要URL功能
	@param isNeedPhoneNumber 是否需要电话功能
	@param isNeedEmail  是否需要Email功能
	@param isNeedAt 是否需要@功能
	@param isNeedPoundSign 是否需要话题功能
	@param isNeedFullcode 是否需要股票链接功能$白云机场(SH600004)$
	@param isNeedTjrAtRedz的可点击At功能
	@returns
 */
- (NSDictionary *)extractEmojiText:(NSString *)emojiText/* 目标文字 */
                          textFont:(UIFont *)textFont	/* 文字font */
                         isNeedUrl:(BOOL)isNeedUrl/* 是否需要URL功能 */
                 isNeedPhoneNumber:(BOOL)isNeedPhoneNumber/* 是否需要电话功能 */
                       isNeedEmail:(BOOL)isNeedEmail/* 是否需要Email功能 */
                          isNeedAt:(BOOL)isNeedAt/* 是否需要@功能 */
                   isNeedPoundSign:(BOOL)isNeedPoundSign/* 是否需要话题功能 */
                    isNeedFullcode:(BOOL)isNeedFullcode/* 是否需要股票链接功能$白云机场(SH600004)$ */
                       isNeedTjrAt:(BOOL)isNeedTjrAt/*Redz的可点击At功能 */;


/**
	将生成的显示文字的字典用来显示
	@param textDictionary
 */
- (void)setEmojiTextWithDictionary:(NSDictionary *)textDictionary;

/**
	设置link的颜色
	@param commonLinkColor
 */
- (void)setCommonLinkColor:(UIColor *)commonLinkColor;

#pragma mark - 查找@表达式
+ (NSArray*)findParam:(NSString *)string;


/**
 *  @brief  从文字中获取TJRAt的参数文字
 *
 *  @param emojiText emojiText
 *
 *  @return
 */
+ (NSString *)getTJRAtParams:(NSString *)emojiText;


/**
 *  @brief  从文字中获取TJRAt的显示文字
 *
 *  @param emojiText emojiText
 *
 *  @return
 */
+ (NSString *)getTJRAtName:(NSString *)emojiText;
@end
