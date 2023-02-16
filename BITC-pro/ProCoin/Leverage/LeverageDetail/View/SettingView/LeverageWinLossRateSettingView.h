//
//  LeverageWinLossRateSettingView.h
//  BYY
//
//  Created by Hay on 2020/1/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeverageWinLossRateSettingView;

@protocol LeverageWinLossRateSettingViewDelegate <NSObject>

@optional
- (void)settingViewCommitButtonPressed:(LeverageWinLossRateSettingView *)view WithWinRate:(NSString *)winRate lossRate:(NSString *)lossRate;

@end



@interface LeverageWinLossRateSettingView : UIView

@property (assign, nonatomic) id<LeverageWinLossRateSettingViewDelegate> delegate;

- (void)showViewInView:(UIView *)superView currentWinRate:(NSString *)currentWinRate currentLossRate:(NSString *)currentLossRate maxLossRate:(NSString *)maxLossRate buySell:(NSString *)buySell openCostPriceValue:(NSString *)openCostPriceValue borrowBalanceValue:(NSString *)borrowBalanceValue bailBalanceValue:(NSString *)bailBalanceValue interestValue:(NSString *)interestValue priceDecimals:(NSString *)priceDecimals;

- (void)dismissViewFromSuperViewWithAnimation;

@end


