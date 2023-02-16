//
//  MineDelegateLevelInfoCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/2/18.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "MineDelegateLevelInfoCell.h"

@interface MineDelegateLevelInfoCell ()

@property (nonatomic, strong) UIView *bgView;

/// 总邀请人数
@property (nonatomic, strong) UILabel *totalLabel;

/// 可邀请人数
@property (nonatomic, strong) UILabel *canLabel;

@end

@implementation MineDelegateLevelInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.totalLabel];
    [self.bgView addSubview:self.canLabel];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 80, 100));
    }];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo((SCREEN_WIDTH - 80) / 2.0);
    }];
    [self.canLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo((SCREEN_WIDTH - 80) / 2.0);
    }];
}

- (void)setModel:(MineDelegateInfoModel *)model{
    self.totalLabel.attributedText = [self textWithMoney:model.sumMyAdd title:NSLocalizedStringForKey(@"总邀请人数")];
    self.canLabel.attributedText = [self textWithMoney:model.remainInviteCount title:NSLocalizedStringForKey(@"可邀请人数")];
}

- (NSMutableAttributedString *)textWithMoney:(NSString *)count title:(NSString *)title{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", title, count]];
    [text yy_setFont:UIFontBoldMake(20) range:text.yy_rangeOfAll];
    [text yy_setFont:UIFontMake(15) range:NSMakeRange(0, title.length)];
    [text yy_setColor:UIColorWhite range:text.yy_rangeOfAll];
    [text yy_setAlignment:NSTextAlignmentCenter range:text.yy_rangeOfAll];
    [text yy_setLineSpacing:15 range:text.yy_rangeOfAll];
    return text;
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
        NSMutableArray *ar = [NSMutableArray array];
        [ar addObject:(id)UIColorMakeWithHex(@"#1994FD").CGColor];
        [ar addObject:(id)UIColorMakeWithHex(@"#5AB2FE").CGColor];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = ar;
        gradientLayer.locations = @[@0, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH - 80, 100);
        [_bgView.layer insertSublayer:gradientLayer atIndex:0];
    }
    return _bgView;
}

- (UILabel *)totalLabel{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.numberOfLines = 2;
    }
    return _totalLabel;
}

- (UILabel *)canLabel{
    if (!_canLabel) {
        _canLabel = [[UILabel alloc] init];
        _canLabel.numberOfLines = 2;
    }
    return _canLabel;
}

@end
