//
//  HomeNewPurchaseDetailContentCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/23.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeNewPurchaseDetailTopCell.h"

@interface HomeNewPurchaseDetailTopCell ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *nameLabel;

//@property (nonatomic, strong) UILabel *statusLabel;

//@property (nonatomic, strong) UILabel *descLabel;

/// 基本信息
@property (nonatomic, strong) UILabel *infoTitleLabel;

/// 进度
@property (nonatomic, strong) UILabel *progressLeftLabel;

@property (nonatomic, strong) UILabel *progressLabel;

/// 本次剩余申购量
@property (nonatomic, strong) UILabel *progressRightLabel;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UILabel *sumLabel;

//@property (nonatomic, strong) UIButton *buyBtn;

@end

@implementation HomeNewPurchaseDetailTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.logoImageView];
    [self.contentView addSubview:self.nameLabel];
//    [self.contentView addSubview:self.statusLabel];
//    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.infoTitleLabel];
    [self.contentView addSubview:self.progressLeftLabel];
    [self.contentView addSubview:self.progressRightLabel];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.progressLabel];
    [self.contentView addSubview:self.sumLabel];
//    [self.contentView addSubview:self.buyBtn];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(32);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(75);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20);
        make.top.mas_equalTo(self.logoImageView.mas_top).offset(7);
    }];
//    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.nameLabel.mas_right).offset(10);
//        make.centerY.mas_equalTo(self.nameLabel);
//        make.size.mas_equalTo(CGSizeMake(38, 18));
//    }];
//    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.nameLabel);
//        make.right.mas_equalTo(-40);
//        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(15);
//    }];
//    [self.buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(200, 40));
//        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(15);
//    }];
    [self.infoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(32);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(15);
    }];
    [self.progressLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(32);
        make.top.mas_equalTo(self.infoTitleLabel.mas_bottom).offset(23);
    }];
    [self.progressRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-33);
        make.centerY.mas_equalTo(self.progressLeftLabel);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(32);
        make.right.mas_equalTo(-33);
        make.top.mas_equalTo(self.progressLeftLabel.mas_bottom).offset(10);
    }];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(32);
        make.bottom.mas_equalTo(-30);
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(10);
    }];
    
    [self.sumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-33);
        make.bottom.mas_equalTo(-30);
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(10);
    }];
}

- (void)setModel:(HomeNewPurchaseModel *)model{
    _model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:UIImageMake(@"uitl_hightlight_gray_light")];
    self.nameLabel.text = model.title;
//    self.buyBtn.enabled = NO;
//    if (model.state == 0) {
//        self.buyBtn.backgroundColor = UIColor.grayColor;
//        [self.buyBtn setTitle:NSLocalizedStringForKey(@"预热中") forState:0];
//    }else if (model.state == 1) {
//        self.buyBtn.enabled = YES;
//        self.buyBtn.backgroundColor = UIColorMakeWithHex(@"#5FCE64");
//        [self.buyBtn setTitle:NSLocalizedStringForKey(@"申购") forState:0];
//    }else if (model.state == 2) {
//        self.buyBtn.backgroundColor = UIColor.grayColor;
//        [self.buyBtn setTitle:NSLocalizedStringForKey(@"已结束") forState:0];
//    }
    
//    NSDictionary *optoins=@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
//
//                                    NSFontAttributeName:[UIFont systemFontOfSize:14]};
//    NSData *data=[model.summary dataUsingEncoding:NSUnicodeStringEncoding];
//    NSAttributedString *attributeString=[[NSAttributedString alloc] initWithData:data options:optoins documentAttributes:nil error:nil];
//    self.descLabel.attributedText = attributeString;
//    /// 状态：0 待开始，1 申购中，2 已结束
//    if (model.state == 0) {
//        self.statusLabel.text = NSLocalizedStringForKey(@"待开始");
//    }else if (model.state == 1) {
//        self.statusLabel.text = NSLocalizedStringForKey(@"进行中");
//    }else if (model.state == 2) {
//        self.statusLabel.text = NSLocalizedStringForKey(@"已结束");
//    }
    
    self.progressView.progress = model.progress ? model.progress.floatValue / 100.0: 0;
    self.progressLabel.text = [NSString stringWithFormat:@"%@%%", model.progress];
    self.sumLabel.text = [NSString stringWithFormat:@"%@", model.sum ];
    
//    if (model.alCount.floatValue >= model.sum.floatValue) {
//        self.progressView.progress = 1;
//        self.progressLabel.text = @"100%";
//    }else{
//        self.progressView.progress = model.alCount.floatValue / model.sum.floatValue;
//        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%@", (model.alCount.floatValue / model.sum.floatValue) * 100, @"%"];
//    }
}

- (NSString *)stringWithCreat_time:(NSString *)creat_time dateFormat:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    int timeval = [creat_time intValue];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeval];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

- (void)buyBtnAction{
    if (self.buyBtnActionBlock) {
        self.buyBtnActionBlock();
    }
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
    }
    return _nameLabel;
}

//- (UILabel *)statusLabel{
//    if (!_statusLabel) {
//        _statusLabel = [[UILabel alloc] init];
//        _statusLabel.font = UIFontMake(10);
//        _statusLabel.textColor = UIColor.whiteColor;
//        _statusLabel.backgroundColor = UIColorMakeWithHex(@"#5FCE64");
//        _statusLabel.textAlignment = NSTextAlignmentCenter;
//        _statusLabel.layer.cornerRadius = 3;
//        _statusLabel.layer.masksToBounds = YES;
//    }
//    return _statusLabel;
//}

//- (UILabel *)descLabel{
//    if (!_descLabel) {
//        _descLabel = [[UILabel alloc] init];
//        _descLabel.font = UIFontMake(10);
//        _descLabel.textColor = UIColorMakeWithHex(@"#999999");
//        _descLabel.numberOfLines = 0;
//    }
//    return _descLabel;
//}

- (UILabel *)infoTitleLabel{
    if (!_infoTitleLabel) {
        _infoTitleLabel = [[UILabel alloc] init];
        _infoTitleLabel.font = UIFontMake(15);
        _infoTitleLabel.textColor = UIColorMakeWithHex(@"#333333");
        _infoTitleLabel.text = @"基本信息";
    }
    return _infoTitleLabel;
}

- (UILabel *)progressLeftLabel{
    if (!_progressLeftLabel) {
        _progressLeftLabel = [[UILabel alloc] init];
        _progressLeftLabel.font = UIFontMake(11);
        _progressLeftLabel.textColor = UIColorMakeWithHex(@"#999999");
        _progressLeftLabel.text = @"进度";
    }
    return _progressLeftLabel;
}

- (UILabel *)progressRightLabel{
    if (!_progressRightLabel) {
        _progressRightLabel = [[UILabel alloc] init];
        _progressRightLabel.font = UIFontMake(11);
        _progressRightLabel.textColor = UIColorMakeWithHex(@"#999999");
        _progressRightLabel.text = NSLocalizedStringForKey(@"申购总量"); //@"本次剩余申购量";
    }
    return _progressRightLabel;
}

- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = UIFontMake(11);
        _progressLabel.textColor = UIColorMakeWithHex(@"#999999");
    }
    return _progressLabel;
}

- (UILabel *)sumLabel{
    if (!_sumLabel) {
        _sumLabel = [[UILabel alloc] init];
        _sumLabel.font = UIFontMake(11);
        _sumLabel.textColor = UIColorMakeWithHex(@"#999999");
    }
    return _sumLabel;
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

//- (UIButton *)buyBtn{
//    if (!_buyBtn) {
//        _buyBtn = [[UIButton alloc] init];
//        [_buyBtn setTitle:NSLocalizedStringForKey(@"申购") forState:0];
//        [_buyBtn setTitleColor:UIColor.whiteColor forState:0];
//        _buyBtn.titleLabel.font = UIFontMake(15);
//        _buyBtn.backgroundColor = UIColorMakeWithHex(@"#5FCE64");
//        _buyBtn.layer.cornerRadius = 5;
//        _buyBtn.layer.masksToBounds = YES;
//        [_buyBtn addTarget:self action:@selector(buyBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _buyBtn;
//}

@end
