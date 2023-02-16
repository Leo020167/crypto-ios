//
//  TJRTabBarController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/1/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRTabBarController.h"
#import "TJRTabBarItem.h"
#import <objc/runtime.h>

@interface UIViewController (TJRTabBarControllerItemInternal)

- (void)tjr_setTabBarController:(TJRTabBarController *)tabBarController;

@end

@interface TJRTabBarController () {
    UIView *_contentView;
    BOOL isShow;
}

@property (nonatomic, readwrite) TJRTabBarView *tabBarView;

@end

@implementation TJRTabBarController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!isShow) {
        _pastSelectIndex = -1;
        [self.view addSubview:[self contentView]];
        [self.view addSubview:[self tabBarView]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!isShow) {
        [self setSelectedIndex:[self selectedIndex]];
        _pastSelectIndex = self.selectedIndex;
        [self setTabBarHidden:self.isTabBarHidden animated:NO];
        isShow = YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
    for (UIViewController *viewController in _viewControllers) {
        if (![viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
            return UIInterfaceOrientationMaskPortrait;
        }
        
        UIInterfaceOrientationMask supportedOrientations = [viewController supportedInterfaceOrientations];
        
        if (orientationMask > supportedOrientations) {
            orientationMask = supportedOrientations;
        }
    }
    
    return orientationMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    for (UIViewController *viewCotroller in _viewControllers) {
        if (![viewCotroller respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] ||
            ![viewCotroller shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Methods

- (UIViewController *)selectedViewController {
    return [_viewControllers objectAtIndex:[self selectedIndex]];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
    }
    
    if ([self selectedViewController]) {
        [[self selectedViewController] willMoveToParentViewController:nil];
        [[[self selectedViewController] view] removeFromSuperview];
        [[self selectedViewController] removeFromParentViewController];
    }
    _selectedIndex = selectedIndex;
    [[self tabBarView] setSelectedItem:[[self tabBarView] items][selectedIndex]];
    
    [self setSelectedViewController:[_viewControllers objectAtIndex:selectedIndex]];
    [self addChildViewController:[self selectedViewController]];
    [[[self selectedViewController] view] setFrame:[[self contentView] bounds]];
    [[self contentView] addSubview:[[self selectedViewController] view]];
    [[self selectedViewController] didMoveToParentViewController:self];
}

- (void)setViewControllers:(NSArray *)viewControllers barItemTexts:(NSArray *)texts selectedTitleAttributes:(NSArray *)selectedAttributes unSelectedTitleAttributes:(NSArray *)unSelectedAttributes {
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        RELEASE(_viewControllers);
        _viewControllers = [viewControllers retain];
        NSUInteger textCount = texts ? texts.count : 0;
        NSUInteger selectAttributesCount = selectedAttributes ? selectedAttributes.count : 0;
        NSUInteger unSelectAttributesCount = unSelectedAttributes ? unSelectedAttributes.count : 0;
        BOOL countSame = (textCount == selectAttributesCount) && (unSelectAttributesCount == selectAttributesCount);
        if(countSame){
        }
        NSAssert(countSame == YES, @"长度不一样");
        
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        int i = 0;
        for (UIViewController *viewController in viewControllers) {
            TJRTabBarItem *tabBarItem = [[TJRTabBarItem alloc] init];
            tabBarItem.title = texts[i];
            tabBarItem.selectedTitleAttributes = selectedAttributes[i];
            tabBarItem.unselectedTitleAttributes = unSelectedAttributes[i];
            [tabBarItems addObject:tabBarItem];
            [viewController tjr_setTabBarController:self];
            RELEASE(tabBarItem);
            i++;
        }
        
        [[self tabBarView] setItems:tabBarItems];
        RELEASE(tabBarItems);
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [viewController tjr_setTabBarController:nil];
        }
        
        _viewControllers = nil;
    }
}

- (NSInteger)indexForViewController:(UIViewController *)viewController {
    UIViewController *searchedController = viewController;
    if ([searchedController navigationController]) {
        searchedController = [searchedController navigationController];
    }
    return [_viewControllers indexOfObject:searchedController];
}

- (TJRTabBarView *)tabBarView {
    if (!_tabBarView) {
        _tabBarView = [[TJRTabBarView alloc] init];
        [_tabBarView setBackgroundColor:[UIColor clearColor]];
        [_tabBarView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                      UIViewAutoresizingFlexibleTopMargin|
                                      UIViewAutoresizingFlexibleLeftMargin|
                                      UIViewAutoresizingFlexibleRightMargin|
                                      UIViewAutoresizingFlexibleBottomMargin)];
        [_tabBarView setDelegate:self];
    }
    return _tabBarView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_contentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                           UIViewAutoresizingFlexibleHeight)];
    }
    return _contentView;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    _tabBarHidden = hidden;
    
    void (^block)() = ^{
        CGSize viewSize = self.view.bounds.size;
        CGFloat tabBarStartingY = viewSize.height;
        CGFloat contentViewHeight = viewSize.height;
        CGFloat tabBarHeight = CGRectGetHeight([[self tabBarView] frame]);
        
        if (!tabBarHeight) {
            tabBarHeight = 49;
        }
        
        if (!hidden) {
            tabBarStartingY = viewSize.height - tabBarHeight;
            if (![[self tabBarView] isTranslucent]) {
                contentViewHeight -= ([[self tabBarView] minimumContentHeight] ?: tabBarHeight);
            }
            [[self tabBarView] setHidden:NO];
        }
        
        [[self tabBarView] setFrame:CGRectMake(0, tabBarStartingY, viewSize.width, tabBarHeight)];
        [[self contentView] setFrame:CGRectMake(0, 0, viewSize.width, contentViewHeight)];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished){
        if (hidden) {
            [[self tabBarView] setHidden:YES];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.24 animations:block completion:completion];
    } else {
        block();
        completion(YES);
    }
}

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

#pragma mark - TJRTabBarDelegate

- (BOOL)tabBarView:(TJRTabBarView *)tabBar shouldSelectItemAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![_delegate tabBarController:self shouldSelectViewController:_viewControllers[index]]) {
            return NO;
        }
    }
    
    if ([self selectedViewController] == _viewControllers[index]) {
        if ([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *selectedController = (UINavigationController *)[self selectedViewController];
            
            if ([selectedController topViewController] != [selectedController viewControllers][0]) {
                [selectedController popToRootViewControllerAnimated:YES];
            }
        }
        if (index == _pastSelectIndex) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

- (void)tabBarView:(TJRTabBarView *)tabBar didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= [_viewControllers count]) {
        return;
    }
    
    [self setSelectedIndex:index];
    
    if ([_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [_delegate tabBarController:self didSelectViewController:_viewControllers[index]];
    }
}

- (void)dealloc {
    RELEASE(_contentView);
    RELEASE(_tabBarView);
    RELEASE(_viewControllers);
    [super dealloc];
}

@end

#pragma mark - UIViewController+TJRTabBarControllerItem

@implementation UIViewController (TJRTabBarControllerItemInternal)

- (void)tjr_setTabBarController:(TJRTabBarController *)tabBarController {
    objc_setAssociatedObject(self, @selector(tjr_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIViewController (TJRTabBarControllerItem)

- (TJRTabBarController *)tjr_tabBarController {
    TJRTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(tjr_tabBarController));
    
    if (!tabBarController && self.parentViewController) {
        tabBarController = [self.parentViewController tjr_tabBarController];
    }
    
    return tabBarController;
}

- (TJRTabBarItem *)tjr_tabBarItem {
    TJRTabBarController *tabBarController = [self tjr_tabBarController];
    NSInteger index = [tabBarController indexForViewController:self];
    return [[[tabBarController tabBarView] items] objectAtIndex:index];
}

- (void)tjr_setTabBarItem:(TJRTabBarItem *)tabBarItem {
    TJRTabBarController *tabBarController = [self tjr_tabBarController];
    
    if (!tabBarController) {
        return;
    }
    
    TJRTabBarView *tabBar = [tabBarController tabBarView];
    NSInteger index = [tabBarController indexForViewController:self];
    
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:[tabBar items]];
    [tabBarItems replaceObjectAtIndex:index withObject:tabBarItem];
    [tabBar setItems:tabBarItems];
    RELEASE(tabBarItems);
}

@end
