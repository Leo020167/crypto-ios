//
//  LeverageAddBondBalanceView.m
//  BYY
//
//  Created by Hay on 2020/1/2.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "LeverageAddBondBalanceView.h"
#import "CommonUtil.h"
#import "LeverageBondView.h"

@interface LeverageAddBondBalanceView()<LeverageBondViewDelegate>

@property (copy, nonatomic) NSString *selectedBondBalance;

/** 懒加载*/
@property (retain, nonatomic) LeverageBondView *bondSettingView;              //保证金设置view

@property (retain, nonatomic) IBOutlet UIButton *commitButton;
@property (retain, nonatomic) IBOutlet UIView *contentView;         //contentView
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;
@property (retain, nonatomic) IBOutlet UILabel *holdUsdtLabel;

@end

@implementation LeverageAddBondBalanceView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _contentViewLayoutConstraintBottom.constant = - (self.contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
    
    
    [self initialAddBondBalanceView];
}

- (void)initialAddBondBalanceView
{
    self.selectedBondBalance = @"";
    [self.bondSettingView setFrame:CGRectMake(12, 55, self.frame.size.width - 24, 108)];
    [self.contentView addSubview:self.bondSettingView];
}

- (void)dealloc
{
    [_selectedBondBalance release];
    [_bondSettingView release];
    [_commitButton release];
    [_contentViewLayoutConstraintBottom release];
    [_contentView release];
    [_holdUsdtLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (LeverageBondView *)bondSettingView
{
    if(!_bondSettingView){
        _bondSettingView = [[[[NSBundle mainBundle] loadNibNamed:@"LeverageBondView" owner:nil options:nil] lastObject] retain];
        _bondSettingView.delegate = self;
    }
    return _bondSettingView;
}

#pragma mark - 显示与消失
- (void)showViewInView:(UIView *)superView bondBalanceData:(NSArray *)bondBalanceData holdUsdt:(NSString *)holdUsdt
{
    _holdUsdtLabel.text = [NSString stringWithFormat:@"%@：%@USDT", NSLocalizedStringForKey(@"可用"), holdUsdt];
    [self.bondSettingView reloadLeverageBondData:bondBalanceData];
    self.selectedBondBalance = [bondBalanceData firstObject];           //默认选择第一个
    [superView addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissViewWithAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = - (self.contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - LeverageBondView delegate
- (void)leverageBondBalanceDidChanged:(NSString *)bondBalance
{
    if(!checkIsStringWithAnyText(bondBalance)){
        return;
    }
    self.selectedBondBalance = bondBalance;
}

#pragma mark - 按钮点击事件

- (IBAction)cancelViewButtonPressed:(id)sender
{
    [self dismissViewWithAnimation];
}

- (IBAction)backgroundViewDidTouchDown:(id)sender
{
    [self dismissViewWithAnimation];
}

- (IBAction)digitalAssetsDebitAndCreditProtocolButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(addBondBalanceViewDigitalAssetsDebitAndCreditProtocolButtonPressed)]){
        [_delegate addBondBalanceViewDigitalAssetsDebitAndCreditProtocolButtonPressed];
    }
}

- (IBAction)leverageTradeProtocolButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(addBondBalanceViewLeverageTradeProtocolButtonPressed)]){
        [_delegate addBondBalanceViewLeverageTradeProtocolButtonPressed];
    }
}
- (IBAction)commitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(addBondBalanceViewCommitButtonPressed:bondBalance:)]){
        [_delegate addBondBalanceViewCommitButtonPressed:self bondBalance:self.selectedBondBalance];
    }
}
@end
