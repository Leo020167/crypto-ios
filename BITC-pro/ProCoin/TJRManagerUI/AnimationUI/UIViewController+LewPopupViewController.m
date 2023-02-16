//
//  UIViewController+LewPopupViewController.m
//  LewPopupViewController
//
//  Created by pljhonglu on 15/3/4.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import "UIViewController+LewPopupViewController.h"
#import <objc/runtime.h>
#import "LewPopupBackgroundView.h"

#define kLEWHideShadow				@"kLEWHideShadow"
#define kLEWCanDragBack				@"kLEWCanDragBack"
#define kLEWPopupView				@"kLEWPopupView"
#define kLEWOverlayView				@"kLEWOverlayView"
#define kLEWBackgroundViewTapBlock  @"kLEWBackgroundViewTapBlock"
#define kLEWPopupViewDismissedBlock @"kLEWPopupViewDismissedBlock"
#define KLEWPopupAnimation			@"KLEWPopupAnimation"
#define kLEWPopupViewController		@"kLEWPopupViewController"

#define kLEWPopupViewTag			8002
#define kLEWOverlayViewTag			8003
#define kLEWBackgroundViewTag		8004
#define kLEWClickViewTag		    8005

@interface UIView (LewPopupViewControllerPrivate)
@property (nonatomic, weak, readwrite) TJRBaseViewController *lewPopupViewController;
@end

@interface TJRBaseViewController (LewPopupViewControllerPrivate)
@property (nonatomic, retain) UIView *lewPopupView;
@property (nonatomic, retain) UIView *lewOverlayView;
@property (nonatomic, copy) void (^lewDismissCallback)(void);
@property (nonatomic, retain) id <LewPopupAnimation> popupAnimation;
- (UIView *)topView;
@end

@implementation TJRBaseViewController (LewPopupViewController)

#pragma public method

- (void)lew_presentPopupView:(UIView *)popupView animation:(id <LewPopupAnimation>)animation {
	[self _presentPopupView:popupView animation:animation backgroundClickable:nil dismissed:nil];
}

- (void)lew_presentPopupView:(UIView *)popupView animation:(id <LewPopupAnimation>)animation dismissed:(void (^)(void))dismissed {
	[self _presentPopupView:popupView animation:animation backgroundClickable:nil dismissed:dismissed];
}

- (void)lew_presentPopupView:(UIView *)popupView animation:(id <LewPopupAnimation>)animation backgroundClickable:(void (^)(void))clickable {
	[self _presentPopupView:popupView animation:animation backgroundClickable:clickable dismissed:nil];
}

- (void)lew_presentPopupView:(UIView *)popupView animation:(id <LewPopupAnimation>)animation backgroundClickable:(void (^)(void))clickable dismissed:(void (^)(void))dismissed {
	[self _presentPopupView:popupView animation:animation backgroundClickable:clickable dismissed:dismissed];
}

- (void)lew_dismissPopupViewWithanimation:(id <LewPopupAnimation>)animation {
	[self _dismissPopupViewWithAnimation:animation];
}

- (void)lew_dismissPopupView {
	[self _dismissPopupViewWithAnimation:self.lewPopupAnimation];
}

#pragma mark - inline property

- (void)setSelfCanDragBack:(BOOL)canDragBack {
    objc_setAssociatedObject(self, kLEWCanDragBack, [NSNumber numberWithBool:canDragBack], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)selfCanDragBack {
    return [objc_getAssociatedObject(self, kLEWCanDragBack) boolValue];
}

- (void)setHideShadow:(BOOL)hideShadow {
    objc_setAssociatedObject(self, kLEWHideShadow, [NSNumber numberWithBool:hideShadow], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hideShadow {
    return [objc_getAssociatedObject(self, kLEWHideShadow) boolValue];
}

- (UIView *)lewPopupView {
	return objc_getAssociatedObject(self, kLEWPopupView);
}

- (void)setLewPopupView:(UIViewController *)lewPopupView {
	objc_setAssociatedObject(self, kLEWPopupView, lewPopupView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)lewOverlayView {
	return objc_getAssociatedObject(self, kLEWOverlayView);
}

- (void)setLewOverlayView:(UIView *)lewOverlayView {
	objc_setAssociatedObject(self, kLEWOverlayView, lewOverlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))lewDismissCallback {
	return objc_getAssociatedObject(self, kLEWPopupViewDismissedBlock);
}

- (void)setLewDismissCallback:(void (^)(void))lewDismissCallback {
	objc_setAssociatedObject(self, kLEWPopupViewDismissedBlock, lewDismissCallback, OBJC_ASSOCIATION_COPY);
}

- (void (^)(void))lewBackgroundViewTapCallback {
    return objc_getAssociatedObject(self, kLEWBackgroundViewTapBlock);
}

- (void)setLewBackgroundViewTapCallback:(void (^)(void))lewBackgroundViewTapCallback {
	objc_setAssociatedObject(self, kLEWBackgroundViewTapBlock, lewBackgroundViewTapCallback, OBJC_ASSOCIATION_COPY);
}

- (id <LewPopupAnimation>)lewPopupAnimation {
	return objc_getAssociatedObject(self, KLEWPopupAnimation);
}

- (void)setLewPopupAnimation:(id <LewPopupAnimation>)lewPopupAnimation {
	objc_setAssociatedObject(self, KLEWPopupAnimation, lewPopupAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - view handle

- (void)_presentPopupView:(UIView *)popupView animation:(id <LewPopupAnimation>)animation backgroundClickable:(void (^)(void))clickable dismissed:(void (^)(void))dismissed {
    [self setSelfCanDragBack:self.canDragBack];
    self.canDragBack = false;
    // check if source view controller is not in destination
	if ([self.lewOverlayView.subviews containsObject:popupView]) return;

	// fix issue #2
	if (self.lewOverlayView && (self.lewOverlayView.subviews.count > 1)) {
		[self _dismissPopupViewWithAnimation:nil];
	}

	self.lewPopupView = nil;
	self.lewPopupView = popupView;
	self.lewPopupAnimation = nil;
	self.lewPopupAnimation = animation;

	UIView *sourceView = [self _lew_topView];

	// customize popupView
	popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
	popupView.tag = kLEWPopupViewTag;
    if (!self.hideShadow) {
        popupView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
        popupView.layer.masksToBounds = NO;
        popupView.layer.shadowOffset = CGSizeMake(1, 1);
        popupView.layer.shadowRadius = 5;
        popupView.layer.shadowOpacity = 0.5;
        popupView.layer.shouldRasterize = YES;
        popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }

	// Add overlay
	if (self.lewOverlayView == nil) {
		UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
		overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		overlayView.tag = kLEWOverlayViewTag;
		overlayView.backgroundColor = [UIColor clearColor];

		// BackgroundView
		UIView *backgroundView = [[LewPopupBackgroundView alloc] initWithFrame:sourceView.bounds];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.tag = kLEWBackgroundViewTag;
        backgroundView.backgroundColor = [UIColor clearColor];
        [overlayView addSubview:backgroundView];

		// Make the Background Clickable
		if (clickable) {
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTapGesture:)];
            [backgroundView addGestureRecognizer:tap];
        }
		self.lewOverlayView = overlayView;
	}

	[self.lewOverlayView addSubview:popupView];
	[sourceView addSubview:self.lewOverlayView];

	self.lewOverlayView.alpha = 1.0f;
	popupView.center = self.lewOverlayView.center;

	if (animation) {
		[animation showView:popupView overlayView:self.lewOverlayView];
	}

	[self setLewDismissCallback:dismissed];
    [self setLewBackgroundViewTapCallback:clickable];
}

- (void)backgroundTapGesture:(UIGestureRecognizer *)recognizer {
    id dismissed = [self lewBackgroundViewTapCallback];
    
    if (dismissed != nil) {
        ((void (^)(void))dismissed)();
    }
}

- (void)_dismissPopupViewWithAnimation:(id <LewPopupAnimation>)animation {
    self.canDragBack = [self selfCanDragBack];
    if (!self.lewPopupView) return;
	if (animation) {
		[animation dismissView:self.lewPopupView overlayView:self.lewOverlayView completion:^(void) {
			[self.lewOverlayView removeFromSuperview];
			[self.lewPopupView removeFromSuperview];
			self.lewPopupView = nil;
			self.lewPopupAnimation = nil;

			id dismissed = [self lewDismissCallback];

			if (dismissed != nil) {
				((void (^)(void))dismissed)();
				[self setLewDismissCallback:nil];
			}
		}];
	} else {
		[self.lewOverlayView removeFromSuperview];
		[self.lewPopupView removeFromSuperview];
		self.lewPopupView = nil;
		self.lewPopupAnimation = nil;

		id dismissed = [self lewDismissCallback];

		if (dismissed != nil) {
			((void (^)(void))dismissed)();
			[self setLewDismissCallback:nil];
		}
	}
    self.hideShadow = false;
    [self setLewBackgroundViewTapCallback:nil];//清除backgroundView的回调事件
}

- (UIView *)_lew_topView {
	UIViewController *recentView = self;

	while (recentView.parentViewController != nil) {
		recentView = recentView.parentViewController;
	}

	return recentView.view;
}

@end

#pragma mark - UIView+LewPopupView
@implementation UIView (lewPopupViewController)
- (TJRBaseViewController *)lewPopupViewController {
	return objc_getAssociatedObject(self, kLEWPopupViewController);
}

- (void)setLewPopupViewController:(TJRBaseViewController *_Nullable)lewPopupViewController {
	objc_setAssociatedObject(self, kLEWPopupViewController, lewPopupViewController, OBJC_ASSOCIATION_ASSIGN);
}

@end// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
