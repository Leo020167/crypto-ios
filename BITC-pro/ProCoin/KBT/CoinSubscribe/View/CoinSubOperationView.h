//
//  CoinSubOperationView.h
//  BYY
//
//  Created by Hay on 2019/10/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoinSubOperationViewDelegate <NSObject>

@optional
- (void)coinSubOperationViewSubscribeButtonDidSelected;
- (void)coinSubOperationViewTradeButtonDidSelected;

@end



@interface CoinSubOperationView : UIView

@property (assign, nonatomic) id<CoinSubOperationViewDelegate> delegate;

#pragma mark - 数据展示
- (void)reloadButtonStateWithBuyButtonState:(BOOL)buyEnable tradeButtonState:(BOOL)tradeEnable buyButtonTitle:(NSString *)buyButtonTitle;

@end


