//
//  TJRCommentString.m
//  RCLabel
//
//  Created by taojin on 13-7-09.
//
//

#import "TJRCommentString.h"


@implementation TJRCommentString

- (id)init {
	self = [super init];

	if (self) {
	}

	return self;
}




#pragma mark - 传入股票代码和股票简称返回特定字符串(需要保留的自行copy,否则自动销毁)
- (NSString *)convertStringWithFdm:(NSString *)fdm jc:(NSString *)jc
{
    //格式为{"fdm":"sz002090","jc":"金智科技"}字符串
    NSString *component1 = [NSString stringWithFormat:@"{\"%@\":\"%@\"",@"fdm",fdm];
    NSString *component2 = [NSString stringWithFormat:@"\"%@\":\"%@\"}",@"jc",jc];
    
    return [NSString stringWithFormat:@"%@,%@",component1,component2];
}


#pragma mark - 将输入文字生成html语句
/**
 *    将输入文字生成html语句.
 *    如：把文本中首个包含key转换为<a fullcode='key'><font underline='3'>name</font></a>
 *    @param dictionary 包含fullcode的字典,格式：{"fdm":"sz002090","jc":"金智科技"},其中jc作为key
 *    @param text 输入的完整文章内容
 *    @returns html语句
 */
- (NSString *)spliceAllStringForHtmlWithString:(NSString *)text dictionary:(NSDictionary*)dictionary{
	if (!text || (text.length == 0)) {
		return @"";
	}
    
	for (int i = 0 ; i<dictionary.allKeys.count; i++) {
        NSString* key = [dictionary.allKeys objectAtIndex:i];
        NSRange rang = [text rangeOfString:key];
        if (rang.location != NSNotFound) {
            text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font underline='1' color='#0ca6f2'>%@</font></a>",[dictionary objectForKey:key],key],[text substringFromIndex:rang.location+rang.length]];
        }
    }
    return [self htmlToText:text];
}

#pragma mark -  将输入文字生成html语句(颜色，字体大小,是否有下划线,下滑线多少自行设置).
- (NSString *)spliceAllStringForHtmlWithString:(NSString *)text dictionary:(NSDictionary *)dictionary fontSize:(NSInteger)fontSize textColor:(NSString *)textColor underLine:(BOOL)isUnderLine strokeRough:(NSInteger)strokeRough
{
    
    if (!text || (text.length == 0)) {
		return @"";
	}
    
    if(fontSize == 0){              //字体大小为默认
        if(textColor == nil || textColor.length == 0){ //字体颜色为默认
            if(underline){  //有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font underline='%ld'>%@</font></a>",[dictionary objectForKey:key],(long)strokeRough,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }else{      //没有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'>%@</font></a>",[dictionary objectForKey:key],key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }
        }else{  //字体颜色为自行设置
            if(underline){  //有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font color='%@' underline='%ld'>%@</font></a>",[dictionary objectForKey:key],textColor,(long)strokeRough,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }else{      //没有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font color='%@'>%@</font></a>",[dictionary objectForKey:key],textColor,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }
        }
    }else{      //字体大小由自己设置
        if(textColor == nil || textColor.length == 0){ //字体颜色为默认
            if(underline){  //有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font size=%ld underline='%ld'>%@</font></a>",[dictionary objectForKey:key],(long)fontSize,(long)strokeRough,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }else{      //没有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font size=%ld>%@</font></a>",[dictionary objectForKey:key],(long)fontSize,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }
        }else{  //字体颜色为自行设置
            if(underline){  //有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font size=%ld color='%@' underline='%ld'>%@</font></a>",[dictionary objectForKey:key],(long)fontSize,textColor,(long)strokeRough,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }else{      //没有下划线
                //生成html text
                for (int i = 0 ; i<dictionary.allKeys.count; i++) {
                    NSString* key = [dictionary.allKeys objectAtIndex:i];
                    NSRange rang = [text rangeOfString:key];
                    text = [NSString stringWithFormat:@"%@%@%@",[text substringWithRange:NSMakeRange(0, rang.location)], [NSString stringWithFormat:@"<a fullcode='%@'><font size=%ld color='%@'>%@</font></a>",[dictionary objectForKey:key],(long)fontSize,textColor,key],[text substringFromIndex:rang.location+rang.length]];
                }
                return [self htmlToText:text];
            }
        }

    }
}


- (NSString *)htmlToText:(NSString *)htmlString
{
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@"&"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@""""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&#039;"  withString:@"'"];
    
    // Extras
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<3" withString:@"♥"];
    
    return htmlString;
}



- (void)dealloc {
	[super dealloc];
}

@end

