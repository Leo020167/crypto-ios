//
//  TYAccountListViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountCoinViewController.h"
#import "TYMinePositionCell.h"
#import "BBMinePositionCell.h"
#import "TYAccountCoinHeaderView.h"
#import "TYAccountBalanceInfoCell.h"
#import "TYMinePositionDetailViewController.h"
#import "PCCoinOperationRecordModel.h"
#import "TYAccountSubscribeCell.h"
#import "TYAccountFinancialRecordeCell.h"

@interface TYAccountCoinViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *positionArray;

@property (nonatomic, strong) NSMutableArray *financeArray;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, strong) PCAccountModel *balanceAccountEntity;

@property (nonatomic, strong) NSTimer *requestDataTimer;

/// 1持仓  2财务记录
@property (nonatomic, assign) NSInteger type;

@end

@implementation TYAccountCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self getFinanceData];
}

- (void)initUI{
    self.type = 1;
    self.positionArray = [NSMutableArray array];
    self.financeArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];
}

- (void)getData:(PCAccountModel *)model{
    self.balanceAccountEntity = model;
    [self.positionArray removeAllObjects];
    for(NSDictionary *dic in model.openList){
        TYMinePositionModel *entity = [TYMinePositionModel yy_modelWithDictionary:dic];
        [self.positionArray addObject:entity];
    }
    [self.tableView reloadData];
}

- (void)getFinanceData{
    [YYRequestUtility Post:@"depositeWithdraw/list.do" addParameters:@{@"type" : @"2", @"inOut" : @"", @"pageNo" : @"1"} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [self.financeArray removeAllObjects];
            NSArray *dataArr = [responseDict[@"data"] objectForKey:@"data"];
            for(NSDictionary *dic in dataArr){
                PCCoinOperationRecordModel *entity = [[[PCCoinOperationRecordModel alloc] initWithJson:dic] autorelease];
                [self.financeArray addObject:entity];
            }
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return self.type == 1 ? self.positionArray.count : self.financeArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){     //账户信息
        return 140;
    }else if(indexPath.section == 1){   //财务记录
        if (self.type == 1) {
            return 120;
        }
        PCCoinOperationRecordModel *recordEntity = [self.financeArray objectAtIndex:indexPath.row];
        return recordEntity.inOut > 1 ? 160 : 100;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        TYAccountBalanceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountBalanceInfoCell class]) forIndexPath:indexPath];
        if(self.balanceAccountEntity == nil)
            return cell;
        cell.coinModel = self.balanceAccountEntity;
        return cell;
    }
    if (self.type == 1) {
        TYMinePositionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMinePositionCell class]) forIndexPath:indexPath];
        TYMinePositionModel *model = self.positionArray[indexPath.row];
        cell.model = model;
        return cell;
    }
    PCCoinOperationRecordModel *recordEntity = [self.financeArray objectAtIndex:indexPath.row];
    if (recordEntity.inOut == 2 || recordEntity.inOut == 3 || recordEntity.inOut == 4) {
        /// 财务记录
        TYAccountSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountSubscribeCell class]) forIndexPath:indexPath];
        cell.model = recordEntity;
        return cell;
    }
    TYAccountFinancialRecordeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountFinancialRecordeCell class]) forIndexPath:indexPath];
    cell.model = recordEntity;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && self.type == 1) {
        TYMinePositionModel *entity = self.positionArray[indexPath.row];
        TYMinePositionDetailViewController *detail = [[TYMinePositionDetailViewController alloc] init];
        detail.symbol = entity.symbol;
        [QMUIHelper.visibleViewController.navigationController pushViewController:detail animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1){
        return 40;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1){       //财务记录
        TYAccountCoinHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([TYAccountCoinHeaderView class])];
        headerView.btnClickActionBlock = ^(NSInteger tag) {
            if (self.type == tag) {
                return;
            }
            self.type = tag;
            [self.tableView reloadData];
        };
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 10)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 50 - kUINormalTabBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.whiteColor ;   //UIColorMakeWithHex(@"#F5F5F5");
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYMinePositionCell class] forCellReuseIdentifier:NSStringFromClass([TYMinePositionCell class])];
        [_tableView registerClass:[BBMinePositionCell class] forCellReuseIdentifier:NSStringFromClass([BBMinePositionCell class])];
        [_tableView registerClass:[TYAccountBalanceInfoCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountBalanceInfoCell class])];
        [_tableView registerClass:[TYAccountSubscribeCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountSubscribeCell class])];
        [_tableView registerClass:[TYAccountFinancialRecordeCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountFinancialRecordeCell class])];
        [_tableView registerClass:[TYAccountCoinHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([TYAccountCoinHeaderView class])];
    }
    return _tableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollCallback(scrollView);
}

#pragma mark - JXPagingViewListViewDelegate
- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

- (UIView *)listView {
    return self.view;
}

@end
