//
//  DrawTouchPointView.m
//  DrawTouchPointTest
//
//  Created by ethan on 11-10-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawTouchPointView.h"
#import "DWStroke.h"

@implementation DrawTouchPointView
@synthesize brushColor;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	currentPath = CGPathCreateMutable();
	DWStroke *stroke = [[DWStroke alloc] init];
	stroke.path = currentPath;
	stroke.blendMode =  kCGBlendModeNormal;
	stroke.strokeWidth =  2.0;
	stroke.strokeColor = [brushColor CGColor];
	[stroks addObject:stroke];
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPathMoveToPoint(currentPath, NULL, point.x, point.y);
	
	CGPathRelease(currentPath);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPathAddLineToPoint(currentPath, NULL, point.x, point.y);
	[self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		stroks = [[NSMutableArray alloc] initWithCapacity:1];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	for (DWStroke *stroke in stroks) {
		[stroke strokeWithContext:context];
	}
}


- (void)dealloc {
	[stroks release];
    [brushColor release];
    [super dealloc];
}


@end
