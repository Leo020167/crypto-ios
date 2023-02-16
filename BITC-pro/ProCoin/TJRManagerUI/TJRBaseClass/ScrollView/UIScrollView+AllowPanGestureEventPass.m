//
//  UIScrollView+AllowPanGestureEventPass.m
//
//  Created by taojinroad on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import "UIScrollView+AllowPanGestureEventPass.h"
#import "UINavigationController+PanGesture.h"

@implementation UIScrollView (AllowPanGestureEventPass)

- (void)setScrollViewScreenEdgePanGestureRecognizer{
    
    TJRAppDelegate *application = (TJRAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = application.navigation.screenEdgePanGestureRecognizer;
    [self.panGestureRecognizer requireGestureRecognizerToFail:screenEdgePanGestureRecognizer];
}

/**  设置UINavigationController的左边缘滑动返回手势优先级高于scrollercView的滑动手势 */
- (void)setScreenEdgePanGestureRecognizerPriority {
    
    TJRAppDelegate *appDelegate =(TJRAppDelegate *)[[UIApplication sharedApplication] delegate];
    //  获取当前最上层的navigation
    UINavigationController *navigation = appDelegate.navigation;
    if ([navigation presentedViewController]) {
        if ([[navigation presentedViewController] isKindOfClass:[UINavigationController class]]) {
            navigation = (UINavigationController *)[navigation presentedViewController];
        }
    }
    
    UIScreenEdgePanGestureRecognizer *leftGR = [(UIScreenEdgePanGestureRecognizer *)navigation.interactivePopGestureRecognizer retain];
    // 当返回手势失效时才执行滑动手势
    [self.panGestureRecognizer requireGestureRecognizerToFail:leftGR];
}


@end
