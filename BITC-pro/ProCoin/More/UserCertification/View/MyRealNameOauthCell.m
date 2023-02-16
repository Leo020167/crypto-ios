//
//  MyRealNameOauthCell.m
//  YuanLeLing
//
//  Created by 李祥翔 on 2021/12/22.
//

#import "MyRealNameOauthCell.h"

@interface MyRealNameOauthCell ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation MyRealNameOauthCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.lineView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.centerY.mas_equalTo(self);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(16);
        _titleLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = UIFontMake(16);
        _descLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _descLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorMakeWithHex(@"#EEEEEE");
    }
    return _lineView;
}

@end

