//
//  CommodityTradeReplyView.m
//  Perval
//
//  Created by Hay on 2017/10/10.
//  Copyright © 2017年 淘金路. All rights reserved.
//

#import "RZPlainTextInputView.h"

#import "CommonUtil.h"

@interface RZPlainTextInputView()<HPGrowingTextViewDelegate>



@end

@implementation RZPlainTextInputView

@synthesize delegate;


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initPlainTextInputView];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_growTextView release];
    [super dealloc];
}


#pragma mark - 初始化
- (void)initPlainTextInputView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    _growTextView.delegate = self;
    _growTextView.textCountLabel.hidden = YES;
    _growTextView.internalTextView.returnKeyType = UIReturnKeySend;
    [CommonUtil viewMasksToBounds:_growTextView cornerRadius:3.5f borderColor:RGBA (211, 211, 222, 1)];
}


#pragma mark - 弹起键盘
- (void)inputViewBecomeFirstResponder
{
    [_growTextView becomeFirstResponder];
}

#pragma mark - 缩下键盘
- (void)inputViewResignFirstResponder
{
    if([_growTextView isFirstResponder]){
        [_growTextView resignFirstResponder];
    }
    
}


#pragma mark - grow text view 改变高度时
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGRect frame = self.frame;
    CGFloat diff = height - _growTextView.frame.size.height;
    frame.origin.y = frame.origin.y - diff;
    frame.size.height = frame.size.height + diff;
    
    self.frame = frame;
}

#pragma mark - 点击发送
- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView
{
    NSString *str = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([delegate respondsToSelector:@selector(plainTextInputDidFinished:)]){
        [delegate plainTextInputDidFinished:str];
    }
}

#pragma mark - 设置文本框空文本
- (void)inputViewSetNoText
{
    _growTextView.text = @"";
}

#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if([self.delegate respondsToSelector:@selector(plainTextInputWillShowKeyboardFrame:)]){
        [delegate plainTextInputWillShowKeyboardFrame:keyboardRect];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    if([delegate respondsToSelector:@selector(plainTextInputWillHideKeyboard)]){
        [delegate plainTextInputWillHideKeyboard];
    }
}

@end
