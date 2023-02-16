//
//  MineDelegateInfoViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/28.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "MineDelegateInfoViewController.h"
#import "MineDelegateInfoHeaderView.h"
#import "MineDelegateInfoCell.h"
#import "MineDelegateLevelInfoCell.h"

@interface MineDelegateInfoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MineDelegateInfoHeaderView *headerView;

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) MineDelegateInfoModel *model;

@end

@implementation MineDelegateInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
    
    [self getMainData];
}

- (void)setNav{
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
    titleLabel.text = NSLocalizedStringForKey(@"我的佣金");
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *rulesBtn = [[UIButton alloc] init];
    [rulesBtn setTitle:NSLocalizedStringForKey(@"代理规则") forState:0];
    [rulesBtn setTitleColor:UIColor.blueColor forState:0];
    rulesBtn.titleLabel.font = UIFontMake(15);
    [navView addSubview:rulesBtn];
    rulesBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        TYWebViewController *web = [[TYWebViewController alloc] init];
        web.url = DelegateRules;
        [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
    };
    [rulesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(44);
    }];
}

- (void)initUI{
    [self.view addSubview:self.tableView];
}

- (void)getMainData{
    [YYRequestUtility Post:@"agent/info.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            self.model = [MineDelegateInfoModel yy_modelWithDictionary:responseDict[@"data"][@"agent"]];
            self.model.upgradeFlag = [responseDict[@"data"][@"upgradeFlag"] boolValue];
            self.headerView.model = self.model;
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        NSLog(@"error : %@", error);
    }];
}

- (void)upgradeBtnAction{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"您是否需要花费%@USDT购买%@"), self.model.upgradeAmout, self.model.upgradeName] message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        [YYRequestUtility Post:@"agent/upgradeLevel.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
            NSLog(@"responseDict : %@", responseDict);
            if ([responseDict[@"code"] intValue] == 200) {
                [QMUITips showSucceed:responseDict[@"msg"]];
                [self getMainData];
            }else{
                [QMUITips showError:responseDict[@"msg"]];
            }
        } failure:^(NSError *error) {
            NSLog(@"error : %@", error);
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        MineDelegateLevelInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MineDelegateLevelInfoCell class]) forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }
    MineDelegateInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MineDelegateInfoCell class]) forIndexPath:indexPath];
    cell.model = self.model;
    cell.indexPath = indexPath;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[MineDelegateInfoCell class] forCellReuseIdentifier:NSStringFromClass([MineDelegateInfoCell class])];
        [_tableView registerClass:[MineDelegateLevelInfoCell class] forCellReuseIdentifier:NSStringFromClass([MineDelegateLevelInfoCell class])];
    }
    return _tableView;
}

- (MineDelegateInfoHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[MineDelegateInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
        _headerView.upgradeBtnActionBlock = ^{
            [self upgradeBtnAction];
        };
    }
    return _headerView;
}

@end
