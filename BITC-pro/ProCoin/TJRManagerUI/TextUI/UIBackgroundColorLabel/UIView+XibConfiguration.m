//
//  UIViewBackgroundColor+XibConfiguration.m
//  TJRtaojinroad
//
//  Created by taojinroad on 16/1/12.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "UIView+XibConfiguration.h"
#import "CommonUtil.h"

@implementation UIView(XibConfiguration)

- (void)setBackgroundUIColor:(UIColor *)color {
    self.backgroundColor = color;
}

- (UIColor *)backgroundUIColor {
    return self.backgroundColor;
}
@end

@implementation UIButton(XibConfiguration)
- (void)setNormalImageColor:(UIColor *)color {
    [self setBackgroundImage:[CommonUtil createImageWithColor:color] forState:UIControlStateNormal];
}

- (UIColor *)normalImageColor {
    return [UIColor clearColor];
}

- (void)setHighlightedImageColor:(UIColor *)color {
    [self setBackgroundImage:[CommonUtil createImageWithColor:color] forState:UIControlStateHighlighted];
}

- (UIColor *)highlightedImageColor {
    return [UIColor clearColor];
}

- (void)setSelectedImageColor:(UIColor *)color {
    [self setBackgroundImage:[CommonUtil createImageWithColor:color] forState:UIControlStateSelected];
}

- (UIColor *)selectedImageColor {
    return [UIColor clearColor];
}

@end
