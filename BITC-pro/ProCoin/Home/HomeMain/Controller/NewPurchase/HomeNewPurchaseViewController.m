//
//  HomeNewPurchaseViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/23.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeNewPurchaseViewController.h"
#import "HomeNewPurchaseCell.h"
#import "HomeNewPurchaseDetailViewController.h"

@interface HomeNewPurchaseViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSTimer *limitTimer;

@end

@implementation HomeNewPurchaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.limitTimer) {
        [self.limitTimer setFireDate:[NSDate date]];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.limitTimer setFireDate:[NSDate distantFuture]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self initUI];
    
    [self getData];
}

- (void)initUI{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight) style:QMUITableViewStyleInsetGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.qmui_insetGroupedHorizontalInset = 15;
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.estimatedRowHeight = 500;
    tableView.tableHeaderView = [[UIView alloc] init];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[HomeNewPurchaseCell class] forCellReuseIdentifier:NSStringFromClass([HomeNewPurchaseCell class])];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
}

- (void)getData{
    [YYRequestUtility Post:@"subscribe/getList.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.dataSource = [NSMutableArray array];
            for (NSDictionary *dict in responseDict[@"data"]) {
                HomeNewPurchaseListModel *model = [HomeNewPurchaseListModel yy_modelWithDictionary:dict];
                if (model.state == self.index) {
                    [self.dataSource addObject:model];
                }
            }
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)refreshCloseTimeAction{
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeNewPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeNewPurchaseCell class]) forIndexPath:indexPath];
    HomeNewPurchaseListModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    cell.reloadDataBlock = ^{
        [self getData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(ROOTCONTROLLER_USER.userId){
        HomeNewPurchaseModel *model = self.dataSource[indexPath.row];
        HomeNewPurchaseDetailViewController *detail = [[HomeNewPurchaseDetailViewController alloc] init];
        detail.id = model.id;
        [QMUIHelper.visibleViewController.navigationController pushViewController:detail animated:YES];
    }else{
        [ROOTCONTROLLER gotoLogin];
    }
}

#pragma mark =========================== 懒加载 ===========================
#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

@end
