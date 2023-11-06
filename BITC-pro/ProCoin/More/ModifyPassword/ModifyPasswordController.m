//
//  ModifyPasswordController.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "ModifyPasswordController.h"
#import "LoginBase.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "NetWorkManage+User.h"
#import "NetWorkManage+Security.h"
#import "TJRBaseParserJson.h"

#define kUpOfHeight                     80

@interface ModifyPasswordController ()
{
    TextFieldToolBar    *toolBar;
    NSTimer* timer;
    NSInteger timerCount;
}
@property (retain, nonatomic) IBOutlet UIView *emailBacView;
@property (retain, nonatomic) IBOutlet UILabel *emailContentLab;
@property (retain, nonatomic) IBOutlet UITextField *emailCodeTF;
@property (retain, nonatomic) IBOutlet UIButton *emailGetCodeBtn;
@property (retain, nonatomic) IBOutlet UIButton *emailNextBtn;

@property (retain, nonatomic) IBOutlet UIButton *btnKnowPsw;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutTopBGView;
@end

@implementation ModifyPasswordController
@synthesize oldPassword;
@synthesize textFieldNewPassword;
@synthesize textFieldNewPassword2;
@synthesize textBackgroundView;
@synthesize commitBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *color = RGBA(150, 150, 150, 1);
    [CommonUtil setUITextFieldPlaceholderColor:oldPassword color:color];
    [CommonUtil setUITextFieldPlaceholderColor:textFieldNewPassword color:color];
    [CommonUtil setUITextFieldPlaceholderColor:textFieldNewPassword2 color:color];
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:3];
    oldPassword.inputAccessoryView = toolBar;
    textFieldNewPassword.inputAccessoryView = toolBar;
    textFieldNewPassword2.inputAccessoryView = toolBar;
    
    CGFloat startY = STATUS_BAR_HEIGHT + 44;
    CGRect frame = CGRectMake(0, startY, textBackgroundView.frame.size.width, phoneRectScreen.size.height - startY);
    textBackgroundView.frame = frame;
    
    textBackgroundView.hidden = YES;
    _emailBacView.hidden = NO;
//
    if ([CommonUtil checkEmail:ROOTCONTROLLER_USER.email]) {
        _emailContentLab.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedStringForKey(@"已绑定邮箱号:"), [CommonUtil hidenEmailStr:ROOTCONTROLLER_USER.email]];
    } else {
//        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"请绑定邮箱")] delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"去设置"),nil];
//        [alt show];
//        RELEASE(alt);
//        _emailContentLab.text = NSLocalizedStringForKey(@"请绑定邮箱");
    }

    [CommonUtil viewMasksToBounds:_emailGetCodeBtn cornerRadius:2 borderColor:[UIColor blueColor]];
    
    textBackgroundView.hidden = NO;
    _emailBacView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [oldPassword becomeFirstResponder];
}

- (void)viewDidUnload
{
    TT_RELEASE_SAFELY(toolBar);
    [self setOldPassword:nil];
    [self setTextFieldNewPassword:nil];
    [self setTextFieldNewPassword2:nil];
    [self setTextBackgroundView:nil];
    [self setCommitBtn:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [toolBar release];
    [oldPassword release];
    [textFieldNewPassword release];
    [textFieldNewPassword2 release];
    [textBackgroundView release];
    [commitBtn release];
    [_btnKnowPsw release];
    [_layoutTopBGView release];
    [_emailBacView release];
    [_emailContentLab release];
    [_emailCodeTF release];
    [_emailGetCodeBtn release];
    [_emailNextBtn release];
    [self closeTimer];
    [super dealloc];
}

#pragma mark - Action
- (IBAction)getCodeAction:(id)sender {
    if (![CommonUtil checkEmail:ROOTCONTROLLER_USER.email]) {
        [self showToast:NSLocalizedStringForKey(@"请绑定邮箱")];
        return;
    }
    [[NetWorkManage shareSingleNetWork] reqGetEmailCode:self emailStr:ROOTCONTROLLER_USER.email finishedCallback:@selector(requestEmailCodeFinished:) failedCallback:@selector(requestEmailCodeFalid:)];
}

- (IBAction)nextBtnAction:(id)sender {
    if (!checkIsStringWithAnyText(_emailCodeTF.text)) {
        [self showToast:NSLocalizedStringForKey(@"请输入验证码")];
        return;
    }
    [[NetWorkManage shareSingleNetWork] reqCheckEmailCode:self emailStr:ROOTCONTROLLER_USER.email emailCode:_emailCodeTF.text finishedCallback:@selector(requestCheckEmailCodeFinished:) failedCallback:@selector(requestCheckEmailCodeFalid:)];
}


- (IBAction)knowPswBtnClicked:(id)sender {
    _btnKnowPsw.selected = !_btnKnowPsw.selected;
    oldPassword.secureTextEntry = !_btnKnowPsw.selected;
    textFieldNewPassword.secureTextEntry = !_btnKnowPsw.selected;
    textFieldNewPassword2.secureTextEntry = !_btnKnowPsw.selected;
}

- (IBAction)backgroundTouch:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        _layoutTopBGView.constant = 0;
        [textBackgroundView setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [oldPassword resignFirstResponder];
        [textFieldNewPassword resignFirstResponder];
        [textFieldNewPassword2 resignFirstResponder];
    }];
}

- (IBAction)gobackPressed:(id)sender {
    [self goBack];
}
- (IBAction)commitModifyPassword:(id)sender {
    RAJudgement *judge = [[RAJudgement alloc]init];
    judge.raDelegate = self;

    if ( [judge judgePassword:textFieldNewPassword.text andPassword2:textFieldNewPassword2.text]) {
        commitBtn.enabled = NO;
        //发送修改密码请求
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqModifyPassword:self oldPwd:[CommonUtil getMD5:oldPassword.text] newPwd:[CommonUtil getMD5:textFieldNewPassword.text] finishedCallback:@selector(reqModifyPasswordFinished:) failedCallback:@selector(reqModifyPasswordFailed:)];
    }
    [judge release];
}

- (void)reqModifyPasswordFinished:(id)result{
    [self dismissProgress];
    commitBtn.enabled = YES;

    TJRBaseParserJson *userParser = [[[TJRBaseParserJson alloc] init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    if ([userParser parseBaseIsOk:result]) {
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
}
- (void)reqModifyPasswordFailed:(NSDictionary*)jsonDic{
    commitBtn.enabled = YES;
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败") inView:self.view];
}


- (void)requestEmailCodeFinished:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
        [self startTimer];
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

- (void)requestCheckEmailCodeFinished:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
//        [self refreshUIState];
        _emailBacView.hidden = YES;
        textBackgroundView.hidden = NO;
        [oldPassword becomeFirstResponder];
    } else {
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)requestCheckEmailCodeFalid:(NSDictionary *)json {
    [self dismissProgress];
    self.canDragBack = YES;
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (!isok) {
        NSLog(NSLocalizedStringForKey(@"获取验证码失败"));
    }
    [self showToastCenter:NSLocalizedStringForKey(@"获取验证码失败") inView:self.view];
}

#pragma mark - Text Field Delegate
- (IBAction)textFieldChange:(UITextField *)sender {

    if (TTIsStringWithAnyText(oldPassword.text) && TTIsStringWithAnyText(textFieldNewPassword.text) && TTIsStringWithAnyText(textFieldNewPassword2.text)) {
        commitBtn.enabled = YES;
    }else{
        commitBtn.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [oldPassword becomeFirstResponder];
            break;
        case 2:
            [textFieldNewPassword becomeFirstResponder];
            break;
        case 3:
            [textFieldNewPassword2 becomeFirstResponder];
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

    float height = 0;
    [UIView animateWithDuration:0.25 animations:^{
        switch (tag) {
            case 1:
            case 2:
                _layoutTopBGView.constant = height;
                break;
            case 3:
                _layoutTopBGView.constant = height - 0.8 * kUpOfHeight;
                break;
                
        }
        [textBackgroundView setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag{
}
- (void)TFDonePressed{
    [self backgroundTouch:nil];
}
#pragma mark - RAJudgement Delegate Methods
- (void)RAShowToast:(NSString *)message{
    [self showToastCenter:message inView:self.view];
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        [self pageToOrBackWithName:@"EmailVerificationViewController"];
    }
}


#pragma mark - 定时器 统计超时
- (void)startTimer{
    [self closeTimer];
    timerCount = 60;
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)closeTimer
{
    if(timer && [timer isValid]){
        [timer invalidate];
        timer = nil;
    }
}

- (void)onTimer:(NSTimer *)timer {
    
    timerCount--;
    if (timerCount>=0) {
        _emailGetCodeBtn.userInteractionEnabled = NO;
        [_emailGetCodeBtn setTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"剩余 %ld 秒"), (long)timerCount] forState:(UIControlStateNormal)];
        [_emailGetCodeBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        [CommonUtil viewMasksToBounds:_emailGetCodeBtn cornerRadius:2 borderColor:[UIColor grayColor]];
    }
    if (timerCount == 0) {
        [self closeTimer];
        _emailGetCodeBtn.userInteractionEnabled = YES;
        [_emailGetCodeBtn setTitle:NSLocalizedStringForKey(@"重新获取") forState:(UIControlStateNormal)];
        [_emailGetCodeBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
        [CommonUtil viewMasksToBounds:_emailGetCodeBtn cornerRadius:2 borderColor:[UIColor blueColor]];
    }
}


@end
