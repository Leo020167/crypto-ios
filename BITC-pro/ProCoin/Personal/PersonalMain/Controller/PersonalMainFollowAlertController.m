//
//  PersonalMainFollowAlertController.m
//  YuanLeLing
//
//  Created by 李祥翔 on 2021/12/27.
//

#import "PersonalMainFollowAlertController.h"
#import "TYWkWebView.h"

@interface PersonalMainFollowAlertController ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) TYWkWebView *webView;

@end

@implementation PersonalMainFollowAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 300));
    }];
}

- (void)sureBtnAction{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.sureBtnActionBlock) {
            self.sureBtnActionBlock();
        }
    }];
}

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColor.whiteColor;
        
        [_bgView addSubview:self.titleLabel];
        [_bgView addSubview:self.sureBtn];
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = UIColorMakeWithHex(@"#999999");
        [_bgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
            make.bottom.mas_equalTo(-50);
        }];
        
        self.webView = [[TYWkWebView alloc] init];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:RiskWarningURL]]];
        
        [_bgView addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(50);
            make.bottom.mas_equalTo(-51);
        }];
    }
    return _bgView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 100, 40)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = NSLocalizedStringForKey(@"风险提示书");
        _titleLabel.font = UIFontMake(15);
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.backgroundColor = UIColor.redColor;
    }
    return _titleLabel;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [[UIButton alloc] init];
        [_sureBtn setTitle:NSLocalizedStringForKey(@"我已阅读并同意") forState:0];
        [_sureBtn setTitleColor:UIColor.redColor forState:0];
        _sureBtn.titleLabel.font = UIFontMake(15);
        [_sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}


@end
