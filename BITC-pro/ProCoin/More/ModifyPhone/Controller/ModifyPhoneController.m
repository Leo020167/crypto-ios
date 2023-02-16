//
//  ModifyPhoneController.m
//  Redz
//
//  Created by taojinroad on 2018/11/16.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "ModifyPhoneController.h"
#import "RAJudgement.h"
#import "TextFieldToolBar.h"
#import "PuzzleVerifyView.h"
#import "NetWorkManage+User.h"
#import "TJRBaseParserJson.h"
#import "CommonUtil.h"
#import "CountrySelectController.h"
#import "LoginSQLModel.h"

#define IMG_TO_1            @"pay_accout_logo_to1"
#define IMG_TO_2            @"pay_accout_logo_to2"
#define IMG_TO_3            @"pay_accout_logo_to3"

@interface ModifyPhoneController ()<RAJudgementDelegate,PuzzleVerifyViewDelegate>{
    
    BOOL bAutoChange;
    BOOL bAutoCheck;
    BOOL bReqFinished;
    
    RAJudgement         *judgeMent;
    RAJudgement         *judgeMentNew;
    TextFieldToolBar    *toolBar;
}

@property (retain, nonatomic) IBOutlet UIView *phoneView;
@property (retain, nonatomic) IBOutlet UIView *phoneNewView;
@property (retain, nonatomic) IBOutlet UITextField *tfCode;
@property (retain, nonatomic) IBOutlet UIButton *btnPhone;
@property (retain, nonatomic) IBOutlet UIView *phoneVerifyView;
@property (retain, nonatomic) IBOutlet UILabel *lbVerifyPhoneNum;
@property (retain, nonatomic) IBOutlet UIButton *btnTipsPhone;
@property (retain, nonatomic) IBOutlet UIButton *btnTipsPassword1;
@property (retain, nonatomic) IBOutlet UIButton *btnTipsPassword2;
@property (retain, nonatomic) IBOutlet UIButton *btnSecurityCode;
@property (retain, nonatomic) IBOutlet UIButton *btnSecurityNewCode;
@property (retain, nonatomic) IBOutlet UIImageView *ivTo1;
@property (retain, nonatomic) IBOutlet UIImageView *ivTo2;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UITextField *tfPhone;
@property (retain, nonatomic) IBOutlet UITextField *tfNewCode;
@property (retain, nonatomic) IBOutlet UIButton *btnNewPhone;
@property (retain, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *countryCodeLabel;

@property (retain, nonatomic) PuzzleVerifyView *puzzleVerifyView;
@property (copy, nonatomic) NSString *countryCode;
@property (copy, nonatomic) NSString *countryName;

@property (copy, nonatomic) NSString *dragImgKey;
@property (assign, nonatomic) NSInteger locationx;

@property (copy, nonatomic) NSString *phoneNum;
@end

@implementation ModifyPhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countryName = NSLocalizedStringForKey(@"香港");
    self.countryCode = @"+852";
    _countryNameLabel.text = self.countryName;
    _countryCodeLabel.text = self.countryCode;
    
    _phoneView.hidden = NO;
    _phoneNewView.hidden = YES;
    _btnTipsPhone.selected = YES;
    _btnTipsPassword1.selected = NO;
    _btnTipsPassword2.selected = NO;
    _ivTo1.image = [UIImage imageNamed:IMG_TO_2];
    _ivTo2.image = [UIImage imageNamed:IMG_TO_1];
    
    self.dragImgKey = @"";
    
    bReqFinished = YES;
    
    judgeMent = [[RAJudgement alloc]init];
    judgeMent.raDelegate = self;
    
    judgeMentNew = [[RAJudgement alloc]init];
    judgeMentNew.raDelegate = self;
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:2];
    _tfPhone.inputAccessoryView = toolBar;
    _tfNewCode.inputAccessoryView = toolBar;
    
    _puzzleVerifyView = [[PuzzleVerifyView alloc]initWithFrame:phoneRectScreen];
    _puzzleVerifyView.delegate = self;
    [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"完成验证获取验证码")];
    
//    self.phoneNum = ROOTCONTROLLER_USER.userAccount;
//    if (_phoneNum.length>6) {
//        NSString* start = [_phoneNum substringToIndex:3];
//        NSString* end = [_phoneNum substringFromIndex:(_phoneNum.length - 3)];
//        _lbVerifyPhoneNum.text = [NSString stringWithFormat:@"%@：%@*******%@", NSLocalizedStringForKey(@"已绑定手机号"), start,end];
//    }else{
//        _lbVerifyPhoneNum.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"已绑定邮箱号"), ROOTCONTROLLER_USER.email];
//    }
    [YYRequestUtility Post:@"user/info.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            TJRUser *user = [TJRUser yy_modelWithDictionary:responseDict[@"data"]];
            self.phoneNum = user.phone;
            if (_phoneNum.length>6) {
                NSString* start = [_phoneNum substringToIndex:3];
                NSString* end = [_phoneNum substringFromIndex:(_phoneNum.length - 3)];
                _lbVerifyPhoneNum.text = [NSString stringWithFormat:@"%@：%@*******%@", NSLocalizedStringForKey(@"已绑定手机号"), start,end];
            }else{
                _phoneNum = @"";
                _phoneView.hidden = YES;
                _phoneNewView.hidden = NO;
                _btnTipsPhone.selected = NO;
                _btnTipsPassword1.selected = YES;
                _ivTo1.image = [UIImage imageNamed:IMG_TO_1];
                _ivTo2.image = [UIImage imageNamed:IMG_TO_2];
                [_btnTipsPassword1 setTitle:NSLocalizedStringForKey(@"绑定手机") forState:0];
                self.tfPhone.placeholder = NSLocalizedStringForKey(@"请输入手机号码");
                _btnTipsPassword2.selected = NO;
                _lbTitle.text = NSLocalizedStringForKey(@"绑定手机");
            }
            
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {

    }];
    
}

- (IBAction)leftButtonClicked:(id)sender
{
    [self goBack];
}

- (IBAction)phoneNextBtnClicked:(id)sender {
    bAutoCheck = NO;
    [_tfCode resignFirstResponder];
    if ([judgeMent judgePhoneNum:_phoneNum] && [judgeMent judgeSecurityCode:_tfCode.text]) {
        

        [self reqCheckIdentity:_phoneNum smsCode:_tfCode.text dragImgKey:_dragImgKey locationx:_locationx];
    }
}

- (IBAction)countryCodeButtonPressed:(id)sender
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


- (IBAction)phoneNewDoneBtnClicked:(id)sender {
    bAutoChange = NO;
    [_tfPhone resignFirstResponder];
    [_tfNewCode resignFirstResponder];
    if ([judgeMent judgePhoneNum:_tfPhone.text] && [judgeMent judgeSecurityCode:_tfNewCode.text]) {
        if (!self.phoneNum.length) {
            [YYRequestUtility Post:@"user/security/updatePhone.do" addParameters:@{@"phone" : self.tfPhone.text, @"code" : _tfNewCode.text, @"countryCode": self.countryCode} progress:nil success:^(NSDictionary *responseDict) {
                NSLog(@"responseDict : %@", responseDict);
                if ([responseDict[@"code"] intValue] == 200) {
                    [QMUITips showSucceed:responseDict[@"msg"]];
                    if (self.isForSetPayPwd) {
                        TJRBaseViewController* ctr = (TJRBaseViewController *)ROOTCONTROLLER.navigationController.topViewController;
                        [ctr pageToOrBackWithName:@"PayPasswordController"];
                        /// 移除当前界面
                        NSMutableArray *naviVCsArr = [[NSMutableArray alloc]initWithArray:ROOTCONTROLLER.navigationController.viewControllers];
                        for (UIViewController *vc in naviVCsArr) {
                            if ([vc isKindOfClass:[ModifyPhoneController class]]) {
                                [naviVCsArr removeObject:vc];
                                break;
                            }
                        }
                        ROOTCONTROLLER.navigationController.viewControllers = naviVCsArr;
                        
                    } else {
                        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
                    }
                }else{
                    [QMUITips showError:responseDict[@"msg"]];
                }
            } failure:^(NSError *error) {
        
            }];
        }else{
            [self reqChangePhoneTwo:_tfPhone.text newSmsCode:_tfNewCode.text oldPhone:_phoneNum oldSmsCode:_tfCode.text dragImgKey:_dragImgKey locationx:_locationx];
        }
    }
}

#pragma mark - ChangePhoneTwo
- (void)reqChangePhoneTwo:(NSString*)newPhone newSmsCode:(NSString*)newSmsCode oldPhone:(NSString*)oldPhone oldSmsCode:(NSString*)oldSmsCode dragImgKey:(NSString*)dragImgKey locationx:(NSInteger)locationx
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqUserChangePhoneTwo:self newPhone:newPhone newCountryCode:self.countryCode newSmsCode:newSmsCode oldPhone:oldPhone oldSmsCode:oldSmsCode dragImgKey:dragImgKey locationx:locationx finishedCallback:@selector(reqChangePhoneTwoFinished:) failedCallback:@selector(reqFailed:)];
    }
}

- (void)reqChangePhoneTwoFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([parser parseBaseIsOk:result]) {
        
        _phoneView.hidden = YES;
        _phoneNewView.hidden = NO;
        _btnTipsPhone.selected = YES;
        _btnTipsPassword1.selected = YES;
        _btnTipsPassword2.selected = YES;
        _ivTo1.image = [UIImage imageNamed:IMG_TO_3];
        _ivTo2.image = [UIImage imageNamed:IMG_TO_3];
        
        ROOTCONTROLLER_USER.userAccount = _tfPhone.text;
        ROOTCONTROLLER_USER.countryCode = self.countryCode;
        [LoginSQLModel updateLoginInfo:ROOTCONTROLLER.user];
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
    NSString* code = [NSString stringWithFormat:@"%@",[result objectForKey:@"code"]];
    if ([code isEqualToString:@"40016"]) {
        // 重新验证拖动图片
        bAutoChange = YES;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
    }
    
}

- (void)reqFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - CheckIdentity
- (void)reqCheckIdentity:(NSString*)phone smsCode:(NSString*)smsCode dragImgKey:(NSString*)dragImgKey locationx:(NSInteger)locationx
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqUserCheckIdentity:self phone:phone smsCode:smsCode dragImgKey:dragImgKey locationx:locationx finishedCallback:@selector(reqCheckIdentityFinished:) failedCallback:@selector(reqFailed:)];
    }
}

- (void)reqCheckIdentityFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([parser parseBaseIsOk:result]) {

        _phoneView.hidden = YES;
        _phoneNewView.hidden = NO;
        _btnTipsPhone.selected = YES;
        _btnTipsPassword1.selected = YES;
        _btnTipsPassword2.selected = NO;
        _ivTo1.image = [UIImage imageNamed:IMG_TO_3];
        _ivTo2.image = [UIImage imageNamed:IMG_TO_2];

    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
    NSString* code = [NSString stringWithFormat:@"%@",[result objectForKey:@"code"]];
    if ([code isEqualToString:@"40016"]) {
        // 重新验证拖动图片
        bAutoCheck = YES;
        [_puzzleVerifyView show:self.view];
        [_puzzleVerifyView setTips:NSLocalizedStringForKey(@"请重新拖动验证图片")];
    }
    
}

#pragma mark - 获取验证码
- (IBAction)getSecurityCode:(id)sender {
    [_tfCode resignFirstResponder];
    _tfCode.text = @"";
    _tfPhone.text = @"";
    [self requestCodeData];
}

- (IBAction)getNewSecurityCode:(id)sender {
    [_tfNewCode resignFirstResponder];
    _tfNewCode.text = @"";
    [self requestNewCodeData];
}

- (void)requestNewCodeData{
    if ([judgeMentNew judgePhoneNum:_tfPhone.text]) {
        [judgeMentNew getSecurityCodeAndControlBtn:_btnSecurityNewCode phoneNum:_tfPhone.text dragImgKey:_dragImgKey locationx:_locationx countryCode:self.countryCode];
    }
}

- (void)requestCodeData{
    if ([judgeMent judgePhoneNum:_phoneNum]) {
        [judgeMent getSecurityCodeAndControlBtn:_btnSecurityCode phoneNum:_phoneNum dragImgKey:_dragImgKey locationx:_locationx countryCode:ROOTCONTROLLER_USER.countryCode];
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
    }else if (tf == _tfPhone || tf == _tfNewCode) {
        if (TTIsStringWithAnyText(_tfNewCode.text) && TTIsStringWithAnyText(_tfPhone.text)) {
            _btnNewPhone.enabled = YES;
        }else{
            _btnNewPhone.enabled = NO;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [_tfPhone becomeFirstResponder];
            break;
        case 2:
            [_tfNewCode becomeFirstResponder];
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
- (void)TFDonePressed
{
    [_tfPhone resignFirstResponder];
    [_tfNewCode resignFirstResponder];
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
        bAutoChange = NO;
        bAutoCheck = NO;
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
        
        if (bAutoCheck && !bAutoChange) {
            [self phoneNextBtnClicked:nil];
        }else if (!bAutoCheck && bAutoChange) {
            [self phoneNewDoneBtnClicked:nil];
        }else{
            if (TTIsStringWithAnyText(_tfPhone.text)) {
                [self requestNewCodeData];
            }else{
                [self requestCodeData];
            }
        }
    }
}


- (void)dealloc {
    judgeMent.raDelegate = nil;
    [judgeMent close];
    [judgeMent release];
    judgeMentNew.raDelegate = nil;
    [judgeMentNew close];
    [judgeMentNew release];
    [_phoneNum release];
    [_phoneView release];
    [_tfCode release];
    [_btnPhone release];
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
    [_tfPhone release];
    [_tfNewCode release];
    [_phoneNewView release];
    [_btnNewPhone release];
    [_btnSecurityNewCode release];
    [_countryNameLabel release];
    [_countryCodeLabel release];
    [_countryCode release];
    [_countryName release];
    [super dealloc];
}
@end
