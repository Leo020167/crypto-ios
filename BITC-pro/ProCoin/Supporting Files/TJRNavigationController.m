//
//  TJRNavigationController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-10-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//  用于横屏

#import "TJRNavigationController.h"

@interface TJRNavigationController ()

@end

@implementation TJRNavigationController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
