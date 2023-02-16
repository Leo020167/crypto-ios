//
//  TYMinePositionCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/13.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMinePositionCell.h"

@interface TYMinePositionCell ()

@property (nonatomic, strong) UILabel *nameTtileLabel;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *countTitleLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *moneyTitleLabel;

@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) UILabel *profitTitleLabel;

@property (nonatomic, strong) UILabel *profitLabel;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation TYMinePositionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.nameTtileLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.countTitleLabel];
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.moneyTitleLabel];
    [self.contentView addSubview:self.moneyLabel];
    [self.contentView addSubview:self.profitTitleLabel];
    [self.contentView addSubview:self.profitLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.arrowImageView];
    CGFloat width = (SCREEN_WIDTH - 40) / 4.0;
    [self.nameTtileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(width);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(width);
        make.top.mas_equalTo(self.nameTtileLabel.mas_bottom).offset(10);
    }];
    [self.countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameTtileLabel);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(width);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.countTitleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(width);
    }];
    [self.moneyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameTtileLabel);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(2 * width);
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.moneyTitleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(2 * width);
    }];
    [self.profitTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameTtileLabel);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(3 * width);
    }];
    [self.profitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.profitTitleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(3 * width);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(15);
    }];
}

- (void)setModel:(TYMinePositionModel *)model{
    self.nameLabel.text = model.symbol;
    self.countLabel.text = [NSString stringWithFormat:@"%@\n%@", model.amount, model.availableAmount];
    self.moneyLabel.text = model.price;
    self.profitLabel.text = model.profit;
    self.profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:model.profit.doubleValue];
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)nameTtileLabel{
    if (!_nameTtileLabel) {
        _nameTtileLabel = [[UILabel alloc] init];
        _nameTtileLabel.font = UIFontMake(15);
        _nameTtileLabel.textColor = UIColorMakeWithHex(@"#666666");
        _nameTtileLabel.text = NSLocalizedStringForKey(@"币种");
        _nameTtileLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameTtileLabel;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontMake(15);
        _nameLabel.textColor = UIColorMakeWithHex(@"#333333");
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)countTitleLabel{
    if (!_countTitleLabel) {
        _countTitleLabel = [[UILabel alloc] init];
        _countTitleLabel.font = UIFontMake(15);
        _countTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _countTitleLabel.text = NSLocalizedStringForKey(@"数量/可用");
        _countTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countTitleLabel;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = UIFontMake(15);
        _countLabel.textColor = UIColorMakeWithHex(@"#333333");
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.numberOfLines = 0;
    }
    return _countLabel;
}

- (UILabel *)moneyTitleLabel{
    if (!_moneyTitleLabel) {
        _moneyTitleLabel = [[UILabel alloc] init];
        _moneyTitleLabel.font = UIFontMake(15);
        _moneyTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _moneyTitleLabel.text = NSLocalizedStringForKey(@"成本");
        _moneyTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _moneyTitleLabel;
}

- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = UIFontMake(15);
        _moneyLabel.textColor = UIColorMakeWithHex(@"#333333");
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.numberOfLines = 0;
    }
    return _moneyLabel;
}

- (UILabel *)profitTitleLabel{
    if (!_profitTitleLabel) {
        _profitTitleLabel = [[UILabel alloc] init];
        _profitTitleLabel.font = UIFontMake(15);
        _profitTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _profitTitleLabel.text = NSLocalizedStringForKey(@"盈亏");
        _profitTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _profitTitleLabel;
}

- (UILabel *)profitLabel{
    if (!_profitLabel) {
        _profitLabel = [[UILabel alloc] init];
        _profitLabel.font = UIFontMake(15);
        _profitLabel.textColor = UIColorMakeWithHex(@"#333333");
        _profitLabel.textAlignment = NSTextAlignmentCenter;
        _profitLabel.numberOfLines = 0;
    }
    return _profitLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    }
    return _lineView;
}

- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:UIImageMake(@"util_Icon_more_arrow_gray")];
    }
    return _arrowImageView;
}

@end
