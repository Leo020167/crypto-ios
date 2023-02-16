//
//  KBTBuyBackInputView.m
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinSubscribeInputView.h"
#import "CommonUtil.h"
#import "TradeUtil.h"

#define ButtonOriginIndex         1000

@interface CoinSubscribeInputView()
{
    NSInteger selectedPriceIndex;                   //选中的价格索引
    NSInteger buyBackDecimals;                      //认购位数
}


@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *holdAmount;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSArray *balanceOptionsArr;

@property (retain, nonatomic) IBOutlet UIView *balanceOptionsView;
@property (retain, nonatomic) IBOutlet UILabel *subAmountTitleLabel;    //认购数量
@property (retain, nonatomic) IBOutlet UILabel *subBalanceLabel;        //认购金额
@property (retain, nonatomic) IBOutlet UIButton *equityInfoButton;      //锁仓权益说明
@property (retain, nonatomic) IBOutlet UIView *equityLevelView;         //权益view
@property (retain, nonatomic) IBOutlet UILabel *equityLevelLabel;       //权益等级
@property (retain, nonatomic) IBOutlet UILabel *equityTipLabel;         //权益提示
@property (retain, nonatomic) IBOutlet UILabel *holdAmountLabel;        //持有数量
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;           //content view底部约束

@end

@implementation CoinSubscribeInputView

- (void)awakeFromNib
{
    [super awakeFromNib];
    selectedPriceIndex = -1;
    buyBackDecimals = 8;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);

    
    _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
    
}

- (void)dealloc
{
    [_symbol release];
    [_holdAmount release];
    [_price release];
    [_balanceOptionsArr release];
    [_holdAmountLabel release];
    [_contentViewLayoutConstraintBottom release];
    [_contentView release];
    [_balanceOptionsView release];
    [_subAmountTitleLabel release];
    [_equityLevelLabel release];
    [_equityTipLabel release];
    [_subBalanceLabel release];
    [_equityLevelView release];
    [_equityInfoButton release];
    [super dealloc];
}

- (void)reloadInputViewWithHoldAmount:(NSString *)holdAmount symbol:(NSString *)symbol balanceArr:(NSArray *)balanceArr price:(NSString *)price myEquityLevel:(NSString *)myEquityLevel myEquityTip:(NSString *)myEquityTip
{
    self.symbol = symbol;
    self.holdAmount = holdAmount;
    self.price = price;
    self.balanceOptionsArr = balanceArr;
    
    [self createOptionsButtonInOptionsView];
    
    _subAmountTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"选择认购%@数量"),symbol];
    _subBalanceLabel.text = [NSString stringWithFormat:@"%@：0USDT", NSLocalizedStringForKey(@"认购金额")];
    if(checkIsStringWithAnyText(myEquityLevel)){
        [CommonUtil viewHeightForAutoLayout:_equityLevelView height:55.0];
        _equityInfoButton.hidden = NO;
        _equityLevelLabel.text = myEquityLevel;
        _equityTipLabel.text = myEquityTip;
    }else{
        [CommonUtil viewHeightForAutoLayout:_equityLevelView height:0.0];
        _equityInfoButton.hidden = YES;
    }
    _holdAmountLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"持有USDT数量"), holdAmount];
    [self layoutIfNeeded];
    
}

/** 创建按钮*/
- (void)createOptionsButtonInOptionsView
{
    [_balanceOptionsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger count = [_balanceOptionsArr count] > 4 ? 4 : [_balanceOptionsArr count];
    CGFloat buttonWidth = 75;
    CGFloat tap =  ( self.frame.size.width - 30 - buttonWidth * 4) / 3.0f;
    for(int i = 0; i < count; i++){
        NSString *title = [NSString stringWithFormat:@"%@",[_balanceOptionsArr objectAtIndex:i]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0.0 + i * (buttonWidth + tap), 0.0, buttonWidth, _balanceOptionsView.frame.size.height)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3;
        button.layer.borderWidth = 1;
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        button.tag = ButtonOriginIndex + i;
        [button addTarget:self action:@selector(priceOptionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self updateButtonStateNormal:button];
        [self.balanceOptionsView addSubview:button];
    }
    
}

#pragma mark - 显示与消失
- (void)showCoinSubscribeInputViewInView:(UIView *)view
{
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissCoinSubscribeInputView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}




#pragma mark - 按钮点击事件
- (IBAction)backgroundViewTouchDown:(id)sender
{
    [self dismissCoinSubscribeInputView];
}

- (IBAction)equityInfoButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(coinSubscribeInputViewEquityInfoButtonDidPressed)]){
        [_delegate coinSubscribeInputViewEquityInfoButtonDidPressed];
    }
}


- (IBAction)certainButtonPressed:(id)sender
{
    
    if(selectedPriceIndex == -1){
        if([_delegate respondsToSelector:@selector(coinSubscribeInputViewErrorMsg:)]){
            [_delegate coinSubscribeInputViewErrorMsg:NSLocalizedStringForKey(@"请选择认购金额")];
        }
        return;
    }

    [self dismissCoinSubscribeInputView];
    if([_delegate respondsToSelector:@selector(coinSubscribeInputViewCertainButtonDidPressedWithPriceIndex:)]){
        [_delegate coinSubscribeInputViewCertainButtonDidPressedWithPriceIndex:selectedPriceIndex];
    }
    
}

- (void)priceOptionsButtonPressed:(UIButton *)sender
{
    if(sender.isSelected){
        return;
    }
    sender.selected = YES;
    [self updateButtonStateSelected:sender];
    NSInteger index = sender.tag - ButtonOriginIndex;
    selectedPriceIndex = index;
    NSInteger count = [_balanceOptionsArr count] > 4 ? 4 : [_balanceOptionsArr count];
    for(int i = 0; i < count; i++){
        if(i == index)
            continue;
        UIButton *button = [_balanceOptionsView viewWithTag:(ButtonOriginIndex + i)];
        [self updateButtonStateNormal:button];
    }
    NSString *title = [NSString stringWithFormat:@"%@",[_balanceOptionsArr objectAtIndex:selectedPriceIndex]];
    _subBalanceLabel.text = [NSString stringWithFormat:@"%@：%.8fUSDT", NSLocalizedStringForKey(@"认购金额"), [title floatValue] * [_price floatValue]];
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
        [self dismissCoinSubscribeInputView];
    }];
    
}


#pragma mark - 设置按钮状态
- (void)updateButtonStateSelected:(UIButton *)button
{
    button.selected = YES;
    button.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:RGBA(97, 117, 174, 1.0)];
}

- (void)updateButtonStateNormal:(UIButton *)button
{
    button.selected = NO;
    button.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
    [button setTitleColor:RGBA(97, 117, 174, 1.0) forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
}

@end
