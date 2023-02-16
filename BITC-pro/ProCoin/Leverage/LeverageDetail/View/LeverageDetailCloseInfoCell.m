//
//  LeverageDetailCloseInfoCell.m
//  BYY
//
//  Created by Hay on 2020/1/1.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "LeverageDetailCloseInfoCell.h"
#import "VeDateUtil.h"

@interface LeverageDetailCloseInfoCell()

@property (retain, nonatomic) IBOutlet UILabel *closePriceLabel;
@property (retain, nonatomic) IBOutlet UILabel *closeAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *closeBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *closeFeeLabel;
@property (retain, nonatomic) IBOutlet UILabel *closeTimeLabel;

@end

@implementation LeverageDetailCloseInfoCell

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
    [_closePriceLabel release];
    [_closeAmountLabel release];
    [_closeBalanceLabel release];
    [_closeFeeLabel release];
    [_closeTimeLabel release];
    [super dealloc];
}

#pragma mark -
- (void)reloadCloseInfoData:(LeverageTradeDetailModel *)model
{
    _closePriceLabel.text = model.closeCostPrice;
    _closeAmountLabel.text = model.closeDealAmount;
    _closeBalanceLabel.text = model.closeDealBalance;
    _closeFeeLabel.text = model.closeDealFee;
    _closeTimeLabel.text = [VeDateUtil formatterDate:model.closeTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
}
@end
