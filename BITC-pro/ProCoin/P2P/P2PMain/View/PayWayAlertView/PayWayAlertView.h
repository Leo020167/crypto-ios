//
//  PayWayAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2PPayWayEntity;
@class PayWayAlertView;

@protocol PayWayAlertViewDelegate <NSObject>

@optional
- (void)p2pView:(PayWayAlertView *)menuView entity:(P2PPayWayEntity*) entity;
@end

@interface PayWayAlertView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

@property (assign, nonatomic) id<PayWayAlertViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
