//
//  TJRTabBarController.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/1/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "TJRTabBarView.h"

@protocol TJRTabBarControllerDelegate;
@interface TJRTabBarController : TJRBaseViewController<TJRTabBarViewDelegate>

/**
 * The tab bar controller’s delegate object.
 */
@property (nonatomic, assign) id<TJRTabBarControllerDelegate> delegate;

/**
 * An array of the root view controllers displayed by the tab bar interface.
 */
@property (nonatomic, retain) IBOutletCollection(UIViewController) NSArray *viewControllers;

/**
 * The tab bar view associated with this controller. (read-only)
 */
@property (nonatomic, readonly) TJRTabBarView *tabBarView;

/**
 * The view controller associated with the currently selected tab item.
 */
@property (nonatomic, assign) UIViewController *selectedViewController;

/**
 * The index of the view controller associated with the currently selected tab item.
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 * A Boolean value that determines whether the tab bar is hidden.
 */
@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

@property (nonatomic, assign) NSUInteger pastSelectIndex;
/**
 * Changes the visibility of the tab bar.
 */
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)setViewControllers:(NSArray *)viewControllers barItemTexts:(NSArray *)texts selectedTitleAttributes:(NSArray *)selectedAttributes unSelectedTitleAttributes:(NSArray *)unSelectedAttributes;
@end

@protocol TJRTabBarControllerDelegate <NSObject>
@optional
/**
 * Asks the delegate whether the specified view controller should be made active.
 */
- (BOOL)tabBarController:(TJRTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

/**
 * Tells the delegate that the user selected an item in the tab bar.
 */
- (void)tabBarController:(TJRTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end

@interface UIViewController (TJRTabBarControllerItem)

/**
 * The tab bar item that represents the view controller when added to a tab bar controller.
 */
@property(nonatomic, setter = tjr_setTabBarItem:) TJRTabBarItem *tjr_tabBarItem;

/**
 * The nearest ancestor in the view controller hierarchy that is a tab bar controller. (read-only)
 */
@property(nonatomic, readonly) TJRTabBarController *tjr_tabBarController;

@end
