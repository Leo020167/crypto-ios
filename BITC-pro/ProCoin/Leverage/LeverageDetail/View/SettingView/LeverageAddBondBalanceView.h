//
//  LeverageAddBondBalanceView.h
//  BYY
//
//  Created by Hay on 2020/1/2.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeverageAddBondBalanceView;

@protocol LeverageAddBondBalanceViewDelegate <NSObject>

@optional
- (void)addBondBalanceViewCommitButtonPressed:(LeverageAddBondBalanceView *)addBondBalanceView bondBalance:(NSString *)bondBalance;
- (void)addBondBalanceViewDigitalAssetsDebitAndCreditProtocolButtonPressed;
- (void)addBondBalanceViewLeverageTradeProtocolButtonPressed;

@end

@interface LeverageAddBondBalanceView : UIView

@property (assign, nonatomic) id<LeverageAddBondBalanceViewDelegate> delegate;

- (void)showViewInView:(UIView *)superView bondBalanceData:(NSArray *)bondBalanceData holdUsdt:(NSString *)holdUsdt;

- (void)dismissViewWithAnimation;

@end


