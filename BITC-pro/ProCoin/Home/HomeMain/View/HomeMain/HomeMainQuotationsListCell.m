//
//  HomeMainQuotationsListCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeMainQuotationsListCell.h"
#import "RZWebImageView.h"

@interface HomeMainQuotationsListCell ()

@property (nonatomic, strong) RZWebImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *amountLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation HomeMainQuotationsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.amountLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.rateLabel];
    [self.contentView addSubview:self.lineView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(38, 38));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
        make.top.mas_equalTo(25);
    }];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.bottom.mas_equalTo(-20);
    }];
    [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(70, 30));
        make.centerY.mas_equalTo(self);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.centerY.mas_equalTo(self);
        //make.centerX.mas_equalTo(self);
        make.right.mas_equalTo(self.rateLabel.mas_left).offset(-10);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(1);
    }];
}

- (void)setModel:(HomeQuoteModel *)model{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", model.symbol, model.currency]];
    [text yy_setFont:UIFontMake(12) range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"#9BA1B7") range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontBoldMake(18) range:NSMakeRange(0, model.symbol.length)];
    [text yy_setColor:UIColor.blackColor range:NSMakeRange(0, model.symbol.length)];
    [self.iconImageView showImageWithUrl:model.image];
    self.nameLabel.attributedText = text;
    self.amountLabel.text = [NSString stringWithFormat:@"24H%@%@", NSLocalizedStringForKey(@"量"), model.amount];
    self.rateLabel.text = [NSString stringWithFormat:@"%@%@", model.rate, @"%"];
    self.priceLabel.text = model.price;
    self.rateLabel.backgroundColor = [TradeUtil textColorWithQuotationNumber:model.rate.doubleValue];
}

#pragma mark =========================== 懒加载 ===========================
- (RZWebImageView *)iconImageView
{
    if(!_iconImageView){
        _iconImageView = [[RZWebImageView alloc] init];
        _iconImageView.userInteractionEnabled = NO;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        //_iconImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"BTC";
        _nameLabel.textColor = UIColor.blackColor;
        _nameLabel.font = UIFontBoldMake(18);
    }
    return _nameLabel;
}

- (UILabel *)amountLabel{
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] init];
        _amountLabel.textColor = UIColorMakeWithHex(@"#B5BACA");
        _amountLabel.font = UIFontMake(13);
    }
    return _amountLabel;
}

- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.text = @"9999";
        _priceLabel.textColor = UIColorMakeWithHex(@"#0C0C0C");
        _priceLabel.font = UIFontBoldMake(18);
    }
    return _priceLabel;
}

- (UILabel *)rateLabel{
    if (!_rateLabel) {
        _rateLabel = [[UILabel alloc] init];
        _rateLabel.text = @"BTC";
        _rateLabel.textColor = UIColor.whiteColor;
        _rateLabel.font = UIFontBoldMake(15);
        _rateLabel.backgroundColor = QuotationGreenColor;
        _rateLabel.layer.cornerRadius = 5;
        _rateLabel.layer.masksToBounds = YES;
        _rateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rateLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
    }
    return _lineView;
}
@end
