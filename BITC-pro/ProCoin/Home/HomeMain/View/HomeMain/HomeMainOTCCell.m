//
//  HomeMainOTCCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeMainOTCCell.h"

@interface HomeMainOTCCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) QMUIButton *vBtn;

@property (nonatomic, strong) QMUIButton *coinBtn;

@property (nonatomic, strong) QMUIButton *pledgeBtn;

@property (nonatomic, strong) QMUIButton *otcBtn;

@property (nonatomic, strong) QMUIButton *serviceBtn;

@end

@implementation HomeMainOTCCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.vBtn];
    [self.bgView addSubview:self.coinBtn];
    [self.bgView addSubview:self.pledgeBtn];
    [self.bgView addSubview:self.otcBtn];
    [self.bgView addSubview:self.serviceBtn];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    CGFloat width = (SCREEN_WIDTH - 20) / 5.0;
    [self.vBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(width);
    }];
    [self.coinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(width);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(width);
    }];
    [self.pledgeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(width * 2);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(width);
    }];
    [self.otcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(width * 3);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(width);
    }];
    [self.serviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(width);
    }];
}

- (void)btnAction:(QMUIButton *)sender{
    if (self.clickActionBlock) {
        self.clickActionBlock(sender.tag);
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColor.clearColor;
        //_bgView.backgroundColor = UIColor.whiteColor;
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (QMUIButton *)vBtn{
    if (!_vBtn) {
        _vBtn = [[QMUIButton alloc] init];
        [_vBtn setTitle:NSLocalizedStringForKey(@"金牌机构") forState:0];
        [_vBtn setTitleColor:UIColorMakeWithHex(@"#333333") forState:0];
        [_vBtn setImage:UIImageMake(@"home_item_v") forState:0];
        _vBtn.titleLabel.font = UIFontMake(13);
        _vBtn.spacingBetweenImageAndTitle = 5;
        _vBtn.imagePosition = QMUIButtonImagePositionTop;
        _vBtn.backgroundColor = UIColor.clearColor;
        _vBtn.tag = 1;
        [_vBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vBtn;
}

- (QMUIButton *)coinBtn{
    if (!_coinBtn) {
        _coinBtn = [[QMUIButton alloc] init];
        [_coinBtn setTitle:NSLocalizedStringForKey(@"创新试验区") forState:0];
        [_coinBtn setTitleColor:UIColorMakeWithHex(@"#333333") forState:0];
        [_coinBtn setImage:UIImageMake(@"home_item_coin") forState:0];
        _coinBtn.titleLabel.font = UIFontMake(13);
        _coinBtn.spacingBetweenImageAndTitle = 5;
        _coinBtn.imagePosition = QMUIButtonImagePositionTop;
        _coinBtn.backgroundColor = UIColor.clearColor;
        _coinBtn.tag = 2;
        [_coinBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coinBtn;
}

- (QMUIButton *)pledgeBtn{
    if (!_pledgeBtn) {
        _pledgeBtn = [[QMUIButton alloc] init];
        [_pledgeBtn setTitle:NSLocalizedStringForKey(@"Defi专区") forState:0];
        [_pledgeBtn setTitleColor:UIColorMakeWithHex(@"#333333") forState:0];
        [_pledgeBtn setImage:UIImageMake(@"home_item_pledge") forState:0];
        //_pledgeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        _pledgeBtn.titleLabel.font = UIFontMake(13);
        _pledgeBtn.spacingBetweenImageAndTitle = 5;
        _pledgeBtn.imagePosition = QMUIButtonImagePositionTop;
        _pledgeBtn.backgroundColor = UIColor.clearColor;
        _pledgeBtn.tag = 3;
        [_pledgeBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pledgeBtn;
}

- (QMUIButton *)otcBtn{
    if (!_otcBtn) {
        _otcBtn = [[QMUIButton alloc] init];
        [_otcBtn setTitle:NSLocalizedStringForKey(@"OTC交易") forState:0];
        [_otcBtn setTitleColor:UIColorMakeWithHex(@"#333333") forState:0];
        [_otcBtn setImage:UIImageMake(@"home_item_otc") forState:0];
        _otcBtn.titleLabel.font = UIFontMake(13);
        _otcBtn.spacingBetweenImageAndTitle = 5;
        _otcBtn.imagePosition = QMUIButtonImagePositionTop;
        _otcBtn.backgroundColor = UIColor.clearColor;
        _otcBtn.tag = 4;
        [_otcBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otcBtn;
}

- (QMUIButton *)serviceBtn{
    if (!_serviceBtn) {
        _serviceBtn = [[QMUIButton alloc] init];
        [_serviceBtn setTitle:NSLocalizedStringForKey(@"在线客服") forState:0];
        [_serviceBtn setTitleColor:UIColorMakeWithHex(@"#333333") forState:0];
        [_serviceBtn setImage:UIImageMake(@"home_item_service") forState:0];
        _serviceBtn.titleLabel.font = UIFontMake(13);
        _serviceBtn.spacingBetweenImageAndTitle = 5;
        _serviceBtn.imagePosition = QMUIButtonImagePositionTop;
        _serviceBtn.backgroundColor = UIColor.clearColor;
        _serviceBtn.tag = 5;
        [_serviceBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _serviceBtn;
}

@end
