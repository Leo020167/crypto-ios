//
//  VerticalLabel.m
//  TJRtaojinroad
//
//  Created by taojinroad on 2016/12/21.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "VerticalLabel.h"

@implementation VerticalLabel

@synthesize verticalAlignment = _verticalAlignment;

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.verticalAlignment = VerticalAlignmentMiddle;
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.verticalAlignment = VerticalAlignmentMiddle;
    }
    return self;
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
	_verticalAlignment = verticalAlignment;
	[self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	switch (self.verticalAlignment) {
		case VerticalAlignmentTop:
			textRect.origin.y = self.bounds.origin.y;
			break;

		case VerticalAlignmentMiddle:
			break;
		case VerticalAlignmentBottom:
			textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
			break;

		default:
			textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
			break;
	}
	return textRect;
}

- (void)drawTextInRect:(CGRect)rect {
	CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
	[super drawTextInRect:actualRect];
}

@end
