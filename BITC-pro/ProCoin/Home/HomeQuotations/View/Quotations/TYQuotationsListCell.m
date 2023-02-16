//
//  TYQuotationsListCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/28.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYQuotationsListCell.h"

@interface TYQuotationsListCell () {
    HomeQuoteModel *itemModel;
    BOOL didShow;
}

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *amountLabel;

@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UIView *cellView;

@end

@implementation TYQuotationsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.cellView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.amountLabel];
    [self.contentView addSubview:self.rateLabel];
    [self.cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(19);
        make.top.mas_equalTo(20);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.bottom.mas_equalTo(-20);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(100);
        make.centerY.mas_equalTo(self.nameLabel);
    }];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel);
        make.centerY.mas_equalTo(self.descLabel);
    }];
    [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(90, 24));
        make.centerY.mas_equalTo(self);
    }];
}

- (void)bindModel:(HomeQuoteModel *)model index: (NSInteger)index {
    self.nameLabel.text = [NSString stringWithFormat:@"%@", model.symbol];
    self.descLabel.text = model.name;
    self.rateLabel.text = [NSString stringWithFormat:@"%@%@", model.rate, @"%"];
    self.amountLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedStringForKey(@"量"), model.amount];
    self.priceLabel.text = model.price;
    self.priceLabel.textColor = [TradeUtil textColorWithQuotationNumber:model.rate.doubleValue];
    self.rateLabel.backgroundColor = [TradeUtil textColorWithQuotationNumber:model.rate.doubleValue];
    
    if (model.changedRate != 0) {
        [self upDownAnimation: [TradeUtil textColorWithQuotationNumber:model.changedRate]
                        delay: [model.rate doubleValue] == model.changedRate ? (0.3 - 0.3 / index) : 0];
    }

    itemModel = [[HomeQuoteModel alloc] init];
    itemModel.symbol = model.symbol;
    itemModel.rate = model.rate;
}

- (void)startAnimation: (double)changed {
    if (didShow) {
        return;
    }
    UIColor *highlightColor = [TradeUtil textColorWithQuotationNumber:changed];
    [UIView animateKeyframesWithDuration:0.7 delay:drand48() options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:1.0 / 2 animations:^{
            self.cellView.backgroundColor = [highlightColor colorWithAlphaComponent:0.3];
        }];
        [UIView addKeyframeWithRelativeStartTime:1.0 / 2 relativeDuration:1.0 / 2 animations:^{
            self.cellView.backgroundColor = UIColor.clearColor;
        }];
        didShow = YES;
    } completion:^(BOOL finished) {
        NSLog(@"动画结束");
    }];
}


- (void)upDownAnimation: (UIColor *)highlightColor delay: (double)delay {
    [UIView animateKeyframesWithDuration:0.7 delay: delay options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:1.0 / 2 animations:^{
            self.cellView.backgroundColor = [highlightColor colorWithAlphaComponent:0.3];
        }];
        [UIView addKeyframeWithRelativeStartTime:1.0 / 2 relativeDuration:1.0 / 2 animations:^{
            self.cellView.backgroundColor = UIColor.clearColor;
        }];
    } completion:^(BOOL finished) {
        NSLog(@"动画结束");
    }];
}


#pragma mark =========================== 懒加载 ===========================
- (UIView *)cellView {
    if (!_cellView) {
        _cellView = [[UIView alloc] init];
        _cellView.backgroundColor = UIColor.clearColor;
    }
    return _cellView;
}
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColorMakeWithHex(@"#000000");
        _nameLabel.font = UIFontMake(17);
    }
    return _nameLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = UIColorMakeWithHex(@"#828282");
        _descLabel.font = UIFontMake(14);
    }
    return _descLabel;
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

- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.text = @"9999";
        _priceLabel.textColor = UIColor.blackColor;
        _priceLabel.font = UIFontBoldMake(17);
    }
    return _priceLabel;
}

- (UILabel *)amountLabel{
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] init];
        _amountLabel.text = @"9999";
        _amountLabel.textColor = UIColorMakeWithHex(@"#828282");
        _amountLabel.font = UIFontMake(14);
    }
    return _amountLabel;
}

@end
