//
//  TJRScrollView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-10-13.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRScrollView.h"
#import "TJRBaseView.h"
@interface TJRScrollView () <UIGestureRecognizerDelegate>

@end
@implementation TJRScrollView

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.delaysContentTouches = NO;
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.delaysContentTouches = NO;
	}
	return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	if ([view isKindOfClass:TJRBaseView.class] || [view isKindOfClass:UIButton.class]) {
		return YES;
	}

	return [super touchesShouldCancelInContentView:view];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
          return YES;
    }
    else{
        return  NO;
    }
}

@end
