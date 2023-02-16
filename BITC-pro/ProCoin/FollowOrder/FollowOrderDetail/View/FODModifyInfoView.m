//
//  FODModifyInfoView.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FODModifyInfoView.h"
#import "CommonUtil.h"
#import "TradeUtil.h"
#import "TextFieldToolBar.h"

@interface FODModifyInfoView()<UITextFieldDelegate,TextFieldToolBarDelegate>
{
    BOOL isDismissView;             //在缩下键盘时是否需要隐藏view
    TextFieldToolBar *toolBar;
}

@property (retain, nonatomic) TradeConfigInfoEntity *configEntity;

@property (retain, nonatomic) IBOutlet UIButton *commitButton;          //确定按钮
@property (retain, nonatomic) IBOutlet UITextField *balanceTF;
@property (retain, nonatomic) IBOutlet UIView *contentView;             //内容页面
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutBottomConstraint;   //conent view底部约束
@property (retain, nonatomic) IBOutlet UILabel *assetLabel;
@property (retain, nonatomic) IBOutlet UILabel *cnyLabel;
@property (retain, nonatomic) IBOutlet UILabel *feeTipLabel;

@end

@implementation FODModifyInfoView



- (void)awakeFromNib
{
    [super awakeFromNib];
    isDismissView = NO;
    _balanceTF.delegate = self;
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _balanceTF.inputAccessoryView = toolBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
    _commitButton.enabled = NO;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _contentViewLayoutBottomConstraint.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolBar release];
    [_configEntity release];
    [_commitButton release];
    [_contentView release];
    [_balanceTF release];
    [_assetLabel release];
    [_cnyLabel release];
    [_contentViewLayoutBottomConstraint release];
    [_feeTipLabel release];
    [super dealloc];
}

- (void)updateModifyInfoViewData:(TradeConfigInfoEntity *)entity
{
    self.configEntity = entity;
    _assetLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedStringForKey(@"可用USDT"), _configEntity.holdUsdt];
    [_balanceTF setPlaceholder:[NSString stringWithFormat:NSLocalizedStringForKey(@"追加资产不能低于%@USDT"),_configEntity.minFollowAppendBalance]];
    _feeTipLabel.text = _configEntity.followFeeTip;
}


- (void)showModifyViewWithAnimationInView:(UIView *)superView
{
    [superView addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutBottomConstraint.constant = 0.0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissModifyViewWithAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutBottomConstraint.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - 按钮点击事件
- (IBAction)backgroundViewTouchDown:(id)sender
{
    isDismissView = YES;
    if([_balanceTF isFirstResponder]){
        [_balanceTF resignFirstResponder];
    }else{
        [self dismissModifyViewWithAnimation];
    }
    
}

/** 全部按钮点击事件*/
- (IBAction)allOwnAssetsButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(_configEntity.holdUsdt)){
        _balanceTF.text = [TradeUtil stringRoundDownFloatValue:[self.configEntity.holdUsdt doubleValue] dotBits:4];
    }else{
        _balanceTF.text = @"0";
    }
    
    if([_balanceTF.text doubleValue] > 0){
        _commitButton.enabled = YES;
        [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
    }else{
        _commitButton.enabled = NO;
        [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
    }
}

- (IBAction)commitButtonPressed:(id)sender
{
    if(!checkIsStringWithAnyText(_balanceTF.text)){
        if([_delegate respondsToSelector:@selector(modifyInfoViewShowErrorMsg:)]){
            [_delegate modifyInfoViewShowErrorMsg:NSLocalizedStringForKey(@"请输入追加的金额")];
        }
        return;
    }
    if([_balanceTF.text doubleValue] <= 0){
        if([_delegate respondsToSelector:@selector(modifyInfoViewShowErrorMsg:)]){
            [_delegate modifyInfoViewShowErrorMsg:NSLocalizedStringForKey(@"追加的金额不能为0")];
        }
        return;
    }
    [_balanceTF resignFirstResponder];
    if([_delegate respondsToSelector:@selector(modifyInfoViewCommintDidSelectedWithBalance:modifyInfoView:)]){
        [_delegate modifyInfoViewCommintDidSelectedWithBalance:_balanceTF.text modifyInfoView:self];
    }
    
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:4];
}

#pragma mark - observe
- (void)textfieldTextDidChanged:(NSNotification *)notifi
{
    if(checkIsStringWithAnyText(_balanceTF.text)){
       _cnyLabel.text = [NSString stringWithFormat:@"≈¥%@",[TradeUtil stringRoundDownFloatValue:[_balanceTF.text doubleValue] * [_configEntity.usdtRate doubleValue] dotBits:2]];
        if(_commitButton.isEnabled == NO){
            [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1)] forState:UIControlStateNormal];
            _commitButton.enabled = YES;
        }
        
    }else{
        _cnyLabel.text = @"≈¥0.00";
        if(_commitButton.isEnabled == YES){
            [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
            _commitButton.enabled = NO;
        }
        
    }
}

#pragma mark - 键盘事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _contentViewLayoutBottomConstraint.constant = keyboardRect.size.height;
    [self layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutBottomConstraint.constant = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(isDismissView){
            [self dismissModifyViewWithAnimation];
        }
    }];
    
}

#pragma mark - TextFieldTooBar delegate
- (void)TFDonePressed
{
    isDismissView = NO;
    [_balanceTF resignFirstResponder];
}
@end
