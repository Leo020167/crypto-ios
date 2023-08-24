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

#import "RZWebImageView.h"
#import "PCAnnounceModel.h"
#import "LMJVerticalScrollText.h"
#import "CollectionViewCell.h"
#import "NSString+Align.h"
#import "HomeMainOTCCell.h"
#import "HomeBannerCell.h"
#import "HomeAnnounceCell.h"

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
    [tableView registerClass:[HomeBannerCell class] forCellReuseIdentifier:NSStringFromClass([HomeBannerCell class])];
    [tableView registerClass:[HomeMainOTCCell class] forCellReuseIdentifier:NSStringFromClass([HomeMainOTCCell class])];
    [tableView registerClass:[HomeAnnounceCell class] forCellReuseIdentifier:NSStringFromClass([HomeAnnounceCell class])];
    self.tableView = tableView;
    [self addSubview:self.tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kUINormalNavBarHeight, 0, 10, 0));
    }];
}

- (void)setBannerArray:(NSMutableArray *)bannerArray{
    _bannerArray = [[NSMutableArray alloc] initWithArray: bannerArray];
    //self.cycleScrollView.imageURLStringsGroup = bannerArray;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setQuoteArray:(NSMutableArray *)quoteArray{
    _quoteArray = quoteArray;
    //[self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setAnnounceDataArr:(NSMutableArray *)announceDataArr{
//    _announceDataArr = [[NSMutableArray alloc] initWithArray: announceDataArr];
//
//    //[self.scrollText stopToEmpty];
//    //self.scrollText.textDataArr = announceDataArr;
//    //[self.scrollText startScrollBottomToTopWithNoSpace];
//
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        HomeMainOTCCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeMainOTCCell class]) forIndexPath:indexPath];
        cell.clickActionBlock = ^(NSUInteger type) {
            [self clickAction:type];
        };
        return cell;
    } else if (indexPath.row == 1) {
//        HomeAnnounceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeAnnounceCell class]) forIndexPath:indexPath];
//        if (self.announceDataArr.count > 0) {
//            cell.announceDataArr = self.announceDataArr;
//        }
//        return cell;
        HomeBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeBannerCell class]) forIndexPath:indexPath];
        if (self.bannerArray.count > 0) {
            cell.bannerArray = self.bannerArray;
        }
        return cell;
    }
    HomeMainQuotationsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeMainQuotationsCell class]) forIndexPath:indexPath];
    cell.dataArray = self.quoteArray;
    cell.clickDataBlock = ^(HomeQuoteModel * _Nonnull model) {
        if (self.quotationsDataBlock) {
            self.quotationsDataBlock(model);
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 110;
    } else if (indexPath.row == 1) {
        //return 60;
        return ceil((SCREEN_WIDTH - 20) / 2.1);
    }
    return 130;
    //return indexPath.row == 0 ? 120 : 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 1) {
//        [self announceViewAction];
//    }
}

#pragma mark =========================== 懒加载 ===========================
- (UIView *)headerView{
    if (!_headerView) {
//        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, ceil((SCREEN_WIDTH - 20) / 2.1) + 5 )];
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    }
    return _headerView;
}

@end


