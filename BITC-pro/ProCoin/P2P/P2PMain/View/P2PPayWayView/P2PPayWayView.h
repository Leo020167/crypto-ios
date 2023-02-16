//
//  P2PPayWayView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2PPayWayView;

@protocol P2PPayWayViewDelegate <NSObject>

@optional
- (void)p2pView:(P2PPayWayView *)menuView dismissView:(id)sender;
- (void)p2pView:(P2PPayWayView *)menuView buttonClicked:(id)sender filterPayWay:(NSString*) filterPayWay;
@end

@interface P2PPayWayView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

@property (assign, nonatomic) id<P2PPayWayViewDelegate> delegate;
@property (assign, nonatomic) BOOL displayed;

@end

NS_ASSUME_NONNULL_END
