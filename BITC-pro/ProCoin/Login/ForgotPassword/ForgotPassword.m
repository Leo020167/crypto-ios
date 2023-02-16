//
//  ForgotPassword.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import "ForgotPassword.h"
#import "LoginBase.h"
#import "CommonUtil.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Security.h"
#import "RAJudgement.h"
#import "TextFieldToolBar.h"
#import "PuzzleVerifyView.h"
#import "CountrySelectController.h"

#define kUpOfHeight                     80

@interface ForgotPassword ()<UITextFieldDelegate,TextFieldToolBarDelegate,RAJudgementDelegate,PuzzleVerifyViewDelegate>
{
    NSTimeInterval animationDuration;
    NSInteger currentTag; // 当前编辑的textField的tag
    
    BOOL bAutoReq;
    RAJudgement         *judgeMent;
    TextFieldToolBar    *toolBar;
}

@property (copy, nonatomic) NSString *countryCode;
@property (copy, nonatomic) NSString *countryName;

@property (retain, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (retain, nonatomic) IBOutlet UIButton *leftBtn;
@property (retain, nonatomic) IBOutlet UIButton *btnKnowPsw;
@property (retain, nonatomic) IBOutlet UIControl *viewBackground;
@property (retain, nonatomic) IBOutlet UIButton *btnSecurityCode;
@property (retain, nonatomic) IBOutlet UITextField *textFieldRegisterAccount;
@property (retain, nonatomic) IBOutlet UITextField *textFieldSecurityCode;
@property (retain, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (retain, nonatomic) IBOutlet UITextField *textFieldPassword2;
@property (retain, nonatomic) IBOutlet UIButton *okButton;

@property (retain, nonatomic) IBOutlet UIView *phoneView;
@property (retain, nonatomic) IBOutlet UIView *codeView;
@property (retain, nonatomic) IBOutlet UIView *passwordView;
@property (retain, nonatomic) IBOutlet UIView *passwordView2;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) PuzzleVerifyView *puzzleVerifyView;

@property (copy, nonatomic) NSString *dragImgKey;
@property (assign, nonatomic) NSInteger locationx;
@end

@implementation ForgotPassword

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
    
    self.countryName = NSLocalizedStringForKey(@"香港");
    self.countryCode = @"+852";
    _countryNameLabel.text = self.countryName;
    _countryCodeLabel.text = self.countryCode;
    
    self.canDragBack = NO;
    
    judgeMent = [[RAJudgement alloc]init];
    judgeMent.raDelegate = self;
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:4];
    _textFieldRegisterAccount.inputAccessoryView = toolBar;
    _textFieldSecurityCode.inputAccessoryView = toolBar;
    _textFieldPassword.inputAccessoryView = toolBar;
    _textFieldPassword2.inputAccessoryView = toolBar;
    
    UIColor *color = RGBA(187,187,187, 1);
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldRegisterAccount color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldSecurityCode color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldPassword color:color];
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldPassword2 color:color];
    
    _puzzleVerifyView = [[PuzzleVerifyView alloc]initWithFrame:phoneRectScreen];
    _puzzleVerifyView.delegate = self;
    [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"完成验证获取验证码")];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    TT_RELEASE_SAFELY(toolBar);
    TT_RELEASE_SAFELY(judgeMent);
    [self setViewBackground:nil];
    [self setBtnSecurityCode:nil];
    [self setTextFieldRegisterAccount:nil];
    [self setTextFieldSecurityCode:nil];
    [self setTextFieldPassword:nil];
    [self setTextFieldPassword2:nil];
    [super viewDidUnload];
}

- (void)reqForgotPasswordFinished:(NSDictionary*)jsonDic{
    [self dismissProgress];
    
    TJRBaseParserJson* jsonParser = [[[TJRBaseParserJson alloc]init]autorelease];
    if ([jsonParser parseBaseIsOk:jsonDic]) {
        NSString* str = NSLocalizedStringForKey(@"修改成功");
        if ([jsonDic objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_SUCCEED];
        self.canDragBack = NO;
        self.leftBtn.enabled = NO;
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1.5];
    }else{
        NSString* str = @"";
        if ([jsonDic objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[jsonDic objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }

}


- (void)reqForgotPasswordFailed:(NSDictionary*)jsonDic{
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:NSLocalizedStringForKey(@"修改密码失败") imageName:HUD_ERROR];
}

- (IBAction)goBackPressed:(id)sender {
    [self goBack];
}

- (IBAction)knowPswBtnClicked:(id)sender {
    _btnKnowPsw.selected = !_btnKnowPsw.selected;
    _textFieldPassword.secureTextEntry = !_btnKnowPsw.selected;
    _textFieldPassword2.secureTextEntry = !_btnKnowPsw.selected;
}

#pragma mark - 选择国家和地区
- (IBAction)countrySelectButtonPressed:(id)sender
{
    CountrySelectController *selectController = [[CountrySelectController alloc] init];
    selectController.chooseDataBlock = ^(CountryCodeInfoEntity * _Nonnull model) {
        self.countryCode = model.areaCode;
        self.countryName = model.enName;
        _countryNameLabel.text = self.countryName;
        _countryCodeLabel.text = self.countryCode;
    };
    
    selectController.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    selectController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:selectController animated:YES completion:nil];
}


#pragma mark - 获取验证码
- (IBAction)getSecurityCode:(id)sender {
    [_puzzleVerifyView show:self.view];
    [self viewTouchDown:nil];
    _textFieldSecurityCode.text = @"";
}

- (void)requestCodeData{
    if ([judgeMent judgePhoneNum:_textFieldRegisterAccount.text]) {
        //手机号码符合要求，发送获取验证码请求
        [judgeMent getSecurityCodeAndControlBtn:_btnSecurityCode phoneNum:_textFieldRegisterAccount.text dragImgKey:_dragImgKey locationx:_locationx countryCode:self.countryCode];
    }
}

#pragma mark - 确认
- (IBAction)confirm:(id)sender {
    if ([judgeMent judgePhoneNum:_textFieldRegisterAccount.text] &&      //判断手机号码
        [judgeMent judgeSecurityCode:_textFieldSecurityCode.text] &&     //判断验证码         判断密码
        [judgeMent judgePassword:_textFieldPassword.text andPassword2:_textFieldPassword2.text] ) {
        
        //发送请求
        [self showProgressDefaultText];
        
        [[NetWorkManage shareSingleNetWork] reqForgotPasswordUpdatePwd:self smsCode:_textFieldSecurityCode.text phone:_textFieldRegisterAccount.text userPass:[CommonUtil getMD5:_textFieldPassword.text] dragImgKey:_dragImgKey locationx:_locationx  finishedCallback:@selector(reqForgotPasswordFinished:) failedCallback:@selector(reqForgotPasswordFailed:)];
        
        [self viewTouchDown:nil];
    }
}

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_textFieldRegisterAccount resignFirstResponder];
    [_textFieldSecurityCode resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
    [_textFieldPassword2 resignFirstResponder];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [_textFieldRegisterAccount becomeFirstResponder];
            break;
        case 2:
            [_textFieldSecurityCode becomeFirstResponder];
            break;
        case 3:
            [_textFieldPassword becomeFirstResponder];
            break;
        case 4:
            [_textFieldPassword2 becomeFirstResponder];
            break;
        case 5:
            [self confirm:nil];
            break;
    }
    return YES;
}

- (IBAction)textFieldChange:(UITextField *)sender {
    if (TTIsStringWithAnyText(_textFieldRegisterAccount.text) && TTIsStringWithAnyText(_textFieldPassword.text) && TTIsStringWithAnyText(_textFieldSecurityCode.text) && TTIsStringWithAnyText(_textFieldPassword2.text) ) {
        _okButton.enabled = YES;
    }else{
        _okButton.enabled = NO;
    }
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
            distance = 1.8 * kUpOfHeight;
            break;
        case 3:
        case 4:
            distance = 2.7 * kUpOfHeight;
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
    [self showProgressDefaultText];
}
- (void)RAHideHud{
    [self dismissProgress];
}
- (void)RAPageTo:(NSString*)pageName{
    
}

- (void)RAReqFinish:(NSString*)code message:(NSString *)message{
    
    if ([code isEqualToString:@"40016"]) {
        // 重新验证拖动图片
        bAutoReq = NO;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
        
    } else if ([code isEqualToString:@"40070"]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"BYY%@", NSLocalizedStringForKey(@"提示")] message:message preferredStyle:UIAlertControllerStyleAlert];
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
        [_textFieldSecurityCode becomeFirstResponder];
        
        self.dragImgKey = dragImgKey;
        self.locationx = puzzleOriginX;
        
        if (bAutoReq) {
            [self confirm:nil];
        }else{
            if (_textFieldRegisterAccount.text.length>6) {
                [self requestCodeData];
            }
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_countryCode release];
    [_countryName release];
    [_dragImgKey release];
    [_puzzleVerifyView release];
    judgeMent.raDelegate = nil;
    [judgeMent close];
    [toolBar release];
    [judgeMent release];
    [_viewBackground release];
    [_btnSecurityCode release];
    [_textFieldRegisterAccount release];
    [_textFieldSecurityCode release];
    [_textFieldPassword release];
    [_textFieldPassword2 release];
    [_leftBtn release];
    [_btnKnowPsw release];
    [_okButton release];
    [_phoneView release];
    [_codeView release];
    [_passwordView release];
    [_passwordView2 release];
    [_scrollView release];
    [_countryNameLabel release];
    [_countryCodeLabel release];
    [super dealloc];
}

@end
