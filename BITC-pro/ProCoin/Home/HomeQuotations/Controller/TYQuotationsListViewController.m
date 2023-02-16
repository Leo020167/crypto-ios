//
//  HomeAccountListViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/4.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "TYQuotationsListViewController.h"
#import "TYQuotationsListCell.h"

@interface TYQuotationsListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) UIView *headerView;

/// 筛选类型
@property (nonatomic, copy) NSString *sortField;

/// 筛选涨跌 //   涨1 跌 2
@property (nonatomic, copy) NSString *sortType;

@property (nonatomic, strong) NSMutableArray *flagDatas;    /// 备份
@end

@implementation TYQuotationsListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self initUI];
}

- (void)initUI{
    self.sortField = @"symbol";
    self.sortType = @"1";
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 50 - 45)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = UIColorMakeWithHex(@"#F3F3F3");
    tableView.sectionHeaderHeight = 0;
    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0;
    }
    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TYQuotationsListCell class] forCellReuseIdentifier:NSStringFromClass([TYQuotationsListCell class])];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    self.flagDatas = [NSMutableArray array];
}

- (void)getData{
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setObject:self.sortField forKey:@"sortField"];
    [para setObject:self.sortType forKey:@"sortType"];
    if (self.index == 0){// 全球指数
        [para setObject:@"stock" forKey:@"tab"];
    }else if (self.index == 1){// 合约
        [para setObject:@"digital" forKey:@"tab"];
    }else if (self.index == 2){// 币币
        [para setObject:@"spot" forKey:@"tab"];
    }
    [YYRequestUtility Post:@"quote/marketData.do" addParameters:para progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.dataSource = [NSMutableArray array];
            for (NSDictionary *dict in responseDict[@"data"][@"quotes"]) {
                HomeQuoteModel *model = [HomeQuoteModel yy_modelWithDictionary:dict];
                HomeQuoteModel * itemModel = [[self.flagDatas qmui_filterWithBlock:^BOOL(HomeQuoteModel*  _Nonnull item) {
                                                return [item.symbol isEqualToString:model.symbol];
                                            }] firstObject];
                if (itemModel) {
                    model.changedRate = model.rate.doubleValue - itemModel.rate.doubleValue;
                } else {
                    model.changedRate = model.rate.doubleValue;
                }
                [self.dataSource addObject:model];
            }
            self.flagDatas = self.dataSource;
            if (self.dataSource.count == 0) {
                [self showEmptyView];
                self.emptyView.backgroundColor = UIColorWhite;
                [self.emptyView setLoadingView:nil];
                [self.emptyView setImage:[UIImage imageNamed:@"home_follow_bg_no_data"]];
                self.emptyView.textLabel.text = NSLocalizedStringForKey(@"暂无该记录数据");
                self.emptyView.textLabelFont = UIFontMake(14);
                self.emptyView.textLabelTextColor = UIColorMakeWithHex(@"#D9D7D7");
                self.emptyView.textLabelInsets = UIEdgeInsetsMake(130, 0, 0, 0);
            }else{
                [self hideEmptyView];
            }
            [self.tableView reloadData];
            
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)sortBtnAction:(QMUIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.tag == 1) {//名称
        self.sortField = @"symbol";
    }else if (sender.tag == 2) {//最新价
        self.sortField = @"price";
    }else if (sender.tag == 3) {//涨跌幅
        self.sortField = @"rate";
    }
    self.sortType = sender.selected ? @"1" : @"2";
    [self getData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TYQuotationsListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYQuotationsListCell class]) forIndexPath:indexPath];
    //cell.model = self.dataSource[indexPath.row];
    HomeQuoteModel *model = self.dataSource[indexPath.row];
    [cell bindModel:model index:indexPath.row];
//    [cell bindModel:model showAnim:![_didAnimSymbols containsObject:model.symbol]];
//    cell.changeAnimState = ^(HomeQuoteModel *model) {
//        [self.didAnimSymbols addObject:model.symbol];
//    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeQuoteModel *model = self.dataSource[indexPath.row];
    if (self.index == 2) {
        [self putValueToParamDictionary:CoinTradeDic value:model.symbol forKey:@"CoinQuotationsDetailSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:model.marketType forKey:@"CoinQuotationDetailMarketType"];
        [self pageToViewControllerForName:@"TYQuotationsDetailController"];
    }else{
        [self putValueToParamDictionary:CoinTradeDic value:model.symbol forKey:@"CoinQuotationsDetailSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:model.marketType forKey:@"CoinQuotationDetailMarketType"];
        [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
    }
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _headerView.backgroundColor = UIColorMakeWithHex(@"#ffffff");
        
        QMUIButton *nameBtn = [[QMUIButton alloc] init];
        [nameBtn setTitle:NSLocalizedStringForKey(@"名称") forState:0];
        [nameBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        [nameBtn setImage:UIImageMake(@"home_quotations_button_sort_up") forState:0];
        [nameBtn setImage:UIImageMake(@"home_quotations_button_sort_down") forState:UIControlStateSelected];
        nameBtn.titleLabel.font = UIFontMake(13);
        nameBtn.imagePosition = QMUIButtonImagePositionRight;
        nameBtn.spacingBetweenImageAndTitle = 4;
        nameBtn.tag = 1;
        [nameBtn addTarget:self action:@selector(sortBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:nameBtn];
        [nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.centerY.mas_equalTo(self.headerView);
        }];
        
        QMUIButton *priceBtn = [[QMUIButton alloc] init];
        [priceBtn setTitle:NSLocalizedStringForKey(@"最新价") forState:0];
        [priceBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        [priceBtn setImage:UIImageMake(@"home_quotations_button_sort_up") forState:0];
        [priceBtn setImage:UIImageMake(@"home_quotations_button_sort_down") forState:UIControlStateSelected];
        priceBtn.titleLabel.font = UIFontMake(13);
        priceBtn.imagePosition = QMUIButtonImagePositionRight;
        priceBtn.spacingBetweenImageAndTitle = 5;
        priceBtn.tag = 2;
        [priceBtn addTarget:self action:@selector(sortBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:priceBtn];
        [priceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView);
            make.centerX.mas_equalTo(self.headerView.mas_centerX).offset(-15);
        }];
        
        QMUIButton *rateBtn = [[QMUIButton alloc] init];
        [rateBtn setTitle:NSLocalizedStringForKey(@"涨跌幅") forState:0];
        [rateBtn setTitleColor:UIColorMakeWithHex(@"#999999") forState:0];
        [rateBtn setImage:UIImageMake(@"home_quotations_button_sort_up") forState:0];
        [rateBtn setImage:UIImageMake(@"home_quotations_button_sort_down") forState:UIControlStateSelected];
        rateBtn.titleLabel.font = UIFontMake(13);
        rateBtn.imagePosition = QMUIButtonImagePositionRight;
        rateBtn.spacingBetweenImageAndTitle = 5;
        rateBtn.tag = 3;
        [rateBtn addTarget:self action:@selector(sortBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:rateBtn];
        [rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-25);
            make.centerY.mas_equalTo(self.headerView);
        }];
    }
    return _headerView;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

@end
