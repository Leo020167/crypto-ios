//
//  UIView+UIViewEXT.m
//  CanXinTong
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UIView+General.h"

@implementation UIView (General)

- (void)setWidth:(CGFloat)width {
	CGRect rect = self.frame;

	rect.size.width = width;
	self.frame = rect;
}

- (void)setHeight:(CGFloat)height {
	CGRect rect = self.frame;

	rect.size.height = height;
	self.frame = rect;
}

- (void)setX:(CGFloat)x {
	CGRect rect = self.frame;

	rect.origin.x = x;
	self.frame = rect;
}

- (void)setY:(CGFloat)y {
	CGRect rect = self.frame;

	rect.origin.y = y;
	self.frame = rect;
}

- (CGFloat)x {
	return self.frame.origin.x;
}

- (CGFloat)y {
	return self.frame.origin.y;
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (CGFloat)maxY {
	return CGRectGetMaxY(self.frame);
}

- (CGFloat)maxX {
	return CGRectGetMaxX(self.frame);
}

- (void)setSize:(CGSize)size {
	CGRect rect = self.frame;

	rect.size = size;
	self.frame = rect;
}

- (void)horizontalCenterWithWidth:(CGFloat)width {
	[self setX:ceilf((width - self.width) / 2)];
}

- (void)verticalCenterWithHeight:(CGFloat)height {
	[self setY:ceilf((height - self.height) / 2)];
}

- (void)verticalCenterInSuperView {
	[self verticalCenterWithHeight:self.superview.height];
}

- (void)horizontalCenterInSuperView {
	[self horizontalCenterWithWidth:self.superview.width];
}

- (void)setBoarderWith:(CGFloat)width color:(CGColorRef)color {
	self.layer.borderWidth = width;
	self.layer.borderColor = color;
}

- (void)setCornerRadius:(CGFloat)radius {
	self.layer.cornerRadius = radius;
}

- (CALayer *)addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef {
	CALayer *layer = [CALayer layer];

	layer.frame = frame;
	layer.backgroundColor = colorRef;
	[self.layer addSublayer:layer];
	return layer;
}

- (void)setTarget:(id)target action:(SEL)action {
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];

	[self addGestureRecognizer:recognizer];
}

- (UIImage *)capture {
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(270, self.bounds.size.height), self.opaque, 0.0);

	[self.layer renderInContext:UIGraphicsGetCurrentContext()];

	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return img;
}

- (void)applyRadiusMask:(CGFloat)topLeft bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight topRight:(CGFloat)topRight {
    CGSize size = self.bounds.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake( self.bounds.size.width - topRight, 0)];
    [path addLineToPoint:CGPointMake(topLeft, 0)];
    [path addQuadCurveToPoint:CGPointMake(0, topLeft) controlPoint: CGPointZero];
    [path addLineToPoint:CGPointMake(0, self.bounds.size.height - bottomLeft)];
    [path addQuadCurveToPoint:CGPointMake(bottomLeft, self.bounds.size.height) controlPoint:CGPointMake(0, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - bottomRight, self.bounds.size.height)];
    [path addQuadCurveToPoint:CGPointMake(size.width, size.height - bottomRight) controlPoint:CGPointMake(size.width, size.height)];
    [path addLineToPoint:CGPointMake(size.width, topRight)];
    [path addQuadCurveToPoint:CGPointMake(size.width - topRight, 0) controlPoint:CGPointMake(size.width, 0)];
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = path.CGPath;
    self.layer.mask = shape;
}

// 适配阴影
- (void)applyShadow {
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowRadius = 4.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.1;
    self.layer.masksToBounds = NO;
}

//四边阴影(shadowPath 用法)
- (void)allShadow {
    UIView *_contentView = [[UIView alloc] initWithFrame:self.bounds];
    
    _contentView.backgroundColor = [UIColor redColor];
    
    [self addSubview:_contentView];
    
    //shadowColor阴影颜色
    _contentView.layer.shadowColor = [UIColor blueColor].CGColor;
    
    //shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    _contentView.layer.shadowOffset = CGSizeMake(0,0);
    
    //阴影透明度，默认0
    _contentView.layer.shadowOpacity = 1;
    
    //阴影半径，默认3
    _contentView.layer.shadowRadius = 10;
    
    //路径阴影(借助贝塞尔曲线)
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = _contentView.bounds.size.width;
    float height = _contentView.bounds.size.height;
    float x = _contentView.bounds.origin.x;
    float y = _contentView.bounds.origin.y;
    float addWH = 10;
    
    CGPoint topLeft      = _contentView.bounds.origin;
    CGPoint topMiddle = CGPointMake(x+(width/2),y-addWH);
    CGPoint topRight     = CGPointMake(x+width,y);
    
    CGPoint rightMiddle = CGPointMake(x+width+addWH,y+(height/2));
    
    CGPoint bottomRight  = CGPointMake(x+width,y+height);
    CGPoint bottomMiddle = CGPointMake(x+(width/2),y+height+addWH);
    CGPoint bottomLeft   = CGPointMake(x,y+height);
    
    
    CGPoint leftMiddle = CGPointMake(x-addWH,y+(height/2));
    
    [path moveToPoint:topLeft];
    //添加四个二元曲线
    [path addQuadCurveToPoint:topRight
                 controlPoint:topMiddle];
    [path addQuadCurveToPoint:bottomRight
                 controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft
                 controlPoint:bottomMiddle];
    [path addQuadCurveToPoint:topLeft
                 controlPoint:leftMiddle];
    //设置阴影路径
    _contentView.layer.shadowPath = path.CGPath;
}
@end
