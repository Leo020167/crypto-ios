//
//  TYAccountFollowInfoCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountFollowInfoCell.h"

@interface TYAccountFollowInfoCell ()

@property (nonatomic, strong) UILabel *totalAssetTitleLabel;

@property (nonatomic, strong) UILabel *totalAssetLabel;

@property (nonatomic, strong) UILabel *freezeTitleLabel;

@property (nonatomic, strong) UILabel *freezeLabel;

@property (nonatomic, strong) UILabel *profitLabel;

@property (nonatomic, strong) UILabel *availableTitleLabel;

@property (nonatomic, strong) UILabel *availableLabel;

@property (nonatomic, strong) UILabel *priceTitleLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *followFreezeTitleLabel;

@property (nonatomic, strong) UILabel *followFreezeLabel;

@end

@implementation TYAccountFollowInfoCell

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
    [self.contentView addSubview:self.rateBtn];
    [self.contentView addSubview:self.profitLabel];
    [self.contentView addSubview:self.freezeTitleLabel];
    [self.contentView addSubview:self.freezeLabel];
    [self.contentView addSubview:self.availableTitleLabel];
    [self.contentView addSubview:self.availableLabel];
    [self.contentView addSubview:self.priceTitleLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.followFreezeTitleLabel];
    [self.contentView addSubview:self.followFreezeLabel];
    [self.totalAssetTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
    }];
    [self.totalAssetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.totalAssetTitleLabel.mas_bottom).offset(15);
    }];
    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
    }];
    [self.profitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.rateBtn.mas_bottom).offset(15);
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
    [self.followFreezeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.availableLabel.mas_bottom).offset(15);
    }];
    [self.followFreezeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.followFreezeTitleLabel.mas_bottom).offset(15);
    }];
}

- (void)setFollowModel:(PCAccountModel *)followModel{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", followModel.assets, followModel.assetsCny]];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"2B4166") range:NSMakeRange(0, followModel.assets.length)];
    [text yy_setFont:UIFontMake(12) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(14) range:NSMakeRange(0, followModel.assets.length)];
    self.totalAssetLabel.attributedText = text;
    
    self.profitLabel.text = followModel.riskRate;
    
    self.availableLabel.text = followModel.eableBail;
    
    self.freezeLabel.text = followModel.profit;
    self.freezeLabel.textColor = [TradeUtil textColorWithQuotationNumber:[followModel.profit doubleValue]];
    
    self.priceLabel.text = followModel.openBail;
    
    self.followFreezeLabel.text = followModel.disableAmount;
}

- (void)setIndexModel:(PCAccountModel *)indexModel{
    self.totalAssetTitleLabel.text = NSLocalizedStringForKey(@"总资产(USDT)");
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", indexModel.assets, indexModel.assetsCny]];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"2B4166") range:NSMakeRange(0, indexModel.assets.length)];
    [text yy_setFont:UIFontMake(12) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(14) range:NSMakeRange(0, indexModel.assets.length)];
    self.totalAssetLabel.attributedText = text;
    
    self.profitLabel.text = indexModel.riskRate;
    
    self.availableLabel.text = indexModel.eableBail;
    
    self.freezeLabel.text = indexModel.profit;
    self.freezeLabel.textColor = [TradeUtil textColorWithQuotationNumber:[indexModel.profit doubleValue]];
    
    self.priceLabel.text = indexModel.openBail;
    
    self.followFreezeTitleLabel.text = NSLocalizedStringForKey(@"冻结保证金(USDT)");
    self.followFreezeLabel.text = indexModel.disableAmount;
}

- (void)setContractModel:(PCAccountModel *)contractModel{
    self.totalAssetTitleLabel.text = NSLocalizedStringForKey(@"总资产(USDT)");
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", contractModel.assets, contractModel.assetsCny]];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"2B4166") range:NSMakeRange(0, contractModel.assets.length)];
    [text yy_setFont:UIFontMake(12) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(14) range:NSMakeRange(0, contractModel.assets.length)];
    self.totalAssetLabel.attributedText = text;
    
    self.profitLabel.text = contractModel.riskRate;
    
    self.availableLabel.text = contractModel.eableBail;
    
    self.freezeLabel.text = contractModel.profit;
    self.freezeLabel.textColor = [TradeUtil textColorWithQuotationNumber:[contractModel.profit doubleValue]];
    
    self.priceLabel.text = contractModel.openBail;
    
    self.followFreezeTitleLabel.text = NSLocalizedStringForKey(@"冻结保证金(USDT)");
    self.followFreezeLabel.text = contractModel.disableAmount;
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)totalAssetTitleLabel{
    if (!_totalAssetTitleLabel) {
        _totalAssetTitleLabel = [[UILabel alloc] init];
        _totalAssetTitleLabel.font = UIFontMake(15);
        _totalAssetTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _totalAssetTitleLabel.text = NSLocalizedStringForKey(@"总资产(USDT)");
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
        _freezeTitleLabel.text = NSLocalizedStringForKey(@"未实现盈亏(USDT)");
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

- (QMUIButton *)rateBtn{
    if (!_rateBtn) {
        _rateBtn = [[QMUIButton alloc] init];
        [_rateBtn setTitle:NSLocalizedStringForKey(@"风险率") forState:0];
        [_rateBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        _rateBtn.titleLabel.font = UIFontMake(15);
        [_rateBtn setImage:UIImageMake(@"home_account_icon_question") forState:0];
        _rateBtn.spacingBetweenImageAndTitle = 3;
        _rateBtn.imagePosition = QMUIButtonImagePositionRight;
    }
    return _rateBtn;
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
        _availableTitleLabel.text = NSLocalizedStringForKey(@"可用保证金(USDT)");
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
        _priceTitleLabel.text = NSLocalizedStringForKey(@"持仓保证金(USDT)");
    }
    return _priceTitleLabel;
}

- (UILabel *)followFreezeLabel{
    if (!_followFreezeLabel) {
        _followFreezeLabel = [[UILabel alloc] init];
        _followFreezeLabel.font = UIFontMake(13);
        _followFreezeLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _followFreezeLabel;
}

- (UILabel *)followFreezeTitleLabel{
    if (!_followFreezeTitleLabel) {
        _followFreezeTitleLabel = [[UILabel alloc] init];
        _followFreezeTitleLabel.font = UIFontMake(15);
        _followFreezeTitleLabel.textColor = UIColorMakeWithHex(@"#999999");
        _followFreezeTitleLabel.text = NSLocalizedStringForKey(@"跟单冻结资产(USDT)");
    }
    return _followFreezeTitleLabel;
}

@end
