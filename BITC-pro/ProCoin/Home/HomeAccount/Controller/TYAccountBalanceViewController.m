//
//  TYAccountBalanceViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountBalanceViewController.h"
#import "TYMinePositionCell.h"
#import "TYAccountSubscribeCell.h"
#import "TYAccountFinancialRecordeCell.h"
#import "TYAccountFinancialRecordeHeaderView.h"
#import "TYAccountBalanceInfoCell.h"
#import "PCCoinOperationRecordModel.h"
#import "PCAccountModel.h"
#import "TYAccountSymbolInfoCell.h"
#import "TYAccountFinancialSymbolHeaderView.h"
@interface TYAccountBalanceViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

//@property (nonatomic, strong) NSMutableArray *financeArray;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, strong) PCAccountModel *balanceAccountEntity;

@property (nonatomic, strong) NSTimer *requestDataTimer;

@property (nonatomic, strong) NSMutableArray<PCAccountSymbolModel *> *symbolList;

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, assign) BOOL isFilter;
@property (nonatomic, strong) NSString *searchText;

@end

@implementation TYAccountBalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
//    [self getData];
    
//    [self startRequestTimer];
}

- (void)initUI{
    //self.financeArray = [NSMutableArray array];
    self.symbolList = [NSMutableArray array];
    self.resultArray = [NSMutableArray array];
    _isFilter = NO;
    _searchText = @"";
    [self.view addSubview:self.tableView];
}

- (void)getData:(PCAccountModel *)model{
//    [self getAccountData];
    self.balanceAccountEntity = model;
    //[self getFinanceData];
    
    [self.symbolList removeAllObjects];
    for(NSDictionary *dic in model.symbolList){
        PCAccountSymbolModel *entity = [PCAccountSymbolModel yy_modelWithDictionary:dic];
        [self.symbolList addObject:entity];
    }
    
    [self handleResult];
}

- (void)handleResult {
    if (_isFilter) {
        _resultArray = [[NSMutableArray alloc] initWithArray: [_symbolList qmui_filterWithBlock:^BOOL(PCAccountSymbolModel * _Nonnull item) {
            return item.holdAmount.floatValue > 0 || item.frozenAmount.floatValue > 0;
        }]];
    } else {
        _resultArray = _symbolList;
    }
    if (_searchText.length > 0) {
        _resultArray = [[NSMutableArray alloc] initWithArray: [_resultArray qmui_filterWithBlock:^BOOL(PCAccountSymbolModel * _Nonnull item) {
            return [item.symbol.uppercaseString containsString:_searchText.uppercaseString];
        }]];
    }
    [self.tableView reloadData];
}

- (void)getAccountData{
    if(!ROOTCONTROLLER_USER.userId.length){
        return;
    }
    [YYRequestUtility Post:@"home/account.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            NSDictionary *balanceDic = [responseDict[@"data"] objectForKey:@"balanceAccount"];
            PCAccountModel *balanceAccountEntity = [PCAccountModel yy_modelWithDictionary:balanceDic];
            self.balanceAccountEntity = balanceAccountEntity;
//            [self.tableView reloadData];
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

//- (void)getFinanceData{
//    [YYRequestUtility Post:@"depositeWithdraw/list.do" addParameters:@{@"inOut" : @"", @"pageNo" : @"1"} progress:nil success:^(NSDictionary *responseDict) {
//        if ([responseDict[@"code"] intValue] == 200) {
//            [self.financeArray removeAllObjects];
//            NSArray *dataArr = [responseDict[@"data"] objectForKey:@"data"];
//            for(NSDictionary *dic in dataArr){
//                PCCoinOperationRecordModel *entity = [[[PCCoinOperationRecordModel alloc] initWithJson:dic] autorelease];
//                [self.financeArray addObject:entity];
//            }
//            [self.tableView reloadData];
//        }else{
//            [QMUITips showError:responseDict[@"msg"]];
//        }
//    } failure:^(NSError *error) {
//
//    }];
//}

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
        return self.resultArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){     //账户信息
        return 140;
    }else if(indexPath.section == 1){   //财务记录
        //PCCoinOperationRecordModel *recordEntity = [self.financeArray objectAtIndex:indexPath.row];
        //return recordEntity.inOut > 1 ? 160 : 100;
        
        return 120;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        TYAccountBalanceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountBalanceInfoCell class]) forIndexPath:indexPath];
        if(self.balanceAccountEntity == nil)
            return cell;
        cell.balanceModel = self.balanceAccountEntity;
        return cell;
    }else{
//        PCCoinOperationRecordModel *recordEntity = [self.financeArray objectAtIndex:indexPath.row];
//        if (recordEntity.inOut == 2 || recordEntity.inOut == 3 || recordEntity.inOut == 4) {
//            TYAccountSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountSubscribeCell class]) forIndexPath:indexPath];
//            cell.model = recordEntity;
//            return cell;
//        }
//        TYAccountFinancialRecordeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountFinancialRecordeCell class]) forIndexPath:indexPath];
//        cell.model = recordEntity;
//        return cell;
        
        TYAccountSymbolInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountSymbolInfoCell class]) forIndexPath:indexPath];
        cell.model = self.resultArray[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 1 ? 50 : 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1){       //财务记录
        TYAccountFinancialSymbolHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([TYAccountFinancialSymbolHeaderView class])];
        headerView.filterActionBlock = ^(BOOL isFilter) {
            self.isFilter = isFilter;
            [self handleResult];
        };
        headerView.searchActionBlock = ^(NSString *text) {
            self.searchText = text;
            [self handleResult];
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
        _tableView.backgroundColor = UIColorWhite;  //UIColorMakeWithHex(@"#F5F5F5");
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
        [_tableView registerClass:[TYAccountSubscribeCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountSubscribeCell class])];
        [_tableView registerClass:[TYAccountSymbolInfoCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountSymbolInfoCell class])];
        [_tableView registerClass:[TYAccountFinancialRecordeCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountFinancialRecordeCell class])];
        [_tableView registerClass:[TYAccountBalanceInfoCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountBalanceInfoCell class])];
        [_tableView registerClass:[TYAccountFinancialRecordeHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([TYAccountFinancialRecordeHeaderView class])];
        [_tableView registerClass:[TYAccountFinancialSymbolHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([TYAccountFinancialSymbolHeaderView class])];
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
