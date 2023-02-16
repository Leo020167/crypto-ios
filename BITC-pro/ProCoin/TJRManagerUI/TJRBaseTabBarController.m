//
//  TJRBaseTabBarController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/3/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseTabBarController.h"

#import "NetWorkManage.h"

@implementation TJRBaseTabBarController


- (id)init {
    self  = [super init];
    if (self) {
        [self tjr_setViewController:nil];
        [self tjr_setViewController:self];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tjr_setViewController:nil];
        [self tjr_setViewController:self];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self tjr_setViewController:nil];
        [self tjr_setViewController:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!ttDelegateDictionary) ttDelegateDictionary = [[NSMutableDictionary alloc] init];
    phoneRectScreen = [[UIScreen mainScreen] bounds];
    
    if (CURRENT_DEVICE_VERSION >= 7.0) [self setNeedsStatusBarAppearanceUpdate];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) self.edgesForExtendedLayout = UIRectEdgeNone;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //设置重启UIView动画
        dispatch_async(dispatch_get_main_queue(),^{
            [UIView setAnimationsEnabled:YES];});
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationController.viewControllers.count == 1) {		// 关闭主界面的右滑返回
        return NO;
    } else {
        return YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 网络记录

/**
 *	@brief	保存网络里的httpRequest
 *
 *	@param  cacheKey
 *	@param  tjrDelegate
 */
- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest {
    if (!TTIsStringWithAnyText(cacheKey)) return;
    
    [ttDelegateDictionary setObject:httpRequest forKey:cacheKey];
}

/**
 *	@brief	移除一个httpRequest
 *
 *	@param  cacheKey
 */
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey {
    if (!TTIsStringWithAnyText(cacheKey)) return;
    
    [ttDelegateDictionary removeObjectForKey:cacheKey];
}

#pragma mark - dealloc
- (void)dealloc {
    [self clearTTHttpDelegate];
    [ttDelegateDictionary removeAllObjects];
    TT_RELEASE_SAFELY(ttDelegateDictionary);
    RELEASE(_progressHUD);
    [self tjr_setViewController:nil];
    [super dealloc];
}

/**
 *	@brief	清除当前页面Http里的delegate
 */

- (void)clearTTHttpDelegate {
    for (TTBaseHttpDelegate * tt in [ttDelegateDictionary objectEnumerator]) {
        [tt clean];
    }
}

#pragma mark - 父类控制转动
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
