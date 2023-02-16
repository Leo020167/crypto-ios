//
//  P2PPayMoneyView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2PPayMoneyView;

@protocol P2PPayMoneyViewDelegate <NSObject>

@optional
- (void)p2pView:(P2PPayMoneyView *)menuView dismissMoneyView:(id)sender;
- (void)p2pView:(P2PPayMoneyView *)menuView buttonClicked:(id)sender filterCny:(NSString*) filterCny;
@end

@interface P2PPayMoneyView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

@property (assign, nonatomic) id<P2PPayMoneyViewDelegate> delegate;
@property (assign, nonatomic) BOOL displayed;

/// 币种类型
@property (nonatomic, copy) NSString *coinType;

@property (nonatomic, strong) NSMutableArray *coinTypeArray;

@end

NS_ASSUME_NONNULL_END
