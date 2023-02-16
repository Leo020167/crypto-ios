//
//  TYMineTransactionDetailViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/4/8.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineTransactionDetailViewController.h"
#import "TYMineTransactionDetailDefaultCell.h"
#import "VeDateUtil.h"

@interface TYMineTransactionDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *symbolLabel;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation TYMineTransactionDetailViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.symbolLabel.text = self.model.symbol;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
}

- (void)setNav{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColor.whiteColor;

    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
    [backBtn setImage:UIImageMake(@"btn_back_black") forState:0];
    backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    [navView addSubview:backBtn];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedStringForKey(@"交易详情");
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
}

- (void)initUI{
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TYMineTransactionDetailDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMineTransactionDetailDefaultCell class]) forIndexPath:indexPath];
    cell.settingBtn.hidden = YES;
    cell.descBtn.hidden = YES;
    cell.descLabel.hidden = NO;
    cell.descLabel.textColor = UIColorMakeWithHex(@"#000000");
    if (indexPath.row == 0) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"盈亏");
        cell.descLabel.text = self.model.profit;
        cell.descLabel.textColor = [TradeUtil textColorWithQuotationNumber:self.model.profit.doubleValue];
    }else if (indexPath.row == 1) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"成本");
        cell.descLabel.text = self.model.originPrice;
    }else if (indexPath.row == 2) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"卖出价格");
        cell.descLabel.text = self.model.price;
    }else if (indexPath.row == 3) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"卖出数量");
        cell.descLabel.text = self.model.amount;
    }else if (indexPath.row == 4) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"手续费");
        cell.descLabel.text = self.model.fee;
    }else if (indexPath.row == 5) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"时间");
        cell.descLabel.text = [VeDateUtil formatterDate:self.model.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYMineTransactionDetailDefaultCell class] forCellReuseIdentifier:NSStringFromClass([TYMineTransactionDetailDefaultCell class])];
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        
        UILabel *symbolLabel = [[UILabel alloc] init];
        symbolLabel.textColor = UIColor.blackColor;
        symbolLabel.font = UIFontBoldMake(17);
        self.symbolLabel = symbolLabel;
        [_headerView addSubview:symbolLabel];
        [symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.headerView);
        }];
    }
    return _headerView;
}

@end
