//
//  TYAccountSubscribeCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/14.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountSubscribeCell.h"
#import "VeDateUtil.h"

@interface TYAccountSubscribeCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *countTitleLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *statusTitleLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UILabel *subscribeTimeTitleLabel;

@property (nonatomic, strong) UILabel *subscribeTimeLabel;

@property (nonatomic, strong) UILabel *relieveTimeTitleLabel;

@property (nonatomic, strong) UILabel *relieveTimeLabel;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation TYAccountSubscribeCell

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
    [self.contentView addSubview:self.statusTitleLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.subscribeTimeTitleLabel];
    [self.contentView addSubview:self.subscribeTimeLabel];
    [self.contentView addSubview:self.relieveTimeTitleLabel];
    [self.contentView addSubview:self.relieveTimeLabel];
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
    [self.statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.statusTitleLabel.mas_bottom).offset(5);
    }];
    [self.subscribeTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.countLabel.mas_bottom).offset(20);
    }];
    [self.subscribeTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.subscribeTimeTitleLabel.mas_bottom).offset(5);
    }];
    [self.relieveTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.countLabel.mas_bottom).offset(20);
    }];
    [self.relieveTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.relieveTimeTitleLabel.mas_bottom).offset(5);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}

- (void)setModel:(PCCoinOperationRecordModel *)model{
    self.subscribeTimeLabel.hidden = YES;
    self.subscribeTimeTitleLabel.hidden = YES;
    if (model.inOut == 2) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@-%@)", NSLocalizedStringForKey(@"申购冻结"), model.subSymbol, model.subTitle];
        self.subscribeTimeLabel.hidden = NO;
        self.subscribeTimeTitleLabel.hidden = NO;
    } else if (model.inOut == 3) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@-%@)", NSLocalizedStringForKey(@"申购成功转换"), model.subSymbol, model.subTitle];
    } else if (model.inOut == 4) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@-%@)", NSLocalizedStringForKey(@"申购失败转换"), model.subSymbol, model.subTitle];
    }
    self.countLabel.text = model.amount;
    self.statusLabel.text = model.stateDesc;
    NSString *createTime = [VeDateUtil formatterDate:model.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    NSString *transferTime = [VeDateUtil formatterDate:model.transferTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    self.subscribeTimeLabel.text = createTime;
    self.relieveTimeLabel.text = transferTime;
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

- (UILabel *)countTitleLabel{
    if (!_countTitleLabel) {
        _countTitleLabel = [[UILabel alloc] init];
        _countTitleLabel.font = UIFontMake(14);
        _countTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _countTitleLabel.text = NSLocalizedStringForKey(@"数量");
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

- (UILabel *)subscribeTimeTitleLabel{
    if (!_subscribeTimeTitleLabel) {
        _subscribeTimeTitleLabel = [[UILabel alloc] init];
        _subscribeTimeTitleLabel.font = UIFontMake(14);
        _subscribeTimeTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _subscribeTimeTitleLabel.text = NSLocalizedStringForKey(@"申购时间");
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

- (UILabel *)relieveTimeTitleLabel{
    if (!_relieveTimeTitleLabel) {
        _relieveTimeTitleLabel = [[UILabel alloc] init];
        _relieveTimeTitleLabel.font = UIFontMake(14);
        _relieveTimeTitleLabel.textColor = UIColorMakeWithHex(@"#666666");
        _relieveTimeTitleLabel.text = NSLocalizedStringForKey(@"解仓时间");
        _relieveTimeTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _relieveTimeTitleLabel;
}

- (UILabel *)relieveTimeLabel{
    if (!_relieveTimeLabel) {
        _relieveTimeLabel = [[UILabel alloc] init];
        _relieveTimeLabel.font = UIFontMake(14);
        _relieveTimeLabel.textColor = UIColorMakeWithHex(@"2B4166");
        _relieveTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _relieveTimeLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#E6E6E6");
    }
    return _lineView;
}

@end
