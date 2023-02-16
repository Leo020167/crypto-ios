//
//  TradeInputView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 1/25/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#define TradeKeyboardDeleteButtonClick  @"TradeKeyboardDeleteButtonClick"
#define TradeKeyboardNumberButtonClick  @"TradeKeyboardNumberButtonClick"
#define TradeKeyboardNumberKey          @"TradeKeyboardNumberKey"

#import <UIKit/UIKit.h>

@class TradeInputView;

@protocol TradeInputViewDelegate <NSObject>

@optional

- (void)tradeInputView:(TradeInputView *)tradeInputView finish:(NSString *)password;

- (void)tradeInputView:(TradeInputView *)tradeInputView statue:(BOOL)statue;
@end

@interface TradeInputView : UIView
@property (nonatomic, assign) id<TradeInputViewDelegate> delegate;

/** 响应者 */
@property (nonatomic, retain) UITextField *responsder;

/** 完成的回调block */
@property (nonatomic, copy) void (^finish) (NSString *passWord);

- (void)clean;

- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
@end
