//
//  CTDTradeFollowOrderInfoCell.m
//  Cropyme
//
//  Created by Hay on 2019/5/28.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CTDTradeFollowOrderInfoCell.h"

@interface CTDTradeFollowOrderInfoCell()
//title
@property (retain, nonatomic) IBOutlet UILabel *amountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealAmountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *feeTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *balanceTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *followAmountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *followDealAmountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *followFeeTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *followBalanceTitleLabel;



//content
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *feeLabel;
@property (retain, nonatomic) IBOutlet UILabel *balanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *followOrderShareProfitLabel;    //跟单分成
@property (retain, nonatomic) IBOutlet UILabel *serviceFeeLabel;                //技术服务费
@property (retain, nonatomic) IBOutlet UILabel *followAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *followDealAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *followFeeLabel;
@property (retain, nonatomic) IBOutlet UILabel *followBalanceLabel;

@end

@implementation CTDTradeFollowOrderInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc
{
    
    [_amountTitleLabel release];
    [_dealAmountTitleLabel release];
    [_feeTitleLabel release];
    [_balanceTitleLabel release];
    [_amountLabel release];
    [_dealAmountLabel release];
    [_feeLabel release];
    [_balanceLabel release];
    [_followAmountTitleLabel release];
    [_followDealAmountTitleLabel release];
    [_followFeeTitleLabel release];
    [_followBalanceTitleLabel release];
    [_followAmountLabel release];
    [_followDealAmountLabel release];
    [_followFeeLabel release];
    [_followBalanceLabel release];
    [_followOrderShareProfitLabel release];
    [_serviceFeeLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 更新页面信息
- (void)reloadOrderInfoCellData:(CoinTradeOrderEntity *)orderEntity
{
    if([orderEntity.buySell isEqualToString:@"1"]){         //买入
        _feeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), orderEntity.originSymbol];
        _followFeeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), orderEntity.originSymbol];
    }else{                  //卖出
        _feeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), orderEntity.unitSymbol];
        _followFeeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), orderEntity.unitSymbol];;
    }
    
    _amountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"委托数量"),orderEntity.originSymbol];
    _amountLabel.text = orderEntity.amount;
    _dealAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交数量"), orderEntity.originSymbol];
    _dealAmountLabel.text = orderEntity.dealAmount;
    _feeLabel.text = orderEntity.dealFee;
    _balanceTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交额"), orderEntity.unitSymbol];
    _balanceLabel.text = orderEntity.dealBalance;
    
    _followOrderShareProfitLabel.text = orderEntity.profitShare;
    _serviceFeeLabel.text = orderEntity.serviceShare;
    _followAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"委托数量"), orderEntity.originSymbol];
    _followAmountLabel.text = orderEntity.followAmount;
    _followDealAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交数量"), orderEntity.originSymbol];
    _followDealAmountLabel.text = orderEntity.followDealAmount;
    _followFeeLabel.text = orderEntity.followDealFee;
    _followBalanceTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交额"), orderEntity.unitSymbol];;
    _followBalanceLabel.text = orderEntity.followDealBalance;
}


@end
