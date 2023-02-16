//
//  LeverageDetailOpenInfoCell.m
//  BYY
//
//  Created by Hay on 2019/12/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageDetailOpenInfoCell.h"
#import "TradeUtil.h"
#import "VeDateUtil.h"

@interface LeverageDetailOpenInfoCell()

@property (retain, nonatomic) LeverageTradeDetailModel *infoModel;

@property (retain, nonatomic) IBOutlet UILabel *totalBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalRateLabel;
@property (retain, nonatomic) IBOutlet UILabel *bailBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *buySellStateLabel;
@property (retain, nonatomic) IBOutlet UILabel *openPriceLabel;
@property (retain, nonatomic) IBOutlet UILabel *openAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *openBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *openFeeLabel;
@property (retain, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (retain, nonatomic) IBOutlet UIView *addBondBalanceView;          //增加保证金view


@end

@implementation LeverageDetailOpenInfoCell

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
    [_infoModel release];
    [_totalBalanceLabel release];
    [_totalRateLabel release];
    [_bailBalanceLabel release];
    [_buySellStateLabel release];
    [_openPriceLabel release];
    [_openAmountLabel release];
    [_openBalanceLabel release];
    [_openFeeLabel release];
    [_openTimeLabel release];
    [_addBondBalanceView release];
    [super dealloc];
}

- (void)reloadOpenInfoData:(LeverageTradeDetailModel *)model
{
    self.infoModel = model;
    
    if(model.closeDone == 0 && model.closeState <= 0){          //未平仓
        _addBondBalanceView.hidden = NO;
    }else{          //平仓中或已平仓
        _addBondBalanceView.hidden = YES;
    }
    
    _totalBalanceLabel.text = model.totalAssets;
    _totalRateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:model.assetsRate]];
    _bailBalanceLabel.text = model.bailBalance;
    _buySellStateLabel.text = model.buySellValue;
    _openPriceLabel.text = model.openCostPrice;
    _openAmountLabel.text = model.openDealAmount;
    _openBalanceLabel.text = model.openDealBalance;
    _openFeeLabel.text = model.openDealFee;
    _openTimeLabel.text = [VeDateUtil formatterDate:model.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    
}

#pragma mark - 增加保证金按钮点击事件
- (IBAction)addBondBalanceButonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(openInfoCellAddBondBalanceDidPressed)]){
        [_delegate openInfoCellAddBondBalanceDidPressed];
    }
}


@end
