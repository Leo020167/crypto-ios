//
//  BankWayAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BankWayAlertView;

@protocol BankWayAlertViewDelegate <NSObject>

@optional
- (void)p2pView:(BankWayAlertView *)alertView alipayButtonClicked:(id)sender;
- (void)p2pView:(BankWayAlertView *)alertView bankButtonClicked:(id)sender;
- (void)p2pView:(BankWayAlertView *)alertView wechatpayButtonClicked:(id)sender;

@end

@interface BankWayAlertView : UIView

@property (assign, nonatomic) id<BankWayAlertViewDelegate> delegate;

- (void)showInView:(UIView *)view;

- (void)dismissView;


@end

NS_ASSUME_NONNULL_END
