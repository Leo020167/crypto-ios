//
//  NSString+Align.m
//  Redz
//
//  Created by Taojin on 2018/7/23.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "NSString+Align.h"

@implementation NSString (Align)

// 设置两端对齐的富文本
- (NSMutableAttributedString*)getAttStrWithfont:(UIFont *)font{
    
    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
//    [paragraphStyle setLineSpacing:2];//行间距
    paragraphStyle.alignment = NSTextAlignmentJustified;//文本对齐方式 左右对齐（两边对齐）
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail]; //截断方式,"abcd..."

    NSMutableAttributedString * attributedString = [[[NSMutableAttributedString alloc] initWithString:self] autorelease];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self length])];//设置段落样式
    
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [self length])];//设置字体大小
    
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [self length])];//这段话必须要添加，否则UIlabel两边对齐无效 NSUnderlineStyleAttributeName （设置下划线）
    
    return attributedString;
}

// 计算富文本高度
- (CGFloat)heightForMaxWidth:(CGFloat)maxWidth withFont:(UIFont*)font {
 
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    /*
     不要设置NSMutableParagraphStyle.lineBreakMode为
     NSLineBreakByClipping
     NSLineBreakByTruncatingHead
     NSLineBreakByTruncatingMiddle
     NSLineBreakByTruncatingTail
     不然高度会一直为一行.
     */
    // [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail]; //截断方式,"abcd..."
    paraStyle.alignment = NSTextAlignmentJustified;  //文本对齐方式 左右对齐（两边对齐）
//    [paraStyle setLineSpacing:2]; //行间距
    // NSKernAttributeName字体间距
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle,NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleNone]};
    CGSize size = [self boundingRectWithSize:CGSizeMake(maxWidth,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:dic context:nil].size;
    return  size.height;
}

- (CGFloat)getWidthWithFont:(NSInteger)font{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, font) options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
}


@end
