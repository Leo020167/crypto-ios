//
//  QuadCurveMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kQuadCurveMenuDefaultNearRadius = 60.0f;
static CGFloat const kQuadCurveMenuDefaultEndRadius = 70.0f;
static CGFloat const kQuadCurveMenuDefaultFarRadius = 80.0f;
static CGFloat const kQuadCurveMenuDefaultTimeOffset = 0.036f;
static CGFloat const kQuadCurveMenuDefaultRotateAngle = 0.0;
static CGFloat const kQuadCurveMenuDefaultMenuWholeAngle = M_PI;


static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle) {
	CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
	CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
	CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);

	return CGPointApplyAffineTransform(point, transformGroup);
}

@interface QuadCurveMenu ()<CAAnimationDelegate>
- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation QuadCurveMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint;
@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;

#pragma mark - initialization & cleaning up


- (instancetype)initWithStartPoint:(CGPoint)_startPoint startSize:(CGSize)startSize
                          itemSize:(CGSize)size startImage:(UIImage *)startImage
                      submenuItems:(NSArray *)submenuItems {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGRect bounds = CGRectZero;
        bounds.size = startSize;
        self.bounds = bounds;
        startPoint = _startPoint;
        self.center = startPoint;
        self.menusArray = submenuItems;
        self.nearRadius = kQuadCurveMenuDefaultNearRadius;
        self.endRadius = kQuadCurveMenuDefaultEndRadius;
        self.farRadius = kQuadCurveMenuDefaultFarRadius;
        self.timeOffset = kQuadCurveMenuDefaultTimeOffset;
        self.rotateAngle = kQuadCurveMenuDefaultRotateAngle;
        self.menuWholeAngle = kQuadCurveMenuDefaultMenuWholeAngle;
        _addButton = [[QuadCurveMenuItem alloc] initWithImage:startImage
                                             highlightedImage:startImage
                                                 ContentImage:startImage
                                      highlightedContentImage:startImage
                                                         size:startSize];
        _addButton.delegate = self;
        [self addSubview:_addButton];
    }
    return self;
}

- (void)setItemImage:(UIImage *)image index:(int)index {
    if (index < _menusArray.count) {
        QuadCurveMenuItem *item = _menusArray[index];
        item.contentImageView.image = image;
    }
}

- (void)moveSpherMenuWithY:(CGFloat)y {
    movePoint.y = y;
    CGPoint center = self.center;
    center.x = startPoint.x + movePoint.x;
    center.y = startPoint.y + movePoint.y;
    for (QuadCurveMenuItem *item in _menusArray) {
        item.center = center;
    }
    self.center = center;
    if (self.superview) {
        [self.superview bringSubviewToFront:self];
    }
}

- (void)dealloc {
	[_addButton release];
	[_menusArray release];
	[super dealloc];
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
	_addButton.image = image;
}

- (UIImage *)image {
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage *)highlightedImage {
	return _addButton.highlightedImage;
}

- (void)setContentImage:(UIImage *)contentImage {
	_addButton.contentImageView.image = contentImage;
}

- (UIImage *)contentImage {
	return _addButton.contentImageView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage *)highlightedContentImage {
	return _addButton.contentImageView.highlightedImage;
}

#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	// if the menu state is expanding, everywhere can be touch
	// otherwise, only the add button are can be touch
	if (YES == _expanding) {
		return YES;
	} else {
		return CGRectContainsPoint(_addButton.frame, point);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.expanding = !self.isExpanding;
}

#pragma mark - QuadCurveMenuItem delegates
- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item {
	if (item == _addButton) {
		self.expanding = !self.isExpanding;
	}
}

- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item {
	// exclude the "add" button
	if (item == _addButton) {
		return;
	}
	// blowup the selected menu button
	CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
	[item.layer addAnimation:blowup forKey:@"blowup"];
	item.center = item.startPoint;

	// shrink other menu buttons
	for (int i = 0; i < [_menusArray count]; i++) {
		QuadCurveMenuItem *otherItem = [_menusArray objectAtIndex:i];
		CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];

		if (otherItem.tag == item.tag) {
			continue;
		}
		[otherItem.layer addAnimation:shrink forKey:@"shrink"];

		otherItem.center = otherItem.startPoint;
    }

	_expanding = NO;

	// rotate "add" button
//	float angle = self.isExpanding ? -M_PI_4 : 0.0f;
//	[UIView animateWithDuration:0.2f animations:^{
//		_addButton.transform = CGAffineTransformMakeRotation(angle);
//	}];

	if ([_delegate respondsToSelector:@selector(quadCurveMenu:didSelectIndex:)]) {
		[_delegate quadCurveMenu:self didSelectIndex:item.tag - 1000];
	}
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray {
	if (aMenusArray == _menusArray) {
		return;
	}
	[_menusArray release];
	_menusArray = [aMenusArray copy];

	// clean subviews
	for (UIView *v in self.subviews) {
		if (v.tag >= 1000) {
			[v removeFromSuperview];
		}
	}
}

- (void)_setMenu {
    NSUInteger count = [_menusArray count];
    
    CGFloat tempAngle = menuWholeAngle / (count - 1);
    for (int i = 0; i < count; i++) {
        QuadCurveMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = startPoint;
        CGFloat temp = M_PI_2;
        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * tempAngle - temp), startPoint.y - endRadius * cosf(i * tempAngle - temp));
        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * tempAngle - temp), startPoint.y - nearRadius * cosf(i * tempAngle - temp));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * tempAngle - temp), startPoint.y - farRadius * cosf(i * tempAngle - temp));
        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);
        item.center = item.startPoint;
        item.delegate = self;
        [self.superview insertSubview:item belowSubview:_addButton];
    }
}

- (BOOL)isExpanding {
	return _expanding;
}

- (void)setExpanding:(BOOL)expanding {
	if (expanding) {
		[self _setMenu];
	}

	_expanding = expanding;

	// rotate add button
//	float angle = self.isExpanding ? -M_PI_4 : 0.0f;
//	[UIView animateWithDuration:0.2f animations:^{
//		_addButton.transform = CGAffineTransformMakeRotation(angle);
//	}];

	// expand or close animation
	if (!_timer) {
		_flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
		SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);

		// Adding timer to runloop to make sure UI event won't block the timer from firing
		_timer = [[NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
	}
}

#pragma mark - private methods
- (void)_expand {
	if (_flag == [_menusArray count]) {
		[_timer invalidate];
		[_timer release];
		_timer = nil;
		return;
	}

	NSInteger tag = 1000 + _flag;
	QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self.superview viewWithTag:tag];

	CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:M_PI], [NSNumber numberWithFloat:0.0f], nil];
	rotateAnimation.duration = 0.5f;
	rotateAnimation.keyTimes = [NSArray arrayWithObjects:
		[NSNumber numberWithFloat:.3],
		[NSNumber numberWithFloat:.4], nil];

	CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	positionAnimation.duration = 0.5f;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, item.startPoint.x + movePoint.x, item.startPoint.y + movePoint.y);
	CGPathAddLineToPoint(path, NULL, item.farPoint.x + movePoint.x, item.farPoint.y + movePoint.y);
	CGPathAddLineToPoint(path, NULL, item.nearPoint.x + movePoint.x, item.nearPoint.y + movePoint.y);
	CGPathAddLineToPoint(path, NULL, item.endPoint.x + movePoint.x, item.endPoint.y + movePoint.y);
	positionAnimation.path = path;
	CGPathRelease(path);

	CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
	animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
	animationgroup.duration = 0.5f;
	animationgroup.fillMode = kCAFillModeForwards;
	animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[item.layer addAnimation:animationgroup forKey:@"Expand"];
    CGPoint center = item.endPoint;
    center.x += movePoint.x;
    center.y += movePoint.y;
    item.center = center;

	_flag++;
}

- (void)_close {
	if (_flag == -1) {
		[_timer invalidate];
		[_timer release];
        _timer = nil;
		return;
	}

	NSInteger tag = 1000 + _flag;
	QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self.superview viewWithTag:tag];
    
	CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:M_PI * 2], [NSNumber numberWithFloat:0.0f], nil];
	rotateAnimation.duration = 0.5f;
	rotateAnimation.keyTimes = [NSArray arrayWithObjects:
		[NSNumber numberWithFloat:.0],
		[NSNumber numberWithFloat:.4],
		[NSNumber numberWithFloat:.5], nil];

	CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	positionAnimation.duration = 0.5f;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, item.endPoint.x + movePoint.x, item.endPoint.y + movePoint.y);
	CGPathAddLineToPoint(path, NULL, item.farPoint.x + movePoint.x, item.farPoint.y + movePoint.y);
	CGPathAddLineToPoint(path, NULL, item.startPoint.x + movePoint.x, item.startPoint.y + movePoint.y);
	positionAnimation.path = path;
	CGPathRelease(path);

	CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
	animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
	animationgroup.duration = 0.5f;
	animationgroup.fillMode = kCAFillModeForwards;
	animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    CGPoint center = item.startPoint;
    center.x += movePoint.x;
    center.y += movePoint.y;
    item.center = center;
	_flag--;
    [item performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p {
	CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

	positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
	positionAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.3], nil];

	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];

	CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];

	CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
	animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
	animationgroup.duration = 0.3f;
	animationgroup.fillMode = kCAFillModeForwards;

	return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p {
	CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

	positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
	positionAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.3], nil];

	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];

	CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];

	CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
	animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
	animationgroup.duration = 0.3f;
	animationgroup.fillMode = kCAFillModeForwards;

	return animationgroup;
}


@end
