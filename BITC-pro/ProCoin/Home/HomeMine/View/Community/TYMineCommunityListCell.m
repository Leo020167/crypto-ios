//
//  TYMineCommunityListCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/1.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineCommunityListCell.h"

@interface TYMineCommunityListCell ()

@property (nonatomic, strong) UILabel *inviteLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UILabel *idLabel;

@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation TYMineCommunityListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.inviteLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.idLabel];
    [self.contentView addSubview:self.moneyLabel];
    [self.contentView addSubview:self.lineView];
    CGFloat width = (SCREEN_WIDTH - 30) / 4.0;
    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(width);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15 + width);
        make.width.mas_equalTo(width);
        make.centerY.mas_equalTo(self);
    }];
    [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- 15 - width);
        make.width.mas_equalTo(width);
        make.centerY.mas_equalTo(self);
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(width);
        make.centerY.mas_equalTo(self);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)setModel:(TYMineCommunityListModel *)model{
    self.inviteLabel.text = model.inviteCode;
    self.statusLabel.text = model.status == 0 ? NSLocalizedStringForKey(@"未使用") : NSLocalizedStringForKey(@"已使用");
    if (model.status == 0) {
        self.idLabel.text = @"";
        self.moneyLabel.text = @"";
    }else{
        self.idLabel.text = model.inviteUserId;
        self.moneyLabel.text = model.amount;
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)inviteLabel{
    if (!_inviteLabel) {
        _inviteLabel = [[UILabel alloc] init];
        _inviteLabel.font = UIFontMake(12);
        _inviteLabel.textColor = UIColorMakeWithHex(@"#999999");
        _inviteLabel.text = @"12512";
    }
    return _inviteLabel;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = UIFontMake(12);
        _statusLabel.textColor = UIColorMakeWithHex(@"#999999");
        _statusLabel.text = @"已使用";
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (UILabel *)idLabel{
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.font = UIFontMake(12);
        _idLabel.textColor = UIColorMakeWithHex(@"#999999");
        _idLabel.text = @"已使用";
        _idLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _idLabel;
}


- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = UIFontMake(12);
        _moneyLabel.textColor = UIColorMakeWithHex(@"#999999");
        _moneyLabel.text = @"125";
        _moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
    }
    return _lineView;
}

@end
