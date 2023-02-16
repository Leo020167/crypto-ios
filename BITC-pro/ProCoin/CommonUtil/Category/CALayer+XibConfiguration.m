//
//  CALayer+XibConfiguration.m
//  TJRtaojinroad
//
//  Created by taojinroad on 16/1/5.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer (XibConfiguration)

- (void)setBorderUIColor:(UIColor *)color {
	self.borderColor = color.CGColor;
}

- (UIColor *)borderUIColor {
	return [UIColor colorWithCGColor:self.borderColor];
}

@end
