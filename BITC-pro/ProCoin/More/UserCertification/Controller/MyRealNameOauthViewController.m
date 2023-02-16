//
//  MyRealNameOauthViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2021/12/22.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "MyRealNameOauthViewController.h"
#import "MyRealNameOauthCell.h"
#import "VeDateUtil.h"

@interface MyRealNameOauthViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, copy) NSString *certNo;

@end

@implementation MyRealNameOauthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self setNav];
    
    [self getData];
}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColorMakeWithHex(@"#1677FF");
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
    [backBtn setImage:UIImageMake(@"btn_back_white") forState:0];
    backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedStringForKey(@"实名认证中心");
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
    [self.view addSubview:self.tableView];
}

- (void)getData{
    [YYRequestUtility Post:@"identity/get.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
//        state  0：审核中，1：已通过，2：未通过
        if ([responseDict[@"code"] intValue] == 200) {
            self.name = responseDict[@"data"][@"identityAuth"][@"name"];
            self.certNo = responseDict[@"data"][@"identityAuth"][@"certNo"];
            self.createTime = responseDict[@"data"][@"identityAuth"][@"createTime"];
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyRealNameOauthCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyRealNameOauthCell class]) forIndexPath:indexPath];
    cell.descLabel.textColor = UIColorMakeWithHex(@"#999999");
    if (indexPath.row == 0) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"真实姓名");
        cell.descLabel.text = self.name ?: @"";
    }else if (indexPath.row == 1) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"证件号");
        cell.descLabel.text = self.certNo ?: @"";
    }else if (indexPath.row == 2) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"认证状态");
        cell.descLabel.text = NSLocalizedStringForKey(@"已实名认证");
        cell.descLabel.textColor = UIColorMakeWithHex(@"#0CC741");
    }else if (indexPath.row == 3) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"认证日期");
        cell.descLabel.text = self.createTime ? [VeDateUtil formatterDate:self.createTime inStytle:@"" outStytle:@"yyyy-MM-dd" isTimestamp:YES] : @"";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -kUIStatusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT + kUIStatusBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[MyRealNameOauthCell class] forCellReuseIdentifier:NSStringFromClass([MyRealNameOauthCell class])];

    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 305)];
        _headerView.backgroundColor = UIColorMakeWithHex(@"#1677FF");
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = NSLocalizedStringForKey(@"您已通过实名认证");
        titleLabel.font = UIFontMake(18);
        titleLabel.textColor = UIColor.whiteColor;
        [_headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.headerView);
            make.bottom.mas_equalTo(-44);
        }];
//        myoauth_success_icon_bg
        UIImageView *bgImageView = [[UIImageView alloc] init];
        bgImageView.image = UIImageMake(@"myoauth_success_icon_bg");
        [_headerView addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.headerView);
            make.size.mas_equalTo(CGSizeMake(130, 106));
            make.bottom.mas_equalTo(-90);
        }];
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [iconImageView sd_setImageWithURL:[NSURL URLWithString:ROOTCONTROLLER_USER.headurl]];
        iconImageView.layer.cornerRadius = 44.5;
        iconImageView.layer.masksToBounds = YES;
        [bgImageView addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(bgImageView);
            make.size.mas_equalTo(89);
        }];
    }
    return _headerView;
}

@end
