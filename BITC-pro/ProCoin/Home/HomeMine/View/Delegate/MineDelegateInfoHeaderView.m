//
//  MineDelegateInfoHeaderView.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/28.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "MineDelegateInfoHeaderView.h"

@interface MineDelegateInfoHeaderView ()

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIButton *detailBtn;

@property (nonatomic, strong) UILabel *codeLabel;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *levelLabel;

@property (nonatomic, strong) UIButton *upgradeBtn;

@end

@implementation MineDelegateInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.moneyLabel];
    [self.bgImageView addSubview:self.descLabel];
    [self.bgImageView addSubview:self.codeLabel];
    [self.bgImageView addSubview:self.detailBtn];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.levelLabel];
    [self.bgView addSubview:self.upgradeBtn];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 20, 0));
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgImageView);
        make.top.mas_equalTo(40);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.moneyLabel);
        make.top.mas_equalTo(self.moneyLabel.mas_bottom).offset(5);
    }];
    [self.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.moneyLabel);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(5);
    }];
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(30);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.bgView);
    }];
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.bgView);
    }];
    [self.upgradeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.levelLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(70, 20));
    }];
}

- (void)setModel:(MineDelegateInfoModel *)model{
    self.moneyLabel.text = model.sumCommission;
    self.codeLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"我的邀请码"), model.inviteCode];
    self.levelLabel.text = model.levelName;
    self.upgradeBtn.hidden = !model.upgradeFlag;
}

- (void)upgradeBtnAction{
    if (self.upgradeBtnActionBlock) {
        self.upgradeBtnActionBlock();
    }
}

- (void)detailBtnAction{
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.isNavHidden = YES;
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&token=%@",CommissionWebUrl, ROOTCONTROLLER_USER.userId, ROOTCONTROLLER_USER.token];
    web.url = urlStr;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

#pragma mark =========================== 懒加载 ===========================
- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = UIColorMakeWithHex(@"#2053FD");
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.textColor = UIColor.whiteColor;
        _moneyLabel.font = UIFontBoldMake(20);
    }
    return _moneyLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = UIColor.whiteColor;
        _descLabel.font = UIFontMake(15);
        _descLabel.text = [NSString stringWithFormat:@"%@（USDT）", NSLocalizedStringForKey(@"全部佣金")];
    }
    return _descLabel;
}

- (UILabel *)codeLabel{
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] init];
        _codeLabel.textColor = UIColor.whiteColor;
        _codeLabel.font = UIFontMake(15);
    }
    return _codeLabel;
}

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorWhite;
        _bgView.layer.cornerRadius = 20;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorMakeWithHex(@"#2970FE");
        _titleLabel.font = UIFontMake(15);
        _titleLabel.text = NSLocalizedStringForKey(@"代理等级：");
    }
    return _titleLabel;
}

- (UILabel *)levelLabel{
    if (!_levelLabel) {
        _levelLabel = [[UILabel alloc] init];
        _levelLabel.textColor = UIColorMakeWithHex(@"#2970FE");
        _levelLabel.font = UIFontBoldMake(15);
        _levelLabel.text = @"LV5";
    }
    return _levelLabel;
}

- (UIButton *)upgradeBtn{
    if (!_upgradeBtn) {
        _upgradeBtn = [[UIButton alloc] init];
        [_upgradeBtn setTitle:NSLocalizedStringForKey(@"立即升级") forState:0];
        [_upgradeBtn setTitleColor:UIColor.whiteColor forState:0];
        _upgradeBtn.titleLabel.font = UIFontMake(12);
        _upgradeBtn.layer.cornerRadius = 5;
        _upgradeBtn.layer.masksToBounds = YES;
        _upgradeBtn.backgroundColor = UIColorMakeWithHex(@"#F27927");
        [_upgradeBtn addTarget:self action:@selector(upgradeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _upgradeBtn;
}

- (UIButton *)detailBtn{
    if (!_detailBtn) {
        _detailBtn = [[UIButton alloc] init];
        [_detailBtn setTitle:NSLocalizedStringForKey(@"明细>>") forState:0];
        [_detailBtn setTitleColor:UIColor.whiteColor forState:0];
        _detailBtn.titleLabel.font = UIFontMake(15);
        [_detailBtn addTarget:self action:@selector(detailBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailBtn;
}


@end
