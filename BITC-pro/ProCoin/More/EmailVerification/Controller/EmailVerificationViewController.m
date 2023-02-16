//
//  EmailVerificationViewController.m
//  ProCoin
//
//  Created by sh on 2021/7/20.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "EmailVerificationViewController.h"

#import "CommonUtil.h"
#import "NetWorkManage+Security.h"
#import "TJRBaseParserJson.h"
#import "LoginSQLModel.h"

@interface EmailVerificationViewController ()
{
    NSInteger _uiState;
}

@property (retain, nonatomic) IBOutlet UILabel *navTitle;
@property (retain, nonatomic) IBOutlet UILabel *contentLab;
@property (retain, nonatomic) IBOutlet UITextField *emailTF;
@property (retain, nonatomic) IBOutlet UILabel *emailLab;
@property (retain, nonatomic) IBOutlet UIButton *sendBtn;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *emailTFTopLayout;

@property (nonatomic, copy) NSString *emailStr;
@property (nonatomic, copy) NSString *emailCode;

@end

@implementation EmailVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 0:绑定邮箱 1:安全验证 2:输入新邮箱 3:邮箱验证 4:更新邮箱
    _uiState = [CommonUtil checkEmail:ROOTCONTROLLER_USER.email] ? 1 : 0;
    [self refreshUIState];
}


- (IBAction)sendEmailCode:(id)sender {
    
    if (_uiState == 0 || _uiState == 1 || _uiState == 2) {
        self.emailStr = _uiState == 1 ? ROOTCONTROLLER_USER.email : _emailTF.text;
        [[NetWorkManage shareSingleNetWork] reqGetEmailCode:self emailStr:[_emailStr copy] finishedCallback:@selector(requestEmailCodeFinished:) failedCallback:@selector(requestEmailCodeFalid:)];
    }
    else if (_uiState == 3) {
        self.emailCode= _emailTF.text;
        [[NetWorkManage shareSingleNetWork] reqCheckEmailCode:self emailStr:[_emailStr copy] emailCode:[_emailCode copy] finishedCallback:@selector(requestCheckEmailCodeFinished:) failedCallback:@selector(requestCheckEmailCodeFalid:)];
    }
    else if (_uiState == 4) {
        self.emailCode= _emailTF.text;
        [[NetWorkManage shareSingleNetWork] reqUpdateEmail:self emailStr:[_emailStr copy] emailCode:[_emailCode copy] finishedCallback:@selector(requestUpdateEmailFinished:) failedCallback:@selector(requestUpdateEmailFalid:)];
    }
}

- (IBAction)backAction:(id)sender {
    [self goBack];
}

#pragma mark - GET CODE
- (void)requestEmailCodeFinished:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
        if (_uiState == 0 || _uiState == 2) {
            _uiState = 4;
        } else if (_uiState == 1) {
            _uiState = 3;
        }
        [self refreshUIState];
    } else {
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)requestEmailCodeFalid:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (!isok) {
        NSLog(NSLocalizedStringForKey(@"获取验证码失败"));
    }
    [self showToastCenter:NSLocalizedStringForKey(@"获取验证码失败") inView:self.view];
}

#pragma mark - CHECK CODE
- (void)requestCheckEmailCodeFinished:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
        _uiState = 2;
        [self refreshUIState];
    } else {
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)requestCheckEmailCodeFalid:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];
    
    NSString *content = _uiState == 0 ? NSLocalizedStringForKey(@"添加邮箱失败") : NSLocalizedStringForKey(@"更新邮箱失败");
    if (!isok) {
        NSLog(NSLocalizedStringForKey(@"更新邮箱失败"));
    }
    [self showToastCenter:content inView:self.view];
}

#pragma mark - UPDATE EMAIL
- (void)requestUpdateEmailFinished:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
        ROOTCONTROLLER_USER.email = _emailStr;
        [LoginSQLModel updateLoginInfo:ROOTCONTROLLER.user];
        [self pageToOrBackWithName:@"TJRSetUpViewController"];
    } else {
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)requestUpdateEmailFalid:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];
    
    NSString *content = _uiState == 0 ? NSLocalizedStringForKey(@"添加邮箱失败") : NSLocalizedStringForKey(@"更新邮箱失败");
    if (!isok) {
        NSLog(NSLocalizedStringForKey(@"更新邮箱失败"));
    }
    [self showToastCenter:content inView:self.view];
}

- (void)refreshUIState {
    
    // 0:绑定邮箱 1:安全验证 2:输入新邮箱 3:邮箱验证 4:更新邮箱
    switch (_uiState) {
        case 0:
        {
            _emailTF.hidden = NO;
            _contentLab.hidden = _emailLab.hidden = YES;
            _navTitle.text = NSLocalizedStringForKey(@"绑定邮箱");
            _emailTF.text = nil;
            _emailTF.placeholder = NSLocalizedStringForKey(@"请输入邮箱");
            [_sendBtn setTitle:NSLocalizedStringForKey(@"发送验证码") forState:(UIControlStateNormal)];
            _contentLab.hidden = _emailLab.hidden = YES;
            _emailTFTopLayout.constant = -30;
        }
            break;
        case 1:
        {
            _emailTF.hidden = YES;
            _contentLab.hidden = _emailLab.hidden = NO;
            _navTitle.text = NSLocalizedStringForKey(@"安全验证");
            [_sendBtn setTitle:NSLocalizedStringForKey(@"发送验证码") forState:(UIControlStateNormal)];
            _contentLab.text = NSLocalizedStringForKey(@"为了保证你的账号安全，请验证身份。");
            _emailLab.text = [NSString stringWithFormat:@"%@", [CommonUtil hidenEmailStr:ROOTCONTROLLER_USER.email]];
            _emailTFTopLayout.constant = 44;
        }
            break;
        case 2:
        {
            _emailLab.hidden = YES;
            _contentLab.hidden = _emailTF.hidden = NO;
            _navTitle.text = NSLocalizedStringForKey(@"请输入新邮箱");
            _emailTF.text = nil;
            _emailTF.placeholder = NSLocalizedStringForKey(@"请输入邮箱");
            [_sendBtn setTitle:NSLocalizedStringForKey(@"发送验证码") forState:(UIControlStateNormal)];
            _contentLab.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"您目前的邮箱是%@，想要把它更新为？"), [CommonUtil hidenEmailStr:ROOTCONTROLLER_USER.email]];
            _emailTFTopLayout.constant = 44;
        }
            break;
        case 3:
        {
            _emailLab.hidden = YES;
            _contentLab.hidden = _emailTF.hidden = NO;
            _navTitle.text = NSLocalizedStringForKey(@"邮箱验证码");
            _emailTF.text = nil;
            _emailTF.placeholder = NSLocalizedStringForKey(@"请输入邮箱验证码");
            [_sendBtn setTitle:NSLocalizedStringForKey(@"下一步") forState:(UIControlStateNormal)];
            _contentLab.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"验证码已发送至，%@"), [CommonUtil hidenEmailStr:_emailStr]];
            _emailTFTopLayout.constant = 44;
        }
            break;
        case 4:
        {
            _emailLab.hidden = YES;
            _contentLab.hidden = _emailTF.hidden = NO;
            _navTitle.text = NSLocalizedStringForKey(@"邮箱验证码");
            _emailTF.text = nil;
            _emailTF.placeholder = NSLocalizedStringForKey(@"请输入邮箱验证码");
            [_sendBtn setTitle:NSLocalizedStringForKey(@"确定") forState:(UIControlStateNormal)];
            _contentLab.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"验证码已发送至，%@"), _emailStr];
            _emailTFTopLayout.constant = 44;
        }
            break;
            
        default:
            break;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_contentLab release];
    [_emailTF release];
    [_sendBtn release];
    [_navTitle release];
    [_emailTFTopLayout release];
    [_emailLab release];
    [super dealloc];
}
@end
