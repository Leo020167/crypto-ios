//
//  TJRBaseTitleView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-12-27.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseTitleView.h"

@implementation TJRBaseTitleView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        for (NSLayoutConstraint *l in self.constraints) {
            if (l.firstAttribute == NSLayoutAttributeHeight) {
                l.constant = self.frame.size.height + ( [UIApplication sharedApplication].statusBarFrame.size.height - 20);
                break;
            }
        }
        /** 默认添加底部线条*/
        if(self.tag == 0){
            UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height + ( [UIApplication sharedApplication].statusBarFrame.size.height - 20) - 0.5, SCREEN_WIDTH,0.5)];
            lineView.backgroundColor = RGBA(220, 220, 220, 1.0);
            [self addSubview:lineView];
            [lineView release];
        }
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)dealloc
{
    [super dealloc];
}

@end

