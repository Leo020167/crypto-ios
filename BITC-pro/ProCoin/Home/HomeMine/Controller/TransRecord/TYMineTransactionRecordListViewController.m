//
//  TYMineTransactionRecordListViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/29.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineTransactionRecordListViewController.h"
#import "TYMineTransactionRecordListCell.h"
#import "PayAlertView.h"
#import "TYMineTransactionDetailViewController.h"

@interface TYMineTransactionRecordListViewController ()<QMUITableViewDelegate, QMUITableViewDataSource, PayAlertViewDelegate>

@property (nonatomic, strong) QMUITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) PCBaseTransactionRecordModel *model;

@property (assign, nonatomic) CGFloat undoneCellHeight;     //未完成cell高度

@end

@implementation TYMineTransactionRecordListViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI{
    self.page = 1;
    self.dataSource = [NSMutableArray array];
    [self.view addSubview:self.tableView];
}

- (void)getData{
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setObject:@(self.page) forKey:@"pageNo"];
    [para setObject:@"balance" forKey:@"accountType"];
    [para setObject:@"1" forKey:@"isDone"];
    [para setObject:@"" forKey:@"buySell"];
    [para setObject:@"" forKey:@"symbol"];
    [para setObject:@(self.index) forKey:@"orderState"];
    
    [YYRequestUtility Post:@"pro/order/queryList.do" addParameters:para progress:nil success:^(NSDictionary *responseDict) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if ([responseDict[@"code"] intValue] == 200) {
            if (self.page == 1) {
                [self.dataSource removeAllObjects];
            }
            for (NSDictionary *dict in responseDict[@"data"][@"data"]) {
                PCBaseTransactionRecordModel *model = [PCBaseTransactionRecordModel yy_modelWithDictionary:dict];
                model.type = self.index;
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)statusBtnAction:(NSIndexPath *)indexPath{
    self.model = self.dataSource[indexPath.section];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定取消该委托订单吗?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqCancelOrder:@""];          //取消订单
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reqCancelOrder:(NSString *)payPass{
    
    [YYRequestUtility Post:@"pro/order/cancel.do" addParameters:@{@"orderId" : self.model.orderId, @"payPass" : payPass} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [QMUITips showSucceed:responseDict[@"msg"]];
            self.page = 1;
            [self getData];
        }else{
            if ([responseDict[@"code"] intValue] == 40030) { //需要输入交易密码
                PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
                [payAlertView show];
            }else{
                [QMUITips showError:responseDict[@"msg"]];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (CGFloat)undoneCellHeight
{
    if(_undoneCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
        _undoneCellHeight = cell.frame.size.height;
    }
    return _undoneCellHeight;
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqCancelOrder:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.index == 0) {
        static NSString *unDoneCellIdentifier = @"PCBaseTransactionOrderCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unDoneCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
            UIButton *cancelOrderButton = (UIButton *)[cell viewWithTag:500];
            cancelOrderButton.qmui_tapBlock = ^(__kindof UIControl *sender) {
                [self statusBtnAction:indexPath];
            };
        }
        PCBaseTransactionRecordModel *entity = [self.dataSource objectAtIndex:indexPath.section];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
        titleLabel.text = [NSString stringWithFormat:@"%@·%@", entity.symbol, entity.buySellValue];
        dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
        handAmountLabel.text = entity.amount;
        priceLabel.text = entity.price;
        openBailLabel.text = entity.sum;
        return cell;
    }
    TYMineTransactionRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMineTransactionRecordListCell class]) forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.section];
    __weak typeof(self) weakSelf = self;
    cell.statusBtnActionBlock = ^{
        [weakSelf statusBtnAction:indexPath];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.index == 0 ? self.undoneCellHeight : 135;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.index == 1){     //只有历史才能点击
        PCBaseTransactionRecordModel *entity = self.dataSource[indexPath.section];
        if([entity.buySell isEqualToString:@"sell"]){
            TYMineTransactionDetailViewController *detail = [[TYMineTransactionDetailViewController alloc] init];
            detail.model = entity;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
}

#pragma mark =========================== 懒加载 ===========================
- (QMUITableView *)tableView{
    if (!_tableView) {
        _tableView = [[QMUITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 50)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColorMakeWithHex(@"#F3F3F3");
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYMineTransactionRecordListCell class] forCellReuseIdentifier:NSStringFromClass([TYMineTransactionRecordListCell class])];

        
        __weak typeof(self) weakSelf = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.page = 1;
            [weakSelf getData];
        }];
//        _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
//            weakSelf.page ++;
//            [weakSelf getData];
//        }];
    }
    return _tableView;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}
@end
