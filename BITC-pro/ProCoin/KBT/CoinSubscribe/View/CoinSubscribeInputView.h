//
//  KBTBuyBackInputView.h
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoinSubscribeInputViewDelegate <NSObject>

@optional
- (void)coinSubscribeInputViewErrorMsg:(NSString *)msg;
- (void)coinSubscribeInputViewCertainButtonDidPressedWithPriceIndex:(NSInteger)index;
- (void)coinSubscribeInputViewEquityInfoButtonDidPressed;

@end


@interface CoinSubscribeInputView : UIView

@property (assign, nonatomic) id<CoinSubscribeInputViewDelegate> delegate;

#pragma mark - 显示与消失
- (void)showCoinSubscribeInputViewInView:(UIView *)view;

- (void)dismissCoinSubscribeInputView;


- (void)reloadInputViewWithHoldAmount:(NSString *)holdAmount symbol:(NSString *)symbol balanceArr:(NSArray *)balanceArr price:(NSString *)price myEquityLevel:(NSString *)myEquityLevel myEquityTip:(NSString *)myEquityTip;

@end

