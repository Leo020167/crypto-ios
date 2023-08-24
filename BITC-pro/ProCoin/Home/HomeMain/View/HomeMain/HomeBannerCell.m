//
//  HomeBannerCell.m
//  ProCoin
//
//  Created by Luo Chun on 2023/7/21.
//  Copyright © 2023 Toka. All rights reserved.
//

#import "HomeBannerCell.h"


@interface HomeBannerCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@end

@implementation HomeBannerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)initUI{
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.cycleScrollView];
    //[self.bgView addSubview:self.scrollText];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 0, 0));
    }];

    [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];


}


- (void)setBannerArray:(NSMutableArray *)bannerArray{
    _bannerArray = [[NSMutableArray alloc] initWithArray:bannerArray];
    self.cycleScrollView.imageURLStringsGroup = bannerArray;
}


#pragma mark =========================== 懒加载 ===========================
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColor.whiteColor;
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}


- (SDCycleScrollView *)cycleScrollView{
    if (!_cycleScrollView) {
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 10, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20) / 2.1) delegate:self placeholderImage:nil];
        _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        _cycleScrollView.currentPageDotColor = UIColorMakeWithHex(@"#008FE6");
        _cycleScrollView.pageDotColor = [UIColor whiteColor];
        _cycleScrollView.backgroundColor = UIColorClear;
        _cycleScrollView.layer.cornerRadius = 10;
        _cycleScrollView.layer.masksToBounds = YES;
    }
    return _cycleScrollView;
}


@end
