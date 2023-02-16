//
//  P2PHistoryAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2PHistoryAlertView;

@protocol P2PHistoryAlertViewDelegate <NSObject>

@optional
- (void)p2pView:(P2PHistoryAlertView *)alertView buySell:(NSString*)buySell;
@end

@interface P2PHistoryAlertView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

@property (assign, nonatomic) id<P2PHistoryAlertViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
