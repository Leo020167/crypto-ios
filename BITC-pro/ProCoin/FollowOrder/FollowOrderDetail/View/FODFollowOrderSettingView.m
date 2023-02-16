//
//  FODFollowOrderSettingView.m
//  Cropyme
//
//  Created by Hay on 2019/6/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FODFollowOrderSettingView.h"
#import "CommonUtil.h"
#import "TradeUtil.h"
#import "TextFieldToolBar.h"

@interface FODFollowOrderSettingView()<UITextFieldDelegate,TextFieldToolBarDelegate>
{
    TextFieldToolBar *toolBar;
    BOOL isDismissView;             //是否需要隐藏view
}

@property (copy, nonatomic) NSString *usdtRate;
@property (retain, nonatomic) FollowOrderDetailEntity *detailEntity;

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;                   //contentView底部约束
@property (retain, nonatomic) IBOutlet UIButton *commitButton;

@property (retain, nonatomic) IBOutlet UITextField *amountTF;
@property (retain, nonatomic) IBOutlet UILabel *cnyLabel;
@property (retain, nonatomic) IBOutlet UILabel *stopWinTitleLabel;
@property (retain, nonatomic) IBOutlet UISlider *stopWinSlider;
@property (retain, nonatomic) IBOutlet UILabel *stopLossTitleLabel;
@property (retain, nonatomic) IBOutlet UISlider *stopLossSlider;

@end

@implementation FODFollowOrderSettingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    isDismissView = NO;
    _amountTF.delegate = self;
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = toolBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
    _commitButton.enabled = NO;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolBar release];
    [_usdtRate release];
    [_detailEntity release];
    [_amountTF release];
    [_cnyLabel release];
    [_stopWinTitleLabel release];
    [_stopWinSlider release];
    [_stopLossTitleLabel release];
    [_stopLossSlider release];
    [_contentView release];
    [_commitButton release];
    [_contentViewLayoutConstraintBottom release];
    [super dealloc];
}

- (void)showSettingViewWithAnimationInView:(UIView *)superView
{
    [superView addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissSettingViewWithAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)updateSettingViewData:(FollowOrderDetailEntity *)entity usdtRate:(NSString *)usdtRate
{
    self.usdtRate = usdtRate;
    self.detailEntity = entity;
    _stopWinSlider.value = entity.stopWin;
    _stopLossSlider.value = entity.stopLoss;
    
    if(entity.stopWin <= 0){
        _stopWinTitleLabel.text = NSLocalizedStringForKey(@"止盈 未设置");
    }else{
        _stopWinTitleLabel.text = [NSString stringWithFormat:@"%@ +%@%%", NSLocalizedStringForKey(@"止盈"), [TradeUtil stringRoundDownFloatValue:(entity.stopWin * 100) dotBits:0]];
    }
    
    if(entity.stopLoss <= 0){
        _stopLossTitleLabel.text = NSLocalizedStringForKey(@"止损 未设置");
    }else{
        _stopLossTitleLabel.text = [NSString stringWithFormat:@"%@ -%@%%", NSLocalizedStringForKey(@"止损"), [TradeUtil stringRoundDownFloatValue:(entity.stopLoss * 100) dotBits:0]];
    }
    if(checkIsStringWithAnyText(entity.maxFollowBalance)){
        if([entity.maxFollowBalance doubleValue] > 0){
            _amountTF.text = [TradeUtil stringRoundDownFloatValue:[entity.maxFollowBalance doubleValue] dotBits:4];
            [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
            _commitButton.enabled = YES;
        }else{
            _amountTF.text = @"";
            [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
            _commitButton.enabled = NO;
        }
        
    }else{
        _amountTF.text = @"";
        [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
        _commitButton.enabled = NO;
    }
    
}

#pragma mark - 按钮点击事件
- (IBAction)commitButtonPressed:(id)sender
{
    [_amountTF resignFirstResponder];
    if(!checkIsStringWithAnyText(_amountTF.text)){
        if([_delegate respondsToSelector:@selector(settingViewShowErrorMsg:)]){
            [_delegate settingViewShowErrorMsg:NSLocalizedStringForKey(@"请输入每笔跟单上限")];
        }
        return;
    }
    if([_amountTF.text doubleValue] <= 0){
        if([_delegate respondsToSelector:@selector(settingViewShowErrorMsg:)]){
            [_delegate settingViewShowErrorMsg:NSLocalizedStringForKey(@"每笔跟单上限不能为0")];
        }
        return;
    }
    
    if([_delegate respondsToSelector:@selector(settingViewCommitButtonDidSelectedWithAmount:stopWin:stopLoss:settingView:)]){
        NSString *stopWin = [TradeUtil stringRoundDownFloatValue:_stopWinSlider.value dotBits:2];
        NSString *stopLoss = [TradeUtil stringRoundDownFloatValue:_stopLossSlider.value dotBits:2];
        [_delegate settingViewCommitButtonDidSelectedWithAmount:_amountTF.text stopWin:stopWin stopLoss:stopLoss settingView:self];
    }
}

- (IBAction)backgroundViewTouchDown:(id)sender
{
    isDismissView = YES;
    if([_amountTF isFirstResponder]){
        [_amountTF resignFirstResponder];
    }else{
        [self dismissSettingViewWithAnimation];
    }
    
}

#pragma mark - textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:4];
}

#pragma mark - ob
- (void)textfieldTextDidChanged:(NSNotification *)notifi
{
    if(checkIsStringWithAnyText(_amountTF.text)){
        _cnyLabel.text = [NSString stringWithFormat:@"≈¥%@",[TradeUtil stringRoundDownFloatValue:[_amountTF.text doubleValue] * [_usdtRate doubleValue] dotBits:2]];
        if(_commitButton.isEnabled == NO){
            [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1)] forState:UIControlStateNormal];
            _commitButton.enabled = YES;
        }
    }else{
        _cnyLabel.text = @"≈¥0.00";
        if(_commitButton.isEnabled == YES){
            [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117 ,174, 0.7)] forState:UIControlStateNormal];
            _commitButton.enabled = NO;
        }
    }
    
    
}

#pragma mark - slider
- (IBAction)profitSliderValueDidChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    CGFloat percentage = slider.value;
    if(percentage <= 0){
        _stopWinTitleLabel.text = NSLocalizedStringForKey(@"止盈 未设置");
    }else{
        _stopWinTitleLabel.text = [NSString stringWithFormat:@"%@ +%@%%", NSLocalizedStringForKey(@"止盈"), [TradeUtil stringRoundDownFloatValue:(percentage * 100) dotBits:0]];
    }
    
}

- (IBAction)lossSliderValueDidChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    CGFloat percentage = slider.value;
    if(percentage <= 0){
        _stopLossTitleLabel.text = NSLocalizedStringForKey(@"止损 未设置");
    }else{
        _stopLossTitleLabel.text = [NSString stringWithFormat:@"%@ -%@%%", NSLocalizedStringForKey(@"止损"), [TradeUtil stringRoundDownFloatValue:(percentage * 100) dotBits:0]];
    }
    
}


#pragma mark - 键盘事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _contentViewLayoutConstraintBottom.constant = keyboardRect.size.height;
    [self layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(isDismissView){
            [self dismissSettingViewWithAnimation];
        }
    }];
    
}

#pragma mark - TextFieldTooBar delegate
- (void)TFDonePressed
{
    isDismissView = NO;
    [_amountTF resignFirstResponder];
}
@end
