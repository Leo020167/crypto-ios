//
//  UIOutLineLabel.m
//  TJRtaojinroad
//
//  Created by taojinroad on 16/4/19.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "UIOutLineLabel.h"

@implementation UIOutLineLabel

- (void)drawTextInRect:(CGRect)rect {
	CGSize shadowOffset = self.shadowOffset;
	UIColor *textColor = self.textColor;

	CGContextRef c = UIGraphicsGetCurrentContext();

	CGContextSetLineWidth(c, 2);
	CGContextSetLineJoin(c, kCGLineJoinRound);

	CGContextSetTextDrawingMode(c, kCGTextStroke);
	self.textColor = self.shadowColor;
	[super drawTextInRect:rect];

	CGContextSetTextDrawingMode(c, kCGTextFill);
	self.textColor = textColor;
	self.shadowOffset = CGSizeMake(0, 0);
	[super drawTextInRect:rect];

	self.shadowOffset = shadowOffset;
}

@end
