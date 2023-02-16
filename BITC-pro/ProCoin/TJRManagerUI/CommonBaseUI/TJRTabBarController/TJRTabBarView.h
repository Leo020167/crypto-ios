//
//  TJRTabBarView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/1/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJRTabBarItem, TJRTabBarView;

@protocol TJRTabBarViewDelegate <NSObject>

/**
 * Asks the delegate if the specified tab bar item should be selected.
 */
- (BOOL)tabBarView:(TJRTabBarView *)tabBarView shouldSelectItemAtIndex:(NSInteger)index;

/**
 * Tells the delegate that the specified tab bar item is now selected.
 */
- (void)tabBarView:(TJRTabBarView *)tabBarView didSelectItemAtIndex:(NSInteger)index;

@end

@interface TJRTabBarView : UIView

/**
 * The tab bar’s delegate object.
 */
@property (nonatomic, assign) id <TJRTabBarViewDelegate> delegate;

/**
 * The items displayed on the tab bar.
 */
@property (nonatomic, copy) NSArray *items;

/**
 * The currently selected item on the tab bar.
 */
@property (nonatomic, assign) TJRTabBarItem *selectedItem;

/**
 * backgroundView stays behind tabBar's items. If you want to add additional views,
 * add them as subviews of backgroundView.
 */
@property (nonatomic, readonly) UIView *backgroundView;

/*
 * contentEdgeInsets can be used to center the items in the middle of the tabBar.
 */
@property UIEdgeInsets contentEdgeInsets;

/**
 * Sets the height of tab bar.
 */
- (void)setHeight:(CGFloat)height;

/**
 * Returns the minimum height of tab bar's items.
 */
- (CGFloat)minimumContentHeight;

/*
 * Enable or disable tabBar translucency. Default is NO.
 */
@property (nonatomic, getter=isTranslucent) BOOL translucent;

#pragma mark - 设置上边描边颜色
- (void)setStrokeColor:(UIColor *)strokeColor;
@end
