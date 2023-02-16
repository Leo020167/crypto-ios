//
//  MLEmojiLabel.m
//  MLEmojiLabel
//
//  Created by molon on 5/19/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLEmojiLabel.h"

#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression, regex, option)														 \
																														 \
	static inline NSRegularExpression * k##regularExpression() {														 \
		static NSRegularExpression *_##regularExpression = nil;															 \
		static dispatch_once_t onceToken;																				 \
		dispatch_once(&onceToken, ^{																					 \
				_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil]; \
			});																											 \
																														 \
		return _##regularExpression;																					 \
	}																													 \


#define REGULAREXPRESSION(regularExpression, regex) REGULAREXPRESSION_OPTION(regularExpression, regex, NSRegularExpressionCaseInsensitive)

REGULAREXPRESSION(URLRegularExpression, @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")

// REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}")
REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{6,12}")

REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")

// REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+") 保留一份最原始的,防止以后有用
REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")
REGULAREXPRESSION(TJRAtRegularExpression, @"@\\((.*?)\\)\\「((.*?))\\」")

REGULAREXPRESSION(FullcodeExpression, @"\\$(.*?)\\(([A-Za-z]*\\d{4,6})\\)\\$")

// @"#([^\\#|.]+)#"
REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)#", NSRegularExpressionCaseInsensitive)

// 微信的表情符其实不是这种格式，这个格式的只是让人看起来更友好。。
// REGULAREXPRESSION(EmojiRegularExpression, @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]")

// @"/:[\\w:~!@$&*()|+<>',?-]{1,8}" , // @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}" ，经过检测发现\w会匹配中文，好奇葩。
// REGULAREXPRESSION(SlashEmojiRegularExpression, @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}")
REGULAREXPRESSION(TJRFaceRegularExpression, @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]")

const CGFloat kLineSpacing = 4.0;
const CGFloat kAscentDescentScale = 0.25;	// 在这里的话无意义，高度的结局都是和宽度一样

const CGFloat kEmojiWidthRatioWithLineHeight = 1.25;// 和字体高度的比例

const CGFloat kEmojiOriginYOffsetRatioWithLineHeight = 0.10;// 表情绘制的y坐标矫正值，和字体高度的比例，越大越往下
NSString *const kCustomGlyphAttributeImageName = @"CustomGlyphAttributeImageName";
NSString *const kCustomGlyphAttributeText = @"kCustomGlyphAttributeText";
NSString *const kCustomGlyphAttributeFaceSize = @"kCustomGlyphAttributeFaceSize";

#define kEmojiReplaceCharacter @"\uFFFC"

#define kURLActionCount		   5
NSString *const kURLActions[] = {@"url->", @"phoneNumber->", @"email->", @"at->", @"poundSign->"};

NSString *const ClickLinkType = @"ClickLinkType";
NSString *const ClickLink = @"ClickLink";
NSString *const ClickDetail = @"ClickDetail";

NSString *const TextFont = @"TextFont";
NSString *const LinksArray = @"LinksArray";
NSString *const AttributedString = @"AttributedString";
NSString *const EmojiText = @"EmojiText";
NSString *const LinkAttributes = @"LinkAttributes";

@interface MLEmojiLabel () <TTTAttributedLabelDelegate>

@property (nonatomic, retain) NSRegularExpression *customEmojiRegularExpression;
@property (nonatomic, retain) NSDictionary *customEmojiDictionary;

@end

@implementation MLEmojiLabel

#pragma mark - 表情包字典
+ (NSDictionary *)emojiDictionary {
	static NSDictionary *emojiDictionary = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
			NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TJRNewFace.plist"];
			emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
		});
	return emojiDictionary;
}

#pragma mark - 表情 callback
typedef struct CustomGlyphMetrics {
	CGFloat ascent;
	CGFloat descent;
	CGFloat width;
} CustomGlyphMetrics, *CustomGlyphMetricsRef;

static void deallocCallback(void *refCon) {
	free(refCon), refCon = NULL;
}

static CGFloat ascentCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;

	return metrics->ascent;
}

static CGFloat descentCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;

	return metrics->descent;
}

static CGFloat widthCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;

	return metrics->width;
}

#pragma mark - 初始化和TTT的一些修正


/**
 *  TTT很鸡巴。commonInit是被调用了两回。如果直接init的话，因为init其中会调用initWithFrame
 *  PS.已经在里面把init里的修改掉了
 */
- (void)commonInit {
	// 这个是用来生成plist时候用到
	//    [self initPlist];

	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = NO;

	self.delegate = self;
	self.numberOfLines = 0;
	self.font = [UIFont systemFontOfSize:14.0];
	self.backgroundColor = [UIColor clearColor];

    self.lineBreakMode = NSLineBreakByCharWrapping;
    
	self.textInsets = UIEdgeInsetsZero;
	self.lineHeightMultiple = 1.0f;
	self.lineSpacing = kLineSpacing;// 默认行间距

	[self setValue:[NSArray array] forKey:@"links"];
	/* [self setCommonLinkColor:RGBA(109, 170, 173, 1)]; */
	/* @"#40b5ff" */
	[self setCommonLinkColor:RGBA(64, 181, 255, 1)];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    RELEASE(longPress);
}


- (void)setCommonLinkColor:(UIColor *)commonLinkColor {
	if (!commonLinkColor) return;

	NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
	[mutableLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];

	NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
	[mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];

	NSMutableDictionary *mutableInactiveLinkAttributes = [NSMutableDictionary dictionary];
	[mutableInactiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
	// 点击时候的背景色
	[mutableActiveLinkAttributes setValue:(id)[[UIColor colorWithWhite:0.631 alpha:1.000] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];

	if ([NSMutableParagraphStyle class]) {
		[mutableLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
		[mutableActiveLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
		[mutableInactiveLinkAttributes setObject:[UIColor grayColor] forKey:(NSString *)kCTForegroundColorAttributeName];
		// 把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
	} else {
		[mutableLinkAttributes setObject:(id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
		[mutableActiveLinkAttributes setObject:(id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
		[mutableInactiveLinkAttributes setObject:(id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
		// 把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
	}

	self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
	self.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
	self.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableInactiveLinkAttributes];
    
}

/**
 *  如果是有attributedText的情况下，有可能会返回少那么点的，这里矫正下
 *
 */
- (CGSize)sizeThatFits:(CGSize)size {
	if (!self.attributedText) {
		return [super sizeThatFits:size];
	}

	CGSize rSize = [super sizeThatFits:size];
	rSize.height += 2;
	return rSize;
}

// 这里是抄TTT里的，因为他不是放在外面的
static inline CGFloat TTTFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
	switch (textAlignment) {
		case NSTextAlignmentCenter:
			return 0.5f;

		case NSTextAlignmentRight:
			return 1.0f;

		case NSTextAlignmentLeft:
		default:
			return 0.0f;
	}
}

#pragma mark - 绘制表情
- (void)drawOtherForEndWithFrame:(CTFrameRef)frame inRect:(CGRect)rect context:(CGContextRef)c {
	// PS:这个是在TTT里drawFramesetter....方法最后做了修改的基础上。

	CGFloat emojiOriginYOffset = self.font.lineHeight * kEmojiOriginYOffsetRatioWithLineHeight;

	// 找到行
	NSArray *lines = (NSArray *)CTFrameGetLines(frame);
	// 找到每行的origin，保存起来
	CGPoint origins[[lines count]];

	CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);

	// 修正绘制offset，根据当前设置的textAlignment
	CGFloat flushFactor = TTTFlushFactorForTextAlignment(self.textAlignment);

	CFIndex lineIndex = 0;

	for (id line in lines) {
		// 获取当前行的宽度和高度，并且设置对应的origin进去，就获得了这行的bounds
		CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
		CGFloat width = (CGFloat)CTLineGetTypographicBounds((CTLineRef)line, &ascent, &descent, &leading);
		CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + descent + leading);
		lineBounds.origin.x = origins[lineIndex].x;
		lineBounds.origin.y = origins[lineIndex].y;

		// 这里其实是能获取到当前行的真实origin.x，根据textAlignment，而lineBounds.origin.x其实是默认一直为0的(不会受textAlignment影响)
		CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush((CTLineRef)line, flushFactor, rect.size.width);

		// 找到当前行的每一个要素，姑且这么叫吧。可以理解为有单独的attr属性的各个range。
		for (id glyphRun in(NSArray *) CTLineGetGlyphRuns((CTLineRef)line)) {
			// 找到此要素所对应的属性
			NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes((CTRunRef)glyphRun);
			// 判断是否有图像，如果有就绘制上去
			NSString *imageName = attributes[kCustomGlyphAttributeImageName];
            CGFloat faceWidth = [attributes[kCustomGlyphAttributeFaceSize] floatValue];

			if (imageName) {
				CGRect runBounds = CGRectZero;
				CGFloat runAscent = 0.0f;
				CGFloat runDescent = 0.0f;

				runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
				runBounds.size.height = runAscent + runDescent;
                
                if (faceWidth > 0 && runBounds.size.width > faceWidth) {
                    runBounds.size.width = faceWidth;
                }
                
				CGFloat xOffset = 0.0f;
				CFRange glyphRange = CTRunGetStringRange((CTRunRef)glyphRun);

				switch (CTRunGetStatus((CTRunRef)glyphRun)) {
					case kCTRunStatusRightToLeft:
						xOffset = CTLineGetOffsetForStringIndex((CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
						break;

					default:
						xOffset = CTLineGetOffsetForStringIndex((CTLineRef)line, glyphRange.location, NULL);
						break;
				}

				runBounds.origin.x = penOffset + xOffset;
				runBounds.origin.y = origins[lineIndex].y;
				runBounds.origin.y -= runDescent;

				UIImage *image = [UIImage imageNamed:imageName];
				runBounds.origin.y -= emojiOriginYOffset;	//稍微矫正下。
				CGContextDrawImage(c, runBounds, image.CGImage);
			}
		}

		lineIndex++;
	}
}

#pragma mark - main

/**
 *  返回经过表情识别处理的Attributed字符串
 */
- (NSMutableAttributedString *)mutableAttributeStringWithEmojiText:(NSString *)emojiText {
	NSArray *emojis = nil;

	if (self.customEmojiRegularExpression) {
		// 自定义表情正则
		emojis = [self.customEmojiRegularExpression matchesInString:emojiText
															options:NSMatchingWithTransparentBounds
															  range:NSMakeRange(0, [emojiText length])];
	} else {
		emojis = [kTJRFaceRegularExpression () matchesInString:emojiText
													   options:NSMatchingWithTransparentBounds
														 range:NSMakeRange(0, [emojiText length])];
	}

	NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] init] autorelease];
	NSUInteger location = 0;

	CGFloat emojiWith = self.font.lineHeight * kEmojiWidthRatioWithLineHeight;

	for (NSTextCheckingResult *result in emojis) {
		NSRange range = result.range;
		NSString *subStr = [emojiText substringWithRange:NSMakeRange(location, range.location - location)];
		NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
		[attrStr appendAttributedString:attSubStr];
		RELEASE(attSubStr);

		location = range.location + range.length;

		NSString *emojiKey = [emojiText substringWithRange:range];

		NSDictionary *emojiDict = self.customEmojiRegularExpression ? self.customEmojiDictionary :[MLEmojiLabel emojiDictionary];

        if (!emojiDict || ![emojiDict.allKeys containsObject:emojiKey]) {
            NSMutableAttributedString *originalStr = [[NSMutableAttributedString alloc] initWithString:emojiKey];
            [attrStr appendAttributedString:originalStr];
            RELEASE(originalStr);
        } else {
            // 如果当前获得key后面有多余的，这个需要记录下
            NSMutableAttributedString *otherAppendStr = nil;
            
            NSString *imageName = [NSString stringWithFormat:@"TJRFace_%@", emojiDict[emojiKey]];
            
            /* if (!self.customEmojiRegularExpression) {
             // 微信的表情没有结束符号,所以有可能会发现过长的只有头部才是表情的段，需要循环检测一次。微信最大表情特殊字符是8个长度，检测8次即可
             if (!imageName && (emojiKey.length > 2)) {
             NSUInteger maxDetctIndex = emojiKey.length > 8 + 2 ? 8 : emojiKey.length - 2;
             
             // 从头开始检测是否有对应的
             for (NSUInteger i = 0; i < maxDetctIndex; i++) {
             imageName = emojiDict[[emojiKey substringToIndex:3 + i]];
             
             if (imageName) {
             otherAppendStr = [[[NSMutableAttributedString alloc] initWithString:[emojiKey substringFromIndex:3 + i]] autorelease];
             break;
             }
             }
             }
             } */
            
            // 这里不用空格，空格有个问题就是连续空格的时候只显示在一行
            NSMutableAttributedString *replaceStr = [[[NSMutableAttributedString alloc] initWithString:kEmojiReplaceCharacter] autorelease];
            NSRange __range = NSMakeRange([attrStr length], 1);
            [attrStr appendAttributedString:replaceStr];
            
            if (otherAppendStr) {	//有其他需要添加的
                [attrStr appendAttributedString:otherAppendStr];
            }
            
            // 定义回调函数
            CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateCurrentVersion;
            callbacks.getAscent = ascentCallback;
            callbacks.getDescent = descentCallback;
            callbacks.getWidth = widthCallback;
            callbacks.dealloc = deallocCallback;
            
            // 这里设置下需要绘制的图片的大小，这里我自定义了一个结构体以便于存储数据
            CustomGlyphMetricsRef metrics = malloc(sizeof(CustomGlyphMetrics));
            metrics->width = emojiWith;
            metrics->ascent = 1 / (1 + kAscentDescentScale) * metrics->width;
            metrics->descent = metrics->ascent * kAscentDescentScale;
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, metrics);
            [attrStr addAttribute:(NSString *)kCTRunDelegateAttributeName value:(id)delegate range:__range];
            CFRelease(delegate);
            
            // 设置自定义属性，绘制的时候需要用到
            [attrStr addAttribute:kCustomGlyphAttributeImageName value:imageName range:__range];
            [attrStr addAttribute:kCustomGlyphAttributeText value:emojiKey range:__range];
            [attrStr addAttribute:kCustomGlyphAttributeFaceSize value:[NSNumber numberWithFloat:emojiWith] range:__range];
        }
	}

	if (location < [emojiText length]) {
		NSRange range = NSMakeRange(location, [emojiText length] - location);
		NSString *subStr = [emojiText substringWithRange:range];
		NSMutableAttributedString *attrSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
		[attrStr appendAttributedString:attrSubStr];
		RELEASE(attrSubStr);
	}
	return attrStr;
}

- (NSDictionary *)mutableAttributeStringWithTJRAtText:(NSMutableAttributedString *)emojiAttributedText {
	NSString *emojiText = emojiAttributedText.string;
	NSArray *emojis = [kTJRAtRegularExpression () matchesInString:emojiText options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [emojiText length])];
	NSUInteger location = 0;
	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
	NSMutableArray *tjrUserArray = [[NSMutableArray alloc] init];
	NSUInteger changeLength = 0;

	for (NSTextCheckingResult *result in emojis) {
		NSRange range = result.range;
		NSAttributedString *subStr = [emojiAttributedText attributedSubstringFromRange:NSMakeRange(location, range.location - location)];
		[attrStr appendAttributedString:subStr];

		location = range.location + range.length;

		NSString *tjrUser = [emojiText substringWithRange:range];
		NSTextCheckingResult *firstMatch = [kTJRAtRegularExpression () firstMatchInString:tjrUser options:0 range:NSMakeRange(0, tjrUser.length)];
		NSString *appendString = nil;

		if (firstMatch.numberOfRanges > 1) {
            NSString *userName = [tjrUser substringWithRange:[firstMatch rangeAtIndex:1]];
			NSString *userId = [tjrUser substringWithRange:[firstMatch rangeAtIndex:2]];
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userName, ClickLink, userId, ClickDetail, [NSNumber numberWithInteger:MLEmojiLabelLinkTypeTjrAt], ClickLinkType, nil];
			NSTextCheckingResult *aResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:NSMakeRange(range.location - changeLength, userName.length) components:dic];
			changeLength += tjrUser.length - userName.length;
			[tjrUserArray addObject:aResult];
			appendString = userName;
		} else {
			appendString = tjrUser;
		}
		NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:appendString];
		[attrStr appendAttributedString:attSubStr];
		RELEASE(attSubStr);
	}

	if (location < [emojiText length]) {
		NSRange range = NSMakeRange(location, [emojiText length] - location);
		NSAttributedString *subStr = [emojiAttributedText attributedSubstringFromRange:range];
		[attrStr appendAttributedString:subStr];
	}
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:tjrUserArray, @"ResultArray", attrStr, @"AttributedString", nil];
	[tjrUserArray release];
	[attrStr release];
	return dic;
}

/**
 *    解析生成可显示文字的字典
 *    @param emojiText 目标文字
 *    @param textFont 文字font
 *    @param isNeedUrl 是否需要URL功能
 *    @param isNeedPhoneNumber 是否需要电话功能
 *    @param isNeedEmail  是否需要Email功能
 *    @param isNeedAt 是否需要@功能
 *    @param isNeedPoundSign 是否需要话题功能
 *    @param isNeedFullcode 是否需要股票链接功能$白云机场(SH600004)$
 *    @param isNeedTjrAtRedz的可点击At功能
 *    @returns
 */
- (NSDictionary *)extractEmojiText:(NSString *)emojiText/* 目标文字 */
						  textFont:(UIFont *)textFont	/* 文字font */
						 isNeedUrl:(BOOL)isNeedUrl	/* 是否需要URL功能 */
				 isNeedPhoneNumber:(BOOL)isNeedPhoneNumber	/* 是否需要电话功能 */
					   isNeedEmail:(BOOL)isNeedEmail/* 是否需要Email功能 */
						  isNeedAt:(BOOL)isNeedAt	/* 是否需要@功能 */
				   isNeedPoundSign:(BOOL)isNeedPoundSign/* 是否需要话题功能 */
					isNeedFullcode:(BOOL)isNeedFullcode	/* 是否需要股票链接功能$白云机场(SH600004)$ */
					   isNeedTjrAt:(BOOL)isNeedTjrAt /*Redz的可点击At功能 */ {
	if (!TTIsStringWithAnyText(emojiText)) return nil;

	if (textFont) self.font = textFont;
	NSMutableArray *userNeedArray = [NSMutableArray new];

	if (isNeedUrl) {
		[userNeedArray addObject:kURLRegularExpression()];
    }
    
    if (isNeedFullcode) {
        [userNeedArray addObject:kFullcodeExpression()];
    }

	if (isNeedPhoneNumber) {
		[userNeedArray addObject:kPhoneNumerRegularExpression()];
	}

	if (isNeedEmail) {
		[userNeedArray addObject:kEmailRegularExpression()];
	}

	if (isNeedAt) {
		[userNeedArray addObject:kAtRegularExpression()];
	}

	if (isNeedPoundSign) {
		[userNeedArray addObject:kPoundSignRegularExpression()];
	}
	NSMutableAttributedString *mutableAttributedString = nil;

	mutableAttributedString = [self mutableAttributeStringWithEmojiText:emojiText];
	NSMutableArray *results = [NSMutableArray array];

	if (isNeedTjrAt) {
		NSDictionary *dic = [self mutableAttributeStringWithTJRAtText:mutableAttributedString];

		if (dic) {
			NSArray *array = [dic objectForKey:@"ResultArray"];

			if (array && (array.count > 0)) {
				[results addObjectsFromArray:array];
			}
			NSMutableAttributedString *attributedString = [dic objectForKey:@"AttributedString"];

			if (attributedString && (attributedString.length > 0)) {
				mutableAttributedString = attributedString;
			}
		}
	}

	for (NSRegularExpression *regexps in userNeedArray) {
		[regexps enumerateMatchesInString:[mutableAttributedString string] options:0 range:NSMakeRange(0, mutableAttributedString.length)
							   usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
				// 检查是否和之前记录的有交集，有的话则忽略
				for (NSTextCheckingResult * record in results) {
					if (NSMaxRange (NSIntersectionRange (record.range, result.range)) > 0) {
						return;
					}
				}

				NSRange resultRange = result.range;
				NSString *action = [[mutableAttributedString string] substringWithRange:result.range];
				NSTextCheckingResult *aResult = nil;
				NSString *detail = action;
				NSString *linkStr = action;
				MLEmojiLabelLinkType type = MLEmojiLabelLinkTypeNone;

				if (regexps == kURLRegularExpression ()) {
					type = MLEmojiLabelLinkTypeURL;
				} else if (regexps == kPhoneNumerRegularExpression ()) {
					type = MLEmojiLabelLinkTypePhoneNumber;
				} else if (regexps == kEmailRegularExpression ()) {
					type = MLEmojiLabelLinkTypeEmail;
				} else if (regexps == kAtRegularExpression ()) {
					type = MLEmojiLabelLinkTypeAt;
				} else if (regexps == kPoundSignRegularExpression ()) {
					type = MLEmojiLabelLinkTypePoundSign;
				} else if (regexps == kFullcodeExpression ()) {						/* 股票代码 */
					type = MLEmojiLabelLinkTypeFullcode;
					NSTextCheckingResult *firstMatch = [regexps firstMatchInString:action options:0 range:NSMakeRange (0, action.length)];

					if (firstMatch.numberOfRanges > 2) {
						detail = [action substringWithRange:[firstMatch rangeAtIndex:2]];
					}
				}
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:linkStr, ClickLink, detail, ClickDetail, [NSNumber numberWithInteger:type], ClickLinkType, nil];
				// 这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
				// 因为有自定义的类型出现，所以这样方便点。
				aResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:resultRange components:dic];
				[results addObject:aResult];
			}];
	}
    [userNeedArray removeAllObjects];
    RELEASE(userNeedArray);
	if (self.linkAttributes) {
		for (NSTextCheckingResult *result in results) {
			[mutableAttributedString addAttributes:self.linkAttributes range:result.range];
		}
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:mutableAttributedString, AttributedString, results, LinksArray,textFont,TextFont,emojiText,EmojiText, nil];
}

/**
 *    将生成的显示文字的字典用来显示
 *    @param textDictionary
 */
- (void)setEmojiTextWithDictionary:(NSDictionary *)textDictionary {
	if (!textDictionary || (textDictionary.count == 0)) {
		[super setText:nil];
		return;
	}
	NSString *attributedString = [textDictionary objectForKey:AttributedString];
    self.emojiText = [textDictionary objectForKeyedSubscript:EmojiText];
    UIFont *font = [textDictionary objectForKey:TextFont];
    if (font) self.font = font;
	NSArray *array = [textDictionary objectForKey:LinksArray];
    [self setText:attributedString afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // 这里直接调用父类私有方法，好处能内部只会setNeedDisplay一次。一次更新所有添加的链接
    [super performSelector:@selector(addLinksWithTextCheckingResults:attributes:) withObject:array withObject:self.linkAttributes];
#pragma clang diagnostic pop
}

#pragma mark - size fit result
- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth
{
    maxWidth = maxWidth - self.textInsets.left - self.textInsets.right;
    return [self sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

- (void)setCustomEmojiRegex:(NSString *)customEmojiRegex {
	RELEASE(_customEmojiRegex);
	_customEmojiRegex = [customEmojiRegex copy];

	if (customEmojiRegex && (customEmojiRegex.length > 0)) {
		NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:customEmojiRegex options:NSRegularExpressionCaseInsensitive error:nil];
		self.customEmojiRegularExpression = regular;
		RELEASE(regular);
	} else {
		self.customEmojiRegularExpression = nil;
	}
}

- (void)setCustomEmojiPlistName:(NSString *)customEmojiPlistName {
	RELEASE(_customEmojiPlistName);
	_customEmojiPlistName = [customEmojiPlistName copy];

	if (customEmojiPlistName && (customEmojiPlistName.length > 0)) {
		if (![customEmojiPlistName hasSuffix:@".plist"]) {
			customEmojiPlistName = [customEmojiPlistName stringByAppendingString:@".plist"];
		}
		NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:customEmojiPlistName];
		NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
		self.customEmojiDictionary = dic;
		RELEASE(dic);
	} else {
		self.customEmojiDictionary = nil;
	}
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_emojiDelegate && [_emojiDelegate respondsToSelector:@selector(mlEmojiLabel:didSelectLink:detail:)]) {
            [_emojiDelegate mlEmojiLabel:self didSelectLink:_emojiText detail:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:MLEmojiLabelLongPress], ClickLinkType, nil]];
        }
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
	if (_emojiDelegate && [_emojiDelegate respondsToSelector:@selector(mlEmojiLabel:didSelectLink:detail:)]) {
		NSString *link = [components objectForKey:ClickLink];
		[_emojiDelegate mlEmojiLabel:self didSelectLink:link detail:components];
	}
}

#pragma mark - 查找@表达式
+ (NSArray*)findParam:(NSString *)string {
    
    NSArray *params = [kTJRAtRegularExpression () matchesInString:string options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [string length])];

    return params;
}

/**
 *  @brief  从文字中获取TJRAt的参数文字
 *
 *  @param emojiText emojiText
 *
 *  @return 
 */ 
+ (NSString *)getTJRAtParams:(NSString *)emojiText {
    
    if (!TTIsStringWithAnyText(emojiText)) return nil;
    
    NSArray *emojis = [kTJRAtRegularExpression () matchesInString:emojiText options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [emojiText length])];
    
    for (NSTextCheckingResult *result in emojis) {
        NSString *tjrUser = [emojiText substringWithRange:result.range];
        if (TTIsStringWithAnyText(tjrUser)) {
            NSTextCheckingResult *firstMatch = [kTJRAtRegularExpression () firstMatchInString:tjrUser options:0 range:NSMakeRange(0, tjrUser.length)];
            return [tjrUser substringWithRange:[firstMatch rangeAtIndex:2]];
        }
    }
    return nil;
}

/**
 *  @brief  从文字中获取TJRAt的显示文字
 *
 *  @param emojiText emojiText
 *
 *  @return
 */
+ (NSString *)getTJRAtName:(NSString *)emojiText {
    
    if (!TTIsStringWithAnyText(emojiText)) return nil;
    
    NSArray *emojis = [kTJRAtRegularExpression () matchesInString:emojiText options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [emojiText length])];
    
    for (NSTextCheckingResult *result in emojis) {
        NSString *tjrUser = [emojiText substringWithRange:result.range];
        if (TTIsStringWithAnyText(tjrUser)) {
            NSTextCheckingResult *firstMatch = [kTJRAtRegularExpression () firstMatchInString:tjrUser options:0 range:NSMakeRange(0, tjrUser.length)];
            return [tjrUser substringWithRange:[firstMatch rangeAtIndex:1]];
        }
    }
    return nil;
}


- (void)dealloc {
    RELEASE(_emojiText);
	RELEASE(_customEmojiRegex);
	RELEASE(_customEmojiPlistName);
	[super dealloc];
}

@end

