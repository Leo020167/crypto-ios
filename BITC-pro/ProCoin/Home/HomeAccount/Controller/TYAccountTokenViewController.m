//
//  TYAccountTokenViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountTokenViewController.h"
#import "TYAccountTokenInfoCell.h"
#import "TYAccountFinancialRecordeCell.h"
#import "TYAccountFinancialRecordeHeaderView.h"
#import "PCCoinOperationRecordModel.h"
#import "PCAccountModel.h"

@interface TYAccountTokenViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *financeArray;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, strong) PCAccountModel *tokenModel;

@property (nonatomic, strong) NSTimer *requestDataTimer;

@end

@implementation TYAccountTokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI{
    self.financeArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];
}

- (void)getData:(PCAccountModel *)model{
    self.tokenModel = model;
    [self getFinanceData];
    [self.tableView reloadData];
}

- (void)getFinanceData{
    [YYRequestUtility Post:@"account/recordList.do" addParameters:@{@"pageNo": @1, @"accountType" : @"token"} progress:nil success:^(NSDictionary *responseDict) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if ([responseDict[@"code"] intValue] == 200) {
            [self.financeArray removeAllObjects];
            for (NSDictionary *dict in responseDict[@"data"][@"data"]) {
                PCCoinOperationRecordModel *model = [PCCoinOperationRecordModel yy_modelWithDictionary:dict];
                [self.financeArray addObject:model];
            }
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        [QMUITips showError:NSLocalizedStringForKey(@"Request Failed")];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];
}

//- (void)startRequestTimer
//{
//    if(self.requestDataTimer && [self.requestDataTimer isValid]){
//        [self closeRequestTimer];
//    }
//    self.requestDataTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getData) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.requestDataTimer forMode:NSRunLoopCommonModes];
//}

//- (void)closeRequestTimer
//{
//    if(self.requestDataTimer && [self.requestDataTimer isValid]){
//        [self.requestDataTimer invalidate];
//        self.requestDataTimer = nil;
//    }
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){           //账户信息
        return 1;
    }else if(section == 1){     //财务记录
        return self.financeArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){     //账户信息
        return 165;
    }else if(indexPath.section == 1){   //财务记录
        return 100;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        TYAccountTokenInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountTokenInfoCell class]) forIndexPath:indexPath];
        if(self.tokenModel == nil)
            return cell;
        cell.tokenModel = self.tokenModel;
        cell.getBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.url = GetTokenUrl;
            [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
        };
        return cell;
    }else{
        TYAccountFinancialRecordeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountFinancialRecordeCell class]) forIndexPath:indexPath];
        PCCoinOperationRecordModel *model = self.financeArray[indexPath.row];
        model.stateDesc = NSLocalizedStringForKey(@"已成功");
        cell.model = model;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
        TYAccountFinancialRecordeHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([TYAccountFinancialRecordeHeaderView class])];
        headerView.financialBtn.hidden = YES;
        [headerView.positionBtn setTitle:NSLocalizedStringForKey(@"财务记录") forState:0];
        headerView.btnClickActionBlock = ^(NSInteger tag) {
            if (tag == 3) {
                [self pageToViewControllerForName:@"PCCoinOperationRecordController"];
            }
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
        _tableView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYAccountFinancialRecordeCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountFinancialRecordeCell class])];
        [_tableView registerClass:[TYAccountTokenInfoCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountTokenInfoCell class])];
        [_tableView registerClass:[TYAccountFinancialRecordeHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([TYAccountFinancialRecordeHeaderView class])];
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
