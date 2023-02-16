//
//  NSString+Align.h
//  Redz
//
//  Created by Taojin on 2018/7/23.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Align)

// 设置两端对齐的富文本
- (NSMutableAttributedString*)getAttStrWithfont:(UIFont *)font;

// 计算富文本高度
- (CGFloat)heightForMaxWidth:(CGFloat)maxWidth withFont:(UIFont*)font;


/**
 根据字符串获取 宽度
 */
- (CGFloat)getWidthWithFont:(NSInteger)font;

@end
