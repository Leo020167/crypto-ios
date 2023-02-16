//
//  TYMineCommunityBuyCodeViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/2.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineCommunityBuyCodeViewController.h"

@interface TYMineCommunityBuyCodeViewController ()<UITableViewDelegate, UITableViewDataSource, QMUITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) QMUITextField *textField;

@property (nonatomic, strong) UILabel *expendLabel;

@end

@implementation TYMineCommunityBuyCodeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.expendLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"可兑换数量:%@"), self.inviteCodePrice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
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
    titleLabel.text = NSLocalizedStringForKey(@"兑换邀请码");
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

- (void)sureBtnAction{
    if (!self.textField.text.length) {
        [QMUITips showError:NSLocalizedStringForKey(@"请输入购买数量")];
        return;
    }
    [YYRequestUtility Post:@"/invite/buy.do" addParameters:@{@"count" : self.textField.text} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            if (self.reloadDataBlock) {
                self.reloadDataBlock();
            }
            [self showAction:1 msg:NSLocalizedStringForKey(@"购买成功")];
        }else{
            [self showAction:2 msg:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

/// 1成功 2失败
- (void)showAction:(NSInteger)type msg:(NSString *)msg{
    [self.view endEditing:YES];
    QMUIModalPresentationViewController *modalViewController = [[QMUIModalPresentationViewController alloc] init];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 267, 175)];
    contentView.backgroundColor = UIColor.whiteColor;
    contentView.layer.cornerRadius = 5;
    
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = type == 1 ? UIImageMake(@"mine_invite_buy_success") : UIImageMake(@"mine_invite_buy_fail");
    [contentView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(42);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = UIColorMakeWithHex(@"#7E7E7E");
    titleLabel.font = UIFontMake(16);
    titleLabel.text = msg;
    [contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView);
        make.top.mas_equalTo(logoImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setTitle:NSLocalizedStringForKey(@"我知道了") forState:0];
    [sureBtn setTitleColor:UIColor.whiteColor forState:0];
    sureBtn.titleLabel.font = UIFontMake(15);
    sureBtn.backgroundColor = UIColorMakeWithHex(@"#C0C0C0");
    sureBtn.layer.cornerRadius = 13;
    sureBtn.layer.masksToBounds = YES;
    sureBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [modalViewController hideWithAnimated:YES completion:nil];
    };
    [contentView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(100, 26));
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(17);
    }];
    modalViewController.contentView = contentView;
    [modalViewController showWithAnimated:YES completion:nil];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (text.length) {
//        self.expendLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"可兑换数量:%@"), [NSString stringWithFormat:@"%.2f", self.inviteCodePrice * text.floatValue]];
//    }else{
//        self.expendLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"可兑换数量:%@"), @"0"];
//    }
//    return YES;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        [_headerView addSubview:self.textField];
        [_headerView addSubview:self.expendLabel];
        [self.expendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-37);
            make.top.mas_equalTo(self.textField.mas_bottom).offset(12);
        }];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        [cancelBtn setTitle:NSLocalizedStringForKey(@"取消") forState:0];
        [cancelBtn setTitleColor:UIColor.whiteColor forState:0];
        cancelBtn.titleLabel.font = UIFontMake(17);
        cancelBtn.layer.cornerRadius = 19;
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.backgroundColor = UIColorMakeWithHex(@"#C0C0C0");
        cancelBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [_headerView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.textField);
            make.size.mas_equalTo(CGSizeMake(136, 38));
            make.top.mas_equalTo(self.textField.mas_bottom).offset(84);
        }];
        
        UIButton *sureBtn = [[UIButton alloc] init];
        [sureBtn setTitle:NSLocalizedStringForKey(@"确定") forState:0];
        [sureBtn setTitleColor:UIColor.whiteColor forState:0];
        sureBtn.titleLabel.font = UIFontMake(17);
        sureBtn.layer.cornerRadius = 19;
        sureBtn.layer.masksToBounds = YES;
        sureBtn.backgroundColor = UIColorMakeWithHex(@"#4D4CE6");
        [sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.textField);
            make.size.mas_equalTo(CGSizeMake(136, 38));
            make.top.mas_equalTo(self.textField.mas_bottom).offset(84);
        }];
    }
    return _headerView;
}

- (QMUITextField *)textField{
    if (!_textField) {
        _textField = [[QMUITextField alloc] initWithFrame:CGRectMake(32, 50, SCREEN_WIDTH - 64, 40)];
        _textField.placeholder = NSLocalizedStringForKey(@"请输入兑换数量");
        _textField.font = UIFontMake(15);
        _textField.textColor = UIColorMakeWithHex(@"#333333");
        _textField.textInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        _textField.layer.borderColor = UIColorMakeWithHex(@"#E2E2E2").CGColor;
        _textField.layer.borderWidth = 1;
        _textField.layer.cornerRadius = 5;
        _textField.layer.masksToBounds = YES;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.delegate = self;
    }
    return _textField;
}

- (UILabel *)expendLabel{
    if (!_expendLabel) {
        _expendLabel = [[UILabel alloc] init];
        _expendLabel.font = UIFontMake(13);
        _expendLabel.textColor = UIColorMakeWithHex(@"#666666");
        _expendLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"可兑换数量:%@"), @"0"];
    }
    return _expendLabel;
}


@end
