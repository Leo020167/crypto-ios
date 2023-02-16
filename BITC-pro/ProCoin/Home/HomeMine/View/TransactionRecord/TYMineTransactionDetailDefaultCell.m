//
//  TYMineTransactionDetailDefaultCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/4/8.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineTransactionDetailDefaultCell.h"

@interface TYMineTransactionDetailDefaultCell ()

@end

@implementation TYMineTransactionDetailDefaultCell

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
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.settingBtn];
    [self.contentView addSubview:self.descBtn];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.centerY.mas_equalTo(self);
    }];
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(60, 23));
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(self);
    }];
    [self.descBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)settingBtnAction{
    if (self.settingBtnActionBlock) {
        self.settingBtnActionBlock();
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(15);
        _titleLabel.textColor = UIColorMakeWithHex(@"#575757");
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = UIFontMake(14);
    }
    return _descLabel;
}

- (UIButton *)settingBtn{
    if (!_settingBtn) {
        _settingBtn = [[UIButton alloc] init];
        [_settingBtn setTitle:NSLocalizedStringForKey(@"设置") forState:0];
        [_settingBtn setTitleColor:UIColorMakeWithHex(@"#757575") forState:0];
        _settingBtn.titleLabel.font = UIFontMake(13);
        _settingBtn.layer.cornerRadius = 2;
        _settingBtn.layer.masksToBounds = YES;
        _settingBtn.layer.borderColor = UIColorMakeWithHex(@"#757575").CGColor;
        _settingBtn.layer.borderWidth = 1;
        _settingBtn.hidden = YES;
        [_settingBtn addTarget:self action:@selector(settingBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

- (QMUIButton *)descBtn{
    if (!_descBtn) {
        _descBtn = [[QMUIButton alloc] init];
        [_descBtn setTitleColor:UIColorMakeWithHex(@"#000000") forState:0];
        _descBtn.titleLabel.font = UIFontMake(15);
        _descBtn.imagePosition = QMUIButtonImagePositionRight;
        _descBtn.spacingBetweenImageAndTitle = 10;
        _descBtn.userInteractionEnabled = NO;
    }
    return _descBtn;
}

- (UIImageView *)imgImageView{
    if (!_imgImageView) {
        _imgImageView = [[UIImageView alloc] init];
    }
    return _imgImageView;
}

@end
