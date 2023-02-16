//
//  TJRNewFaceString.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-12-26.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRNewFaceString.h"
#import "CommonUtil.h"
#import "RCLabel.h"

static NSMutableArray *stringArray;
static NSMutableDictionary *faceDictionary;
static NSString *urlRegular = @"(http|ftp|https|www):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?";
static NSString *faceRegular = @"\\[(.*?)\\]";
static NSString *fullcodeRegular = @"\\$(.*?)\\(([A-Za-z]*\\d{4,6})\\)\\$";
static NSString *topicRegular = @"\\#([^\\#|.]+)\\#";

static NSInteger fullcodeIndex = 0;
static BOOL lastIsText = NO;

@implementation TJRNewFaceString

/**
 *    生成文字的Html
 *    @param text 文字
 *    @param color 文字颜色
 *    @param textSize  文字大小
 *    @returns
 */
+ (NSString *)faceTextHtml:(NSString *)text color:(NSString *)color textSize:(NSInteger)textSize {
    lastIsText = YES;
	return [NSString stringWithFormat:@"<font size=%ld color='%@'>%@</font>", (long)textSize, color, text];
}

/**
 *    生成Url的Html
 *    @param url url文字
 *    @param color url文字颜色
 *    @param textSize  url文字大小
 *    @returns
 */
+ (NSString *)faceUrlHtml:(NSString *)url color:(NSString *)color textSize:(NSInteger)textSize {
    lastIsText = NO;
	return [NSString stringWithFormat:@"<font size=%ld color='%@'><a %@='%@'><u color='%@'>%@</u></a></font>", (long)textSize, color,RCLabelLinkForUrl, url, color, url];
}

/**
 *    生成可点击Fullcode的Html
 *    @param name fullcode
 *    @param data 点击参数
 *    @param color fullcode颜色
 *    @param textSize  fullcode文字大小
 *    @returns
 */
+ (NSString *)faceFullcodeHtml:(NSString *)name data:(NSString *)data color:(NSString *)color textSize:(NSInteger)textSize {
    lastIsText = NO;
	return [NSString stringWithFormat:@"<a %@='%@'><font size=%ld color='%@'>%@</font></a>",RCLabelLinkForFullcode, data, (long)textSize, color, name];
}

/**
 *    生成可点击Topic的Html
 *    @param topic 话题
 *    @param data 点击参数
 *    @param color fullcode颜色
 *    @param textSize  fullcode文字大小
 *    @returns
 */
+ (NSString *)faceTopicHtml:(NSString *)topic data:(NSString *)data color:(NSString *)color textSize:(NSInteger)textSize {
    lastIsText = NO;
	return [NSString stringWithFormat:@"<a %@='%@'><font size=%ld color='%@'>%@</font></a>",RCLabelLinkForTopic, data, (long)textSize, color, topic];
}

/**
 *    生成表情图片的Html(带宽高和偏移量)
 *    @param image 表情图片名
 *    @param width 表情宽
 *    @param height 表情高
 *    @param xPadding x方向偏移量
 *    @param yPadding  y方向偏移量
 *    @returns
 */
+ (NSString *)faceImageHtmlWithImageSizeAndPadding:(NSString *)image imageSize:(CGSize)imageSize padding:(CGPoint)padding {
    lastIsText = NO;
	return [NSString stringWithFormat:@"<img src='TJRFace_%@' width=%.0f height=%.0f xPadding=%.2f yPadding=%.2f>", image, imageSize.width, imageSize.height, padding.x, padding.y];
}

/**
 *    生成表情图片的Html(带宽高)
 *    @param image 表情图片名
 *    @param width 表情宽
 *    @param height  表情高
 *    @returns
 */
+ (NSString *)faceImageHtmlWithImageSize:(NSString *)image imageSize:(CGSize)imageSize {
	return [TJRNewFaceString faceImageHtmlWithImageSizeAndPadding:image imageSize:imageSize padding:CGPointMake(320.0, 320.0)];
}

/**
 *    生成表情图片的Html(依文字大小来)
 *    @param image 表情图片名
 *    @param textSize  文字大小
 *    @returns
 */
+ (NSString *)faceImageHtmlWithTextSize:(NSString *)image textSize:(NSInteger)textSize {
	return [TJRNewFaceString faceImageHtmlWithImageSize:image imageSize:CGSizeMake(textSize, textSize)];
}

+ (void)checkInit {
    fullcodeIndex = 0;
    lastIsText = NO;
	if (!stringArray) {
		stringArray = [[NSMutableArray alloc] init];
		NSString *path = [[NSBundle mainBundle] pathForResource:@"TJRNewFace" ofType:@"plist"];
		faceDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	} else {
		[stringArray removeAllObjects];
	}
}

#pragma mark - 查找url
+ (NSRange)findUrl:(NSString *)string {
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegular options:0 error:&error];

	NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];

	if (firstMatch) {
		return [firstMatch rangeAtIndex:0];
	}

	return NSMakeRange(NSNotFound, 0);
}

#pragma mark - 查找表情
+ (NSRange)findFace:(NSString *)string {
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:faceRegular options:0 error:&error];

	NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];

	if (firstMatch) {
		return [firstMatch rangeAtIndex:0];
	}

	return NSMakeRange(NSNotFound, 0);
}

#pragma mark - 查找股票代码
+ (NSTextCheckingResult *)findFullcode:(NSString *)string {
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fullcodeRegular options:0 error:&error];
	NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];

	return firstMatch;
}

#pragma mark - 查找url
+ (NSRange)findTopic:(NSString *)string {
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:topicRegular options:0 error:&error];

	NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];

	if (firstMatch) {
		return [firstMatch rangeAtIndex:0];
	}

	return NSMakeRange(NSNotFound, 0);
}

#pragma mark - 格式化将表情,url,文字分别装载
+ (void)formatRCString:(NSString *)string isFormatTopic:(BOOL)isFormatTopic isFormatFullcode:(BOOL)isFormatFullcode {
	if (!string || (string.length == 0)) {
		return;
	}

	NSRange faceRang = [self findFace:string];
	NSRange urlRang = [self findUrl:string];
	NSRange stockRang = NSMakeRange(NSNotFound, 0);
	NSRange jcRang = NSMakeRange(NSNotFound, 0);
	NSRange fdmRang = NSMakeRange(NSNotFound, 0);
	NSRange topicRang = NSMakeRange(NSNotFound, 0);

	if (isFormatTopic) {
		topicRang = [self findTopic:string];
	}

	if (isFormatFullcode) {
		NSTextCheckingResult *firstMatch = [self findFullcode:string];

		if (firstMatch) {
			if (firstMatch.numberOfRanges > 0) {
				stockRang = [firstMatch rangeAtIndex:0];
			}
            if (firstMatch.numberOfRanges > 1) {
                jcRang = [firstMatch rangeAtIndex:1];
            }
			if (firstMatch.numberOfRanges > 2) {
				fdmRang = [firstMatch rangeAtIndex:2];
			}
		}
	}

	if (isFormatTopic && (topicRang.location < stockRang.location && topicRang.location < faceRang.location)) {
		NSString *topicString = [string substringWithRange:topicRang];

		if (topicRang.location == 0) {	/* 开始就是话题 */
			[self addTopicStringForRegular:topicString];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:topicRang];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		} else {
			NSString *text = [string substringWithRange:NSMakeRange(0, topicRang.location)];
			[self processText:text isFormatFullcode:isFormatFullcode];
			[self addTopicStringForRegular:topicString];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:NSMakeRange(0, topicRang.location + topicRang.length)];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		}
	} else if (isFormatFullcode && (stockRang.location < faceRang.location)) {	/* 股票代码 */
		NSString *stockString = [string substringWithRange:stockRang];
		NSString *fdmString = @"";
        NSString *jcString = @"";
        if (jcRang.location + jcRang.length < string.length) {
			jcString = [string substringWithRange:jcRang];
		}
		if (fdmRang.location + fdmRang.length < string.length) {
			fdmString = [string substringWithRange:fdmRang];
		}

		if (stockRang.location == 0) {	/* 开始就是股票代码 */
			[self addFullcodeStringForRegular:stockString jc:jcString fullcode:fdmString];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:stockRang];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		} else {
			NSString *text = [string substringWithRange:NSMakeRange(0, stockRang.location)];
			[self processText:text isFormatFullcode:isFormatFullcode];
			[self addFullcodeStringForRegular:stockString jc:jcString fullcode:fdmString];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:NSMakeRange(0, stockRang.location + stockRang.length)];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		}
	} else if (faceRang.location < urlRang.location) {	/* 表情 */
		NSString *face = [string substringWithRange:faceRang];

		if ([faceDictionary.allKeys containsObject:[face lowercaseString]]) {	/* 为淘金表情 */
			if (faceRang.location == 0) {	/* 开始就是表情 */
				[self addFaceString:face];
				NSMutableString *msString = [NSMutableString stringWithString:string];
				[msString deleteCharactersInRange:faceRang];
				[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
			} else {
				NSString *text = [string substringWithRange:NSMakeRange(0, faceRang.location)];
				[self processText:text isFormatFullcode:isFormatFullcode];
				[self addFaceString:face];
				NSMutableString *msString = [NSMutableString stringWithString:string];
				[msString deleteCharactersInRange:NSMakeRange(0, faceRang.location + faceRang.length)];
				[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
			}
		} else {/* 为假表情 */
			NSString *text = [string substringWithRange:NSMakeRange(0, faceRang.location + 1)];
			[self processText:text isFormatFullcode:isFormatFullcode];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:NSMakeRange(0, faceRang.location + 1)];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		}
	} else if (urlRang.location < faceRang.location) {	/* 先出现URL */
		NSString *url = [string substringWithRange:urlRang];

		if (urlRang.location == 0) {/* 开始就是URL */
			[self addUrlString:url];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:urlRang];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		} else {
			NSString *text = [string substringWithRange:NSMakeRange(0, urlRang.location)];
			[self processText:text isFormatFullcode:isFormatFullcode];
			[self addUrlString:url];
			NSMutableString *msString = [NSMutableString stringWithString:string];
			[msString deleteCharactersInRange:NSMakeRange(0, urlRang.location + urlRang.length)];
			[self formatRCString:msString isFormatTopic:isFormatTopic isFormatFullcode:isFormatFullcode];
		}
	} else {/* 没有表情和URL */
		[self processText:string isFormatFullcode:isFormatFullcode];
	}
}



#pragma mark - 装载股票代码(正则表达式分出来,要二次处理)
+ (void)addFullcodeStringForRegular:(NSString *)text jc:(NSString *)jc fullcode:(NSString *)fullcode {
	if (!TTIsStringWithAnyText(text)) return;

	/*  text = [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]];	// 去掉首尾的$符号 */
	if (!TTIsStringWithAnyText(jc)) {/* 股票名为空就截取 */
        NSRange rang1 = [text rangeOfString:@"$"];
		NSRange rang2 = [text rangeOfString:@"("];
        
		if ((rang1.location != NSNotFound) && (rang2.location != NSNotFound) && (rang2.location > rang1.location)) {
			jc = [text substringWithRange:NSMakeRange(rang1.location + 1, rang2.location - rang1.location - 1)];
		}
    }
    if (!TTIsStringWithAnyText(fullcode)) {	/* fullcode为空就截取 */
		NSRange rang1 = [text rangeOfString:@"("];
		NSRange rang2 = [text rangeOfString:@")"];

		if ((rang1.location != NSNotFound) && (rang2.location != NSNotFound) && (rang2.location > rang1.location)) {
			fullcode = [text substringWithRange:NSMakeRange(rang1.location + 1, rang2.location - rang1.location - 1)];
		}
	}
	NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSString stringWithString:[text stringByReplacingOccurrencesOfString:@" " withString:@""]],StringType_StockInfo,
                         [NSString stringWithString:!fullcode ? @"":fullcode], StringType_Fullcode,
                         [NSString stringWithString:!jc ? @"":jc], StringType_StockName, nil];
	[stringArray addObject:dic];
	RELEASE(dic);
}

#pragma mark - 装载话题
+ (void)addTopicStringForRegular:(NSString *)text {
	NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithString:text], StringType_Topic, nil];

	[stringArray addObject:dic];
	RELEASE(dic);
}

#pragma mark - 装载表情文字
+ (void)addFaceString:(NSString *)text {
	NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithString:text], StringType_Face, nil];

	[stringArray addObject:dic];
	RELEASE(dic);
}

#pragma mark - 装载url文字
+ (void)addUrlString:(NSString *)text {
	NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithString:text], StringType_Url, nil];

	[stringArray addObject:dic];
    RELEASE(dic);
}

#pragma mark - 装载股票代码
+ (void)addFullcodeString:(NSString *)text {
    fullcodeIndex++;
	NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithString:text], StringType_Fullcode, nil];
    
	[stringArray addObject:dic];
	RELEASE(dic);
}

#pragma mark - 处理文字
+ (void)processText:(NSString *)text isFormatFullcode:(BOOL)isFormatFullcode {
	if (isFormatFullcode) {
		[self checkStockDmFromString:text];
	} else {
        [self addText:text];
	}
}

#pragma mark - 装载文字
+ (void)addText:(NSString *)text {
	NSMutableString *string = nil;

	if (!stringArray || (stringArray.count == 0) || ![[stringArray objectAtIndex:stringArray.count - 1] isKindOfClass:[NSMutableString class]]) {
		string = [[NSMutableString alloc] initWithString:text];
		[stringArray addObject:string];
		RELEASE(string);
	} else {
		string = [stringArray objectAtIndex:stringArray.count - 1];
		[string appendString:text];
	}
}

#pragma mark - 将输入文字生成html语句

/**
 *    将输入文字生成html语句(图片大小不用设置,图片大小和文字大小差不多)
 *    @param text 内容
 *    @param textSize 文字字体大小
 *    @param textColor 文字字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @param urlSize url字体大小
 *    @param urlColor url字体颜色(可以用red这种,也可以自定义,自定义就要用#6f6f6f这种类型)
 *    @returns html语句
 */
+ (NSString *)spliceAllStringForHtmlWithString:(NSString *)text textSize:(int)textSize textColor:(NSString *)textColor urlSize:(int)urlSize urlColor:(NSString *)urlColor {
    return [self spliceAllStringForHtmlWithString:text textSize:textSize imageSize:CGSizeMake(textSize + 12, textSize + 12) imagePaddingPoint:CGPointMake(2,(CURRENT_DEVICE_VERSION>=7.0?8:4)) textColor:textColor urlSize:urlSize urlColor:urlColor];
}

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
+ (NSString *)spliceAllStringForHtmlWithString:(NSString *)text textSize:(int)textSize imageSize:(CGSize)imageSize imagePaddingPoint:(CGPoint)paddingPoint textColor:(NSString *)textColor urlSize:(int)urlSize urlColor:(NSString *)urlColor {
	return [self spliceAllStringForHtmlWithString:text textSize:textSize imageSize:imageSize imagePaddingPoint:paddingPoint textColor:textColor urlSize:urlSize urlColor:urlColor isSpliceTopic:NO topicSize:0 topicColor:@"" isSpliceFullcode:NO fullcodeSize:0 fullcodeColor:@""];
}

/**
 *    将输入文字生成html语句
 *    @param text 内容
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
								 fullcodeColor:(NSString *)fullcodeColor {
	if (!text || (text.length == 0)) {
		return @"";
	}
    fullcodeIndex = 0;
	[self checkInit];
	[self formatRCString:text isFormatTopic:isSpliceTopic isFormatFullcode:isSpliceFullcode];	/* 格式化将表情,url,文字分别装载 */

	if (!stringArray || (stringArray.count == 0)) {
		return @"";
	} else {
		NSMutableString *string = [[NSMutableString alloc] init];
		for (id item in [stringArray objectEnumerator]) {
			if ([item isKindOfClass:[NSDictionary class]]) {
				NSString *faceText = [(NSDictionary *) item objectForKey:StringType_Face];
				NSString *urlText = [(NSDictionary *) item objectForKey:StringType_Url];
                NSString *fullcodeText = [(NSDictionary *) item objectForKey:StringType_Fullcode];
                NSString *topicText = [(NSDictionary *) item objectForKey:StringType_Topic];

                if (TTIsStringWithAnyText(topicText)) {/* 切分话题 */
                    [string appendString:[TJRNewFaceString faceTopicHtml:topicText data:topicText color:topicColor textSize:topicSize]];
                } else if (TTIsStringWithAnyText(fullcodeText)) {/* 切分股票 */
                    NSString *stockInfo = [(NSDictionary *) item objectForKey:StringType_StockInfo];/* $外高桥(SH600648)$ */
                    if (TTIsStringWithAnyText(stockInfo)) {	/* 如果输入的符合正则表达式的 */
                        NSString *stockName = [(NSDictionary *) item objectForKey:StringType_StockName];/* 外高桥 */
                        NSString *dataString = [NSString stringWithFormat:@"{\"jc\":\"%@\",\"fdm\":\"%@\"}",[stockName stringByReplacingOccurrencesOfString:@" " withString:@""],[fullcodeText lowercaseString]];
                        [string appendString:[TJRNewFaceString faceFullcodeHtml:stockInfo data:dataString color:fullcodeColor textSize:fullcodeSize]];
                    } else {/* 代码不是股票时,就当文字 */
                        if (fullcodeIndex > 100) {/* 代码数量过多时就不转换成链接 */
                            [self appendText:string withText:fullcodeText textColor:textColor textSize:textSize];
                        } else {
                            
                        }
                    }
                } else if (faceText && (faceText.length > 0)) {
					[string appendString:[TJRNewFaceString faceImageHtmlWithImageSizeAndPadding:[faceDictionary objectForKey:faceText] imageSize:imageSize padding:paddingPoint]];
				} else if (urlText && (urlText.length > 0)) {
					[string appendString:[TJRNewFaceString faceUrlHtml:urlText color:urlColor textSize:urlSize]];
				}
			} else {// 文字
                [self appendText:string withText:(NSMutableString *)item textColor:textColor textSize:textSize];
			}
		}

		[stringArray removeAllObjects];
		NSString *result = [NSString stringWithString:string];
		RELEASE(string);
		return result;
	}
}

+ (void)appendText:(NSMutableString *)string withText:(NSString *)text textColor:(NSString *)textColor textSize:(NSInteger)textSize {
    if (!TTIsStringWithAnyText(text)) return;
    if (lastIsText) {
        [string insertString:text atIndex:string.length - 7];
    } else {
        [string appendString:[TJRNewFaceString faceTextHtml:text color:textColor textSize:textSize]];
    }
}

#pragma mark - 测试方法
+ (NSString *)testDMWithString:(NSString *)text {
    [self checkInit];
    [self checkStockDmFromString:text];
    NSMutableString *string = [NSMutableString string];
    for (id item in [stringArray objectEnumerator]) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            NSString *fullcodeText = [(NSDictionary *) item objectForKey:StringType_Fullcode];
            if (TTIsStringWithAnyText(fullcodeText)) {
                
            }
        } else {
            [string appendString:(NSMutableString *)item];
        }
    }
    return string;
}

#pragma mark - 区分文字里面的六连数字(六连数字当作股票代码,是否是真股票就后面判断)
+ (void)checkStockDmFromString:(NSString *)string {
	if (!TTIsStringWithAnyText(string)) return;

	__block NSMutableString *dmString = [NSMutableString string];
	__block NSInteger lastIndex = string.length - 1;

	[string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
		^(NSString * substring, NSRange substringRange, NSRange enclosingRange, BOOL * stop) {
			const unichar hs = [substring characterAtIndex:0];
			BOOL isNum = NO;

			if (hs >= 48 && hs <= 57) {
				[dmString appendString:substring];
				isNum = YES;
			}

			if (!isNum || substringRange.location == lastIndex) {
				if (TTIsStringWithAnyText (dmString)) {
					if (dmString.length == 6) {
						[self addFullcodeString:dmString];
					} else {
						[self addText:dmString];
					}
					[dmString deleteCharactersInRange:NSMakeRange (0, dmString.length)];
				}

				if (!isNum) [self addText:substring];
			}
		}];
}

+ (void)faceStringRelease {
	if (stringArray) [stringArray removeAllObjects];
	RELEASE(stringArray);

	if (faceDictionary) [faceDictionary removeAllObjects];
	RELEASE(faceDictionary);
}

/*=====================================================以下方法自己添加,按需要来==============================================================================*/

#pragma mark -
#pragma mark -
#pragma mark - 股友吧和好友圈所用

#pragma mark - 股友吧,主题页面专用
+ (NSString *)faceStringForTalkieTalkiePlazaForDetail:(NSString *)say textColor:(NSString *)textColor {
     if (!TTIsStringWithAnyText(say)) return @"";
    BOOL isSpliceFullcode = say.length <= 1000;
    return [self spliceAllStringForHtmlWithString:say textSize:16
                                        imageSize:CGSizeMake(33, 33) imagePaddingPoint:CGPointMake(2, (CURRENT_DEVICE_VERSION>=7.0?5:4))
                                        textColor:textColor urlSize:16  urlColor:@"#6f6f6f"
                                    isSpliceTopic:isSpliceFullcode topicSize:16 topicColor:@"#40b5ff"
                                 isSpliceFullcode:isSpliceFullcode fullcodeSize:16 fullcodeColor:@"#6daad1"];
}

#pragma mark - 股友吧,解析前面200个符
+ (NSString *)faceStringForTalkieTalkiePlaza:(NSString *)say isCutHeader:(BOOL)isCutHeader isSpliceFullcode:(BOOL)isSpliceFullcode textColor:(NSString *)textColor  {
    if (isCutHeader && TTIsStringWithAnyText(say) && say.length > 200) {
        say = [say substringToIndex:200];
    }
    return [self spliceAllStringForHtmlWithString:say textSize:16 imageSize:CGSizeMake(33, 33)
                                imagePaddingPoint:CGPointMake(2, (CURRENT_DEVICE_VERSION>=7.0?5:4)) textColor:textColor urlSize:16
                                         urlColor:@"#6f6f6f" isSpliceTopic:isSpliceFullcode topicSize:16
                                       topicColor:@"#40b5ff" isSpliceFullcode:isSpliceFullcode fullcodeSize:16
                                    fullcodeColor:@"#6daad1"];
}

#pragma mark - 股友吧和好友圈帖子评论
+ (NSString *)faceStringForTalkieTalkiePlazaComment:(NSString *)say {
	return [self spliceAllStringForHtmlWithString:say textSize:14 imageSize:CGSizeMake(33, 33) imagePaddingPoint:CGPointMake(2, (CURRENT_DEVICE_VERSION>=7.0?5:4)) textColor:@"#808080" urlSize:16 urlColor:@"#6f6f6f" isSpliceTopic:YES topicSize:14 topicColor:@"#40b5ff" isSpliceFullcode:YES fullcodeSize:14 fullcodeColor:@"#6daad1"];
}

#pragma mark - 好友圈所用


#pragma mark - 好友圈帖子内容
+ (NSString *)faceStringForNewFriend:(NSString *)say {
	return [self spliceAllStringForHtmlWithString:say textSize:16  imageSize:CGSizeMake(33, 33) imagePaddingPoint:CGPointMake(2, (CURRENT_DEVICE_VERSION>=7.0?5:4)) textColor:@"#000000" urlSize:16 urlColor:@"#6f6f6f" isSpliceTopic:NO topicSize:0 topicColor:@"" isSpliceFullcode:YES fullcodeSize:16 fullcodeColor:@"#6daad1"];
}

#pragma mark - 股友吧和好友圈帖子评论
+ (NSString *)faceStringForNewFriendComment:(NSString *)say {
	return [self spliceAllStringForHtmlWithString:say textSize:14 imageSize:CGSizeMake(33, 33) imagePaddingPoint:CGPointMake(2, (CURRENT_DEVICE_VERSION>=7.0?5:4)) textColor:@"#808080" urlSize:16 urlColor:@"#6f6f6f" isSpliceTopic:NO topicSize:0 topicColor:@"" isSpliceFullcode:YES fullcodeSize:14 fullcodeColor:@"#6daad1"];
}

@end

