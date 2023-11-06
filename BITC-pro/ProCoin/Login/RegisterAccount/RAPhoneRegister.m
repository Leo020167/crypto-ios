//
//  RAPhoneRegister.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-31.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "RAPhoneRegister.h"
#import "CommonUtil.h"
#import "RAJudgement.h"
#import "TextFieldToolBar.h"
#import "LoginBase.h"
#import "CountrySelectController.h"
#import "UserParser.h"
#import "NetWorkManage+Security.h"


#import "LoginSQLModel.h"

#define kUpOfHeight 40

@interface RAPhoneRegister ()<UITextFieldDelegate,TextFieldToolBarDelegate, RAJudgementDelegate>
{
    BOOL bReqFinished;
    NSTimeInterval animationDuration;
    RAJudgement         *judgeMent;
    TextFieldToolBar    *toolBar;
    
    BOOL bAutoReg;
}

@property (copy, nonatomic) NSString *countryCode;
@property (copy, nonatomic) NSString *countryName;
@property (retain, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *countryCodeLabel;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *btnKnowPsw;
@property (retain, nonatomic) IBOutlet UIControl *viewBackground;
@property (retain, nonatomic) IBOutlet UITextField *textFieldRegisterAccount;
@property (retain, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (retain, nonatomic) IBOutlet UITextField *textFieldPassword2;
@property (retain, nonatomic) IBOutlet UITextField *textFieldCode;
@property (retain, nonatomic) IBOutlet UIButton *registerButton;
@property (retain, nonatomic) IBOutlet UILabel *lbViewTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbWelcomeTips;


@property (retain, nonatomic) IBOutlet UIView *phoneView;
@property (retain, nonatomic) IBOutlet UIView *passwordView1;
@property (retain, nonatomic) IBOutlet UIView *passwordView2;

@end

@implementation RAPhoneRegister

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
//    self.countryName = NSLocalizedStringForKey(@"香港");
//    self.countryCode = @"+852";
    self.countryName = NSLocalizedStringForKey(@"中国");
    self.countryCode = @"+86";
    _countryNameLabel.text = self.countryName;
    _countryCodeLabel.text = self.countryCode;
    
    self.canDragBack = NO;
    
    bReqFinished = YES;
    
    judgeMent = [[RAJudgement alloc]init];
    judgeMent.raDelegate = self;
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:4];
    _textFieldRegisterAccount.inputAccessoryView = toolBar;
    _textFieldPassword.inputAccessoryView = toolBar;
    _textFieldPassword2.inputAccessoryView = toolBar;
    _textFieldCode.inputAccessoryView = toolBar;

    UIColor *color = RGBA(204, 204, 204, 1);
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldRegisterAccount color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldPassword color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldPassword2 color:color];
    
    _lbViewTitle.text = NSLocalizedStringForKey(@"注册");
    [_registerButton setTitle:NSLocalizedStringForKey(@"注册") forState:UIControlStateNormal];
    _textFieldRegisterAccount.placeholder = NSLocalizedStringForKey(@"请输入手机号码");
    _textFieldPassword.placeholder = NSLocalizedStringForKey(@"请输入密码");
    _textFieldPassword2.placeholder = NSLocalizedStringForKey(@"请再次输入密码");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CountrySelectCallBackCode"]){
        self.countryCode = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CountrySelectCallBackCode"];
        self.countryName = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CountrySelectCallBackName"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"CountrySelectCallBackCode"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"CountrySelectCallBackName"];
        _countryNameLabel.text = self.countryName;
        _countryCodeLabel.text = self.countryCode;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewDidUnload
{
    TT_RELEASE_SAFELY(toolBar);
    TT_RELEASE_SAFELY(judgeMent);
    [self setViewBackground:nil];
    [self setTextFieldRegisterAccount:nil];
    [self setTextFieldPassword:nil];
    [self setTextFieldPassword2:nil];
    [self setTextFieldCode:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}


#pragma mark - 按钮点击事件
- (IBAction)goBackPressed:(id)sender {
    [self goBack];
}

- (IBAction)knowPswBtnClicked:(id)sender {
    _btnKnowPsw.selected = !_btnKnowPsw.selected;
    _textFieldPassword.secureTextEntry = !_btnKnowPsw.selected;
    _textFieldPassword2.secureTextEntry = !_btnKnowPsw.selected;
}

/** 查看协议按钮 */
- (IBAction)protocolButtonClicked:(UIButton *)sender
{
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = URL_SERVICE_PROTOCOL;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

- (IBAction)softButtonClicked:(id)sender
{
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = URL_PRIVACY_POLICY;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

- (IBAction)countrySelectButtonPressed:(id)sender
{
    CountrySelectController *selectController = [[CountrySelectController alloc] init];
    selectController.chooseDataBlock = ^(CountryCodeInfoEntity * _Nonnull model) {
        self.countryCode = model.areaCode;
        self.countryName = model.tcName;
        _countryNameLabel.text = self.countryName;
        _countryCodeLabel.text = self.countryCode;
    };
    
    selectController.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    selectController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:selectController animated:YES completion:nil];
}


#pragma mark - 确认注册
- (IBAction)confirmRegister:(id)sender {

    if ([judgeMent judgePhoneNum:_textFieldRegisterAccount.text] && [judgeMent judgePassword:_textFieldPassword.text andPassword2:_textFieldPassword2.text] ) {
        
//        [self putValueToParamDictionary:RegisterAccountDict value:_textFieldRegisterAccount.text forKey:@"phoneNum"];
//        [self putValueToParamDictionary:RegisterAccountDict value:_textFieldPassword.text forKey:@"password"];
//        [self putValueToParamDictionary:RegisterAccountDict value:self.countryCode forKey:@"countryCode"];
//        [self putValueToParamDictionary:RegisterAccountDict value:_textFieldCode.text forKey:@"inviteCode"];
//        [self pageToViewControllerForName:@"RACodeRegister"];
        
        [self toRegister];
    }
}

#pragma mark - 确认注册
- (IBAction)toRegister {
    NSString *phoneNum = _textFieldRegisterAccount.text;
    NSString *password  = _textFieldPassword.text;
    if ([judgeMent judgePhoneNum:phoneNum]  && TTIsStringWithAnyText(password)) {
        
        if (bReqFinished) {
            bReqFinished = NO;
            [self showProgressDefaultText];
            NSString* psw = [CommonUtil getMD5:password];
            [[NetWorkManage shareSingleNetWork] reqRegisterNewUser:self countryCode:self.countryCode phone:phoneNum smsCode:@""  sex:@"0" userName:@"" userPass:psw inviteCode:_textFieldCode.text headUrl:@"" describes:@"" dragImgKey:@"" locationx:0 finishedCallback:@selector(reqPhoneRegisterFinished:) failedCallback:@selector(reqPhoneRegisterFailed:)];

        }
    }
}

- (void)reqPhoneRegisterFinished:(id)result{
    bReqFinished = YES;
    [self dismissProgress];

    UserParser *userParser = [[[UserParser alloc] init]autorelease];
    
    if ([userParser parseBaseIsOk:result]) {
       
        NSDictionary* dic = [result objectForKey:@"data"];
        
        if ([dic objectForKey:@"user"]) {
            
            TJRUser *user = [userParser parserMyInfoJson:[dic objectForKey:@"user"]];
            
            NSString *token = [dic objectForKey:@"token"];
            user.token = token.length>0?token:@"";
            NSString *password  = _textFieldPassword.text;
            user.password = [CommonUtil getMD5:password];
            
            if (user.userId.length > 0) {
                [LoginBase setRootLoginUser:user];
                
                [LoginSQLModel insertLoginInfo:ROOTCONTROLLER_USER];
                [self performSelector:@selector(delayGoToHome) withObject:nil afterDelay:0.5];
                [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"注册成功") detailsMessage:NSLocalizedStringForKey(@"正在进入") imageName:HUD_SUCCEED];
            }
        }
    }else{
        
        NSString* str = @"";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        [self showToast:str];
        
        
    }
}


- (void)delayGoToHome{
    
    [[self getTJRAppDelegate].navigation popToRootViewControllerAnimated:NO];
    [self pageToViewControllerForName:@"HomeViewController" animated:NO];
    [CommonUtil setPageToAnimation];
}


- (void)reqPhoneRegisterFailed:(id)result{
    bReqFinished = YES;
    [self dismissProgress];
    [self showToast:NSLocalizedStringForKey(@"注册失败")];
}


- (IBAction)registerEmail_btn:(id)sender {
    [self pageToViewControllerForName:@"RAEmailRegister"];
}

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_textFieldRegisterAccount resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
    [_textFieldPassword2 resignFirstResponder];
    [_textFieldCode resignFirstResponder];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)sender {
    if (TTIsStringWithAnyText(_textFieldRegisterAccount.text) && TTIsStringWithAnyText(_textFieldPassword.text) && TTIsStringWithAnyText(_textFieldPassword2.text)) {
        _registerButton.enabled = YES;
    }else{
        _registerButton.enabled = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_textFieldRegisterAccount becomeFirstResponder];
            break;
        case 2:
            [_textFieldPassword becomeFirstResponder];
            break;
        case 3:
            [_textFieldPassword2 becomeFirstResponder];
            break;
        case 4:
            [_textFieldCode becomeFirstResponder];
            break;
        case 5:
            [self confirmRegister:nil];
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
        case 3:
            distance = 1.6 * kUpOfHeight;
            break;
        case 4:
            distance = 2.2 * kUpOfHeight;
            break;
            
    }
    [_scrollView setContentOffset:CGPointMake(0.0, distance) animated:YES];
}


#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag{
}
- (void)TFDonePressed{
    [self viewTouchDown:nil];
}


#pragma mark - RAJudgement Delegate Methods
- (void)RAShowToast:(NSString*)message{
    if (message.length>0) {
        [self showToastCenter:message inView:self.view];
    }
}
- (void)RAShowHud{
}
- (void)RAHideHud{
}
- (void)RAReqFinish:(NSString*)code message:(NSString *)message{
}

- (void)dealloc {
    judgeMent.raDelegate = nil;
    [judgeMent close];
    [toolBar release];
    [judgeMent release];
    [_countryName release];
    [_countryCode release];
    [_viewBackground release];
    [_textFieldRegisterAccount release];
    [_textFieldPassword release];
    [_textFieldPassword2 release];
    [_textFieldCode release];
    [_btnKnowPsw release];
    [_registerButton release];
    [_phoneView release];
    [_passwordView1 release];
    [_passwordView2 release];
    [_scrollView release];
    [_lbViewTitle release];
    [_lbWelcomeTips release];
    [_countryCodeLabel release];
    [_countryNameLabel release];
    [super dealloc];
}

@end
