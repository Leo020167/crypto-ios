//
//  MTDashLine.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/27.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "MTDashLine.h"

@implementation MTDashLine

#pragma mark - Object Lifecycle

- (instancetype)init {
    self = [super init];

    if (self) {
        // Set Default Values
        _thickness = 1.0f;
        _color = [UIColor whiteColor];
        _dashedGap = 1.0f;
        _dashedLength = 5.0f;
        self.clipsToBounds = YES;
    }

    return self;
}

#pragma mark - View Lifecycle

- (void)layoutSubviews {
    // Note, this object draws a straight line. If you wanted the line at an angle you simply need to adjust the start and/or end point here.
    [self updateLineStartingAt: CGPointZero andEndPoint:CGPointMake(self.frame.size.width, 0)];
}

#pragma mark - Setters

- (void)setThickness:(CGFloat)thickness {
    _thickness = thickness;
    [self setNeedsLayout];
}

- (void)setColor:(UIColor *)color {
    _color = [color copy];
    [self setNeedsLayout];
}

- (void)setDashedGap:(CGFloat)dashedGap {
    _dashedGap = dashedGap;
    [self setNeedsLayout];
}

- (void)setDashedLength:(CGFloat)dashedLength {
    _dashedLength = dashedLength;
    [self setNeedsLayout];
}

#pragma mark - Draw Methods

-(void)updateLineStartingAt:(CGPoint)beginPoint andEndPoint:(CGPoint)endPoint {

    // Important, otherwise we will be adding multiple sub layers
    if ([[[self layer] sublayers] objectAtIndex:0]) {
        self.layer.sublayers = nil;
    }

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds)/ 2)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:self.color.CGColor];
    [shapeLayer setLineWidth:self.thickness];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:@[@(self.dashedLength), @(self.dashedGap)]];

    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, beginPoint.x, beginPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);

    [shapeLayer setPath:path];
    CGPathRelease(path);

    [[self layer] addSublayer:shapeLayer];
}


@end
