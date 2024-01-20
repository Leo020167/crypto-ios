//
//  TYNewSubscribeCell.m
//  ProCoin
//
//  Created by Luo Chun on 2024/1/20.
//  Copyright © 2024 Toka. All rights reserved.
//

#import "TYNewSubscribeCell.h"
#import "VeDateUtil.h"

@interface TYNewSubscribeCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *countTitleLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *timeTitleLabel;

@property (nonatomic, strong) UILabel *timeLabel;


@property (nonatomic, strong) UILabel *luckyCountTitleLabel;

@property (nonatomic, strong) UILabel *luckyCountLabel;

@property (nonatomic, strong) UILabel *statusTitleLabel;

@property (nonatomic, strong) UILabel *statusLabel;


@property (nonatomic, strong) UILabel *paidAmountTitleLabel;

@property (nonatomic, strong) UILabel *paidAmountLabel;

@property (nonatomic, strong) UILabel *unpaidAmountTitleLabel;

@property (nonatomic, strong) UILabel *unpaidAmountLabel;


@property (nonatomic, strong) UILabel *subscribeTimeTitleLabel;

@property (nonatomic, strong) UILabel *subscribeTimeLabel;


@property (nonatomic, strong) UIView *lineView;

@end

@implementation TYNewSubscribeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.countTitleLabel];
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.timeTitleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.luckyCountTitleLabel];
    [self.contentView addSubview:self.luckyCountLabel];
    [self.contentView addSubview:self.statusTitleLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.paidAmountTitleLabel];
    [self.contentView addSubview:self.paidAmountLabel];
    [self.contentView addSubview:self.unpaidAmountTitleLabel];
    [self.contentView addSubview:self.unpaidAmountLabel];
    [self.contentView addSubview:self.subscribeTimeTitleLabel];
    [self.contentView addSubview:self.subscribeTimeLabel];
    
    [self.contentView addSubview:self.lineView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
    }];
    [self.countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.countTitleLabel.mas_bottom).offset(5);
    }];
    [self.timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.timeTitleLabel.mas_bottom).offset(5);
    }];
    [self.luckyCountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.countLabel.mas_bottom).offset(15);
    }];
    [self.luckyCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.luckyCountTitleLabel.mas_bottom).offset(5);
    }];
    [self.statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(15);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.statusTitleLabel.mas_bottom).offset(5);
    }];
    [self.paidAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.luckyCountLabel.mas_bottom).offset(15);
    }];
    [self.paidAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.paidAmountTitleLabel.mas_bottom).offset(5);
    }];
    [self.unpaidAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(15);
    }];
    [self.unpaidAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.unpaidAmountTitleLabel.mas_bottom).offset(5);
    }];
    
    [self.subscribeTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.paidAmountLabel.mas_bottom).offset(20);
    }];
    [self.subscribeTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.subscribeTimeTitleLabel.mas_bottom).offset(5);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}

- (void)setModel:(PCCoinSubscribeRecordModel *)model{
    self.titleLabel.text = [NSString stringWithFormat:@"%@(%@-%@)", NSLocalizedStringForKey(@"申购"), model.symbol, model.title];
    self.countLabel.text = model.count;
    self.timeLabel.text = model.time;
    self.luckyCountLabel.text = model.luckyCount;
    self.statusLabel.text = model.stateDesc;
    self.paidAmountLabel.text = model.paidAmount;
    self.unpaidAmountLabel.text = model.unpaidAmount;
    
    NSString *createTime = [VeDateUtil formatterDate:model.time inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    NSString *tradeTime = [VeDateUtil formatterDate:model.tradeTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    self.timeLabel.text = createTime;
    self.subscribeTimeLabel.text = tradeTime;
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(18);
        _titleLabel.textColor = UIColorMakeWithHex(@"#2B4166");
        _titleLabel.text = @"--";
    }
    return _titleLabel;
}

- (UILabel *)countTitleLabel{
    if (!_countTitleLabel) {
        _countTitleLabel = [[UILabel alloc] init];
        _countTitleLabel.font = UIFontMake(14);
        _countTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _countTitleLabel.text = NSLocalizedStringForKey(@"申购数量");
    }
    return _countTitleLabel;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.numberOfLines = 2;
    }
    return _countLabel;
}

- (UILabel *)timeTitleLabel{
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] init];
        _timeTitleLabel.font = UIFontMake(14);
        _timeTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _timeTitleLabel.text = NSLocalizedStringForKey(@"申购时间");
        _timeTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeTitleLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = UIFontMake(14);
        _timeLabel.textColor = UIColorMakeWithHex(@"2B4166");
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UILabel *)luckyCountTitleLabel{
    if (!_luckyCountTitleLabel) {
        _luckyCountTitleLabel = [[UILabel alloc] init];
        _luckyCountTitleLabel.font = UIFontMake(14);
        _luckyCountTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _luckyCountTitleLabel.text = NSLocalizedStringForKey(@"中签数量");
        _luckyCountTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _luckyCountTitleLabel;
}

- (UILabel *)luckyCountLabel{
    if (!_luckyCountLabel) {
        _luckyCountLabel = [[UILabel alloc] init];
        _luckyCountLabel.font = UIFontMake(14);
        _luckyCountLabel.textColor = UIColorMakeWithHex(@"2B4166");
        _luckyCountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _luckyCountLabel;
}



- (UILabel *)statusTitleLabel{
    if (!_statusTitleLabel) {
        _statusTitleLabel = [[UILabel alloc] init];
        _statusTitleLabel.font = UIFontMake(14);
        _statusTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _statusTitleLabel.text = NSLocalizedStringForKey(@"状态");
        _statusTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _statusTitleLabel;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = UIFontMake(14);
        _statusLabel.textColor = UIColorMakeWithHex(@"2B4166");
        _statusLabel.textAlignment = NSTextAlignmentRight;
    }
    return _statusLabel;
}

- (UILabel *)paidAmountTitleLabel{
    if (!_paidAmountTitleLabel) {
        _paidAmountTitleLabel = [[UILabel alloc] init];
        _paidAmountTitleLabel.font = UIFontMake(14);
        _paidAmountTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _paidAmountTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"已缴款")];
        _paidAmountTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _paidAmountTitleLabel;
}

- (UILabel *)paidAmountLabel{
    if (!_paidAmountLabel) {
        _paidAmountLabel = [[UILabel alloc] init];
        _paidAmountLabel.font = UIFontMake(14);
        _paidAmountLabel.textColor = UIColorMakeWithHex(@"2B4166");
        _paidAmountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _paidAmountLabel;
}

- (UILabel *)unpaidAmountTitleLabel{
    if (!_unpaidAmountTitleLabel) {
        _unpaidAmountTitleLabel = [[UILabel alloc] init];
        _unpaidAmountTitleLabel.font = UIFontMake(14);
        _unpaidAmountTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _unpaidAmountTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)",NSLocalizedStringForKey(@"未缴款")];
        _unpaidAmountTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _unpaidAmountTitleLabel;
}

- (UILabel *)unpaidAmountLabel{
    if (!_unpaidAmountLabel) {
        _unpaidAmountLabel = [[UILabel alloc] init];
        _unpaidAmountLabel.font = UIFontMake(14);
        _unpaidAmountLabel.textColor = UIColorMakeWithHex(@"2B4166");
        _unpaidAmountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _unpaidAmountLabel;
}

- (UILabel *)subscribeTimeTitleLabel{
    if (!_subscribeTimeTitleLabel) {
        _subscribeTimeTitleLabel = [[UILabel alloc] init];
        _subscribeTimeTitleLabel.font = UIFontMake(14);
        _subscribeTimeTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _subscribeTimeTitleLabel.text = NSLocalizedStringForKey(@"上市交易时间");
    }
    return _subscribeTimeTitleLabel;
}

- (UILabel *)subscribeTimeLabel{
    if (!_subscribeTimeLabel) {
        _subscribeTimeLabel = [[UILabel alloc] init];
        _subscribeTimeLabel.font = UIFontMake(14);
        _subscribeTimeLabel.textColor = UIColorMakeWithHex(@"2B4166");
    }
    return _subscribeTimeLabel;
}



- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#E6E6E6");
    }
    return _lineView;
}

@end
