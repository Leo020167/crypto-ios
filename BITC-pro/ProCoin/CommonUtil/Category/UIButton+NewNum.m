//
//  UIButton+NewNum.m
//  TJRtaojinroad
//
//  Created by taojinroad on 16/2/1.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "UIButton+NewNum.h"
#import "CommonUtil.h"

@implementation UIButton(NewNum)
/**
 *  显示数字,或者红点
 *
 *  @param newNum 数字
 *  @param isShowDot 是否是显示红点
 */
- (void)showNewNum:(NSUInteger)newNum isShowDot:(BOOL)isShowDot {
    if (isShowDot) {
        if (newNum > 0) {
            self.hidden = false;
            [self setTitle:@"" forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"util_Icon_new_small_dot_red"] forState:UIControlStateNormal];
            [self setBackgroundImage:nil forState:UIControlStateNormal];
        } else {
            self.hidden = true;
        }
    } else {
        [self setImage:nil forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"util_Icon_new_bg_red"] forState:UIControlStateNormal];
        [self showNewNum:newNum];
    }
}

- (void)showNewNum:(NSUInteger)newNum {
    if (newNum == 0) {
        [self setTitle:@"" forState:UIControlStateNormal];
        self.hidden = true;
    } else {
        self.hidden = false;
        NSString *numString = [NSString stringWithFormat:@" %@ ", @(newNum)];
        [self setTitle:numString forState:UIControlStateNormal];
       
        if (self.translatesAutoresizingMaskIntoConstraints) {
            CGSize size = [CommonUtil getPerfectSizeByBoldText:numString andFontSize:self.titleLabel.font.pointSize andWidth:1000];
            CGRect frame = self.frame;
            frame.size.width = newNum < 10 ? 17 : size.width;
            frame.size.height = 17;
            self.frame = frame;
            UIImage *image = [self backgroundImageForState:UIControlStateNormal];
            if (image) {
                if (newNum < 10) {
                    [self setBackgroundImage:image forState:UIControlStateNormal];
                } else {
                    [self setBackgroundImage:[CommonUtil stretchableImageWithImage:image edgeInsets:UIEdgeInsetsMake(0, image.size.width/2.0f, image.size.height, image.size.width/2.0f+0.01)] forState:UIControlStateNormal];
                }
            }
        }
    }
}
@end
