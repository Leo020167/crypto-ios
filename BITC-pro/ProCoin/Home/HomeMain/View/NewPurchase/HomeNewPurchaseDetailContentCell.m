//
//  HomeNewPurchaseDetailContentCell.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/22.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "HomeNewPurchaseDetailContentCell.h"

@interface HomeNewPurchaseDetailContentCell ()

@end

@implementation HomeNewPurchaseDetailContentCell

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
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(32);
        make.top.mas_equalTo(6);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(37);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.bottom.mas_equalTo(-6);
    }];
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(11);
        _titleLabel.textColor = UIColorMakeWithHex(@"#999999");
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = UIFontMake(13);
        _descLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _descLabel;
}



@end
