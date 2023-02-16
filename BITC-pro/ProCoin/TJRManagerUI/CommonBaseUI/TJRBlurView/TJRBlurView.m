//
//  TJRBlurView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 16/5/21.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "TJRBlurView.h"

@implementation TJRBlurView

- (instancetype)init {
	self = [super init];

	if (self) {
		[self initTJRBlurView];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];

	if (self) {
		[self initTJRBlurView];
        if (self.tag == 123456789) {
            CGFloat alpha = self.alpha;
            [self setBlurViewAlpha:alpha];
            self.alpha = 1;
        }
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self initTJRBlurView];
	}
	return self;
}

- (void)initTJRBlurView {
	UIView *view = (UIView *)[self viewWithTag:10];

	if (!view) {
		if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
			UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
			toolbar.barStyle = UIBarStyleBlackTranslucent;
			[self addSubview:toolbar];
			toolbar.tag = 10;
			[self sendSubviewToBack:toolbar];
			RELEASE(toolbar);
		} else {
			UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
			effectView.frame = self.bounds;
			[self addSubview:effectView];
			effectView.tag = 10;
			[self sendSubviewToBack:effectView];
			RELEASE(effectView);
		}
	}
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    UIView *view = (UIView *)[self viewWithTag:10];
    if (view) {
        view.frame = self.bounds;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *view = (UIView *)[self viewWithTag:10];
    if (view) {
        view.frame = self.bounds;
    }
}

- (void)setBlurViewAlpha:(CGFloat)alpha {
	UIView *view = (UIView *)[self viewWithTag:10];

	view.alpha = alpha;
}

@end
