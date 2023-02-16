//
//  LeverageDetailBorrowInfoCell.m
//  BYY
//
//  Created by Hay on 2019/12/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageDetailBorrowInfoCell.h"

@interface LeverageDetailBorrowInfoCell()
@property (retain, nonatomic) IBOutlet UIView *sysStopView;
@property (retain, nonatomic) IBOutlet UILabel *sysStopTipsLabel;
@property (retain, nonatomic) IBOutlet UIView *settingView;
@property (retain, nonatomic) IBOutlet UIButton *settingButton;
@property (retain, nonatomic) IBOutlet UILabel *borrowBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *interestLabel;
@property (retain, nonatomic) IBOutlet UILabel *sysStopPriceLabel;
@property (retain, nonatomic) IBOutlet UILabel *stopRateLabel;          //止盈止损文本

@end

@implementation LeverageDetailBorrowInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_sysStopView release];
    [_sysStopTipsLabel release];
    [_settingView release];
    [_settingButton release];
    [_borrowBalanceLabel release];
    [_interestLabel release];
    [_sysStopPriceLabel release];
    [_stopRateLabel release];
    [super dealloc];
}

- (void)reloadBorrowInfoData:(LeverageTradeDetailModel *)model
{
    if(model.closeDone){            //已平仓
        _sysStopView.hidden = YES;
        _settingView.hidden = YES;
    }else{
        _sysStopView.hidden = NO;
        _settingView.hidden = NO;
        _sysStopTipsLabel.text = model.sysStopWarn;
        
    }
    
    _borrowBalanceLabel.text = model.borrowBalance;
    _interestLabel.text = model.interest;
    _sysStopPriceLabel.text = model.sysStopPrice;
    _stopRateLabel.text = model.stopProfitLossValue;
}

#pragma mark - 按钮点击事件
- (IBAction)interestTipsButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(borrowInfoCellInterestTipsButtonPressed)]){
        [_delegate borrowInfoCellInterestTipsButtonPressed];
    }
}

- (IBAction)stopWinLossRateButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(borrowInfoCellStopWinLossRateButtonPressed)]){
        [_delegate borrowInfoCellStopWinLossRateButtonPressed];
    }
}

@end
