//
//  YLNavigationController.m
//  Redz
//
//  Created by Taojin on 2018/6/27.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "YLNavigationController.h"
#import "TJRBaseViewController.h"
#import "HomeViewController.h"

@interface YLNavigationController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation YLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    
    self.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.topViewController isKindOfClass:[HomeViewController class]] || ![self isCanDragBack] || self.viewControllers.count <= 2){
        //关闭主界面的右滑返回
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)isCanDragBack {
    
    if ([self.topViewController isKindOfClass:[TJRBaseViewController class]]) {
        return [((TJRBaseViewController *)self.topViewController)canDragBack];
    }
    
    return NO;
}

// 根据最顶端viewController决定navgationController的方向
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

@end
