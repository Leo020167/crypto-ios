//
//  LoginViewController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "LoginViewController.h"
#import <Accelerate/Accelerate.h>
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "RAJudgement.h"
#import "LoginSQLModel.h"
#import "LoginBase.h"
#import "PuzzleVerifyView.h"

#define kUpOfHeight 40

@interface LoginViewController ()<RAJudgementDelegate,LoginBaseDelegate,PuzzleVerifyViewDelegate>
{
    TextFieldToolBar *toolBar;
    RAJudgement *judgeMent;
    NSTimeInterval animationDuration;

    LoginBase *loginBase;
    NSString* RegisterType;
    
    BOOL bNeedCode;
    BOOL bAutoLogin;
}
@property (retain, nonatomic) IBOutlet UIScrollView *bgScrollView;

@property (retain, nonatomic) IBOutlet UITextField *accountTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField; // 密码/验证码
@property (retain, nonatomic) IBOutlet UIButton *forgetButton;
@property (retain, nonatomic) IBOutlet UIButton *loginBtn;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (retain, nonatomic) IBOutlet UILabel *indicatorLabel;
@property (retain, nonatomic) IBOutlet UIButton *regBtn;
@property (retain, nonatomic) IBOutlet UIView *loginView;
@property (retain, nonatomic) IBOutlet UIView *codeView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutCodeViewHeight;
@property (retain, nonatomic) IBOutlet UITextField *codeTextField;
@property (retain, nonatomic) IBOutlet UIButton *btnSecurityCode;
@property (retain, nonatomic) IBOutlet UILabel *lbWelcomeTips;
@property (retain, nonatomic) IBOutlet UILabel *lbLoginTips;

@property (retain, nonatomic) PuzzleVerifyView *puzzleVerifyView;
@property (copy, nonatomic) NSString *dragImgKey;
@property (assign, nonatomic) NSInteger locationx;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canDragBack = NO;
    
    [UIApplication sharedApplication].statusBarHidden = NO;    // 显示状态栏
    loginBase = [[LoginBase alloc] init];
    loginBase.lbDelegate = self;
    
    judgeMent = [[RAJudgement alloc]init];
    judgeMent.raDelegate = self;
    
    UIColor *color = RGBA(102, 102, 102, 1.0);
    [CommonUtil setUITextFieldPlaceholderColor:_accountTextField color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_passwordTextField color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_codeTextField color:color];
    
    if ([loginBase getUserLoginInfoFromSQL] && [[self getRootController].user.type isEqualToString:LoginAccountTypePhone]) {
        _accountTextField.text = [self getRootController].user.userAccount;
        _passwordTextField.text = [self getRootController].user.password;
        _loginBtn.enabled = YES;
    }
    
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:2];
    _accountTextField.inputAccessoryView = toolBar;
    _passwordTextField.inputAccessoryView = toolBar;
    
    _layoutCodeViewHeight.constant = 0;
    _codeTextField.enabled = NO;
    
    _puzzleVerifyView = [[PuzzleVerifyView alloc]initWithFrame:phoneRectScreen];
    _puzzleVerifyView.delegate = self;
    [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
    
    self.dragImgKey = @"";
    
    _lbLoginTips.text = NSLocalizedStringForKey(@"登录");
    [_regBtn setTitle:NSLocalizedStringForKey(@"注册") forState:UIControlStateNormal];
  //  _accountTextField.placeholder = NSLocalizedStringForKey(@"请输入手机号码");
    _accountTextField.placeholder = NSLocalizedStringForKey(@"邮箱或手机");
    _passwordTextField.placeholder = NSLocalizedStringForKey(@"请输入密码");
    [_forgetButton setTitle:NSLocalizedStringForKey(@"忘记密码? 找回密码") forState:UIControlStateNormal];
    [_loginBtn setTitle:NSLocalizedStringForKey(@"登录") forState:UIControlStateNormal];
    
#ifdef DEBUG
    _accountTextField.text = @"2036";
    _passwordTextField.text  = @"123456";
#else
    
#endif
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    _indicatorLabel.text = @"";
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    TT_RELEASE_SAFELY(toolBar);
    TT_RELEASE_SAFELY(loginBase);
    [self setIndicator:nil];
    [self setIndicatorLabel:nil];
    [self setLoginBtn:nil];
    [super viewDidUnload];
}

#pragma mark - 按钮点击事件
// 注册
- (IBAction)registerButtonPressed:(id)sender{
    RegisterType = LoginAccountTypePhone;
    [self pageToViewControllerForName:@"RAPhoneRegister"];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self goBackWithAnimated:NO];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [_accountTextField becomeFirstResponder];
            break;
        case 2:
            [_passwordTextField becomeFirstResponder];
            break;
        case 3:
            [_codeTextField becomeFirstResponder];
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSUInteger tag = [textField tag];
    [self animateView:tag];
    [toolBar checkBarButton:tag];
}

- (void)animateView:(NSUInteger)tag{
    
    float distance = 0;
    switch (tag) {
        case 1:
        case 2:
            distance = 1.6 * kUpOfHeight;
            break;
        case 3:
            distance = 3.0 * kUpOfHeight;
            break;
            
    }
    [_bgScrollView setContentOffset:CGPointMake(0.0, distance) animated:YES];
}

#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag{
}
- (void)TFDonePressed{
    [self backgroundViewTouch:nil];
    
}
// 背景触摸
- (IBAction)backgroundViewTouch:(id)sender {
    [_accountTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_codeTextField resignFirstResponder];
    [_bgScrollView setContentOffset:CGPointZero animated:YES];
}

// 忘记密码按钮
- (IBAction)forgotPasswordPressed:(id)sender {
    [self backgroundViewTouch:nil];
    [self pageToViewControllerForName:@"ForgotPassword"];
}

#pragma mark - 获取验证码
- (IBAction)getSecurityCode:(id)sender {
    [self backgroundViewTouch:nil];
    _codeTextField.text = @"";
    [self requestCodeData];
}

- (void)requestCodeData{
    if ([judgeMent judgePhoneNum:_accountTextField.text]) {
        //手机号码符合要求，发送获取验证码请求
        [judgeMent getSecurityCodeAndControlBtn:_btnSecurityCode phoneNum:_accountTextField.text dragImgKey:_dragImgKey locationx:_locationx countryCode:@""];
    }
}

#pragma mark - 密码框完成
- (IBAction)passwordTextFieldEndOnExit:(id)sender {
    [self loginBtnPressed:nil];
}
#pragma mark - 账号框输入改变
- (IBAction)accountTextFieldEditingChanged:(id)sender {
    if (TTIsStringWithAnyText(_accountTextField.text) && TTIsStringWithAnyText(_passwordTextField.text)) {
        _loginBtn.enabled = YES;
    }else{
        _loginBtn.enabled = NO;
    }
}
- (IBAction)accountTextFieldEditingDidBegin:(id)sender {
    
}

- (IBAction)passwordTextFieldEditingDidBegin:(id)sender {
    [self accountTextFieldEditingDidBegin:sender];
    
}

- (IBAction)passwordTextFieldEditingChanged:(id)sender {
    
    if (TTIsStringWithAnyText(_accountTextField.text) && TTIsStringWithAnyText(_passwordTextField.text)) {
        _loginBtn.enabled = YES;
    }else{
        _loginBtn.enabled = NO;
    }
}

- (IBAction)accountTextFieldDidEndOnExit:(id)sender {
    [_accountTextField resignFirstResponder];
    [_passwordTextField becomeFirstResponder];
}

#pragma mark - 手机登陆
- (IBAction)loginBtnPressed:(id)sender {
    [self backgroundViewTouch:nil];
    
    if (_accountTextField.text.length == 0)
        [self showToast:NSLocalizedStringForKey(@"请输入手机号码")];
    else if (_passwordTextField.text.length == 0) {
        [self showToast:NSLocalizedStringForKey(@"请输入密码")];
    }else if (_codeTextField.text.length == 0 && bNeedCode) {
        [self showToast:NSLocalizedStringForKey(@"请填写验证码")];
    }else{
        bAutoLogin = NO;
        [loginBase loginByPwd:_accountTextField.text andPassword:_passwordTextField.text smsCode:_codeTextField.text dragImgKey:_dragImgKey locationx:_locationx];
    }
}

#pragma mark - LoginBase Delegate Methods

- (void)LBRequestStart{
    _indicatorLabel.text = NSLocalizedStringForKey(@"正在登录...");
    [_indicator startAnimating];
    _loginBtn.enabled = NO;
    _accountTextField.enabled = NO;
    _passwordTextField.enabled = NO;
}
- (void)LBRequestFinished{
    [_indicator stopAnimating];
    _indicatorLabel.text = @"";
    _loginBtn.enabled = YES;
    _accountTextField.enabled = YES;
    _passwordTextField.enabled = YES;
}
- (void)LBRequestFaild{
    [_indicator stopAnimating];
    _indicatorLabel.text = NSLocalizedStringForKey(@"登录失败!");
    _loginBtn.enabled = YES;
    _accountTextField.enabled = YES;
    _passwordTextField.enabled = YES;
}

- (void)LBLoginInto:(TJRUser*)user
{
    [CommonUtil setPageToAnimation];
    [self goBackWithAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHomeBanner" object:nil];
}

- (void)LBPageToRegister {
    // 第三方账号第一次登陆，跳转到绑定注册页面
}


- (void)LBLoginOut{
    
}

- (void)LBNeedCode:(NSString*)code{
    
    if ([code isEqualToString:@"40015"]) {
        [UIView animateWithDuration:0.25 animations:^{
            _layoutCodeViewHeight.constant = 65;
            [self.view layoutIfNeeded];
            
        }];
        _codeTextField.enabled = YES;
        bNeedCode = YES;
    }else if ([code isEqualToString:@"40016"]) {
        bAutoLogin = YES;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
    }
}

#pragma mark - RAJudgement Delegate Methods
- (void)RAShowToast:(NSString*)message{
    if (message.length>0) {
        [self showToast:message];
    }
}
- (void)RAShowHud{
    [self showProgressDefaultText];
}
- (void)RAHideHud{
    [self dismissProgress];
}

- (void)RAReqFinish:(NSString*)code message:(NSString *)message{

    if ([code isEqualToString:@"40016"]) {
        // 重新验证拖动图片
        bAutoLogin = NO;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
        
    } else if ([code isEqualToString:@"40070"]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:message preferredStyle:UIAlertControllerStyleAlert];
        __block typeof(self) weakSelf = self;
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:alertController completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        _btnSecurityCode.enabled = NO;
        
    } else {
        
        if (TTIsStringWithAnyText(message)) {
            [self showToastCenter:message inView:self.view];
        }
    }
}

#pragma mark - PuzzleVerifyView Delegate Methods
- (void)puzzleVerifyView:(PuzzleVerifyView*)puzzleVerifyView dragImgKey:(NSString*)dragImgKey puzzleOriginX:(CGFloat)puzzleOriginX{

    if (puzzleOriginX>0) {
        self.dragImgKey = dragImgKey;
        self.locationx = puzzleOriginX;
        
        if (bAutoLogin) {
            [self loginBtnPressed:nil];
        }else{
            if (_layoutCodeViewHeight.constant > 0) {
                [self requestCodeData];
            }else{
                [loginBase loginByPwd:_accountTextField.text andPassword:_passwordTextField.text smsCode:@"" dragImgKey:_dragImgKey locationx:_locationx];
            }
        }
    }
}

- (void)dealloc {
    [_puzzleVerifyView release];
    [_dragImgKey release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    judgeMent.raDelegate = nil;
    [judgeMent release];
    [toolBar release];
    [loginBase release];
    [_indicator release];
    [_indicatorLabel release];
    [_loginBtn release];
    [_regBtn release];
    [_loginView release];
    [_forgetButton release];
    [_accountTextField release];
    [_passwordTextField release];
    [_bgScrollView release];
    [_codeView release];
    [_layoutCodeViewHeight release];
    [_codeTextField release];
    [_btnSecurityCode release];
    [_lbWelcomeTips release];
    [_lbLoginTips release];
    [super dealloc];
}

@end

