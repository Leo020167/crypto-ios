//
//  TYMineCommunityHeaderView.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/1.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineCommunityHeaderView.h"
#import "NSString+Align.h"

@interface TYMineCommunityHeaderView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

/// 社区人数
@property (nonatomic, strong) UILabel *peopleCountLabel;

/// 邀请码数量
@property (nonatomic, strong) UILabel *inviteCountLabel;

/// 总收入标题
@property (nonatomic, strong) UILabel *incomeTitleLabel;

/// 总收入金额
@property (nonatomic, strong) UILabel *incomeLabel;

/// 佣金收入标题
@property (nonatomic, strong) UIView *titleView;

/// 邀请码
@property (nonatomic, strong) UILabel *inviteLabel;

/// 状态
@property (nonatomic, strong) UILabel *statusLabel;

/// 下级
@property (nonatomic, strong) UILabel *idLabel;

/// 返佣
@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation TYMineCommunityHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.iconImageView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.peopleCountLabel];
    [self.bgView addSubview:self.inviteCountLabel];
    [self.bgView addSubview:self.incomeTitleLabel];
    [self.bgView addSubview:self.incomeLabel];
    [self.bgView addSubview:self.titleView];
    [self.titleView addSubview:self.inviteLabel];
    [self.titleView addSubview:self.statusLabel];
    [self.titleView addSubview:self.idLabel];
    [self.titleView addSubview:self.moneyLabel];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(235);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24);
        make.top.mas_equalTo(14);
        make.size.mas_equalTo(38);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
        make.top.mas_equalTo(self.iconImageView.mas_top).offset(3);
    }];
    [self.peopleCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
    }];
    [self.inviteCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.peopleCountLabel.mas_right).offset(34);
        make.centerY.mas_equalTo(self.peopleCountLabel);
    }];
    [self.incomeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(30);
        make.left.mas_equalTo(self.iconImageView);
    }];
    [self.incomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.incomeTitleLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(self.iconImageView);
    }];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(64);
    }];
    CGFloat width = (SCREEN_WIDTH - 30) / 4.0;
    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(34);
        make.bottom.mas_equalTo(0);
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(34);
        make.bottom.mas_equalTo(0);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15 + width);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(34);
        make.bottom.mas_equalTo(0);
    }];
    [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- 15 - width);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(34);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)setModel:(TYMineCommunityModel *)model{
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:ROOTCONTROLLER_USER.headurl] placeholderImage:UIImageMake(@"home_main_icon")];
    self.nameLabel.text = ROOTCONTROLLER_USER.name;
    self.peopleCountLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"社区人数：%@"), model.teamCount];
    self.inviteCountLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"邀请码数量：%@"), model.inviteCount];
    self.incomeLabel.text = model.sumAmount;
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorMakeWithHex(@"#4D4CE6");
    }
    return _bgView;
}

- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:UIImageMake(@"home_main_icon")];
        _iconImageView.layer.cornerRadius = 19;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontBoldMake(15);
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.text = @"name";
    }
    return _nameLabel;
}

- (UILabel *)peopleCountLabel{
    if (!_peopleCountLabel) {
        _peopleCountLabel = [[UILabel alloc] init];
        _peopleCountLabel.font = UIFontMake(11);
        _peopleCountLabel.textColor = UIColorMakeWithHex(@"#EEF4FF");
    }
    return _peopleCountLabel;
}

- (UILabel *)inviteCountLabel{
    if (!_inviteCountLabel) {
        _inviteCountLabel = [[UILabel alloc] init];
        _inviteCountLabel.font = UIFontMake(11);
        _inviteCountLabel.textColor = UIColorMakeWithHex(@"#EEF4FF");
    }
    return _inviteCountLabel;
}

- (UILabel *)incomeTitleLabel{
    if (!_incomeTitleLabel) {
        _incomeTitleLabel = [[UILabel alloc] init];
        _incomeTitleLabel.font = UIFontMake(12);
        _incomeTitleLabel.textColor = UIColorMakeWithHex(@"#EEF4FF");
        _incomeTitleLabel.text = NSLocalizedStringForKey(@"社区总奖励(ECloud)");
    }
    return _incomeTitleLabel;
}

- (UILabel *)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc] init];
        _incomeLabel.font = UIFontBoldMake(30);
        _incomeLabel.textColor = UIColor.whiteColor;
        _incomeLabel.text = @"10000.00";
    }
    return _incomeLabel;
}

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = UIColor.whiteColor;
        _titleView.layer.cornerRadius = 25;
        _titleView.layer.masksToBounds = YES;
        _titleView.layer.maskedCorners = QMUILayerMinXMinYCorner | QMUILayerMaxXMinYCorner;
    }
    return _titleView;
}

- (UILabel *)inviteLabel{
    if (!_inviteLabel) {
        _inviteLabel = [[UILabel alloc] init];
        _inviteLabel.font = UIFontMake(14);
        _inviteLabel.textColor = UIColorMakeWithHex(@"#666666");
        _inviteLabel.text = NSLocalizedStringForKey(@"邀请码");
    }
    return _inviteLabel;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = UIFontMake(14);
        _statusLabel.textColor = UIColorMakeWithHex(@"#666666");
        _statusLabel.text = NSLocalizedStringForKey(@"状态");
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (UILabel *)idLabel{
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.font = UIFontMake(14);
        _idLabel.textColor = UIColorMakeWithHex(@"#666666");
        _idLabel.text = NSLocalizedStringForKey(@"成员");
        _idLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _idLabel;
}

- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = UIFontMake(14);
        _moneyLabel.textColor = UIColorMakeWithHex(@"#666666");
        _moneyLabel.text = NSLocalizedStringForKey(@"奖励(ECloud)");
        _moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLabel;
}

@end
