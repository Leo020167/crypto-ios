//
//  UIScrollView+AllowPanGestureEventPass.h
//
//  Created by taojinroad on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (AllowPanGestureEventPass)

- (void)setScrollViewScreenEdgePanGestureRecognizer;

//  设置UINavigationController的左边缘滑动返回手势优先级高于scrollercView的滑动手势，
- (void)setScreenEdgePanGestureRecognizerPriority;
@end
