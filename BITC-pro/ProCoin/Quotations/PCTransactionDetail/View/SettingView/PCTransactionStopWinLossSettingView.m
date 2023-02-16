//
//  PCTransactionStopWinLossSettingView.m
//  ProCoin
//
//  Created by Hay on 2020/3/1.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransactionStopWinLossSettingView.h"
#import "TextFieldToolBar.h"
#import "CommonUtil.h"

@interface PCTransactionStopWinLossSettingView()<TextFieldToolBarDelegate,UITextFieldDelegate>
{
    BOOL isDismissView;         //是否消失页面
    TextFieldToolBar *toolBar;
}

@property (assign, nonatomic) PCTDStopWinLossType type;

/** UI*/
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceTipsLabel;
@property (retain, nonatomic) IBOutlet UITextField *priceTF;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;

@end

@implementation PCTransactionStopWinLossSettingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.priceDecimals = 2;         //默认两位小数
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [CommonUtil viewHeightForAutoLayout:_contentView height:_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT];
    _contentViewLayoutConstraintBottom.constant = - self.contentView.frame.size.height;
    [self layoutIfNeeded];
    [self initialSettingView];
}

- (void)initialSettingView
{
    isDismissView = NO;
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _priceTF.inputAccessoryView = toolBar;
    _priceTF.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [toolBar release];
    [_titleLabel release];
    [_priceTipsLabel release];
    [_priceTF release];
    [_contentView release];
    [_contentViewLayoutConstraintBottom release];
    [super dealloc];
}

#pragma mark - 显示与消失
- (void)showViewInView:(UIView *)view settingType:(PCTDStopWinLossType)type
{
    self.type = type;
    if(type == PCTDStopLossType){
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"止损设置")];
        _priceTipsLabel.text = NSLocalizedStringForKey(@"止损价");
        [_priceTF setPlaceholder:NSLocalizedStringForKey(@"请输入止损价格")];
    }else{
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"止盈设置")];
        _priceTipsLabel.text = NSLocalizedStringForKey(@"止盈价");
        [_priceTF setPlaceholder:NSLocalizedStringForKey(@"请输入止盈价格")];
    }
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)dimissViewWithAnimation
{
    if([_priceTF isFirstResponder]){
        isDismissView = YES;
        [_priceTF resignFirstResponder];
    }else{
        isDismissView = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _contentViewLayoutConstraintBottom.constant = -_contentView.frame.size.height;
            [self layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - 点击事件
- (IBAction)backgroundViewTouchDown:(id)sender
{
    [self dimissViewWithAnimation];
}

- (IBAction)commitDataButtonPressed:(id)sender
{
    [_priceTF resignFirstResponder];
    if([_delegate respondsToSelector:@selector(stopWinLossSettingView:commitDataButtonPressedWithSettingType:limitPrice:)]){
        [_delegate stopWinLossSettingView:self commitDataButtonPressedWithSettingType:_type limitPrice:_priceTF.text];
    }
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
            [self dimissViewWithAnimation];
        }
    }];
    
}

#pragma mark - TextFieldToolBar delegate
- (void)TFDonePressed
{
    [_priceTF resignFirstResponder];
}

#pragma mark - UITextFiled delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL success = [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:self.priceDecimals];
    return success;
}
@end
