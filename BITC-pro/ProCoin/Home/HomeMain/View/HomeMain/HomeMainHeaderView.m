//
//  HomeMainHeaderView.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeMainHeaderView.h"
#import "NetWorkManage+Home.h"
#import "NetWorkManage+Personal.h"
#import "CropymeBannerEntity.h"
#import "InfluencerRankEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "RZSmallVideoManager.h"
#import "SDCycleScrollView.h"
#import "RZWebImageView.h"
#import "PCAnnounceModel.h"
#import "LMJVerticalScrollText.h"
#import "CollectionViewCell.h"
#import "NSString+Align.h"
#import "HomeMainOTCCell.h"

@interface HomeMainHeaderView ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate, LMJVerticalScrollTextDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) LMJVerticalScrollText *scrollText;

@end

@implementation HomeMainHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH - 20, SCREEN_HEIGHT)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = UIColor.clearColor;
    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[HomeMainQuotationsCell class] forCellReuseIdentifier:NSStringFromClass([HomeMainQuotationsCell class])];
    [tableView registerClass:[HomeMainOTCCell class] forCellReuseIdentifier:NSStringFromClass([HomeMainOTCCell class])];
    self.tableView = tableView;
    [self addSubview:self.tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kUINormalNavBarHeight, 0, 10, 0));
    }];
}

- (void)setBannerArray:(NSMutableArray *)bannerArray{
    _bannerArray = bannerArray;
    self.cycleScrollView.imageURLStringsGroup = bannerArray;
}

- (void)setQuoteArray:(NSMutableArray *)quoteArray{
    _quoteArray = quoteArray;
    [self.tableView reloadData];
}

- (void)setAnnounceDataArr:(NSMutableArray *)announceDataArr{
    [self.scrollText stopToEmpty];
    self.scrollText.textDataArr = announceDataArr;
    [self.scrollText startScrollBottomToTopWithNoSpace];
}

/// 公告
- (void)announceViewAction{
    if (self.announceViewActionBlock) {
        self.announceViewActionBlock();
    }
}

- (void)clickAction:(NSInteger)type{
    if (self.clickActionBlock) {
        self.clickActionBlock(type);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        HomeMainQuotationsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeMainQuotationsCell class]) forIndexPath:indexPath];
        cell.dataArray = self.quoteArray;
        cell.clickDataBlock = ^(HomeQuoteModel * _Nonnull model) {
            if (self.quotationsDataBlock) {
                self.quotationsDataBlock(model);
            }
        };
        return cell;
    }
    HomeMainOTCCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeMainOTCCell class]) forIndexPath:indexPath];
    cell.clickActionBlock = ^(NSUInteger type) {
        [self clickAction:type];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 0 ? 120 : 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, ceil((SCREEN_WIDTH - 20) / 2.1) + 20 + 55)];
        [_headerView addSubview:self.cycleScrollView];
        
        UIView *announceView = [[UIView alloc] initWithFrame:CGRectMake(0, ceil((SCREEN_WIDTH - 20) / 2.1) + 20, SCREEN_WIDTH - 20, 50)];
        announceView.backgroundColor = UIColor.whiteColor;
        announceView.layer.cornerRadius = 10;
        announceView.layer.masksToBounds = YES;
        [announceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(announceViewAction)]];
        [_headerView addSubview:announceView];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:UIImageMake(@"home_notice")];
        [announceView addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.size.mas_equalTo(20);
            make.centerY.mas_equalTo(announceView);
        }];
        
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:UIImageMake(@"home_notice_arrow")];
        [announceView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-36);
            make.size.mas_equalTo(CGSizeMake(28, 21));
            make.centerY.mas_equalTo(announceView);
        }];
        
        self.scrollText = [[LMJVerticalScrollText alloc] initWithFrame:CGRectMake(47, 0, SCREEN_WIDTH - 47 - 20 - 60, 50)];
        self.scrollText.delegate            = self;
        self.scrollText.textStayTime        = 2;
        self.scrollText.scrollAnimationTime = 1;
        self.scrollText.backgroundColor     = [UIColor whiteColor];
        self.scrollText.textColor           = RGBA(61, 58, 80, 1.0);
        self.scrollText.textFont            = [UIFont boldSystemFontOfSize:14.f];
        self.scrollText.textAlignment       = NSTextAlignmentLeft;
        self.scrollText.touchEnable         = NO;
        self.scrollText.layer.cornerRadius  = 3;
        [announceView addSubview:self.scrollText];
    }
    return _headerView;
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
