//
//  TJRBaseTitleImageView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-12-27.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseTitleImageView.h"

@implementation TJRBaseTitleImageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        for (NSLayoutConstraint *l in self.constraints) {
            if (l.firstAttribute == NSLayoutAttributeHeight) {
                if (CURRENT_DEVICE_VERSION < 11.0) {
                    l.constant += 24;
                }
                break;
            }
        }
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

- (void)dealloc {
	[super dealloc];
}

@end

