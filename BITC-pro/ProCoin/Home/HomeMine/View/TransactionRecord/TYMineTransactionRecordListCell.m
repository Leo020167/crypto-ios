//
//  TYMineTransactionRecordListCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/29.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineTransactionRecordListCell.h"
#import "VeDateUtil.h"


@interface TYMineTransactionRecordListCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *lotLabel;

@property (nonatomic, strong) UILabel *lotTitleLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *priceTitleLabel;

@property (nonatomic, strong) UILabel *totalLabel;

@property (nonatomic, strong) UILabel *totalTitleLabel;

@property (nonatomic, strong) UILabel *marginLabel;

@property (nonatomic, strong) UILabel *marginTitleLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) QMUIButton *statusBtn;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation TYMineTransactionRecordListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.statusBtn];
    [self.contentView addSubview:self.lotLabel];
    [self.contentView addSubview:self.lotTitleLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.priceTitleLabel];
    [self.contentView addSubview:self.totalLabel];
    [self.contentView addSubview:self.totalTitleLabel];
    [self.contentView addSubview:self.marginLabel];
    [self.contentView addSubview:self.marginTitleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.lineView];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.nameLabel);
    }];
    [self.statusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.nameLabel);
    }];
    CGFloat width = (SCREEN_WIDTH - 30) / 4.0;
    [self.lotTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(width);
    }];
    [self.lotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lotTitleLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(self.lotTitleLabel);
        make.width.mas_equalTo(width);
    }];
    [self.priceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.left.mas_equalTo(width);
        make.width.mas_equalTo(width);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceTitleLabel.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.priceTitleLabel);
        make.width.mas_equalTo(width);
    }];
    [self.totalTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.right.mas_equalTo(- width - 15);
        make.width.mas_equalTo(width);
    }];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalTitleLabel.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.totalTitleLabel);
        make.width.mas_equalTo(width);
    }];
    [self.marginTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(width);
    }];
    [self.marginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.marginTitleLabel.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.marginTitleLabel);
        make.width.mas_equalTo(width);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}

- (void)setModel:(PCBaseTransactionRecordModel *)model{
    
    if ([model.buySell isEqualToString:@"buy"]) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ · ", model.symbol];
        self.titleLabel.text = NSLocalizedStringForKey(@"买入");
    }else{
        self.nameLabel.text = [NSString stringWithFormat:@"%@ · ", model.symbol];
        self.titleLabel.text = NSLocalizedStringForKey(@"卖出");
    }
    self.titleLabel.textColor = [model.buySell isEqualToString:@"buy"] ? QuotationGreenColor : QuotationRedColor;
    self.lotLabel.text = model.amount;
    self.priceLabel.text = model.price;
    self.totalLabel.text = model.sum;
    self.marginLabel.text = [VeDateUtil formatterDate:model.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    
    
    /// 1历史 0 委托
    if (model.type == 1) {
        [self.statusBtn setTitle:[NSString stringWithFormat:@"%@%@ %@", NSLocalizedStringForKey(@"手续费"), model.fee, NSLocalizedStringForKey(@"已成交")] forState:0];
        [self.statusBtn setTitleColor:UIColorMakeWithHex(@"#828282") forState:0];
        /// 关闭订单状态 filled--历史记录下已成交的订单 canceled --- 历史记录下已撤销的订单
        self.statusBtn.userInteractionEnabled = NO;
    }else{
        self.statusBtn.userInteractionEnabled = YES;
        [self.statusBtn setTitle:NSLocalizedStringForKey(@"撤销") forState:0];
        [self.statusBtn setTitleColor:UIColorMakeWithHex(@"#366091") forState:0];
    }
}

- (void)statusBtnAction{
    if (self.statusBtnActionBlock) {
        self.statusBtnActionBlock();
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontMake(15);
        _nameLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _nameLabel;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(14);
        _titleLabel.textColor = UIColorMakeWithHex(@"#828282");
    }
    return _titleLabel;
}

- (UILabel *)lotLabel{
    if (!_lotLabel) {
        _lotLabel = [[UILabel alloc] init];
        _lotLabel.textColor = UIColorMakeWithHex(@"#333333");
        _lotLabel.font = UIFontMake(16);
    }
    return _lotLabel;
}

- (UILabel *)lotTitleLabel{
    if (!_lotTitleLabel) {
        _lotTitleLabel = [[UILabel alloc] init];
        _lotTitleLabel.textColor = UIColorMakeWithHex(@"#828282");
        _lotTitleLabel.font = UIFontMake(15);
        _lotTitleLabel.text = NSLocalizedStringForKey(@"数量");
    }
    return _lotTitleLabel;
}

- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = UIColorMakeWithHex(@"#333333");
        _priceLabel.font = UIFontMake(16);
        _priceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _priceLabel;
}

- (UILabel *)priceTitleLabel{
    if (!_priceTitleLabel) {
        _priceTitleLabel = [[UILabel alloc] init];
        _priceTitleLabel.textColor = UIColorMakeWithHex(@"#828282");
        _priceTitleLabel.font = UIFontMake(15);
        _priceTitleLabel.textAlignment = NSTextAlignmentCenter;
        _priceTitleLabel.text = NSLocalizedStringForKey(@"价格");
    }
    return _priceTitleLabel;
}

- (UILabel *)totalLabel{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textColor = UIColorMakeWithHex(@"#333333");
        _totalLabel.font = UIFontMake(16);
        _totalLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalLabel;
}

- (UILabel *)totalTitleLabel{
    if (!_totalTitleLabel) {
        _totalTitleLabel = [[UILabel alloc] init];
        _totalTitleLabel.textColor = UIColorMakeWithHex(@"#828282");
        _totalTitleLabel.font = UIFontMake(15);
        _totalTitleLabel.textAlignment = NSTextAlignmentCenter;
        _totalTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)",  NSLocalizedStringForKey(@"金额")];
    }
    return _totalTitleLabel;
}

- (UILabel *)marginLabel{
    if (!_marginLabel) {
        _marginLabel = [[UILabel alloc] init];
        _marginLabel.font = UIFontMake(16);
        _marginLabel.textAlignment = NSTextAlignmentCenter;
        _marginLabel.textColor = UIColorMakeWithHex(@"#333333");
        _marginLabel.numberOfLines = 0;
    }
    return _marginLabel;
}

- (UILabel *)marginTitleLabel{
    if (!_marginTitleLabel) {
        _marginTitleLabel = [[UILabel alloc] init];
        _marginTitleLabel.textColor = UIColorMakeWithHex(@"#A2A2A2");
        _marginTitleLabel.font = UIFontMake(15);
        _marginTitleLabel.textAlignment = NSTextAlignmentCenter;
        _marginTitleLabel.text = NSLocalizedStringForKey(@"时间");
    }
    return _marginTitleLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = UIFontMake(13);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = UIColorMakeWithHex(@"#828282");
    }
    return _timeLabel;
}

- (QMUIButton *)statusBtn{
    if (!_statusBtn) {
        _statusBtn = [[QMUIButton alloc] init];
        [_statusBtn setTitleColor:UIColorMakeWithHex(@"#366091") forState:0];
        [_statusBtn setImage:UIImageMake(@"mine_main_arrow") forState:0];
        _statusBtn.imagePosition = QMUIButtonImagePositionRight;
        _statusBtn.spacingBetweenImageAndTitle = 5;
        _statusBtn.titleLabel.font = UIFontMake(15);
        [_statusBtn addTarget:self action:@selector(statusBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusBtn;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#E6E6E6");
    }
    return _lineView;
}

@end
