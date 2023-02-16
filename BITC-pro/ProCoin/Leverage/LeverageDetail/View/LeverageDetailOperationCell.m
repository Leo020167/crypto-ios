//
//  LeverageDdetailOperationCell.m
//  BYY
//
//  Created by Hay on 2020/1/1.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "LeverageDetailOperationCell.h"
#import "TradeUtil.h"

@interface LeverageDetailOperationCell()

@property (retain, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIImageView *rateStateIV;
@property (retain, nonatomic) IBOutlet UIButton *operationButton;


@end

@implementation LeverageDetailOperationCell

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
    [_priceTitleLabel release];
    [_priceLabel release];
    [_rateStateIV release];
    [_operationButton release];
    [super dealloc];
}

#pragma mark -
- (void)reloadOpetationCellData:(LeverageTradeDetailModel *)model
{
    _priceTitleLabel.text = [NSString stringWithFormat:@"%@%@",model.symbol, NSLocalizedStringForKey(@"现价")];
    _priceLabel.text = [NSString stringWithFormat:@"%@ %@%%",model.last,[TradeUtil stringByAppendingPlusSymbolString:model.rate]];
    _priceLabel.textColor = [TradeUtil textColorWithQuotationNumber:[model.rate doubleValue]];
    if(model.rate >= 0){
        _rateStateIV.image = [UIImage imageNamed:@"leverage_icon_rise"];
    }else{
        _rateStateIV.image = [UIImage imageNamed:@"leverage_icon_down"];
    }
    
    if(model.closeDone == 0 && model.closeState > 0){
        _operationButton.backgroundColor = RGBA(97, 117, 174, 0.2);
        [_operationButton setTitle:NSLocalizedStringForKey(@"正在平仓中") forState:UIControlStateNormal];
        _operationButton.enabled = NO;
    }else{
        _operationButton.backgroundColor = RGBA(97, 117, 174, 1.0);
        [_operationButton setTitle:NSLocalizedStringForKey(@"平仓") forState:UIControlStateNormal];
        _operationButton.enabled = YES;
    }
}

#pragma mark - 按钮点击事件
- (IBAction)closeButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(operationCellCloseButtonPressed)]){
        [_delegate operationCellCloseButtonPressed];
    }
}

- (IBAction)quotationInfoButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(operationCellQuotationInfoButtonPressed)]){
        [_delegate operationCellQuotationInfoButtonPressed];
    }
}

@end
