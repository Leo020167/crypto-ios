//
//  CMDepositController.m
//  Cropyme
//
//  Created by Hay on 2019/5/11.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CMDepositController.h"
#import "NetWorkManage+Trade.h"
#import "TradeConfigInfoEntity.h"
#import "CMDDepositWayView.h"
#import "RZWebImageView.h"
#import "FundExchangeOrderEntity.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"
#import "CommonUtil.h"
#import "CMDDepositWayView.h"
#import "OTCTradeEntity.h"

@interface CMDepositController ()<UITextFieldDelegate,TextFieldToolBarDelegate,CMDDepositWayViewDelegate>
{
    NSMutableArray *wayListArr;
    BOOL isRequestFinished;             //是否请求完成
    NSInteger selectWayIndex;           //选择方式索引
    TextFieldToolBar *toolBar;
}
@property (copy, nonatomic) NSString *recharge;                 //其他页面传过来的充值金额

@property (retain, nonatomic) TradeConfigInfoEntity *configEntity;

@property (retain, nonatomic) IBOutlet UITextField *inputMoneyTF;       //输入金额
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;
@property (retain, nonatomic) IBOutlet UILabel *decimalLabel;
@property (retain, nonatomic) IBOutlet UIButton *depositButton;             //购买按钮


@end

@implementation CMDepositController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputMoneyTextFieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    selectWayIndex = -1;                //默认值
    wayListArr = [[NSMutableArray alloc] init];
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _inputMoneyTF.inputAccessoryView = toolBar;
    _inputMoneyTF.delegate = self;
    [_depositButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
    _depositButton.enabled = NO;
    isRequestFinished = NO;
    
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositRecharge"]){
        self.recharge = [self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositRecharge"];
        if(checkIsStringWithAnyText(_recharge)){
            _inputMoneyTF.text = self.recharge;
        }else{
            _inputMoneyTF.text = @"";
        }
        
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"CMDepositRecharge"];
    }
    
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositPlaceHolder"]){
        [_inputMoneyTF setPlaceholder:[self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositPlaceHolder"]];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"CMDepositPlaceHolder"];
    }
    
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositReceiptWayList"]){
        [wayListArr removeAllObjects];
        if([[self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositReceiptWayList"] isKindOfClass:[NSArray class]]){
            [wayListArr addObjectsFromArray:[self getValueFromModelDictionary:FundExchangeDic forKey:@"CMDepositReceiptWayList"]];
        }
        
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"CMDepositReceiptWayList"];
    }
    
    [self showProgressDefaultText];
    [self reqDepositConfig];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [wayListArr release];
    [_recharge release];
    [_configEntity release];
    [_inputMoneyTF release];
    [_priceLabel release];
    [_amountLabel release];
    [_decimalLabel release];
    [_depositButton release];
    [super dealloc];
}



#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/** 充值按钮点击事件*/
- (IBAction)depositButtonPressed:(id)sender
{
    [_inputMoneyTF resignFirstResponder];
    if(!checkIsStringWithAnyText(self.inputMoneyTF.text) || [self.inputMoneyTF.text integerValue] <= 0){
        [self showToastCenter:@"请输入正确的充值金额"];
        return;
    }
    
    if([wayListArr count] == 0){
        [self showToastCenter:@"获取他人收款方式错误"];
        return;
    }
    CMDDepositWayView *depositView = (CMDDepositWayView *)[[[NSBundle mainBundle] loadNibNamed:@"CMDDepositWayView" owner:nil options:nil] lastObject];
    depositView.delegate = self;
    [depositView showDepositWayViewInView:self.view wayCount:[wayListArr count]];
    [depositView reloadDepositWayData:wayListArr];
    

}

//- (IBAction)commitOrderButtonPressed:(id)sender
//{
//    [self.tableHeaderView TFDonePressed];       //关闭键盘
//    if(!checkIsStringWithAnyText([self.tableHeaderView inputMoney]) || [[self.tableHeaderView inputMoney] integerValue] <= 0){
//        [self showToastCenter:@"请输入正确的充值金额"];
//        return;
//    }
//
//    if(selectWayIndex == -1){
//        [self showToastCenter:NSLocalizedStringForKey(@"请选择支付方式")];
//        return;
//    }
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"是否确定进行充值USDT" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [self reqDepositUSDTOrder];
//    }]];
//    [self presentViewController:alertController animated:YES completion:nil];
//}

#pragma mark - 请求数据
- (void)reqDepositConfig
{
    [[NetWorkManage shareSingleNetWork] reqDepositUSDTConfig:self symbol:@"" targetUid:@"" finishedCallback:@selector(reqDepositConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqDepositConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        isRequestFinished = YES;
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.configEntity = [[[TradeConfigInfoEntity alloc] initWithJson:dataDic] autorelease];
        _priceLabel.text = [NSString stringWithFormat:@"购买单价：%@",[TradeUtil stringByAppendingRMBSymbolString:_configEntity.usdtRate]];
        _amountLabel.text = [NSString stringWithFormat:@"购买数量：%.6f USDT",(CGFloat)([_inputMoneyTF.text floatValue]/[_configEntity.usdtRate floatValue])];
        _decimalLabel.text = [NSString stringWithFormat:@".%@",_configEntity.randomNum];

    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

//- (void)reqUserFundPayList
//{
//    [[NetWorkManage shareSingleNetWork] reqUserFundPayList:self finishedCallback:@selector(reqUserFundPayListFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
//}
//
//- (void)reqUserFundPayListFinished:(NSDictionary *)json
//{
//    [self dismissProgress];
//    if([self checkJsonIsSuccess:json]){
//        NSDictionary *dataDic = [json objectForKey:@"data"];
//        NSArray *receiptList = [dataDic objectForKey:@"receiptList"];
//        for(NSDictionary *dic in receiptList){
//            FundExchangeWayEntity *entity = [[[FundExchangeWayEntity alloc] initWithJson:dic] autorelease];
//            [wayListArr addObject:entity];
//        }
//
//    }else{
//        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
//    }
//}

/** 充值*/
- (void)reqDepositUSDTOrder
{
    [self showProgressDefaultText];
    OTCReceiptEntity *entity = [wayListArr objectAtIndex:selectWayIndex];
    [[NetWorkManage shareSingleNetWork] reqDepositUSDTOrder:self cny:[NSString stringWithFormat:@"%@.%@",_inputMoneyTF.text,self.configEntity.randomNum] receiptId:entity.receiptId finishedCallback:@selector(reqDepositUSDTOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqDepositUSDTOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *orderDic = [dataDic objectForKey:@"order"];
        [self putValueToParamDictionary:FundExchangeDic value:@"1" forKey:@"FundMainNeedUpdate"];
        FundExchangeOrderEntity *orderEntity = [[[FundExchangeOrderEntity alloc] initWithJson:orderDic] autorelease];
        [self putValueToParamDictionary:FundExchangeDic value:orderEntity.orderCashId forKey:@"FundPayDetailOrderCashId"];
        [self pageToViewControllerForNameAndPopCurrentController:@"FundPayDetailController"];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark -
- (void)TFDonePressed
{
    [_inputMoneyTF resignFirstResponder];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:0];
}

#pragma mark - observe
- (void)inputMoneyTextFieldTextDidChanged:(NSNotification *)notification
{
    if(checkIsStringWithAnyText(_inputMoneyTF.text)){
        _amountLabel.text = [NSString stringWithFormat:@"购买数量：%.6f USDT",(CGFloat)([[NSString stringWithFormat:@"%@%@",_inputMoneyTF.text,_decimalLabel.text] floatValue]/[_configEntity.usdtRate floatValue])];
        [_depositButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 1.0)] forState:UIControlStateNormal];
        _depositButton.enabled = YES;
    }else{
        [_depositButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(97, 117, 174, 0.7)] forState:UIControlStateNormal];
        _depositButton.enabled = NO;
        _amountLabel.text = @"购买数量：0.000000";
    }
    
}


#pragma mark - CMDepositWayView delegate
- (void)depositWayViewDidSelectedWayWithIndex:(NSInteger)index
{
    selectWayIndex = index;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"是否确定充值¥%@.%@金额的USDT"),_inputMoneyTF.text,self.configEntity.randomNum] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqDepositUSDTOrder];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}



@end
