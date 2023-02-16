//
//  TJRRootNavigationController.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-10-9.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define kkBackViewHeight [UIScreen mainScreen].bounds.size.height
#define kkBackViewWidth [UIScreen mainScreen].bounds.size.width

#define startX -200;// 背景视图起始frame.x

@interface TJRRootNavigationController : UINavigationController<UIGestureRecognizerDelegate> {
    CGPoint startTouch;
    BOOL isMoving;
    NSArray *noGestureArray;
}

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *blackMask;
@property (nonatomic, assign) int dragBackIndex;
@end
