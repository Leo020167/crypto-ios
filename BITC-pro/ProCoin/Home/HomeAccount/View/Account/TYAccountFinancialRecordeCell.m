//
//  TYAccountFinancialRecordeCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/14.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountFinancialRecordeCell.h"
#import "VeDateUtil.h"

@interface TYAccountFinancialRecordeCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *countTitleLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *statusTitleLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UILabel *timeTitleLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation TYAccountFinancialRecordeCell

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
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.countTitleLabel];
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.statusTitleLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.timeTitleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.lineView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(15);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
    [self.countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo((SCREEN_WIDTH - 30) / 3.0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo((SCREEN_WIDTH - 30) / 3.0);
        make.top.mas_equalTo(self.countTitleLabel.mas_bottom).offset(5);
    }];
    [self.statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo((SCREEN_WIDTH - 30) / 3.0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo((SCREEN_WIDTH - 30) / 3.0);
        make.top.mas_equalTo(self.statusTitleLabel.mas_bottom).offset(5);
    }];
    [self.timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.timeTitleLabel.mas_bottom).offset(5);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}

- (void)setModel:(PCCoinOperationRecordModel *)model{
    if (model.remark.length) {
        self.titleLabel.text = model.remark;
    }else{
        NSString *title = @"";
        if (model.inOut == 1) {
            title = NSLocalizedStringForKey(@"充币");
        } else if (model.inOut == -1) {
            title = NSLocalizedStringForKey(@"提币");
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@", title];
    }
    self.countLabel.text = model.amount;
    self.statusLabel.text = model.stateDesc;
    NSString *createTime = [VeDateUtil formatterDate:model.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    self.timeLabel.text = createTime;
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(18);
        _titleLabel.textColor = UIColorMakeWithHex(@"#2B4166");
        _titleLabel.text = @"一号玩家";
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:UIImageMake(@"util_Icon_more_arrow_gray")];
    }
    return _arrowImageView;
}

- (UILabel *)countTitleLabel{
    if (!_countTitleLabel) {
        _countTitleLabel = [[UILabel alloc] init];
        _countTitleLabel.font = UIFontMake(14);
        _countTitleLabel.textColor = UIColorMakeWithHex(@"666666");
        _countTitleLabel.text = NSLocalizedStringForKey(@"数量");
        _countTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _countTitleLabel;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = UIFontMake(14);
        _countLabel.textColor = UIColorMakeWithHex(@"6775AB");
        _countLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _countLabel;
}

- (UILabel *)statusTitleLabel{
    if (!_statusTitleLabel) {
        _statusTitleLabel = [[UILabel alloc] init];
        _statusTitleLabel.font = UIFontMake(14);
        _statusTitleLabel.textColor = UIColorMakeWithHex(@"666666");
        _statusTitleLabel.text = NSLocalizedStringForKey(@"状态");
        _statusTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusTitleLabel;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = UIFontMake(14);
        _statusLabel.textColor = UIColorMakeWithHex(@"6775AB");
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (UILabel *)timeTitleLabel{
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] init];
        _timeTitleLabel.font = UIFontMake(14);
        _timeTitleLabel.textColor = UIColorMakeWithHex(@"666666");
        _timeTitleLabel.text = NSLocalizedStringForKey(@"时间");
        _timeTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeTitleLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = UIFontMake(14);
        _timeLabel.textColor = UIColorMakeWithHex(@"6775AB");
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#E6E6E6");
    }
    return _lineView;
}

@end
