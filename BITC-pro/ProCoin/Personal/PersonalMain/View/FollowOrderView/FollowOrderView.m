//
//  FollowOrderView.m
//  Cropyme
//
//  Created by Hay on 2019/7/23.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FollowOrderView.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"


#define DecimalDotBits      4

@interface FollowOrderView()<TextFieldToolBarDelegate,UITextFieldDelegate>
{
    TextFieldToolBar *toolBar;
    BOOL isDismissView;             //是否需要消失页面
}

@property (copy, nonatomic) NSString *ownAssets;

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UITextField *followOrderPriceTF;     //跟单金额输入框
@property (retain, nonatomic) IBOutlet UILabel *ownAssetsLabel;             //可用USDT
@property (retain, nonatomic) IBOutlet UIButton *followOrderButton;         //立即跟单按钮
@property (retain, nonatomic) IBOutlet UILabel *feeTipsLabel;               //收费说明
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;

@end

@implementation FollowOrderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initFollowOrderView];
}

- (void)initFollowOrderView
{
    isDismissView = NO;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followOrderPriceTFTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _followOrderPriceTF.inputAccessoryView = toolBar;
    _followOrderPriceTF.delegate = self;
    [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.6)] forState:UIControlStateNormal];
    _followOrderButton.enabled = NO;
    _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolBar release];
    [_ownAssets release];
    [_contentView release];
    [_followOrderPriceTF release];
    [_ownAssetsLabel release];
    [_followOrderButton release];
    [_contentViewLayoutConstraintBottom release];
    [_feeTipsLabel release];
    [super dealloc];
}

#pragma mark - 显示与消失
- (void)showFollowOrderViewInView:(UIView *)view withOwnAssets:(NSString *)ownAssets minFollowBalance:(NSString *)minFollowBalance followFeeTip:(NSString *)followFeeTip
{
    isDismissView = NO;
    self.ownAssets = ownAssets;
    [view addSubview:self];
    [_followOrderPriceTF setPlaceholder:[NSString stringWithFormat:NSLocalizedStringForKey(@"跟单资产不能低于%@USDT"),minFollowBalance]];
    _feeTipsLabel.text = followFeeTip;
    _ownAssetsLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"可用USDT"), ownAssets];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissFollowOrderView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 按钮点击事件
/** 阴影点击*/
- (IBAction)maskViewDidTouch:(id)sender
{
    isDismissView = YES;
    if([_followOrderPriceTF isFirstResponder]){
        [_followOrderPriceTF resignFirstResponder];
    }else{
        [self dismissFollowOrderView];
    }
}
/** 全部金额按钮点击事件*/
- (IBAction)allPriceButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(_ownAssets)){
        _followOrderPriceTF.text = [TradeUtil stringRoundDownFloatValue:[self.ownAssets doubleValue] dotBits:DecimalDotBits];
    }else{
        _followOrderPriceTF.text = @"0";
    }
    
    if([_followOrderPriceTF.text doubleValue] > 0){
        [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
        _followOrderButton.enabled = YES;
    }else{
        [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.6)] forState:UIControlStateNormal];
        _followOrderButton.enabled = NO;
    }
    
}

/** 风险提示*/
- (IBAction)riskTipsButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(followOrderViewButtonDidPressedWithType:infoDic:followOrderView:)]){
        [_delegate followOrderViewButtonDidPressedWithType:FollowOrderViewRiskTipsButtonType infoDic:nil followOrderView:self];
    }
}

/** 跟单规则*/
- (IBAction)followOrderRulesButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(followOrderViewButtonDidPressedWithType:infoDic:followOrderView:)]){
        [_delegate followOrderViewButtonDidPressedWithType:FollowOrderViewFollowOrderRulesButtonType infoDic:nil followOrderView:self];
    }
}

/** 立即跟单*/
- (IBAction)followOrderButtonPressed:(id)sender
{
    [_followOrderPriceTF resignFirstResponder];
    if([_delegate respondsToSelector:@selector(followOrderViewButtonDidPressedWithType:infoDic:followOrderView:)]){
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:_followOrderPriceTF.text forKey:FollowOrderInputPriceTextKey];
        [_delegate followOrderViewButtonDidPressedWithType:FollowOrderViewFollowOrderButtonType infoDic:infoDic followOrderView:self];
    }
}

#pragma mark -  textfield tool bar delegate
- (void)TFDonePressed
{
    [_followOrderPriceTF resignFirstResponder];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL success = [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:DecimalDotBits];
    return success;
}

#pragma mark - observe
- (void)followOrderPriceTFTextDidChanged:(NSNotification *)notification
{
    if(checkIsStringWithAnyText(_followOrderPriceTF.text)){
        if(_followOrderButton.isEnabled){
            return;
        }
        [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 1.0)] forState:UIControlStateNormal];
        _followOrderButton.enabled = YES;
    }else{
        if(!_followOrderButton.isEnabled){
            return;
        }
        [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 0.6)] forState:UIControlStateNormal];
        _followOrderButton.enabled = NO;
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
            [self dismissFollowOrderView];
        }
    }];
    
}
@end
