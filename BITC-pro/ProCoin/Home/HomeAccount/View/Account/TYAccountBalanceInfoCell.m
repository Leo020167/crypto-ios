//
//  TYAccountBalanceInfoCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/21.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountBalanceInfoCell.h"

@interface TYAccountBalanceInfoCell ()

@property (nonatomic, strong) UILabel *totalAssetTitleLabel;

@property (nonatomic, strong) UILabel *totalAssetLabel;

@property (nonatomic, strong) UILabel *freezeTitleLabel;

@property (nonatomic, strong) UILabel *freezeLabel;

@property (nonatomic, strong) UILabel *profitTitleLabel;

@property (nonatomic, strong) UILabel *profitLabel;

@property (nonatomic, strong) UILabel *availableTitleLabel;

@property (nonatomic, strong) UILabel *availableLabel;

@property (nonatomic, strong) UILabel *priceTitleLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation TYAccountBalanceInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.totalAssetTitleLabel];
    [self.contentView addSubview:self.totalAssetLabel];
    [self.contentView addSubview:self.profitTitleLabel];
    [self.contentView addSubview:self.profitLabel];
    [self.contentView addSubview:self.freezeTitleLabel];
    [self.contentView addSubview:self.freezeLabel];
    [self.contentView addSubview:self.availableTitleLabel];
    [self.contentView addSubview:self.availableLabel];
    [self.contentView addSubview:self.priceTitleLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.totalAssetTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
    }];
    [self.totalAssetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.totalAssetTitleLabel.mas_bottom).offset(15);
    }];
    [self.profitTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
    }];
    [self.profitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.profitTitleLabel.mas_bottom).offset(15);
    }];
    [self.availableTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.totalAssetLabel.mas_bottom).offset(15);
    }];
    [self.availableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.availableTitleLabel.mas_bottom).offset(15);
    }];
    [self.freezeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.totalAssetLabel.mas_bottom).offset(15);
    }];
    [self.freezeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.freezeTitleLabel.mas_bottom).offset(15);
    }];
    [self.priceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.availableLabel.mas_bottom).offset(15);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.priceTitleLabel.mas_bottom).offset(15);
    }];
}

- (void)setBalanceModel:(PCAccountModel *)balanceModel{
    
    self.totalAssetTitleLabel.text = NSLocalizedStringForKey(@"余额账户总资产(USDT)");
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", balanceModel.assets, balanceModel.assetsCny]];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"2B4166") range:NSMakeRange(0, balanceModel.assets.length)];
    [text yy_setFont:UIFontMake(12) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(14) range:NSMakeRange(0, balanceModel.assets.length)];
    self.totalAssetLabel.attributedText = text;
    
    self.availableTitleLabel.text = NSLocalizedStringForKey(@"可用(USDT)");
    self.availableLabel.text = balanceModel.holdAmount;
    
    self.freezeTitleLabel.text = NSLocalizedStringForKey(@"冻结(USDT)");
    self.freezeLabel.text = balanceModel.frozenAmount;
    
    self.profitTitleLabel.text = @"";
    self.profitLabel.text = @"";
    
    self.priceTitleLabel.text = @"";
    self.priceLabel.text = @"";
}

- (void)setCoinModel:(PCAccountModel *)coinModel{
    self.totalAssetTitleLabel.text = NSLocalizedStringForKey(@"总资产(USDT)");
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", coinModel.assets, coinModel.assetsCny]];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"2B4166") range:NSMakeRange(0, coinModel.assets.length)];
    [text yy_setFont:UIFontMake(12) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(14) range:NSMakeRange(0, coinModel.assets.length)];
    self.totalAssetLabel.attributedText = text;
    
    self.profitTitleLabel.text = NSLocalizedStringForKey(@"总盈亏(USDT)");
    self.profitLabel.text = coinModel.profit;
    self.profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[coinModel.profit doubleValue]];
    
    self.availableTitleLabel.text = NSLocalizedStringForKey(@"可用(USDT)");
    self.availableLabel.text = coinModel.holdAmount;
    
    self.freezeTitleLabel.text = NSLocalizedStringForKey(@"委托金额(USDT)");
    self.freezeLabel.text = coinModel.frozenBail;
    
    self.priceTitleLabel.text = @"";
    self.priceLabel.text = @"";
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)totalAssetTitleLabel{
    if (!_totalAssetTitleLabel) {
        _totalAssetTitleLabel = [[UILabel alloc] init];
        _totalAssetTitleLabel.font = UIFontMake(15);
        _totalAssetTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _totalAssetTitleLabel.text = @"总资产(USDT)";
    }
    return _totalAssetTitleLabel;
}

- (UILabel *)totalAssetLabel{
    if (!_totalAssetLabel) {
        _totalAssetLabel = [[UILabel alloc] init];
        _totalAssetLabel.font = UIFontMake(13);
        _totalAssetLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _totalAssetLabel;
}

- (UILabel *)freezeTitleLabel{
    if (!_freezeTitleLabel) {
        _freezeTitleLabel = [[UILabel alloc] init];
        _freezeTitleLabel.font = UIFontMake(15);
        _freezeTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _freezeTitleLabel.text = @"冻结(USDT)";
    }
    return _freezeTitleLabel;
}

- (UILabel *)freezeLabel{
    if (!_freezeLabel) {
        _freezeLabel = [[UILabel alloc] init];
        _freezeLabel.font = UIFontMake(13);
        _freezeLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _freezeLabel;
}

- (UILabel *)profitTitleLabel{
    if (!_profitTitleLabel) {
        _profitTitleLabel = [[UILabel alloc] init];
        _profitTitleLabel.font = UIFontMake(15);
        _profitTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _profitTitleLabel.text = @"总盈亏(USDT)";
    }
    return _profitTitleLabel;
}

- (UILabel *)profitLabel{
    if (!_profitLabel) {
        _profitLabel = [[UILabel alloc] init];
        _profitLabel.font = UIFontMake(13);
        _profitLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _profitLabel;
}

- (UILabel *)availableLabel{
    if (!_availableLabel) {
        _availableLabel = [[UILabel alloc] init];
        _availableLabel.font = UIFontMake(13);
        _availableLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _availableLabel;
}

- (UILabel *)availableTitleLabel{
    if (!_availableTitleLabel) {
        _availableTitleLabel = [[UILabel alloc] init];
        _availableTitleLabel.font = UIFontMake(15);
        _availableTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _availableTitleLabel.text = @"可用(USDT)";
    }
    return _availableTitleLabel;
}

- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = UIFontMake(13);
        _priceLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _priceLabel;
}

- (UILabel *)priceTitleLabel{
    if (!_priceTitleLabel) {
        _priceTitleLabel = [[UILabel alloc] init];
        _priceTitleLabel.font = UIFontMake(15);
        _priceTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _priceTitleLabel.text = @"委托金额(USDT)";
    }
    return _priceTitleLabel;
}

@end
