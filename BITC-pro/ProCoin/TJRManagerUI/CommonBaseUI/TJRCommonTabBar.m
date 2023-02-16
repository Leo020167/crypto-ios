//
//  TJRCommonTabBar.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-30.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRCommonTabBar.h"

@implementation TJRCommonTabBar

- (void)drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"quotation_titlebar_bg@2x.png"];
    [barImage drawInRect:rect];
}

@end
