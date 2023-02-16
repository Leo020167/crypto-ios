//
//  NewbieHelpView.h
//  TJRtaojinroad
//
//  Created by Jeans on 10/18/12.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachMarksArrayItem.h"




@protocol NewbieHelpViewDelegate;

@interface NewbieHelpView : UIView

@property (assign, nonatomic) id<NewbieHelpViewDelegate>    nhDelegate;

@property (assign, nonatomic) NHType        currentType;

/**
	查询页面是否是第一次运行
	@param type
	@returns YES为第一次运行,反之不是
 */
+ (BOOL)checkIsNewbieWithNHType:(NHType)type;

/** 
    在某个view显示某个type类型的新手指南
 */
- (void)ShowNewbieHelpByNHType:(NHType)type andSuperView:(UIView *)view;

/**
 @params isPortrait 是否竖屏模式
 */
- (void)ShowNewbieHelpByNHType:(NHType)type andSuperView:(UIView *)view andIsPortrait:(BOOL)isPortrait;


@end

@protocol NewbieHelpViewDelegate <NSObject>

@optional
//- (void)NHTouch;
- (void)newBieHelpViewWillDisappear:(NewbieHelpView *)newbieHelpView;
//- (void)newbieHelpView:(NewbieHelpView*)newbieHelpView willNavigateToIndex:(NSUInteger)index;
//- (void)newbieHelpView:(NewbieHelpView*)newbieHelpView didNavigateToIndex:(NSUInteger)index;
//- (void)newbieHelpViewWillCleanup:(NewbieHelpView*)newbieHelpView;
//- (void)newbieHelpViewDidCleanup:(NewbieHelpView*)newbieHelpView;

@end
