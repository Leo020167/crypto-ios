//
//  PuzzleSlider.m
//  Redz
//
//  Created by taojinroad on 2018/10/12.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuzzleSlider.h"
#import "UIImage+Color.h"

@implementation PuzzleSlider

- (id)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        [self initSlider];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSlider];
    }
    return self;
}

- (void)initSlider{
    
    [self start];
    
    UIImage* imageMax = [UIImage imageWithColor:RGBA(238, 238, 238, 1) size:CGSizeMake(1.0, 1.0)];
    UIImage* imgMax = [imageMax stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    [self setMaximumTrackImage:imgMax forState:UIControlStateNormal];
}

// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)start{
    [self setThumbImage:[UIImage imageNamed:@"puzzle_bar_selected"] forState:UIControlStateNormal];
    
    UIImage* imageMin = [UIImage imageWithColor:RGBA(248, 146, 95, 1) size:CGSizeMake(1.0, 1.0)];
    UIImage* imgMin = [imageMin stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    [self setMinimumTrackImage:imgMin forState:UIControlStateNormal];
}

- (void)end{
    [self setThumbImage:[UIImage imageNamed:@"puzzle_bar_finish"] forState:UIControlStateNormal];
    
    UIImage* imageMin = [UIImage imageWithColor:RGBA(48, 202, 153, 1) size:CGSizeMake(1.0, 1.0)];
    UIImage* imgMin = [imageMin stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    [self setMinimumTrackImage:imgMin forState:UIControlStateNormal];
}

@end
