//
//  KBTBuyBackInputView.h
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KBTBuyBackInputViewDelegate <NSObject>

@optional
- (void)buyBackInputViewErrorMsg:(NSString *)msg;
- (void)buyBackInputViewCertainButtonDidPressedWithAmount:(NSString *)amount;

@end


@interface KBTBuyBackInputView : UIView

@property (assign, nonatomic) id<KBTBuyBackInputViewDelegate> delegate;

#pragma mark - 显示与消失
- (void)showBuyBackInputViewInView:(UIView *)view;

- (void)dismissBuyBackInputView;

- (void)reloadInputViewWithHoldAmount:(NSString *)holdAmount repoAmount:(NSString *)repoAmount;

@end

