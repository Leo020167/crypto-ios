//
//  EVCircularProgressView.m
//  Test
//
//  Created by Ethan Vaughan on 8/18/13.
//  Copyright (c) 2013 Ethan James Vaughan. All rights reserved.
//

#import "EVCircularProgressView.h"

#define DEGREES_TO_RADIANS(x) (x) / 180.0 * M_PI
#define RADIANS_TO_DEGREES(x) (x) / M_PI * 180.0
#define LoadingImageBaseName  _isFooter == YES ? @"loading_footer" :@"loading_icon"
@interface EVCircularProgressViewBackgroundLayer : CALayer
{}
@property (nonatomic, strong) UIColor *tintColor;

@end

@implementation EVCircularProgressViewBackgroundLayer

- (id)init {
	self = [super init];

	if (self) {
		self.contentsScale = [UIScreen mainScreen].scale;
	}
    
	return self;
}

- (void)dealloc {
	[_tintColor release];
	[super dealloc];
}

- (void)setTintColor:(UIColor *)tintColor {
	[_tintColor release]; _tintColor = nil;
	_tintColor = [tintColor retain];
	self.opacity = 0;
	[self setNeedsDisplay];
}



@end

@interface EVCircularProgressView ()

@property (nonatomic, retain) EVCircularProgressViewBackgroundLayer *backgroundLayer;
@property (nonatomic, retain) CAShapeLayer *shapeLayer;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation EVCircularProgressView {
	UIColor *_progressTintColor;
}

- (instancetype)init {
	self = [super initWithFrame:CGRectMake(0, 0, 100, 55)];

	if (self) {
		[self commonInit];
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];

	if (self) {
		[self commonInit];
	}

	return self;
}

- (void)commonInit {
	self.progressTintColor = [UIColor colorWithRed:128.0 / 255.0 green:128.0 / 255.0 blue:128.0 / 255.0 alpha:1];

	// Set up the background layer

	EVCircularProgressViewBackgroundLayer *backgroundLayer = [[[EVCircularProgressViewBackgroundLayer alloc] init]autorelease];
	backgroundLayer.frame = self.bounds;
	backgroundLayer.tintColor = self.progressTintColor;
	[self.layer addSublayer:backgroundLayer];
	self.backgroundLayer = backgroundLayer;
	[self setStyle:EVCircularProgressBlackTint];
	self.backgroundLayer.opacity = 0;
	// Set up the shape layer

	CAShapeLayer *shapeLayer = [[[CAShapeLayer alloc] init]autorelease];
	shapeLayer.frame = self.bounds;
	shapeLayer.fillColor = nil;
	shapeLayer.strokeColor = self.progressTintColor.CGColor;

	[self.layer addSublayer:shapeLayer];
	self.shapeLayer = shapeLayer;

	[self stopIndeterminateAnimation];
}

- (void)setStyle:(EVCircularProgressStyle)style {
	if (_style == EVCircularProgressBlackTint) {
		self.backgroundLayer.contents = (id)[UIImage imageNamed:LoadingImageBaseName].CGImage;
	} else if (_style == EVCircularProgressWhiteTint) {
		self.backgroundLayer.contents = (id)[UIImage imageNamed:LoadingImageBaseName].CGImage;
    } else {
		self.backgroundLayer.contents = (id)[UIImage imageNamed:LoadingImageBaseName].CGImage;
	}
    self.shapeLayer.contents = (id)[UIImage imageNamed:LoadingImageBaseName].CGImage;
    self.shapeLayer.affineTransform = CGAffineTransformMakeScale(0, 0);
	_style = style;
}

#pragma mark - Accessors

- (void)setProgress:(float)progress animated:(BOOL)animated {
	_progress = progress;

	if (progress >= 0) {

		[self stopIndeterminateAnimation];

        self.shapeLayer.affineTransform = CGAffineTransformMakeScale(progress, progress);
        
	} else {
		[self.shapeLayer removeAnimationForKey:@"animation"];

		[self startIndeterminateAnimation];
	}
}

- (void)setProgress:(float)progress {
	[self setProgress:progress animated:NO];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
	if ([self respondsToSelector:@selector(setTintColor:)]) {
		self.tintColor = progressTintColor;
	} else {
		_progressTintColor = progressTintColor;
		[self tintColorDidChange];
	}
}

- (UIColor *)progressTintColor {
	if ([self respondsToSelector:@selector(tintColor)]) {
		return self.tintColor;
	} else {
		return _progressTintColor;
	}
}

#pragma mark - UIControl overrides

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
	if (self.progress > 0) {
		[super sendAction:action to:target forEvent:event];
	}
}

#pragma mark - Other methods

- (void)tintColorDidChange {
	self.backgroundLayer.tintColor = self.progressTintColor;
	self.shapeLayer.strokeColor = self.progressTintColor.CGColor;
}

- (void)startIndeterminateAnimation {
	[CATransaction begin];
	[CATransaction setDisableActions:YES];

	self.shapeLayer.path = nil;

	[CATransaction commit];

	CAKeyframeAnimation *animation = (CAKeyframeAnimation *)[self.shapeLayer animationForKey:@"contents"];

	if (!animation) {
		animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
		NSMutableArray *values = [[NSMutableArray alloc]init];

		if (_style == EVCircularProgressBlackTint) {
            NSInteger count = _isFooter == YES ? 30 : 53;
            for (int i = 0; i < count; i++) {
                [values insertObject:(id)[UIImage imageNamed:[NSString stringWithFormat:@"%@_%d",LoadingImageBaseName, i]].CGImage atIndex:i];
            }

		} else if (_style == EVCircularProgressWhiteTint) {
			for (int i = 0; i < 30; i++) {
				[values insertObject:(id)[UIImage imageNamed:[NSString stringWithFormat:@"progress_icon_white_%d", i]].CGImage atIndex:i];
			}
		}

		animation.values = values;	// NSArray of CGImageRefs
		animation.calculationMode = kCAAnimationDiscrete;
        animation.duration = _isFooter ? 1.0 : 1.5;
		animation.repeatCount = HUGE_VALF;
	}
	[self.shapeLayer addAnimation:animation forKey:@"contents"];
}

- (void)stopIndeterminateAnimation {
	[self.shapeLayer removeAnimationForKey:@"contents"];

	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	self.backgroundLayer.hidden = NO;
	[CATransaction commit];
}

@end
