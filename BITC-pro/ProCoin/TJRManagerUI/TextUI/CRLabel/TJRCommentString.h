//
//  TJRCommentString.h
//  RCLabel
//
//  Created by taojin on 13-4-11.
//
//

#import <Foundation/Foundation.h>

@interface TJRCommentString : NSObject



/**
 *    将输入文字生成html语句(默认字体大小，蓝色字，有下划线).
 *    如：把文本中首个包含key转换为"<a fullcode='key'><font underline='3'>name</font></a>"
 *    @param dictionary 包含fullcode的字典,格式：{"fdm":"sz002090","jc":"金智科技"},其中jc作为key
 *    @param text 输入的完整文章内容
 *    @returns html语句
 */
- (NSString *)spliceAllStringForHtmlWithString:(NSString *)text dictionary:(NSDictionary*)dictionary;

/**
 *    将输入文字生成html语句(颜色，字体大小,是否有下划线,下滑线多少自行设置).
 *    如：把文本中首个包含key转换为"<a fullcode='key'><font underline='3'>name</font></a>"
 *    @param dictionary 包含fullcode的字典,格式：{"fdm":"sz002090","jc":"金智科技"},其中jc作为key
 *    @param text 输入的完整文章内容
 *    @param fontSize 字体大小(0为默认大小)
 *    @param textColor 字体颜色(nil为默认蓝色)
 *    @param underLine 是否有下划线
 *    @param strokeRough 下划线粗幼程度
 *    @returns html语句
 */
- (NSString *)spliceAllStringForHtmlWithString:(NSString *)text dictionary:(NSDictionary *)dictionary fontSize:(NSInteger)fontSize textColor:(NSString *)textColor underLine:(BOOL)isUnderLine strokeRough:(NSInteger)strokeRough;

/**
 *传入股票代码和股票简称返回特定字符串(需要保留的自行copy,否则自动销毁)
 @param fdm 股票代码
 @param jc  股票简称
 @return 格式为{"fdm":"sz002090","jc":"金智科技"}字符串
 */
- (NSString *)convertStringWithFdm:(NSString *)fdm jc:(NSString *)jc;
@end

