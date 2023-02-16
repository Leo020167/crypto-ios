//
//  HomeNewPurchaseDetailViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/23.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeNewPurchaseDetailViewController.h"
#import "HomeNewPurchaseDetailContentCell.h"
#import "HomeNewPurchaseDetailDemandCell.h"
#import "HomeNewPurchaseDetailTopCell.h"

@interface HomeNewPurchaseDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSTimer *limitTimer;

@property (nonatomic, strong) HomeNewPurchaseModel *model;

@property (nonatomic, strong) QMUITextField *textField;

@end

@implementation HomeNewPurchaseDetailViewController

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
    
    [self setNav];
    
    [self initUI];
    
    [self getData];
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
    titleLabel.text = NSLocalizedStringForKey(@"新币申购");
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

- (void)getData{
    [YYRequestUtility Post:@"subscribe/getDetail.do" addParameters:@{@"id" : self.id} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            HomeNewPurchaseModel *model = [HomeNewPurchaseModel yy_modelWithDictionary:responseDict[@"data"][@"detail"]];
            self.model = model;
            [self.tableView reloadData];
            if (!self.limitTimer && model.state != 2) {
                self.limitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshCloseTimeAction) userInfo:nil repeats:YES];
            }
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)refreshCloseTimeAction{
    NSDate* date = [NSDate date];
    NSString *timeString = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    
    [self lessSecondToDay:self.model.endTime.integerValue - timeString.integerValue];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
    }];
}

- (void)lessSecondToDay:(NSInteger)seconds{
    NSUInteger day = (NSUInteger)(seconds / 3600 / 24);
    NSUInteger hour = (NSUInteger)(seconds%(24*3600))/3600;
    NSUInteger min  = (NSUInteger)(seconds%(3600))/60;
    NSUInteger second = (NSUInteger)(seconds%60);
    NSString *title = @"";
    if (seconds <= 0) {
        [self getData];
    }
    if (day > 0) {
        title = [NSString stringWithFormat:@"%lu天%02lu:%02lu:%02lu", (unsigned long)day, (unsigned long)hour, (unsigned long)min, (unsigned long)second];
    }else{
        title = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)hour, (unsigned long)min, (unsigned long)second];
    }
    self.model.timeStr = title;
    [self.tableView reloadData];
}

- (void)allBtnAction{
    [YYRequestUtility Post:@"/subscribe/allIn.do" addParameters:@{@"subscribeId" : self.id} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.textField.text = responseDict[@"data"][@"maxCount"];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)joinBtnAction{
    QMUIModalPresentationViewController *modalViewController = [[QMUIModalPresentationViewController alloc] init];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 75, 150)];
    contentView.backgroundColor = UIColor.whiteColor;
    contentView.layer.cornerRadius = 6;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedStringForKey(@"请输入申购数量");
    titleLabel.textColor = UIColorMakeWithHex(@"#333333");
    titleLabel.font = UIFontMake(16);
    [contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    QMUITextField *textField = [[QMUITextField alloc] init];
    self.textField = textField;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.placeholder = NSLocalizedStringForKey(@"请输入申购数量");
    textField.font = UIFontMake(15);
    textField.textColor = UIColorMakeWithHex(@"#333333");
    textField.textInsets = UIEdgeInsetsMake(0, 20, 0, 60);
    textField.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
    textField.layer.cornerRadius = 5;
    textField.layer.masksToBounds = YES;
    [contentView addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(40);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *allBtn = [[UIButton alloc] init];
    [allBtn setTitle:NSLocalizedStringForKey(@"全部申购") forState:0];
    [allBtn setTitleColor:UIColorMakeWithHex(@"2B4166") forState:0];
    allBtn.titleLabel.font = UIFontMake(13);
    [allBtn addTarget:self action:@selector(allBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [textField addSubview:allBtn];
    [allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(textField);
        make.width.mas_equalTo(60);
    }];
    
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setTitle:NSLocalizedStringForKey(@"确定") forState:0];
    [sureBtn setTitleColor:UIColorMakeWithHex(@"2B4166") forState:0];
    sureBtn.titleLabel.font = UIFontMake(15);
    sureBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self sureBtnAction:modalViewController];
    };
    [contentView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(textField.mas_bottom).offset(20);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:NSLocalizedStringForKey(@"取消") forState:0];
    [cancelBtn setTitleColor:UIColorMakeWithHex(@"2B4166") forState:0];
    cancelBtn.titleLabel.font = UIFontMake(15);
    cancelBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [modalViewController hideWithAnimated:YES completion:nil];
    };
    [contentView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(textField.mas_bottom).offset(20);
    }];
    modalViewController.contentView = contentView;
    [modalViewController showWithAnimated:YES completion:nil];
}

- (void)sureBtnAction:(QMUIModalPresentationViewController *)modalViewController{
    if (self.textField.text.length < 0) {
        [QMUITips showError:NSLocalizedStringForKey(@"请输入申购数量") inView:modalViewController.contentView];
        return;
    }
    if (self.textField.text.intValue < self.model.min.intValue) {
        [QMUITips showError:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringForKey(@"最低限购"), self.model.min] inView:modalViewController.contentView];
        return;
    }
    [YYRequestUtility Post:@"subscribe/apply.do" addParameters:@{@"subscribeId" : self.id, @"count" : self.textField.text} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [QMUITips showSucceed:responseDict[@"msg"]];
            [modalViewController hideWithAnimated:YES completion:nil];
        }else{
            [QMUITips showError:responseDict[@"msg"] inView:modalViewController.contentView];
        }
    } failure:^(NSError *error) {
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        return 12;
    }
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        HomeNewPurchaseDetailTopCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeNewPurchaseDetailTopCell class]) forIndexPath:indexPath];
        cell.model = self.model;
        cell.buyBtnActionBlock = ^{
            [self joinBtnAction];
        };
        return cell;
    }else if (indexPath.section == 1) {
        HomeNewPurchaseDetailContentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeNewPurchaseDetailContentCell class]) forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"本轮可申购总量");
            cell.descLabel.text = self.model.sum;
        }else if (indexPath.row == 1) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"本轮已申购");
            cell.descLabel.text = self.model.alCount;
        }else if (indexPath.row == 2) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"本轮剩余申购量");
            cell.descLabel.text = [NSString stringWithFormat:@"%d", self.model.sum.intValue - self.model.alCount.intValue];
        }else if (indexPath.row == 3) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"距离本轮申购结束还剩");
            cell.descLabel.text = self.model.timeStr;
        }else if (indexPath.row == 4) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"申购总量");
            cell.descLabel.text = self.model.allSum;
        }else if (indexPath.row == 5) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"本轮开始申购时间");
            cell.descLabel.text = [NSString stringWithFormat:@"%@(%@)", [VeDateUtil formatterDate:self.model.startTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES], NSLocalizedStringForKey(@"香港时间")];
        }else if (indexPath.row == 6) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"本轮结束申购时间");
            cell.descLabel.text = [NSString stringWithFormat:@"%@(%@)", [VeDateUtil formatterDate:self.model.endTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES], NSLocalizedStringForKey(@"香港时间")];
        }else if (indexPath.row == 7) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"上市交易时间");
            cell.descLabel.text = [NSString stringWithFormat:@"%@(%@)", [VeDateUtil formatterDate:self.model.tradeTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES], NSLocalizedStringForKey(@"香港时间")];
        }else if (indexPath.row == 8) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"上市解仓时间");
            cell.descLabel.text = [NSString stringWithFormat:@"%@(%@)", [VeDateUtil formatterDate:self.model.liftBanTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES], NSLocalizedStringForKey(@"香港时间")];
        }else if (indexPath.row == 9) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"申购价格");
            cell.descLabel.text = [NSString stringWithFormat:@"%@USDT", self.model.rate];
        }else if (indexPath.row == 10) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"我已申购");
            cell.descLabel.text = self.model.userCount;
        }else if (indexPath.row == 11) {
            cell.titleLabel.text = NSLocalizedStringForKey(@"最小申购量");
            cell.descLabel.text = self.model.min;
        }
        return cell;
    }
    HomeNewPurchaseDetailDemandCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeNewPurchaseDetailDemandCell class]) forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.htmlContent = self.model.authorSummary;
        cell.titleLabel.text = NSLocalizedStringForKey(@"发起成员");
    }else if (indexPath.row == 1) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"项目介绍");
        cell.htmlContent = self.model.summary;
    }else if (indexPath.row == 2) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"币种介绍");
        cell.htmlContent = self.model.content;
    }else if (indexPath.row == 3) {
        cell.htmlContent = self.model.condition;
        cell.titleLabel.text = NSLocalizedStringForKey(@"项目参与条件");
    }else if (indexPath.row == 4) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"风险提示");
        cell.htmlContent = self.model.warning;
    }else if (indexPath.row == 5) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"申购说明");
        cell.htmlContent = self.model.desc;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && self.model.state == 1) {
        [self joinBtnAction];
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedRowHeight = 200;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[HomeNewPurchaseDetailTopCell class] forCellReuseIdentifier:NSStringFromClass([HomeNewPurchaseDetailTopCell class])];
        [_tableView registerClass:[HomeNewPurchaseDetailContentCell class] forCellReuseIdentifier:NSStringFromClass([HomeNewPurchaseDetailContentCell class])];
        [_tableView registerClass:[HomeNewPurchaseDetailDemandCell class] forCellReuseIdentifier:NSStringFromClass([HomeNewPurchaseDetailDemandCell class])];
    }
    return _tableView;
}
@end
