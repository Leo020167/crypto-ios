//
//  PCNormalCloseView.h
//  ProCoin
//
//  Created by Hay on 2020/3/27.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
@class PCNormalCloseView;

@protocol PCNormalCloseViewDelegate <NSObject>

@required
- (void)normalCloseViewDidCommit:(PCNormalCloseView *)closeView handAmount:(NSString *)handAmount;

@end

@interface PCNormalCloseView : TJRBaseViewController

@property (assign, nonatomic) id<PCNormalCloseViewDelegate> delegate;

#pragma mark - 显示与消失
- (void)showInController:(UIViewController *)controller holdAmount:(NSString *)holdAmount;

- (void)dismissViewWithAnimation;

@end


