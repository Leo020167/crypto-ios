//
//  CTDTradeBaseInfoCell.m
//  Cropyme
//
//  Created by Hay on 2019/5/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CTDTradeBaseInfoCell.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"

@interface CTDTradeBaseInfoCell()

@property (retain, nonatomic) IBOutlet UIView *profitShareView;
@property (retain, nonatomic) IBOutlet UIView *myProfitView;                //我的盈利


//title
@property (retain, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *amountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealAvgPriceTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealAmountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealBalanceTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *feeTitleLabel;



//content
@property (retain, nonatomic) IBOutlet UILabel *buySellLabel;
@property (retain, nonatomic) IBOutlet UILabel *symbolLabel;
@property (retain, nonatomic) IBOutlet UILabel *stateDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;
@property (retain, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealAvgPriceLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *dealBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *feeLabel;
@property (retain, nonatomic) IBOutlet UILabel *myProfitLabel;


@end


@implementation CTDTradeBaseInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc
{
    [_buySellLabel release];
    [_symbolLabel release];
    [_stateDescLabel release];
    [_priceTitleLabel release];
    [_priceLabel release];
    [_amountLabel release];
    [_amountTitleLabel release];
    [_createTimeLabel release];
    [_dealAvgPriceTitleLabel release];
    [_dealAvgPriceLabel release];
    [_dealAmountTitleLabel release];
    [_dealAmountLabel release];
    [_dealBalanceTitleLabel release];
    [_dealBalanceLabel release];
    [_feeTitleLabel release];
    [_feeLabel release];
    [_profitShareView release];
    [_myProfitView release];
    [_myProfitLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 更新数据
- (void)reloadBaseInfoCellData:(CoinTradeOrderEntity *)orderEntity
{
    if([orderEntity.buySell isEqualToString:@"1"]){         //买入
        _buySellLabel.text = NSLocalizedStringForKey(@"买入");
        _buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:1.0];;
        _feeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), orderEntity.originSymbol];
        _amountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"委托额"), orderEntity.unitSymbol];
        _amountLabel.text = orderEntity.tolBalance;
        //买入不需要显示我的盈利
        _myProfitView.hidden = YES;
    }else{                      //卖出
        _buySellLabel.text = NSLocalizedStringForKey(@"卖出");
        _buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:-1.0];;
        _feeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), orderEntity.unitSymbol];
        _amountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"委托数量"), orderEntity.originSymbol];
        _amountLabel.text = orderEntity.tolAmount;
        _myProfitView.hidden = NO;
        _myProfitLabel.text = orderEntity.profit;
    }
    _symbolLabel.text = [NSString stringWithFormat:@"%@",orderEntity.symbol];
    _stateDescLabel.text = orderEntity.stateDesc;
    _priceTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"委托价格")];
    _priceLabel.text = orderEntity.price;
    
    _createTimeLabel.text = [VeDateUtil formatterDate:orderEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    _dealAvgPriceTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交均价"), orderEntity.unitSymbol];
    _dealAvgPriceLabel.text = orderEntity.dealAvgPrice;
    _dealAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交数量"), orderEntity.originSymbol];
    _dealAmountLabel.text = orderEntity.dealTolAmount;
    _dealBalanceTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交额"), orderEntity.unitSymbol];
    _dealBalanceLabel.text = orderEntity.dealTolBalance;
    _feeLabel.text = orderEntity.dealTolFee;
}

@end
