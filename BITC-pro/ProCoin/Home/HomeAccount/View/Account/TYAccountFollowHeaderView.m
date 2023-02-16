//
//  TYAccountFollowHeaderView.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountFollowHeaderView.h"

@interface TYAccountFollowHeaderView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation TYAccountFollowHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.descLabel];
    [self.bgView addSubview:self.iconImageView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.bindBtn];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(60);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.bgView);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(3);
        make.centerY.mas_equalTo(self.bgView);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(3);
        make.centerY.mas_equalTo(self.bgView);
        make.size.mas_equalTo(30);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.bgView);
    }];
    [self.bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(55, 25));
        make.centerY.mas_equalTo(self.bgView);
    }];
}

- (void)setModel:(PCHomeUserFollowOrderInfoModel *)model{
    _model = model;
    if (model.dvUid.length) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.dvHeadUrl] placeholderImage:nil];
        self.nameLabel.text = model.dvUserName;
        self.bindBtn.selected = YES;
        self.descLabel.hidden = YES;
        self.iconImageView.hidden = NO;
        self.nameLabel.hidden = NO;
    }else{
        self.bindBtn.selected = NO;
        self.descLabel.hidden = NO;
        self.iconImageView.hidden = YES;
        self.nameLabel.hidden = YES;
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(16);
        _titleLabel.textColor = UIColorMakeWithHex(@"#282828");
        _titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringForKey(@"跟单机构")];
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = UIFontMake(15);
        _descLabel.textColor = UIColorMakeWithHex(@"#666666");
        _descLabel.text = NSLocalizedStringForKey(@"未绑定");
    }
    return _descLabel;
}

- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = 15;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.userInteractionEnabled = YES;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontMake(15);
        _nameLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _nameLabel;
}

- (UIButton *)bindBtn{
    if (!_bindBtn) {
        _bindBtn = [[UIButton alloc] init];
        [_bindBtn setTitle:NSLocalizedStringForKey(@"去绑定") forState:0];
        [_bindBtn setTitle:NSLocalizedStringForKey(@"查看") forState:UIControlStateSelected];
        [_bindBtn setTitleColor:UIColorMakeWithHex(@"#333333") forState:0];
        _bindBtn.titleLabel.font = UIFontMake(10);
        _bindBtn.backgroundColor = UIColor.whiteColor;
        _bindBtn.layer.cornerRadius = 5;
        _bindBtn.layer.masksToBounds = YES;
    }
    return _bindBtn;
}

@end
