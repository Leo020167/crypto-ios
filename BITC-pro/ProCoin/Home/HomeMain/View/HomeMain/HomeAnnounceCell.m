//
//  HomeAnnounceCell.m
//  ProCoin
//
//  Created by Luo Chun on 2023/7/21.
//  Copyright © 2023 Toka. All rights reserved.
//

#import "HomeAnnounceCell.h"


@interface HomeAnnounceCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong)  UIImageView *iconImageView;

@property (nonatomic, strong) LMJVerticalScrollText *scrollText;

@property (nonatomic, strong) UIImageView *arrowImageView;


@end

@implementation HomeAnnounceCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)setAnnounceDataArr:(NSMutableArray *)announceDataArr{
    _announceDataArr = announceDataArr;
    [self.scrollText stopToEmpty];
    self.scrollText.textDataArr = _announceDataArr;
    [self.scrollText startScrollBottomToTopWithNoSpace];
}

- (void)initUI{
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.iconImageView];
    [self.bgView addSubview:self.arrowImageView];
    //[self.bgView addSubview:self.scrollText];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 0, 0));
    }];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.size.mas_equalTo(24);
        make.centerY.mas_equalTo(self.bgView);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.centerY.mas_equalTo(self.bgView);
    }];
    
    self.scrollText = [[LMJVerticalScrollText alloc] initWithFrame:CGRectMake(47, 0, SCREEN_WIDTH - 47 - 20 - 50, 50)];
    self.scrollText.delegate            = self;
    self.scrollText.textStayTime        = 2;
    self.scrollText.scrollAnimationTime = 1;
    self.scrollText.backgroundColor     = [UIColor whiteColor];
    self.scrollText.textColor           = RGBA(61, 58, 80, 1.0);
    self.scrollText.textFont            = [UIFont boldSystemFontOfSize:14.f];
    self.scrollText.textAlignment       = NSTextAlignmentLeft;
    self.scrollText.touchEnable         = NO;
    self.scrollText.layer.cornerRadius  = 3;
    [self.bgView addSubview:self.scrollText];

}

@end

