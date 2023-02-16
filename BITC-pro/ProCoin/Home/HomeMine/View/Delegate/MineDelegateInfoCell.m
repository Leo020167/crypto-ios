//
//  MineDelegateInfoCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/28.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "MineDelegateInfoCell.h"

@interface MineDelegateInfoCell ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *yesterdayLabel;

@property (nonatomic, strong) UILabel *todayLabel;

@end

@implementation MineDelegateInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView addSubview:self.titleLabel];
    [self.logoImageView addSubview:self.yesterdayLabel];
    [self.logoImageView addSubview:self.todayLabel];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 80, 100));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.logoImageView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    [self.yesterdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.top.mas_equalTo(30);
        make.width.mas_equalTo((SCREEN_WIDTH - 80) / 2.0);
    }];
    [self.todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(30);
        make.width.mas_equalTo((SCREEN_WIDTH - 80) / 2.0);
    }];
}

- (void)setModel:(MineDelegateInfoModel *)model{
    _model = model;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        self.logoImageView.image = UIImageMake(@"home_mine_delegate_people");
        NSString *title1 = NSLocalizedStringForKey(@"新增客户数");
        NSString *title2 = [NSString stringWithFormat:@"(%@)", NSLocalizedStringForKey(@"人")];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", title1, title2]];
        [text yy_setFont:UIFontBoldMake(17) range:NSMakeRange(0, title1.length)];
        [text yy_setFont:UIFontMake(13) range:NSMakeRange(title1.length, title2.length)];
        [text yy_setColor:UIColorMakeWithHex(@"#4E5E91") range:text.yy_rangeOfAll];
        self.titleLabel.attributedText = text;
        self.yesterdayLabel.attributedText = [self textWithMoney:self.model.yesterdayAdd title:NSLocalizedStringForKey(@"昨日新增")];
        self.todayLabel.attributedText = [self textWithMoney:self.model.todayAdd title:NSLocalizedStringForKey(@"今日新增")];
    }else if (indexPath.row == 2){
        self.logoImageView.image = UIImageMake(@"home_mine_delegate_money");
        NSString *title1 = NSLocalizedStringForKey(@"返佣金额");
        NSString *title2 = @"(USTD)";
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", title1, title2]];
        [text yy_setFont:UIFontBoldMake(17) range:NSMakeRange(0, title1.length)];
        [text yy_setFont:UIFontMake(13) range:NSMakeRange(title1.length, title2.length)];
        [text yy_setColor:UIColorMakeWithHex(@"#A83D12") range:text.yy_rangeOfAll];
        self.titleLabel.attributedText = text;
        self.yesterdayLabel.attributedText = [self textWithMoney:self.model.yesterdayCommission title:NSLocalizedStringForKey(@"昨日新增")];
        self.todayLabel.attributedText = [self textWithMoney:self.model.todayCommission title:NSLocalizedStringForKey(@"今日新增")];
    }else if (indexPath.row == 3){
        self.logoImageView.image = UIImageMake(@"home_mine_delegate_deal");
        
        NSString *title1 = NSLocalizedStringForKey(@"客户交易额");
        NSString *title2 = @"(USTD)";
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", title1, title2]];
        [text yy_setFont:UIFontBoldMake(17) range:NSMakeRange(0, title1.length)];
        [text yy_setFont:UIFontMake(13) range:NSMakeRange(title1.length, title2.length)];
        [text yy_setColor:UIColorMakeWithHex(@"#1363BE") range:text.yy_rangeOfAll];
        self.titleLabel.attributedText = text;
    }
}

- (NSMutableAttributedString *)textWithMoney:(NSString *)count title:(NSString *)title{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", count, title]];
    [text yy_setFont:UIFontMake(15) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontBoldMake(20) range:NSMakeRange(0, count.length)];
    [text yy_setColor:UIColorWhite range:text.yy_rangeOfAll];
    [text yy_setAlignment:NSTextAlignmentCenter range:text.yy_rangeOfAll];
    [text yy_setLineSpacing:5 range:text.yy_rangeOfAll];
    return text;
}

#pragma mark =========================== 懒加载 ===========================
- (UIImageView *)logoImageView{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UILabel *)yesterdayLabel{
    if (!_yesterdayLabel) {
        _yesterdayLabel = [[UILabel alloc] init];
        _yesterdayLabel.numberOfLines = 2;
    }
    return _yesterdayLabel;
}

- (UILabel *)todayLabel{
    if (!_todayLabel) {
        _todayLabel = [[UILabel alloc] init];
        _todayLabel.numberOfLines = 2;
    }
    return _todayLabel;
}

@end
