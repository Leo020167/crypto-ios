//
//  HomeNewPurchaseCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/23.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeNewPurchaseCell.h"
#import "VeDateUtil.h"

@interface HomeNewPurchaseCell ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UILabel *progressLabel;

/// 申购总量
@property (nonatomic, strong) UILabel *totalLabel;

/// 可申购总量
@property (nonatomic, strong) UILabel *canLabel;

@property (nonatomic, strong) UILabel *startTimeLabel;

@property (nonatomic, strong) UILabel *endTimeLabel;

@end

@implementation HomeNewPurchaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorMakeWithHex(@"#FAFAFA");
    [self.contentView addSubview:self.logoImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.progressLabel];
    [self.contentView addSubview:self.totalLabel];
    [self.contentView addSubview:self.canLabel];
    [self.contentView addSubview:self.startTimeLabel];
    [self.contentView addSubview:self.endTimeLabel];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(68);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-70);
        make.top.mas_equalTo(self.logoImageView.mas_top).offset(5);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(15);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-22);
        make.centerY.mas_equalTo(self.nameLabel);
        make.size.mas_equalTo(CGSizeMake(38, 18));
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(85);
        make.right.mas_equalTo(-60);
        make.height.mas_equalTo(6);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(20);
    }];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.progressView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.progressView);
    }];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.progressView);
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(18);
    }];
    [self.canLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.progressView);
        make.top.mas_equalTo(self.totalLabel.mas_bottom).offset(10);
    }];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.progressView);
        make.top.mas_equalTo(self.canLabel.mas_bottom).offset(10);
    }];
    [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.progressView);
        make.bottom.mas_equalTo(-20);
        make.top.mas_equalTo(self.startTimeLabel.mas_bottom).offset(10);
    }];
}

- (void)setModel:(HomeNewPurchaseListModel *)model{
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:UIImageMake(@"uitl_hightlight_gray_light")];
    self.nameLabel.text = model.summary;
    /// 状态：0 待开始，1 申购中，2 已结束
    if (model.state == 0) {
        self.statusLabel.text = NSLocalizedStringForKey(@"待开始");
    }else if (model.state == 1) {
        self.statusLabel.text = NSLocalizedStringForKey(@"进行中");
    }else if (model.state == 2) {
        self.statusLabel.text = NSLocalizedStringForKey(@"已结束");
    }
    self.progressView.progress = model.progress ? model.progress.floatValue / 100.0: 0;
    self.progressLabel.text = [NSString stringWithFormat:@"%@%%", model.progress ];
//    if (model.alAmount.floatValue >= model.amount.floatValue) {
//        self.progressView.progress = 1;
//        self.progressLabel.text = @"100%";
//    }else{
//        self.progressView.progress = model.alAmount.floatValue / model.amount.floatValue;
//        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%@", (model.alAmount.floatValue / model.amount.floatValue) * 100, @"%"];
//    }
//    self.canLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedStringForKey(@"本轮可申购总量"), model.amount];
    self.canLabel.text = [NSString stringWithFormat:@"%@:%@ USDT", NSLocalizedStringForKey(@"价格"), model.rate];
    self.totalLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedStringForKey(@"申购总量"),  model.sumAmount];
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"开始时间"), [VeDateUtil formatterDate:model.startTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES]];
    self.endTimeLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"结束时间"), [VeDateUtil formatterDate:model.endTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES]];
}

- (void)lessSecondToDay:(NSInteger)seconds{
    NSUInteger day = (NSUInteger)(seconds / 3600 / 24);
    NSUInteger hour = (NSUInteger)(seconds%(24*3600))/3600;
    NSUInteger min  = (NSUInteger)(seconds%(3600))/60;
    NSUInteger second = (NSUInteger)(seconds%60);
    NSString *title = @"";
    if (seconds <= 0) {
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
    }
    if (self.model.state == 0) {
        if (day > 0) {
            title = [NSString stringWithFormat:@"距開始： %lu天%02lu:%02lu:%02lu", (unsigned long)day, (unsigned long)hour, (unsigned long)min, (unsigned long)second];
        }else{
            title = [NSString stringWithFormat:@"距開始： %02lu:%02lu:%02lu", (unsigned long)hour, (unsigned long)min, (unsigned long)second];
        }
        
    }else if (self.model.state == 1){
        if (day > 0) {
            title = [NSString stringWithFormat:@"距結束： %lu天%02lu:%02lu:%02lu", (unsigned long)day, (unsigned long)hour, (unsigned long)min, (unsigned long)second];
        }else{
            title = [NSString stringWithFormat:@"距結束： %02lu:%02lu:%02lu", (unsigned long)hour, (unsigned long)min, (unsigned long)second];
        }
    }
//    self.timeLabel.text = title;
}

#pragma mark =========================== 懒加载 ===========================
- (UIImageView *)logoImageView{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
    }
    return _logoImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontMake(13);
        _nameLabel.textColor = UIColorMakeWithHex(@"#333333");
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = UIFontMake(10);
        _statusLabel.textColor = UIColor.whiteColor;
        _statusLabel.backgroundColor = UIColorMakeWithHex(@"#5FCE64");
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.layer.cornerRadius = 3;
        _statusLabel.layer.masksToBounds = YES;
    }
    return _statusLabel;
}

- (UILabel *)totalLabel{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.font = UIFontMake(12);
        _totalLabel.textColor = UIColorMakeWithHex(@"#666666");
    }
    return _totalLabel;
}

- (UILabel *)canLabel{
    if (!_canLabel) {
        _canLabel = [[UILabel alloc] init];
        _canLabel.font = UIFontMake(12);
        _canLabel.textColor = UIColorMakeWithHex(@"#666666");
    }
    return _canLabel;
}

- (UILabel *)startTimeLabel{
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] init];
        _startTimeLabel.font = UIFontMake(12);
        _startTimeLabel.textColor = UIColorMakeWithHex(@"#666666");
    }
    return _startTimeLabel;
}

- (UILabel *)endTimeLabel{
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.font = UIFontMake(12);
        _endTimeLabel.textColor = UIColorMakeWithHex(@"#666666");
    }
    return _endTimeLabel;
}

- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = UIFontMake(11);
        _progressLabel.textColor = UIColorMakeWithHex(@"#999999");
    }
    return _progressLabel;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = UIColorMakeWithHex(@"#ECECEC");
        _progressView.progressTintColor = UIColorMakeWithHex(@"#5FCE64");
        _progressView.layer.cornerRadius = 3;
        _progressView.layer.masksToBounds = YES;
    }
    return _progressView;
}

@end
