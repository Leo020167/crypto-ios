//
//  BBMinePositionCell.m
//  ProCoin
//
//  Created by Luo Chun on 2022/12/3.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "BBMinePositionCell.h"

@interface BBMinePositionCell ()

@property (nonatomic, strong) UIView *subView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *countTitleLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *moneyLabel;  //usdt

@property (nonatomic, strong) UILabel *freezeTitleLabel;

@property (nonatomic, strong) UILabel *freezeLabel;

@end

@implementation BBMinePositionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorClear;
    [self.contentView addSubview:self.subView];
    [self.subView addSubview:self.nameLabel];
    [self.subView addSubview:self.countTitleLabel];
    [self.subView addSubview:self.countLabel];
    
    [self.subView addSubview:self.moneyLabel];
    [self.subView addSubview:self.freezeTitleLabel];
    [self.subView addSubview:self.freezeLabel];
    
    CGFloat width = (SCREEN_WIDTH - 40) / 2.0;
    [self.subView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(106);
        //make.bottom.mas_equalTo(-10);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(20);
        //make.width.mas_equalTo(width);
        //make.top.mas_equalTo(self.nameTtileLabel.mas_bottom).offset(10);
        
    }];
    [self.countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(10);
        //make.width.mas_equalTo(width);
        make.left.mas_equalTo(20);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.countTitleLabel.mas_bottom).offset(8);
        make.width.mas_equalTo(width);
        make.left.mas_equalTo(20);
    }];

    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
        make.right.mas_equalTo(-20);
        //make.left.mas_equalTo(2 * width);
    }];
    [self.freezeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.mas_equalTo(self.nameTtileLabel);
        make.centerY.mas_equalTo(self.countTitleLabel.mas_centerY);
        make.right.mas_equalTo(self.moneyLabel.mas_right);
        //make.width.mas_equalTo(width);
        //make.left.mas_equalTo(3 * width);
    }];
    [self.freezeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.freezeTitleLabel.mas_bottom).offset(8);
        //make.width.mas_equalTo(width);
        make.right.mas_equalTo(self.moneyLabel.mas_right);
    }];
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(0);
//        make.height.mas_equalTo(1);
//    }];
//    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-10);
//        make.centerY.mas_equalTo(self);
//        make.size.mas_equalTo(15);
//    }];
}

- (void)setModel:(TYMinePositionModel *)model{
    self.nameLabel.text = model.symbol;
    self.countLabel.text = [NSString stringWithFormat:@"%@", model.availableAmount];
    self.moneyLabel.text = [NSString stringWithFormat:@"≈ %@ USDT", model.usdtAmount];
    self.freezeLabel.text = model.frozenAmount ?: @"0";
    //self.freezeLabel.textColor = [TradeUtil textColorWithQuotationNumber:model.profit.doubleValue];
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)subView{
    if (!_subView) {
        _subView = [[UIView alloc] init];
        
        _subView.backgroundColor = UIColorMakeWithHex(@"#F6F7F9");
        _subView.layer.cornerRadius= 10;
    }
    return _subView;
}


- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontBoldMake(18);
        _nameLabel.textColor = UIColorMakeWithHex(@"#6175AE");
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel *)countTitleLabel{
    if (!_countTitleLabel) {
        _countTitleLabel = [[UILabel alloc] init];
        _countTitleLabel.font = UIFontMake(12);
        _countTitleLabel.textColor = UIColorMakeWithHex(@"#A2A9BC");
        _countTitleLabel.text = NSLocalizedStringForKey(@"可用");
        _countTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _countTitleLabel;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _countLabel.textColor = UIColorMakeWithHex(@"#3E4660");
        _countLabel.textAlignment = NSTextAlignmentLeft;
        //_countLabel.numberOfLines = 0;
    }
    return _countLabel;
}


- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = UIFontMake(12);
        _moneyLabel.textColor = UIColorMakeWithHex(@"#A2A9BC");
        _moneyLabel.textAlignment = NSTextAlignmentRight;
        //_moneyLabel.numberOfLines = 0;
    }
    return _moneyLabel;
}

- (UILabel *)freezeTitleLabel{
    if (!_freezeTitleLabel) {
        _freezeTitleLabel = [[UILabel alloc] init];
        _freezeTitleLabel.font = UIFontMake(12);
        _freezeTitleLabel.textColor = UIColorMakeWithHex(@"#A2A9BC");
        _freezeTitleLabel.text = NSLocalizedStringForKey(@"委托");
        _freezeTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _freezeTitleLabel;
}

- (UILabel *)freezeLabel{
    if (!_freezeLabel) {
        _freezeLabel = [[UILabel alloc] init];
        _freezeLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _freezeLabel.textColor = UIColorMakeWithHex(@"#3E4660");
        _freezeLabel.textAlignment = NSTextAlignmentRight;
        //_freezeLabel.numberOfLines = 0;
    }
    return _freezeLabel;
}

//- (UIView *)lineView{
//    if (!_lineView) {
//        _lineView = [[UIView alloc] init];
//        _lineView.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
//    }
//    return _lineView;
//}
//
//- (UIImageView *)arrowImageView{
//    if (!_arrowImageView) {
//        _arrowImageView = [[UIImageView alloc] initWithImage:UIImageMake(@"util_Icon_more_arrow_gray")];
//    }
//    return _arrowImageView;
//}

@end
