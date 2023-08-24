//
//  HomeMainListViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeMainListViewController.h"
#import "HomeMainQuotationsListCell.h"

@interface HomeMainListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HomeMainListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self getData];
}

- (void)initUI{
    self.dataSource = [NSMutableArray array];
    self.view.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 50 - kUINormalNavBarHeight - kUINormalTabBarHeight - 10)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.layer.qmui_maskedCorners = QMUILayerMaxXMaxYCorner | QMUILayerMinXMaxYCorner;
    tableView.layer.cornerRadius = 10;
    [tableView registerClass:[HomeMainQuotationsListCell class] forCellReuseIdentifier:NSStringFromClass([HomeMainQuotationsListCell class])];
    self.tableView = tableView;
    [self.view addSubview:tableView];
}

- (void)getData{
    [YYRequestUtility Post:@"quote/marketData.do" addParameters:@{@"tab" : @"stock", @"sortField" : @"rate", @"sortType" : self.index == 0 ? @"1" : @"2"} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [self.dataSource removeAllObjects];
            for (NSDictionary *dict in responseDict[@"data"][@"quotes"]) {
                HomeQuoteModel *model = [HomeQuoteModel yy_modelWithDictionary:dict];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count > 10 ? 10 : self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeMainQuotationsListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeMainQuotationsListCell class]) forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
//    if (indexPath.row % 2 == 0) {
//        cell.backgroundColor = UIColorMakeWithHex(@"#f6f7f8");
//    }else{
//        cell.backgroundColor = UIColorWhite;
//    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeQuoteModel *model = self.dataSource[indexPath.row];
    [self putValueToParamDictionary:@"CoinTradeDic" value:model.symbol forKey:@"CoinQuotationsDetailSymbol"];
    [self putValueToParamDictionary:@"CoinTradeDic" value:model.marketType forKey:@"CoinQuotationDetailMarketType"];
    [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _headerView.backgroundColor = UIColorWhite;
        
        QMUIButton *nameBtn = [[QMUIButton alloc] init];
        [nameBtn setTitle:NSLocalizedStringForKey(@"名称") forState:0];
        [nameBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        nameBtn.titleLabel.font = UIFontMake(13);
        nameBtn.imagePosition = QMUIButtonImagePositionRight;
        nameBtn.spacingBetweenImageAndTitle = 5;
        [_headerView addSubview:nameBtn];
        [nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.centerY.mas_equalTo(self.headerView);
        }];
        
        
        QMUIButton *rateBtn = [[QMUIButton alloc] init];
        [rateBtn setTitle:NSLocalizedStringForKey(@"涨跌幅") forState:0];
        [rateBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        rateBtn.titleLabel.font = UIFontMake(13);
        rateBtn.imagePosition = QMUIButtonImagePositionRight;
        rateBtn.spacingBetweenImageAndTitle = 5;
        [_headerView addSubview:rateBtn];
        [rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-30);
            make.centerY.mas_equalTo(self.headerView);
        }];
        
        QMUIButton *priceBtn = [[QMUIButton alloc] init];
        [priceBtn setTitle:NSLocalizedStringForKey(@"最新价") forState:0];
        [priceBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        priceBtn.titleLabel.font = UIFontMake(13);
        priceBtn.imagePosition = QMUIButtonImagePositionRight;
        priceBtn.spacingBetweenImageAndTitle = 5;
        [_headerView addSubview:priceBtn];
        [priceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView);
            //make.centerX.mas_equalTo(self.headerView.mas_centerX).offset(-15);
            make.right.mas_equalTo(rateBtn.mas_left).offset(-70);
        }];

    }
    return _headerView;
}

#pragma mark =========================== 懒加载 ===========================r
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
