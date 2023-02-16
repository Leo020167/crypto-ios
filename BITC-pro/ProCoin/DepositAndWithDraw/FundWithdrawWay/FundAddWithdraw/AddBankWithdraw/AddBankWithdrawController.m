//
//  AddBankWithdrawController.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "AddBankWithdrawController.h"
#import "NetWorkManage+Trade.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "PayAlertView.h"

@interface AddBankWithdrawController ()<UITextFieldDelegate>
{
}

@property (copy, nonatomic) NSString *receiptType;
@property (retain, nonatomic) IBOutlet UITextField *nameTF;             //姓名
@property (retain, nonatomic) IBOutlet UITextField *cardNumTF;          //银行卡号
@property (retain, nonatomic) IBOutlet UITextField *bankNameTF;         //开户银行
@property (retain, nonatomic) IBOutlet UITextField *bankAdderssTF;      //开户地址(选填)
@property (retain, nonatomic) IBOutlet UIButton *addModeButton;         //添加按钮
@property (retain, nonatomic) IBOutlet UIView *infoTipsView;            //信息提示view

@end

@implementation AddBankWithdrawController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _nameTF.delegate = self;
    _cardNumTF.delegate = self;
    _bankNameTF.delegate = self;
    [_addModeButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 1.0)] forState:UIControlStateNormal];
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"AddBankWithdrawReceiptType"]){
        self.receiptType = [self getValueFromModelDictionary:FundExchangeDic forKey:@"AddBankWithdrawReceiptType"];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"AddBankWithdrawReceiptType"];
    }
    
    [self addBorderToLayer:_infoTipsView];
}

- (void)dealloc
{
    [_receiptType release];
    [_nameTF release];
    [_cardNumTF release];
    [_bankNameTF release];
    [_bankAdderssTF release];
    [_addModeButton release];
    [_infoTipsView release];
    [super dealloc];
}

/** 为view添加虚线描边边框*/
- (void)addBorderToLayer:(UIView *)view
{
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = RGBA(255, 143, 1.0, 1).CGColor;
    border.fillColor = nil;
    CGRect frame = view.bounds;
    frame.size.width = SCREEN_WIDTH - 30;
    border.path = [UIBezierPath bezierPathWithRect:frame].CGPath;
    border.frame = frame;
    border.lineWidth = 1;
    border.lineCap = @"square";
    border.lineDashPattern = @[@3, @3];
    [view.layer addSublayer:border];
}


#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)saveBankWithdrawButtonPressed:(id)sender
{
    if(!checkIsStringWithAnyText(_cardNumTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入银行卡号")];
        return;
    }
    
    if(!checkIsStringWithAnyText(_bankNameTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入开户行")];
        return;
    }
    
    if(!checkIsStringWithAnyText(_nameTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入姓名")];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定保存该收款方式?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqSaveReceipt:@""];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)backgroundViewTouchDown:(id)sender
{
    [_nameTF resignFirstResponder];
    [_bankNameTF resignFirstResponder];
    [_cardNumTF resignFirstResponder];
}

#pragma mark - 请求数据
- (void)reqSaveReceipt:(NSString *)payPass
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqUserSaveReceipt:self receiptType:_receiptType receiptId:@"0" receiptName:_nameTF.text receiptNo:_cardNumTF.text bankName:_bankNameTF.text bankBranch:@"" qrCodeUrl:@"" payPass:payPass finishedCallback:@selector(reqSaveReceiptFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSaveReceiptFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"保存成功")];
        }
        
        [self goBackToViewControllerForName:@"FundWithdrawManagerController" animated:YES];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqSaveReceipt:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}
@end
