//
//  HomeAccountCheckViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/31.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeAccountCheckViewController.h"
#import "PuzzleVerifyView.h"
#import "TJRUser.h"

@interface HomeAccountCheckViewController ()<PuzzleVerifyViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *submitBtn;

@property (retain, nonatomic) PuzzleVerifyView *puzzleVerifyView;

@property (copy, nonatomic) NSString *dragImgKey;

@property (assign, nonatomic) NSInteger locationx;

@property (nonatomic, strong) TJRUser *user;

@property (nonatomic, assign) BOOL isCheck;

@end

@implementation HomeAccountCheckViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_puzzleVerifyView show:self.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
    
    [self getData];
}

- (void)setNav{
    self.isCheck = NO;
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
    titleLabel.text = NSLocalizedStringForKey(@"验证");
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
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descLabel];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.submitBtn];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(25 + kUINormalNavBarHeight);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(55 + kUINormalNavBarHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 100, 40));
    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 100, 50));
    }];
    
    _puzzleVerifyView = [[PuzzleVerifyView alloc]initWithFrame:phoneRectScreen];
    _puzzleVerifyView.delegate = self;
    [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"完成验证获取验证码")];
    
}

- (void)getData{
    [YYRequestUtility Post:@"user/info.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            TJRUser *user = [TJRUser yy_modelWithDictionary:responseDict[@"data"]];
            self.user = user;
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - PuzzleVerifyView Delegate Methods
- (void)puzzleVerifyView:(PuzzleVerifyView*)puzzleVerifyView dragImgKey:(NSString*)dragImgKey puzzleOriginX:(CGFloat)puzzleOriginX{
    if (puzzleOriginX > 0) {
        self.dragImgKey = dragImgKey;
        self.locationx = puzzleOriginX;
        if (self.isCheck) {
            [self submitBtnAction];
        }else{
            [self requestCodeData];
        }
    }
}

- (void)requestCodeData{
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setObject:self.dragImgKey forKey:@"dragImgKey"];
    [para setObject:[NSString stringWithFormat:@"%@", @(self.locationx)] forKey:@"locationx"];
    if (self.user.phone.length) {
        [para setObject:self.user.phone forKey:@"sendAddr"];
        [para setObject:@"1" forKey:@"type"];
        [para setObject:self.user.countryCode forKey:@"countryCode"];
        
    }else{
        [para setObject:self.user.email forKey:@"sendAddr"];
        [para setObject:@"2" forKey:@"type"];
    }
    [YYRequestUtility Post:@"sms/get.do" addParameters:para progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.descLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"验证码已发送至，%@"), self.user.phone.length ? self.user.phone : self.user.email];
        }else if ([responseDict[@"code"] intValue] == 40016){
            // 重新验证拖动图片
            [_puzzleVerifyView show:self.view];
            [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)submitBtnAction{
    [self.view endEditing:YES];
    if (!self.textField.text.length) {
        [QMUITips showError:NSLocalizedStringForKey(@"请输入验证码")];
        return;
    }
    if (!self.isCheck) {
        self.isCheck = YES;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
        return;
    }
    NSString *urlStr = @"user/security/checkIdentity.do";
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    
    if (self.user.phone.length) {
        [para setObject:self.dragImgKey forKey:@"dragImgKey"];
        [para setObject:[NSString stringWithFormat:@"%@", @(self.locationx)] forKey:@"locationx"];
        [para setObject:self.user.phone forKey:@"phone"];
        [para setObject:self.textField.text forKey:@"smsCode"];
    }else{
        urlStr = @"user/security/checkEmailCode.do";
        [para setObject:self.user.email forKey:@"email"];
        [para setObject:self.textField.text forKey:@"code"];
    }
    [YYRequestUtility Post:urlStr addParameters:para progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            if (self.checkDataBlock) {
                self.checkDataBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([responseDict[@"code"] intValue] == 40016){
            // 重新验证拖动图片
            [_puzzleVerifyView show:self.view];
            [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedStringForKey(@"为了您的账号安全，请验证身份");
        _titleLabel.textColor = UIColorMakeWithHex(@"#333333");
        _titleLabel.font = UIFontMake(15);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = UIColorMakeWithHex(@"#999999");
        _descLabel.font = UIFontMake(12);
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = UIColorMakeWithHex(@"#666666");
        _textField.layer.cornerRadius = 5;
        _textField.layer.masksToBounds = YES;
        _textField.placeholder = NSLocalizedStringForKey(@"请输入验证码");
        _textField.layer.borderColor = UIColorMakeWithHex(@"#999999").CGColor;
        _textField.layer.borderWidth = 1;
        _textField.font = UIFontMake(15);
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 40)];
        _textField.leftView = leftView;
    }
    return _textField;
}

- (UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] init];
        [_submitBtn setTitle:NSLocalizedStringForKey(@"验证") forState:0];
        [_submitBtn setTitleColor:UIColor.whiteColor forState:0];
        _submitBtn.titleLabel.font = UIFontMake(15);
        _submitBtn.backgroundColor = UIColor.orangeColor;
        _submitBtn.layer.cornerRadius = 25;
        _submitBtn.layer.masksToBounds = YES;
        [_submitBtn addTarget:self action:@selector(submitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}


@end
