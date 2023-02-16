//
//  UIViewController+TopBarMessage.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-4-10.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UIViewController+TopBarMessage.h"
#import <objc/runtime.h>

@interface  TopWarningView()

@end

@implementation TopWarningView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (instancetype)initWithView:(UIView*)view
{
    if (self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)]) {
        
        [self addSubview:view];
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
}

- (void)layoutSubviews
{
    
}

- (void)removeView
{
    CGRect selfFrame = self.frame;
    selfFrame.origin.y -= CGRectGetHeight(selfFrame);
    
    [UIView animateWithDuration:0.4f animations:^{
        self.frame = selfFrame;
        self.alpha = 0.3;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        self.alpha = 1.0;
        CGRect selfFrame = self.frame;
        selfFrame.origin.y -= CGRectGetHeight(selfFrame);
        self.frame = selfFrame;
        selfFrame.origin.y = 0;
        
        [UIView animateWithDuration:0.4f animations:^{
            self.frame = selfFrame;
        } completion:^(BOOL finished) {
            [super willMoveToSuperview:newSuperview];
        }];
    }else {
        [super willMoveToSuperview:newSuperview];
    }
}

@end

static char TopWarningKey;

@implementation UIViewController (TopBarMessage)

- (void)showAutoTopMessage
{
    TopWarningView *topV = objc_getAssociatedObject(self, &TopWarningKey);
    if (!topV) {
        topV = [[TopWarningView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        objc_setAssociatedObject(self, &TopWarningKey, topV, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    topV.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
    [self.view addSubview:topV];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [topV removeFromSuperview];
    });
}


@end
