//
//  TJRSegmentedControl.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-4-2.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRSegmentedControl.h"
#import "CommonUtil.h"

@implementation TJRSegmentedControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    [self setTintColor:[UIColor blueColor]];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        [CommonUtil viewMasksToBounds:self cornerRadius:4.0f borderColor:nil];
    }
}

- (void)setTintColor:(UIColor *)color {
    if (!color) return;
    [super setTintColor:color];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        [self setBackgroundImage:[CommonUtil createImageWithColor:color withSize:CGSizeMake(1, 29)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [self setBackgroundImage:[CommonUtil createImageWithColor:[UIColor whiteColor] withSize:CGSizeMake(1, 29)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [self setDividerImage:[CommonUtil createImageWithColor:color withSize:CGSizeMake(1, 29)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [self setTitleTextAttributes:@ {
        NSForegroundColorAttributeName:color,
        NSFontAttributeName:[UIFont systemFontOfSize:14],
        NSShadowAttributeName:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]
        } forState:UIControlStateNormal];
        
        [self setTitleTextAttributes:@ {
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSFontAttributeName:[UIFont systemFontOfSize:14],
        NSShadowAttributeName:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]
        } forState:UIControlStateSelected];
        self.layer.borderColor = [color CGColor];
    }
}

- (void)setTintColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor{
    if (!color || !backgroundColor) return;
    [self setTintColor:color];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        [self setBackgroundImage:[CommonUtil createImageWithColor:color withSize:CGSizeMake(1, 29)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [self setBackgroundImage:[CommonUtil createImageWithColor:backgroundColor withSize:CGSizeMake(1, 29)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [self setDividerImage:[CommonUtil createImageWithColor:color withSize:CGSizeMake(1, 29)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }else{
        [self setBackgroundColor:backgroundColor];
    }
}

@end
