//
//  PCSubscribeUserAlertView.h
//  ProCoin
//
//  Created by Hay on 2020/3/24.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "PCPersonalInfoModel.h"

@class PCSubscribeUserAlertView;

@protocol PCSubscribeUserAlertViewDelegate <NSObject>

@optional
- (void)subscribeUserAlertViewDidCommit:(PCSubscribeUserAlertView *)alertView buyNum:(NSString *)buyNum;

@end


@interface PCSubscribeUserAlertView : TJRBaseViewController

@property (assign, nonatomic) id<PCSubscribeUserAlertViewDelegate> delegate;

- (void)showInController:(UIViewController *)controller subInfo:(PCPersonalInfoModel *)subInfo holdAmount:(NSString *)holdAmount;
- (void)dismissViewWithAnimation;

@end

