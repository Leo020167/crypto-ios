//
//  P2PAuthCustomerController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PAuthCustomerController.h"
#import "CommonUtil.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "RZWebImageView.h"

@interface P2PAuthCustomerController () {
    BOOL bReqFinished;
}


@property (retain, nonatomic) IBOutlet UILabel *lbName;
@property (retain, nonatomic) IBOutlet UILabel *lbIdNum;
@property (retain, nonatomic) IBOutlet UILabel *lbGuarantee1;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbGuarantee2;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutTipsViewHeight;
@property (retain, nonatomic) IBOutlet UILabel *lbStatus;
@property (retain, nonatomic) IBOutlet UILabel *lbReason;
@property (retain, nonatomic) IBOutlet UIButton *btnAgree;

@property (assign, nonatomic) int state;
@end

@implementation P2PAuthCustomerController

- (void)viewDidLoad {
    [super viewDidLoad];

    bReqFinished = YES;
    
    [self reqCertificationInfoData];
}

- (void)dealloc{

    [_scrollView release];
    [_lbName release];
    [_lbIdNum release];
    [_lbGuarantee1 release];
    [_lbGuarantee2 release];
    [_btnConfirm release];
    [_layoutTipsViewHeight release];
    [_lbStatus release];
    [_lbReason release];
    [_btnAgree release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}
- (IBAction)agreeBtnClicked:(id)sender {
    _btnAgree.selected = !_btnAgree.selected;
}

- (IBAction)confirmBtnClicked:(id)sender {
    
    if(!_btnAgree.selected){
        [self showToastCenter:NSLocalizedStringForKey(@"请确认协议书")];
        return;
    }
    
    NSString* stateStr = (_state == 2)?NSLocalizedStringForKey(@"申请取消商家认证"):NSLocalizedStringForKey(@"申请商家认证");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:stateStr preferredStyle:UIAlertControllerStyleAlert];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"申请") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_state == 2) {
            [weakSelf reqApplyForCancellation];
        }else{
            [weakSelf reqApplyForAuthenticate];
        }
        
    }];
    [alertController addAction:alertAction];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [weakSelf presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)protocolBtnClicked:(id)sender {
}

#pragma mark - 【商家认证】获取商家认证需要信息
- (void)reqCertificationInfoData
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PGetCertificationInfo:self  finishedCallback:@selector(reqCertificationInfoFinished:) failedCallback:@selector(reqCertificationInfoFailed:)];
    }
    
}

- (void)reqCertificationInfoFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){
        
        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSDictionary *dic = [dataDic objectForKey:@"otcCertification"];
        int state = [parser intParser:dic name:@"state"];
        Boolean idCertify = [parser boolParser:dic name:@"idCertify"];
        if (idCertify) {
            NSString* certNo = [parser stringParser:dic name:@"certNo"];
            NSString* realName = [parser stringParser:dic name:@"realName"];
            NSString* securityDeposit = [parser stringParser:dic name:@"securityDeposit"];
            NSString* reason = [parser stringParser:dic name:@"reason"];
            
            _lbName.text = realName;
            _lbIdNum.text = certNo;
            _lbGuarantee1.text = [NSString stringWithFormat:@"%@ USDT", securityDeposit];
            _lbGuarantee2.text = [NSString stringWithFormat:@"%@ USDT", securityDeposit];
            
            _btnConfirm.enabled = YES;
            if (state == 2) {
                [_btnConfirm setTitle:NSLocalizedStringForKey(@"申请取消商家认证") forState:UIControlStateNormal];
            } else if (state == 1) {
                [_btnConfirm setTitle:NSLocalizedStringForKey(@"申请认证中") forState:UIControlStateNormal];
                _btnConfirm.enabled = NO;
            } else if (state == 3) {
                [_btnConfirm setTitle:NSLocalizedStringForKey(@"取消认证中") forState:UIControlStateNormal];
                _btnConfirm.enabled = NO;
            } else {
                [_btnConfirm setTitle:NSLocalizedStringForKey(@"申请商家认证") forState:UIControlStateNormal];
            }
            self.state = state;
            _layoutTipsViewHeight.constant = TTIsStringWithAnyText(reason)?40:0;
            _lbReason.text = reason;
            
        }else{
            _btnConfirm.enabled = NO;
            NSString *msg = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"未实名不能申请商家认证") message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"实名认证") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self pageToViewControllerForName:@"MyOauthController"];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqCertificationInfoFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 【商家认证】申请成为商家
- (void)reqApplyForAuthenticate
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PCertificationAuthenticate:self  finishedCallback:@selector(reqAuthenticateFinished:) failedCallback:@selector(reqCertificationInfoFailed:)];
    }
    
}

- (void)reqAuthenticateFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self reqCertificationInfoData];
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

#pragma mark - 【商家认证】撤销成为商家
- (void)reqApplyForCancellation
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PApplyForCancellation:self  finishedCallback:@selector(reqApplyForCancellationFinished:) failedCallback:@selector(reqCertificationInfoFailed:)];
    }
    
}

- (void)reqApplyForCancellationFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self reqCertificationInfoData];
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}
@end
