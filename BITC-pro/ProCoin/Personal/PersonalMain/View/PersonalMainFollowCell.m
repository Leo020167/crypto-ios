//
//  PersonalMainFollowCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "PersonalMainFollowCell.h"
#import "VeDateUtil.h"

@interface PersonalMainFollowCell ()

/// 余额
@property (nonatomic, strong) UILabel *balanceLabel;

/// 盈利分成
@property (nonatomic, strong) UILabel *profitLabel;

/// 最高倍数
@property (nonatomic, strong) UILabel *maxLabel;

/// 消耗LCN
@property (nonatomic, strong) UILabel *expendLabel;

/// 时间
@property (nonatomic, strong) UILabel *timeLabel;

/// 亏损补贴
@property (nonatomic, strong) UILabel *lossLabel;

/// 到期时间
@property (nonatomic, strong) UILabel *expireLabel;

@end

@implementation PersonalMainFollowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:self.titleBtn];
    [self.contentView addSubview:self.profitLabel];
    [self.contentView addSubview:self.lossLabel];
    [self.contentView addSubview:self.balanceLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.maxLabel];
    [self.contentView addSubview:self.expendLabel];
    [self.contentView addSubview:self.expireLabel];
    [self.titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
    }];
    [self.profitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.titleBtn.mas_bottom).offset(15);
    }];
    [self.maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.profitLabel);
        make.top.mas_equalTo(self.profitLabel.mas_bottom).offset(15);
    }];
    [self.lossLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.titleBtn.mas_bottom).offset(15);
    }];
    [self.expendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lossLabel);
        make.top.mas_equalTo(self.lossLabel.mas_bottom).offset(15);
    }];
    [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.maxLabel.mas_bottom).offset(15);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.maxLabel.mas_bottom).offset(15);
        make.bottom.mas_equalTo(-25);
    }];
    [self.expireLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.maxLabel.mas_bottom).offset(15);
        make.width.mas_equalTo((SCREEN_WIDTH - 50) / 3.0);
    }];
}

- (void)setModel:(PersonalMainFollowModel *)model{
    [self.titleBtn setTitle:[NSString stringWithFormat:@"  %@%@", NSLocalizedStringForKey(@"跟单类型"), @(model.row + 1)] forState:0];
    self.profitLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringForKey(@"盈利分成"), model.profitRate, @"%"];
    self.lossLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringForKey(@"亏损补贴"), model.lossRate, @"%"];
    self.maxLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedStringForKey(@"最高倍数"), [NSString stringWithFormat:@"%ld", (long)model.maxMultiNum]];
    self.expendLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedStringForKey(@"消耗LCN"), model.tokenAmount];
    
    NSString *title = NSLocalizedStringForKey(@"最低金额");
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@USDT", title,  model.limit]];
    [text yy_setFont:UIFontMake(10) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontBoldMake(15) range:NSMakeRange(title.length + 1, model.limit.length)];
    [text yy_setFont:UIFontMake(12) range:NSMakeRange(0, title.length)];
    [text yy_setColor:UIColorMakeWithHex(@"#666666") range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"#333333") range:NSMakeRange(title.length + 1, model.limit.length)];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:NSMakeRange(0, title.length)];
    [text yy_setAlignment:NSTextAlignmentLeft range:text.yy_rangeOfAll];
    [text yy_setLineSpacing:5 range:text.yy_rangeOfAll];
    self.balanceLabel.attributedText = text;
    self.timeLabel.attributedText = [self textWithMoney:[NSString stringWithFormat:@"%@%@", model.duration, NSLocalizedStringForKey(@"天")] title:NSLocalizedStringForKey(@"时间") tag:3];
    NSString *confromTimespStr = [VeDateUtil formatterDate:model.expireTime inStytle:@"" outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    self.expireLabel.attributedText = [self textWithMoney:confromTimespStr title:NSLocalizedStringForKey(@"到期时间") tag:2];
    self.expireLabel.hidden = model.isBind != 1;
}

- (NSMutableAttributedString *)textWithMoney:(NSString *)count title:(NSString *)title tag:(NSInteger)tag{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", title, count]];
    [text yy_setFont:UIFontBoldMake(15) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(12) range:NSMakeRange(0, title.length)];
    [text yy_setColor:UIColor.blackColor range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:NSMakeRange(0, title.length)];
    if (tag == 2) {
        [text yy_setAlignment:NSTextAlignmentCenter range:text.yy_rangeOfAll];
        [text yy_setLineSpacing:2 range:text.yy_rangeOfAll];
    }else{
        [text yy_setAlignment:NSTextAlignmentRight range:text.yy_rangeOfAll];
        [text yy_setLineSpacing:5 range:text.yy_rangeOfAll];
    }
    return text;
}

#pragma mark =========================== 懒加载 ===========================
- (UIButton *)titleBtn{
    if (!_titleBtn) {
        _titleBtn = [[UIButton alloc] init];
        [_titleBtn setTitleColor:UIColor.blackColor forState:0];
        [_titleBtn setImage:UIImageMake(@"common_circle_normal") forState:UIControlStateNormal];
        [_titleBtn setImage:UIImageMake(@"common_circle_selected") forState:UIControlStateSelected];
        _titleBtn.titleLabel.font = UIFontMake(15);
    }
    return _titleBtn;
}

- (UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.numberOfLines = 2;
    }
    return _balanceLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.numberOfLines = 2;
    }
    return _timeLabel;
}

- (UILabel *)expireLabel{
    if (!_expireLabel) {
        _expireLabel = [[UILabel alloc] init];
        _expireLabel.numberOfLines = 0;
    }
    return _expireLabel;
}

- (UILabel *)profitLabel{
    if (!_profitLabel) {
        _profitLabel = [[UILabel alloc] init];
        _profitLabel.numberOfLines = 2;
        _profitLabel.textColor = UIColorMakeWithHex(@"#999999");
        _profitLabel.font = UIFontMake(13);
    }
    return _profitLabel;
}

- (UILabel *)maxLabel{
    if (!_maxLabel) {
        _maxLabel = [[UILabel alloc] init];
        _maxLabel.numberOfLines = 2;
        _maxLabel.textColor = UIColorMakeWithHex(@"#999999");
        _maxLabel.font = UIFontMake(13);
    }
    return _maxLabel;
}

- (UILabel *)lossLabel{
    if (!_lossLabel) {
        _lossLabel = [[UILabel alloc] init];
        _lossLabel.numberOfLines = 2;
        _lossLabel.textColor = UIColorMakeWithHex(@"#999999");
        _lossLabel.font = UIFontMake(13);
    }
    return _lossLabel;
}

- (UILabel *)expendLabel{
    if (!_expendLabel) {
        _expendLabel = [[UILabel alloc] init];
        _expendLabel.numberOfLines = 2;
        _expendLabel.textColor = UIColorMakeWithHex(@"#999999");
        _expendLabel.font = UIFontMake(13);
    }
    return _expendLabel;
}

@end
