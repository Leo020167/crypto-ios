//
//  TYAccountCoinHeaderView.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/5.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountCoinHeaderView.h"

@interface TYAccountCoinHeaderView ()

@end

@implementation TYAccountCoinHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.contentView.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.financialBtn];
    [self.contentView addSubview:self.positionBtn];
    [self.positionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
    }];
    [self.financialBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionBtn.mas_right).offset(30);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)btnAction:(QMUIButton *)sender{
    self.financialBtn.selected = NO;
    self.positionBtn.selected = NO;
    self.financialBtn.titleLabel.font = UIFontMake(13);
    self.positionBtn.titleLabel.font = UIFontMake(13);
    sender.selected = YES;
    sender.titleLabel.font = UIFontMake(15);
    if (self.btnClickActionBlock) {
        self.btnClickActionBlock(sender.tag);
    }
}

#pragma mark =========================== 懒加载 ===========================
- (QMUIButton *)financialBtn{
    if (!_financialBtn) {
        _financialBtn = [[QMUIButton alloc] init];
        [_financialBtn setTitle:NSLocalizedStringForKey(@"申购记录") forState:0];
        [_financialBtn setTitleColor:UIColorMakeWithHex(@"#666666") forState:0];
        [_financialBtn setTitleColor:UIColorMakeWithHex(@"#2B4166") forState:UIControlStateSelected];
        _financialBtn.titleLabel.font = UIFontMake(13);
        _financialBtn.tag = 2;
        [_financialBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _financialBtn;
}

- (QMUIButton *)positionBtn{
    if (!_positionBtn) {
        _positionBtn = [[QMUIButton alloc] init];
        [_positionBtn setTitle:NSLocalizedStringForKey(@"持仓") forState:0];
        [_positionBtn setTitleColor:UIColorMakeWithHex(@"#666666") forState:0];
        [_positionBtn setTitleColor:UIColorMakeWithHex(@"#2B4166") forState:UIControlStateSelected];
        _positionBtn.titleLabel.font = UIFontMake(15);
        _positionBtn.tag = 1;
        _positionBtn.selected = YES;
        [_positionBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _positionBtn;
}

@end
