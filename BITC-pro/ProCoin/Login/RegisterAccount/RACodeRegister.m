//
//  RACodeRegister.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-31.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "RACodeRegister.h"
#import "CommonUtil.h"
#import "LoginBase.h"
#import "UserParser.h"
#import "NetWorkManage+Security.h"
#import "RAJudgement.h"
#import "TextFieldToolBar.h"
#import "PuzzleVerifyView.h"
#import "LoginSQLModel.h"

#define kUpOfHeight                     80

@interface RACodeRegister ()<UITextFieldDelegate,TextFieldToolBarDelegate,RAJudgementDelegate,PuzzleVerifyViewDelegate>
{
    BOOL bReqFinished;
    NSTimeInterval animationDuration;
    NSInteger currentTag; // 当前编辑的textField的tag
    RAJudgement         *judgeMent;
    TextFieldToolBar    *toolBar;
    
    BOOL bAutoReg;
}

@property (retain, nonatomic) IBOutlet UILabel *lbPhoneTips;
@property (retain, nonatomic) IBOutlet UIControl *viewBackground;
@property (retain, nonatomic) IBOutlet UIButton *btnSecurityCode;
@property (retain, nonatomic) IBOutlet UITextField *textFieldSecurityCode;
@property (retain, nonatomic) IBOutlet UIButton *registerButton;
@property (retain, nonatomic) IBOutlet UIView *codeView;
@property (retain, nonatomic) PuzzleVerifyView *puzzleVerifyView;

@property (copy, nonatomic) NSString *phoneNum;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *countryCode;
@property (copy, nonatomic) NSString *inviteCode;

@property (copy, nonatomic) NSString *dragImgKey;
@property (assign, nonatomic) NSInteger locationx;
@end

@implementation RACodeRegister

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
    
    self.lbPhoneTips.text = NSLocalizedStringForKey(@"欢迎来到Liegt ");
    
    self.canDragBack = NO;
    
    bReqFinished = YES;
    
    judgeMent = [[RAJudgement alloc]init];
    judgeMent.raDelegate = self;
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:1];
    _textFieldSecurityCode.inputAccessoryView = toolBar;

    UIColor *color = RGBA(204, 204, 204, 1);
    [CommonUtil setUITextFieldPlaceholderColor:_textFieldSecurityCode color:color];
    
    if ([self getValueFromModelDictionary:RegisterAccountDict forKey:@"phoneNum"]) {
        self.phoneNum = [self getValueFromModelDictionary:RegisterAccountDict forKey:@"phoneNum"];
        [self removeParamFromModelDictionary:RegisterAccountDict forKey:@"phoneNum"];
    }
    
    if ([self getValueFromModelDictionary:RegisterAccountDict forKey:@"password"]) {
        self.password = [self getValueFromModelDictionary:RegisterAccountDict forKey:@"password"];
        [self removeParamFromModelDictionary:RegisterAccountDict forKey:@"password"];
    }
    
    if ([self getValueFromModelDictionary:RegisterAccountDict forKey:@"inviteCode"]) {
        self.inviteCode = [self getValueFromModelDictionary:RegisterAccountDict forKey:@"inviteCode"];
        [self removeParamFromModelDictionary:RegisterAccountDict forKey:@"inviteCode"];
    }
    
    if([self getValueFromModelDictionary:RegisterAccountDict forKey:@"countryCode"]){
        self.countryCode = [self getValueFromModelDictionary:RegisterAccountDict forKey:@"countryCode"];
        [self removeParamFromModelDictionary:RegisterAccountDict forKey:@"countryCode"];
    }else{
        self.countryCode = @"";
    }
    
    self.dragImgKey = @"";

    _puzzleVerifyView = [[PuzzleVerifyView alloc]initWithFrame:phoneRectScreen];
    _puzzleVerifyView.delegate = self;
    [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"完成验证获取验证码")];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_puzzleVerifyView show:self.view];
}

- (void)viewDidUnload
{
    TT_RELEASE_SAFELY(toolBar);
    TT_RELEASE_SAFELY(judgeMent);
    [self setViewBackground:nil];
    [self setBtnSecurityCode:nil];
    [self setTextFieldSecurityCode:nil];
    [super viewDidUnload];
}

- (IBAction)goBackPressed:(id)sender {
    [self goBack];
}


#pragma mark - 获取验证码
- (IBAction)getSecurityCode:(id)sender {
    [_textFieldSecurityCode resignFirstResponder];
    _textFieldSecurityCode.text = @"";
    [self requestCodeData];
}

- (void)requestCodeData{
    if ([judgeMent judgePhoneNum:_phoneNum]) {
        //手机号码符合要求，发送获取验证码请求
        [judgeMent getSecurityCodeAndControlBtn:_btnSecurityCode phoneNum:_phoneNum dragImgKey:_dragImgKey locationx:_locationx countryCode:self.countryCode];
    }
}

#pragma mark - 确认注册
- (IBAction)confirmRegister:(id)sender {
    bAutoReg = NO;
    if ([judgeMent judgePhoneNum:_phoneNum] && [judgeMent judgeSecurityCode:_textFieldSecurityCode.text] && TTIsStringWithAnyText(_password)) {
        
        if (bReqFinished) {
            bReqFinished = NO;
            [self showProgressDefaultText];
            NSString* psw = [CommonUtil getMD5:_password];
            [[NetWorkManage shareSingleNetWork] reqRegisterNewUser:self countryCode:self.countryCode phone:_phoneNum smsCode:_textFieldSecurityCode.text sex:@"0" userName:@"" userPass:psw inviteCode:_inviteCode headUrl:@"" describes:@"" dragImgKey:_dragImgKey locationx:_locationx finishedCallback:@selector(reqPhoneRegisterFinished:) failedCallback:@selector(reqPhoneRegisterFailed:)];

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
            user.password = [CommonUtil getMD5:_password];
            
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
        
        NSString *code = [NSString stringWithFormat:@"%@", [result objectForKey:@"code"]];
        if ([code isEqualToString:@"40016"]) {
            // 重新验证拖动图片
             bAutoReg = YES;
            [_puzzleVerifyView show:self.view];
            [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
        }
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

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_textFieldSecurityCode resignFirstResponder];
}

#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)sender {
    if (TTIsStringWithAnyText(_textFieldSecurityCode.text)) {
        _registerButton.enabled = YES;
    }else{
        _registerButton.enabled = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_textFieldSecurityCode becomeFirstResponder];
            break;
        case 2:
            [self confirmRegister:nil];
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSUInteger tag = [textField tag];
    [toolBar checkBarButton:tag];
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

- (void)RAReqFinish:(NSString*)code message:(NSString *)message{
    if ([code isEqualToString:@"40016"]) {
        // 重新验证拖动图片
        bAutoReg = NO;
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
        _lbPhoneTips.text = message;
        
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
        
        if (bAutoReg) {
            [self confirmRegister:nil];
        }else{
            if (_phoneNum.length>6) {
                NSString* start = [_phoneNum substringToIndex:3];
                NSString* end = [_phoneNum substringFromIndex:(_phoneNum.length - 3)];
                _lbPhoneTips.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"短信验证码已经发送至%@*******%@"),start,end];
                [self requestCodeData];
            }
        }
    }
}

- (void)dealloc {
    [_inviteCode release];
    [_dragImgKey release];
    [_puzzleVerifyView release];
    judgeMent.raDelegate = nil;
    [judgeMent close];
    [judgeMent release];
    [toolBar release];
    [_viewBackground release];
    [_btnSecurityCode release];
    [_textFieldSecurityCode release];
    [_registerButton release];
    [_codeView release];
    [_lbPhoneTips release];
    [_password release];
    [_phoneNum release];
    [_countryCode release];
    [super dealloc];
}

@end
