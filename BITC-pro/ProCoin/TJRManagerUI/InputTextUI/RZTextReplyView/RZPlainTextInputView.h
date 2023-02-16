//
//  CommodityTradeReplyView.h
//  Perval
//
//  Created by Hay on 2017/10/10.
//  Copyright © 2017年 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@protocol RZPlainTextInputViewDelegate <NSObject>

@optional

- (void)plainTextInputDidFinished:(NSString *)text;
- (void)plainTextInputWillShowKeyboardFrame:(CGRect)frame;
- (void)plainTextInputWillHideKeyboard;

@end

@interface RZPlainTextInputView : UIView

@property (retain, nonatomic) IBOutlet HPGrowingTextView *growTextView;

@property (assign, nonatomic) id<RZPlainTextInputViewDelegate> delegate;

//#pragma mark - 初始化
//- (void)initPlainTextInputView;

#pragma mark - 弹起键盘
- (void)inputViewBecomeFirstResponder;

#pragma mark - 缩下键盘
- (void)inputViewResignFirstResponder;

#pragma mark - 设置文本框空文本
- (void)inputViewSetNoText;

//#pragma mark - 设置place holder
//- (void)inputViewSetPlaceHodler:(NSString *)str;

@end
