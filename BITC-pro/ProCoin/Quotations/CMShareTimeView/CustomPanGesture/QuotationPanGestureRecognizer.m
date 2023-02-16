//
//  QuotationPanGestureRecognizer.m
//  Cropyme
//
//  Created by Hay on 2019/7/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "QuotationPanGestureRecognizer.h"

int const static kDirectionPanThreshold = 5;

@implementation QuotationPanGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_drag) {
        if (abs(_moveX) > kDirectionPanThreshold) {
            if (_direction == QuotationPanGestureRecognizerVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }else if (abs(_moveY) > kDirectionPanThreshold) {
            if (_direction == QuotationPanGestureRecognizerHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }
    }
}

- (void)reset
{
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
