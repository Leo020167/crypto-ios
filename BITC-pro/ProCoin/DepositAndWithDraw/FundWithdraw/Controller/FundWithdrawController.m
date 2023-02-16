//
//  FundWithdrawController.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundWithdrawController.h"
#import "NetWorkManage+Trade.h"
#import "TradeUtil.h"
#import "TextFieldToolBar.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "OwnReceiptEntity.h"
#import "RZWebImageView.h"
#import "FundExchangeOrderEntity.h"
#import "PayAlertView.h"
#import "TradeConfigInfoEntity.h"

@interface FundWithdrawController ()<UITextFieldDelegate>
{
    BOOL isRequestFinished;
    TextFieldToolBar *toolBar;
    NSInteger decimalDotBits;               //小数位数
}


@property (retain, nonatomic) TradeConfigInfoEntity *configInfoEntity;      //信息对象
@property (retain, nonatomic) OwnReceiptEntity *receiptEntity;          //默认收款方式
@property (retain, nonatomic) IBOutlet UIView *defaultModeView;         //默认收款view
@property (retain, nonatomic) IBOutlet RZWebImageView *receiptLogo;     //收款方式logo
@property (retain, nonatomic) IBOutlet UILabel *receiptWayLabel;        //收款方式名称
@property (retain, nonatomic) IBOutlet UILabel *receiptTitleLabel;      //收款标题
@property (retain, nonatomic) IBOutlet UILabel *receiptNameLabel;       //收款姓名
@property (retain, nonatomic) IBOutlet UIView *addModeView;             //增加收款view
@property (retain, nonatomic) IBOutlet UITextField *coinAmountTF;       //提币数量文本
@property (retain, nonatomic) IBOutlet UILabel *ownUsdtTipsLabel;       //持有usdt数量文本
@property (retain, nonatomic) IBOutlet UILabel *usdtPriceLabel;         //市价文本
@property (retain, nonatomic) IBOutlet UILabel *tolPriceLabel;          //金额文本
@property (retain, nonatomic) IBOutlet UIButton *commitButton;          //提交订单按钮


@end

@implementation FundWithdrawController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    decimalDotBits = 6;
    self.receiptEntity = nil;
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _coinAmountTF.inputAccessoryView = toolBar;
    _coinAmountTF.delegate = self;
    [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 0.7)] forState:UIControlStateNormal];
    _commitButton.enabled = NO;
    isRequestFinished = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self showProgressDefaultText];
    [self reqWithdrawConfig];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawReceiptEntity"]){
        self.receiptEntity = [self getValueFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawReceiptEntity"];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawReceiptEntity"];
        [self updateDefaultReceiptViewInfo];
    }else{
        //为了保证删除等影响，重新回来需要调用默认的收款方式
        [self reqUserDefaultWithdrawMode];
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_coinAmountTF release];
    [_ownUsdtTipsLabel release];
    [_usdtPriceLabel release];
    [_tolPriceLabel release];
    [_configInfoEntity release];
    [_receiptEntity release];
    [_defaultModeView release];
    [_addModeView release];
    [_commitButton release];
    [_receiptLogo release];
    [_receiptWayLabel release];
    [_receiptTitleLabel release];
    [_receiptNameLabel release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)commitOrderButtonPressed:(id)sender
{
    if(self.receiptEntity == nil || !checkIsStringWithAnyText(self.receiptEntity.receiptId)){
        [self showToastCenter:NSLocalizedStringForKey(@"请选择收款方式")];
        return;
    }
    if(!checkIsStringWithAnyText(_coinAmountTF.text) || _coinAmountTF.text.floatValue <= 0){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入提取数量")];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定提现") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqWithdrawUSDT:@""];
    }]];
    [self presentViewController:alertController animated:NO completion:nil];
}

- (IBAction)withdrawModeButtonPressed:(id)sender
{
    [self putValueToParamDictionary:FundExchangeDic value:@"1" forKey:@"FundWithdrawManagerIsWithdrawPageTo"];
    [self pageToViewControllerForName:@"FundWithdrawManagerController"];
}

/** 全部按钮点击事件*/
- (IBAction)allOwnAssetsButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(_configInfoEntity.holdUsdt)){
        _coinAmountTF.text = [TradeUtil stringRoundDownFloatValue:[_configInfoEntity.holdUsdt doubleValue] dotBits:decimalDotBits];
    }else{
        _coinAmountTF.text = @"0";
    }
}

#pragma mark - 请求数据
- (void)reqUserDefaultWithdrawMode
{
    [[NetWorkManage shareSingleNetWork] reqUserDefaultReceiptMode:self finishedCallback:@selector(reqUserDefaultWithdrawModeFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqUserDefaultWithdrawModeFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *receiptDic = [dataDic objectForKey:@"receipt"];
        if(receiptDic == nil){
            self.receiptEntity = nil;
        }else{
            self.receiptEntity = [[[OwnReceiptEntity alloc] initWithJson:receiptDic] autorelease];
        }
        
        [self updateDefaultReceiptViewInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqWithdrawConfig
{
    [[NetWorkManage shareSingleNetWork] reqDepositUSDTConfig:self symbol:@"" targetUid:@"" finishedCallback:@selector(reqWithdrawConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqWithdrawConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        isRequestFinished = YES;
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.configInfoEntity = [[[TradeConfigInfoEntity alloc] initWithJson:dataDic] autorelease];
        [self updateViewInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 请求提现*/
- (void)reqWithdrawUSDT:(NSString *)payPass
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqWithdrawUSDTOrder:self amount:_coinAmountTF.text receiptId:self.receiptEntity.receiptId payPass:payPass finishedCallback:@selector(reqWithdrawUSDTFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqWithdrawUSDTFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *orderDic = [dataDic objectForKey:@"order"];
        FundExchangeOrderEntity *orderEntity = [[[FundExchangeOrderEntity alloc] initWithJson:orderDic] autorelease];
        [self putValueToParamDictionary:FundExchangeDic value:orderEntity.orderCashId forKey:@"FundWithdrawDetailCashId"];
        [self pageToViewControllerForName:@"FundWithdrawDetailController"];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
}


#pragma mark - 更新页面数据
- (void)updateDefaultReceiptViewInfo
{
    if(self.receiptEntity){
        _defaultModeView.hidden = NO;
        _addModeView.hidden = YES;
        [_receiptLogo showImageWithUrl:_receiptEntity.receiptTypeLogo];
        _receiptWayLabel.text = _receiptEntity.receiptTypeValue;
        if(_receiptEntity.receiptType == 1 || _receiptEntity.receiptType == 2){
            _receiptTitleLabel.text = _receiptEntity.receiptNo;
        }else if(_receiptEntity.receiptType == 3){
            NSString *simpleNo = @"";
            if(_receiptEntity.receiptNo.length > 4){
                simpleNo = [_receiptEntity.receiptNo substringWithRange:NSMakeRange(_receiptEntity.receiptNo.length - 4, 4)];
            }else{
                simpleNo = _receiptEntity.receiptNo;
            }
            _receiptTitleLabel.text = [NSString stringWithFormat:@"%@(%@)",_receiptEntity.bankName,simpleNo];
        }
        _receiptNameLabel.text = _receiptEntity.receiptName;
    }else{
        _defaultModeView.hidden = YES;
        _addModeView.hidden = NO;
    }
}

- (void)updateViewInfo
{
    if(isRequestFinished){
        _ownUsdtTipsLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"可提现数量"), [TradeUtil stringRoundDownFloatValue:[_configInfoEntity.holdUsdt doubleValue] dotBits:decimalDotBits]];
        _usdtPriceLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"提现单价"), [TradeUtil stringByAppendingRMBSymbolString:_configInfoEntity.usdtRateWithdraw]];
        _tolPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",(CGFloat)([_coinAmountTF.text floatValue]*[_configInfoEntity.usdtRateWithdraw floatValue])];
    }
    
}

#pragma mark - TextFieldToolBar delegate
- (void)TFDonePressed
{
    [_coinAmountTF resignFirstResponder];
    if(!checkIsStringWithAnyText(_coinAmountTF.text)){
        _coinAmountTF.text = @"0";
    }
    [self updateViewInfo];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:9 dotAfterBits:decimalDotBits];
}


#pragma mark -
- (void)textFieldTextDidChanged:(NSNotification *)notiInfo
{
    
    if(checkIsStringWithAnyText(_coinAmountTF.text)){
        [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 1.0)] forState:UIControlStateNormal];
        _commitButton.enabled = YES;
        _tolPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",(CGFloat)([_coinAmountTF.text floatValue]*[_configInfoEntity.usdtRateWithdraw floatValue])];
    }else{
        [_commitButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 0.7)] forState:UIControlStateNormal];
        _commitButton.enabled = NO;
        _tolPriceLabel.text = @"¥0.00";
    }
}


#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqWithdrawUSDT:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

@end
