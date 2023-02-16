//
//  MineDelegateViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/24.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "MineDelegateViewController.h"

@interface MineDelegateViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;

/// 金额
@property (nonatomic, copy) NSString *agentFee;

@property (nonatomic, strong) UIButton *applyBtn;

@end

@implementation MineDelegateViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.status == 1) {
        [_applyBtn setTitle:NSLocalizedStringForKey(@"审核中") forState:0];
        _applyBtn.backgroundColor = UIColorMakeWithHex(@"#999999");
        _applyBtn.enabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 50)];
    [self.view addSubview:self.logoImageView];
    
    [self.view addSubview:self.applyBtn];
    [self.applyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    
    self.agentFee = @"0";
    
    [self setNav];
    
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
    titleLabel.text = NSLocalizedStringForKey(@"代理");
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

- (void)getData{
    [YYRequestUtility Post:@"agent/config.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            self.agentFee = responseDict[@"data"][@"agentFee"];
            NSArray *banner = responseDict[@"data"][@"banner"];
            if (banner.count) {
                NSDictionary *bannerDict = banner.firstObject;
                [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:bannerDict[@"imageUrl"]]];
            }
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        NSLog(@"error : %@", error);
    }];
}

- (void)applyBtnAction{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"支付代理费") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"代理费用为%@USDT"), self.agentFee] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        [YYRequestUtility Post:@"agent/apply.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
            NSLog(@"responseDict : %@", responseDict);
            if ([responseDict[@"code"] intValue] == 200) {
                [QMUITips showSucceed:responseDict[@"msg"]];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [QMUITips showError:responseDict[@"msg"]];
            }
        } failure:^(NSError *error) {
            NSLog(@"error : %@", error);
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIButton *)applyBtn{
    if (!_applyBtn) {
        _applyBtn = [[UIButton alloc] init];
        [_applyBtn setTitle:NSLocalizedStringForKey(@"申请成为代理") forState:0];
        [_applyBtn setTitleColor:UIColor.whiteColor forState:0];
        _applyBtn.titleLabel.font = UIFontMake(15);
        _applyBtn.backgroundColor = UIColorMakeWithHex(@"#4B5FA3");
        [_applyBtn addTarget:self action:@selector(applyBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyBtn;
}

@end
