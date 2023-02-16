//
//  PayPasswordController.m
//  Redz
//
//  Created by taojinroad on 2018/11/16.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "PayPasswordController.h"
#import "TradeInputView.h"
#import "RAJudgement.h"
#import "TextFieldToolBar.h"
#import "PuzzleVerifyView.h"
#import "NetWorkManage+User.h"
#import "TJRBaseParserJson.h"
#import "CommonUtil.h"
#import "LoginSQLModel.h"

#define IMG_TO_1            @"pay_accout_logo_to1"
#define IMG_TO_2            @"pay_accout_logo_to2"
#define IMG_TO_3            @"pay_accout_logo_to3"

@interface PayPasswordController ()<TradeInputViewDelegate,RAJudgementDelegate,PuzzleVerifyViewDelegate>{
    
    BOOL bAutoReq;
    BOOL bReqFinished;
    
    RAJudgement         *judgeMent;
    TextFieldToolBar    *toolBar;
}

@property (retain, nonatomic) IBOutlet TradeInputView *tradeInputView1;
@property (retain, nonatomic) IBOutlet TradeInputView *tradeInputView2;
@property (retain, nonatomic) IBOutlet UIView *phoneView;
@property (retain, nonatomic) IBOutlet UIView *password1View;
@property (retain, nonatomic) IBOutlet UIView *password2View;
@property (retain, nonatomic) IBOutlet UITextField *tfCode;
@property (retain, nonatomic) IBOutlet UIButton *btnPhone;
@property (retain, nonatomic) IBOutlet UIButton *btnPassword1;
@property (retain, nonatomic) IBOutlet UIButton *btnPassword2;
@property (retain, nonatomic) IBOutlet UILabel *lbPasswordTips1;
@property (retain, nonatomic) IBOutlet UIView *phoneVerifyView;
@property (retain, nonatomic) IBOutlet UILabel *lbVerifyPhoneNum;
@property (retain, nonatomic) IBOutlet UIButton *btnTipsPhone;
@property (retain, nonatomic) IBOutlet UIButton *btnTipsPassword1;
@property (retain, nonatomic) IBOutlet UIButton *btnTipsPassword2;
@property (retain, nonatomic) IBOutlet UIButton *btnSecurityCode;
@property (retain, nonatomic) IBOutlet UIImageView *ivTo1;
@property (retain, nonatomic) IBOutlet UIImageView *ivTo2;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;

@property (retain, nonatomic) PuzzleVerifyView *puzzleVerifyView;

@property (copy, nonatomic) NSString *dragImgKey;
@property (assign, nonatomic) NSInteger locationx;

@property (copy, nonatomic) NSString *phoneNum;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *passwordOld;

@property (nonatomic, strong) TJRUser *user;
@end

@implementation PayPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tradeInputView1.delegate = self;
    _tradeInputView2.delegate = self;
    
    _phoneView.hidden = NO;
    _password1View.hidden = YES;
    _password2View.hidden = YES;
    _btnTipsPhone.selected = YES;
    _btnTipsPassword1.selected = NO;
    _btnTipsPassword2.selected = NO;
    _ivTo1.image = [UIImage imageNamed:IMG_TO_2];
    _ivTo2.image = [UIImage imageNamed:IMG_TO_1];
    
    self.dragImgKey = @"";
    
    bReqFinished = YES;
    
    judgeMent = [[RAJudgement alloc]init];
    judgeMent.raDelegate = self;
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:1];
    _tfCode.inputAccessoryView = toolBar;
    
    _puzzleVerifyView = [[PuzzleVerifyView alloc]initWithFrame:phoneRectScreen];
    _puzzleVerifyView.delegate = self;
    [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"完成验证获取验证码")];
    
    [self getUserData];
    
    _lbPasswordTips1.text = NSLocalizedStringForKey(@"请设置6位交易密码");
    _lbTitle.text = checkIsStringWithAnyText(ROOTCONTROLLER_USER.payPass)?NSLocalizedStringForKey(@"修改交易密码"):NSLocalizedStringForKey(@"设置交易密码");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

- (IBAction)phoneNextBtnClicked:(id)sender {
    bAutoReq = NO;
    if ([judgeMent judgePhoneNum:_phoneNum] && [judgeMent judgeSecurityCode:_tfCode.text]) {
        
        _phoneView.hidden = YES;
        _password1View.hidden = NO;
        _password2View.hidden = YES;
        _btnTipsPhone.selected = YES;
        _btnTipsPassword1.selected = YES;
        _btnTipsPassword2.selected = NO;
        _ivTo1.image = [UIImage imageNamed:IMG_TO_3];
        _ivTo2.image = [UIImage imageNamed:IMG_TO_2];
        [_tradeInputView1 becomeFirstResponder];
    }
}

- (IBAction)password1NextBtnClicked:(id)sender {
    _phoneView.hidden = YES;
    _password1View.hidden = YES;
    _password2View.hidden = NO;
    _btnTipsPhone.selected = YES;
    _btnTipsPassword1.selected = YES;
    _btnTipsPassword2.selected = YES;
    _ivTo1.image = [UIImage imageNamed:IMG_TO_3];
    _ivTo2.image = [UIImage imageNamed:IMG_TO_3];
    [_tradeInputView2 becomeFirstResponder];
}

- (IBAction)password2DoneBtnClicked:(id)sender {
    [self reqSetPayPass:_password configPayPass:_passwordOld oldPhone:_phoneNum oldSmsCode:_tfCode.text dragImgKey:_dragImgKey locationx:_locationx];
}

- (void)getUserData{
    [YYRequestUtility Post:@"user/info.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            TJRUser *user = [TJRUser yy_modelWithDictionary:responseDict[@"data"]];
            self.user = user;
            self.phoneNum = self.user.phone;
            if (_phoneNum.length>6) {
                NSString* start = [_phoneNum substringToIndex:3];
                NSString* end = [_phoneNum substringFromIndex:(_phoneNum.length - 3)];
                _lbVerifyPhoneNum.text = [NSString stringWithFormat:@"%@：%@*******%@", NSLocalizedStringForKey(@"已绑定手机号"), start,end];
            }
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - set password
- (void)reqSetPayPass:(NSString*)payPass configPayPass:(NSString*)configPayPass oldPhone:(NSString*)oldPhone oldSmsCode:(NSString*)oldSmsCode dragImgKey:(NSString*)dragImgKey locationx:(NSInteger)locationx
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        NSString* psw1 = [CommonUtil getMD5:payPass];
        NSString* psw2 = [CommonUtil getMD5:configPayPass];
        [[NetWorkManage shareSingleNetWork] reqUserSetPayPass:self payPass:psw1 configPayPass:psw2 oldPhone:oldPhone oldSmsCode:oldSmsCode dragImgKey:dragImgKey locationx:locationx finishedCallback:@selector(reqSetPayPassFinished:) failedCallback:@selector(reqSetPayPassFailed:)];
    }
}

- (void)reqSetPayPassFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([parser parseBaseIsOk:result]) {
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        ROOTCONTROLLER_USER.payPass = [CommonUtil getMD5:_password];
        [LoginSQLModel insertLoginInfo:ROOTCONTROLLER_USER];
        
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
    NSString* code = [NSString stringWithFormat:@"%@",[result objectForKey:@"code"]];
    if ([code isEqualToString:@"40016"]) {
        // 重新验证拖动图片
        bAutoReq = YES;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
    }
    
}

- (void)reqSetPayPassFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}


#pragma mark - 获取验证码
- (IBAction)getSecurityCode:(id)sender {
    [_tfCode resignFirstResponder];
    _tfCode.text = @"";
    [self requestCodeData];
}

- (void)requestCodeData{
    if ([judgeMent judgePhoneNum:_phoneNum]) {
        //手机号码符合要求，发送获取验证码请求
        [judgeMent getSecurityCodeAndControlBtn:_btnSecurityCode phoneNum:_phoneNum dragImgKey:_dragImgKey locationx:_locationx countryCode: self.user.countryCode];    //ROOTCONTROLLER_USER.countryCode
    }
}

#pragma mark tradeInputViewDelegate Methods
- (void)tradeInputView:(TradeInputView *)tradeInputView finish:(NSString *)password{
    if (tradeInputView == _tradeInputView1) {
        self.password = password;
    }else if (tradeInputView == _tradeInputView2) {
        self.passwordOld = password;
        if (![_passwordOld isEqualToString:_password]) {
            [self showToastCenter:NSLocalizedStringForKey(@"两次密码不相同")];
            return;
        }
    }
}

- (void)tradeInputView:(TradeInputView *)tradeInputView statue:(BOOL)statue{
    if (tradeInputView == _tradeInputView1) {
        _btnPassword1.enabled = statue;
        
    }else if (tradeInputView == _tradeInputView2) {
        _btnPassword2.enabled = statue;
    }
}

#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)sender {
    UITextField* tf = (UITextField*)sender;
    if (tf == _tfCode) {
        if (TTIsStringWithAnyText(_tfCode.text)) {
            _btnPhone.enabled = YES;
        }else{
            _btnPhone.enabled = NO;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [_tfCode becomeFirstResponder];
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

        self.dragImgKey = dragImgKey;
        self.locationx = puzzleOriginX;
        
        if (bAutoReq) {
            [self password2DoneBtnClicked:nil];
        }else{
            if (_phoneNum.length>6) {
                [self requestCodeData];
            }
        }
    }
}


- (void)dealloc {
    judgeMent.raDelegate = nil;
    [judgeMent close];
    [judgeMent release];
    [_passwordOld release];
    [_phoneNum release];
    [_password release];
    [_tradeInputView1 release];
    [_tradeInputView2 release];
    [_phoneView release];
    [_password1View release];
    [_password2View release];
    [_tfCode release];
    [_btnPhone release];
    [_btnPassword1 release];
    [_btnPassword2 release];
    [_lbPasswordTips1 release];
    [_phoneVerifyView release];
    [_lbVerifyPhoneNum release];
    [_btnTipsPhone release];
    [_btnTipsPassword1 release];
    [_btnTipsPassword2 release];
    [_dragImgKey release];
    [_btnSecurityCode release];
    [_ivTo1 release];
    [_ivTo2 release];
    [_lbTitle release];
    [super dealloc];
}
@end
