//
//  OrderPayWayAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2PPayWayEntity;
@class OrderPayWayAlertView;

@protocol OrderPayWayAlertViewDelegate <NSObject>

@optional
- (void)p2pView:(OrderPayWayAlertView *)alertView selectedPaymentId:(NSString*)selectedPaymentId;
@end

@interface OrderPayWayAlertView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

- (void)reloadUIData:(NSMutableArray*)array selectedPaymentId:(NSString*)selectedPaymentId;

@property (assign, nonatomic) id<OrderPayWayAlertViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
