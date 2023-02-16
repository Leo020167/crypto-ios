//
//  HomeNewPurchaseDetailDemandCell.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/23.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeNewPurchaseDetailDemandCell.h"

@interface HomeNewPurchaseDetailDemandCell ()<WKUIDelegate, UIScrollViewDelegate>

@end

@implementation HomeNewPurchaseDetailDemandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.descLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(0);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.top.mas_equalTo(50);
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setHtmlContent:(NSString *)htmlContent{
    NSDictionary *optoins=@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,

                                    NSFontAttributeName:[UIFont systemFontOfSize:14]};
    NSData *data=[htmlContent dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attributeString=[[NSAttributedString alloc] initWithData:data options:optoins documentAttributes:nil error:nil];
    self.descLabel.attributedText = attributeString;
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = UIFontMake(15);
        _titleLabel.textColor = UIColorMakeWithHex(@"#333333");
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = UIColorMakeWithHex(@"#62D0A5");
        _descLabel.font = UIFontMake(13);
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

@end
