//
//  HomeBigVRankingCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeBigVRankingCell.h"

@interface HomeBigVRankingCell ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation HomeBigVRankingCell

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
    [self.contentView addSubview:self.dayLabel];
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addSubview:self.centerLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.lineView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(15);
        make.size.mas_equalTo(44);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
        make.top.mas_equalTo(self.iconImageView.mas_top).offset(5);
    }];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
        make.bottom.mas_equalTo(self.iconImageView.mas_bottom).offset(-5);
    }];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(15);
        make.bottom.mas_equalTo(-10);
        make.width.mas_equalTo(SCREEN_WIDTH / 3.0);
    }];
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(SCREEN_WIDTH / 3.0);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(15);
        make.bottom.mas_equalTo(-10);
        make.width.mas_equalTo(SCREEN_WIDTH / 3.0);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(15);
        make.bottom.mas_equalTo(-10);
        make.width.mas_equalTo(SCREEN_WIDTH / 3.0);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
}

- (void)setModel:(InfluencerRankEntity *)model{
    self.nameLabel.text = model.userName;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.headUrl]];
    self.dayLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"已入驻%@天"),model.days];
    self.leftLabel.attributedText = [self textWithMoney:model.correctRate title:NSLocalizedStringForKey(@"准确率")];
    self.centerLabel.attributedText = [self textWithMoney:model.totalProfit title:[NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"总收益")]];
    self.rightLabel.attributedText = [self textWithMoney:model.monthProfit title:[NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"上月收益")]];
}

- (NSMutableAttributedString *)textWithMoney:(NSString *)count title:(NSString *)title{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", title, count]];
    [text yy_setFont:UIFontBoldMake(15) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(12) range:NSMakeRange(0, title.length)];
    [text yy_setColor:UIColor.blackColor range:text.yy_rangeOfAll];
    [text yy_setColor:UIColorMakeWithHex(@"#999999") range:NSMakeRange(0, title.length)];
    [text yy_setAlignment:NSTextAlignmentCenter range:text.yy_rangeOfAll];
    [text yy_setLineSpacing:5 range:text.yy_rangeOfAll];
    return text;
}

#pragma mark =========================== 懒加载 ===========================
- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = 22;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.image = UIImageMake(@"util_Image_bg_no_head");
    }
    return _iconImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColor.blackColor;
        _nameLabel.font = UIFontBoldMake(15);
    }
    return _nameLabel;
}

- (UILabel *)dayLabel{
    if (!_dayLabel) {
        _dayLabel = [[UILabel alloc] init];
        _dayLabel.textColor = UIColor.blackColor;
        _dayLabel.font = UIFontBoldMake(15);
    }
    return _dayLabel;
}

- (UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.numberOfLines = 2;
    }
    return _leftLabel;
}

- (UILabel *)centerLabel{
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.numberOfLines = 2;
    }
    return _centerLabel;
}

- (UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.numberOfLines = 2;
    }
    return _rightLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
    }
    return _lineView;
}

@end
