//
//  PCMultiNumSettingView.h
//  ProCoin
//
//  Created by Hay on 2020/2/28.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

@class PCMultiNumSettingView;

@protocol PCMultiNumSettingViewDelegate <NSObject>

@required
- (void)multiNumSettingViewCommitData:(PCMultiNumSettingView *)viewController multiNum:(NSString *)multiNum;

@end

@interface PCMultiNumSettingView : TJRBaseViewController

@property (assign, nonatomic) id<PCMultiNumSettingViewDelegate> delegate;

#pragma mark - 显示与消失
- (void)showMultiNumViewInController:(UIViewController *)controller;
- (void)dismissMultiNumView;

@end


