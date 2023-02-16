//
//  KBTBuyBackInputView.m
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTBuyBackInputView.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"

@interface KBTBuyBackInputView()<TextFieldToolBarDelegate,UITextFieldDelegate>
{
    NSInteger buyBackDecimals;                      //回购位数
    BOOL isDismissView;             //是否需要消失页面
}


@property (copy, nonatomic) NSString *repoAmount;
@property (copy, nonatomic) NSString *holdAmount;

@property (retain, nonatomic) IBOutlet UILabel *suplusAmountLabel;      //剩余可回购数量
@property (retain, nonatomic) IBOutlet UILabel *holdAmountLabel;
@property (retain, nonatomic) IBOutlet UITextField *inputAmountTF;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;           //content view底部约束

@end

@implementation KBTBuyBackInputView

- (void)awakeFromNib
{
    [super awakeFromNib];
    buyBackDecimals = 8;
    isDismissView = NO;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    TextFieldToolBar *toolBar = [[[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1] autorelease];
    _inputAmountTF.inputAccessoryView = toolBar;
    _inputAmountTF.delegate = self;
    _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_repoAmount release];
    [_holdAmount release];
    [_suplusAmountLabel release];
    [_inputAmountTF release];
    [_holdAmountLabel release];
    [_contentViewLayoutConstraintBottom release];
    [_contentView release];
    [super dealloc];
}

- (void)reloadInputViewWithHoldAmount:(NSString *)holdAmount repoAmount:(NSString *)repoAmount
{
    buyBackDecimals = [TradeUtil decimalBitByStringValue:holdAmount];
    if(checkIsStringWithAnyText(holdAmount)){
        self.holdAmount = holdAmount;
        _holdAmountLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"持有YYB数量"), holdAmount];
        
    }else{
        self.holdAmount = @"0";
        _holdAmountLabel.text = [NSString stringWithFormat:@"%@：0", NSLocalizedStringForKey(@"持有YYB数量")];
    }
    
    if(checkIsStringWithAnyText(repoAmount)){
        self.repoAmount = repoAmount;
        _suplusAmountLabel.text = repoAmount;
    }else{
        self.repoAmount = @"0";
        _suplusAmountLabel.text = @"0";
    }
}

#pragma mark - 显示与消失
- (void)showBuyBackInputViewInView:(UIView *)view
{
    isDismissView = NO;
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissBuyBackInputView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}




#pragma mark - 按钮点击事件
- (IBAction)allAmountButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(self.repoAmount)){
        _inputAmountTF.text = self.repoAmount;
    }else{
        _inputAmountTF.text = @"0";
    }
}

- (IBAction)backgroundViewTouchDown:(id)sender
{
    isDismissView = YES;
    
    if([_inputAmountTF isFirstResponder]){
        [_inputAmountTF resignFirstResponder];
    }else{
        [self dismissBuyBackInputView];
    }
}

- (IBAction)certainButtonPressed:(id)sender
{
    if(!checkIsStringWithAnyText(_inputAmountTF.text)){
        if([_delegate respondsToSelector:@selector(buyBackInputViewErrorMsg:)]){
            [_delegate buyBackInputViewErrorMsg:NSLocalizedStringForKey(@"请输入回购数量")];
        }
        return;
    }
    
    if([_inputAmountTF.text doubleValue] == 0){
        if([_delegate respondsToSelector:@selector(buyBackInputViewErrorMsg:)]){
            [_delegate buyBackInputViewErrorMsg:NSLocalizedStringForKey(@"请输入大于0的回购数量")];
        }
        return;
    }
    
    if([_inputAmountTF.text doubleValue] > [self.repoAmount doubleValue]){
        if([_delegate respondsToSelector:@selector(buyBackInputViewErrorMsg:)]){
            [_delegate buyBackInputViewErrorMsg:NSLocalizedStringForKey(@"输入的回购数量不能超过可回购数量")];
        }
        return;
    }
    [self dismissBuyBackInputView];
    if([_delegate respondsToSelector:@selector(buyBackInputViewCertainButtonDidPressedWithAmount:)]){
        [_delegate buyBackInputViewCertainButtonDidPressedWithAmount:_inputAmountTF.text];
    }
    
}

#pragma mark -  textfield tool bar delegate
- (void)TFDonePressed
{
    [_inputAmountTF resignFirstResponder];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL success = [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:buyBackDecimals];
    return success;
}


#pragma mark - 键盘事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _contentViewLayoutConstraintBottom.constant = keyboardRect.size.height - IPHONEX_BOTTOM_HEIGHT;
    [self layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(isDismissView){
            [self dismissBuyBackInputView];
        }
    }];
    
}

@end
