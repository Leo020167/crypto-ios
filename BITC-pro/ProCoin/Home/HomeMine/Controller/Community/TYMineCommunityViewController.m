//
//  TYMineCommunityViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/1.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineCommunityViewController.h"
#import "TYMineCommunityBuyCodeViewController.h"
#import "TYMineCommunityHeaderView.h"
#import "TYMineCommunityListCell.h"

@interface TYMineCommunityViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TYMineCommunityHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *buyBtn;

@property (nonatomic, strong) TYMineCommunityModel *model;

@end

@implementation TYMineCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
    
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"refreshHomeBanner" object:nil];
}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColorMakeWithHex(@"#4D4CE6");
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedStringForKey(@"社区");
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
}

- (void)initUI{
    self.dataSource = [NSMutableArray array];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.buyBtn];
    [self.buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
}

- (void)getData{
    if(!ROOTCONTROLLER_USER.userId){
        return;
    }
    [YYRequestUtility Post:@"invite/home.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            [self.dataSource removeAllObjects];
            TYMineCommunityModel *model = [TYMineCommunityModel yy_modelWithDictionary:responseDict[@"data"]];
            self.model = model;
            self.headerView.model = model;
            for (NSDictionary *dict in model.inviteList) {
                TYMineCommunityListModel *listModel = [TYMineCommunityListModel yy_modelWithDictionary:dict];
                [self.dataSource addObject:listModel];
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

- (void)buyBtnAction{
    TYMineCommunityBuyCodeViewController *code = [[TYMineCommunityBuyCodeViewController alloc] init];
    code.inviteCodePrice = self.model.inviteCodePrice;
    code.reloadDataBlock = ^{
        [self getData];
    };
    [self.navigationController pushViewController:code animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TYMineCommunityListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMineCommunityListCell class]) forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 31;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 50)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYMineCommunityListCell class] forCellReuseIdentifier:NSStringFromClass([TYMineCommunityListCell class])];
        __weak typeof(self) weakSelf = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf getData];
        }];
    }
    return _tableView;
}

- (TYMineCommunityHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[TYMineCommunityHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 235)];
    }
    return _headerView;
}

- (UIButton *)buyBtn{
    if (!_buyBtn) {
        _buyBtn = [[UIButton alloc] init];
        [_buyBtn setTitle:NSLocalizedStringForKey(@"兑换邀请码") forState:0];
        [_buyBtn setTitleColor:UIColor.whiteColor forState:0];
        _buyBtn.titleLabel.font = UIFontMake(17);
        _buyBtn.backgroundColor = UIColorMakeWithHex(@"#4D4CE6");
        [_buyBtn addTarget:self action:@selector(buyBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyBtn;
}

@end
