//
//  FollowOrderController.m
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FollowOrderController.h"
#import "NetWorkManage+FollowOrder.h"
#import "CommonUtil.h"
#import "NetWorkManage+Trade.h"
#import "TradeConfigInfoEntity.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"

@interface FollowOrderController ()<TextFieldToolBarDelegate,UITextFieldDelegate>
{
    TextFieldToolBar *tolBalanceToolBar;
    TextFieldToolBar *perMaxBalanceToolBar;
}

@property (copy, nonatomic) NSString *followUid;            //被跟单的userId
@property (retain, nonatomic) TradeConfigInfoEntity *configEntity;
@property (retain, nonatomic) IBOutlet UILabel *assetsLabel;                //个人资产
@property (retain, nonatomic) IBOutlet UITextField *tolBalanceTF;           //跟单总金额
@property (retain, nonatomic) IBOutlet UILabel *tolBalanceCNYLabel;         //跟单总金额描述
@property (retain, nonatomic) IBOutlet UITextField *perMaxBalanceTF;        //每次跟随最大金额
@property (retain, nonatomic) IBOutlet UILabel *perMaxBalanceCNYLabel;      //每次最大金额描述
@property (retain, nonatomic) IBOutlet UILabel *maxProfitRateLabel;         //止盈
@property (retain, nonatomic) IBOutlet UISlider *profitRateSlider;          //止盈选择器
@property (retain, nonatomic) IBOutlet UILabel *maxLossRateLabel;           //止损
@property (retain, nonatomic) IBOutlet UISlider *lossRateSlider;            //止损选择器
@property (retain, nonatomic) IBOutlet UIButton *followOrderButton;         //跟单按钮
@end

@implementation FollowOrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_followOrderButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(61, 58, 80, 1.0)] forState:UIControlStateNormal];
    tolBalanceToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _tolBalanceTF.inputAccessoryView = tolBalanceToolBar;
    perMaxBalanceToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _perMaxBalanceTF.inputAccessoryView = perMaxBalanceToolBar;
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"FollowOrderFollowUid"]){
        self.followUid = [self getValueFromModelDictionary:CoinTradeDic forKey:@"FollowOrderFollowUid"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"FollowOrderFollowUid"];
    }
    _tolBalanceTF.delegate = self;
    _perMaxBalanceTF.delegate = self;
    [self reqUsdtConfig];
}

- (void)dealloc
{
    [tolBalanceToolBar release];
    [perMaxBalanceToolBar release];
    [_followUid release];
    [_configEntity release];
    [_followOrderButton release];
    [_assetsLabel release];
    [_tolBalanceTF release];
    [_perMaxBalanceTF release];
    [_maxProfitRateLabel release];
    [_maxLossRateLabel release];
    [_profitRateSlider release];
    [_lossRateSlider release];
    [_tolBalanceCNYLabel release];
    [_perMaxBalanceCNYLabel release];
    [super dealloc];
}

#pragma mark - 按钮点击事件

- (IBAction)followOrderButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定进行跟单操作") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqFollowOrderOperation];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)profitSliderValueDidChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    CGFloat percentage = slider.value;
    if(percentage == 0){
        _maxProfitRateLabel.text = NSLocalizedStringForKey(@"止盈 未设置");
    }else{
        _maxProfitRateLabel.text = [NSString stringWithFormat:@"%@ +%@%%", NSLocalizedStringForKey(@"止盈"), [TradeUtil stringRoundDownFloatValue:(percentage * 100) dotBits:0]];
    }
    
}

- (IBAction)lossSliderValueDidChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    CGFloat percentage = slider.value;
    if(percentage == 0){
        _maxLossRateLabel.text = NSLocalizedStringForKey(@"止损 未设置");
    }else{
       _maxLossRateLabel.text = [NSString stringWithFormat:@"%@ -%@%%", NSLocalizedStringForKey(@"止损"), [TradeUtil stringRoundDownFloatValue:(percentage * 100) dotBits:0]];
    }
    
}

- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)riskButtonPressed:(id)sender
{
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = @"http://api.cropyme.com/crpm/html/liability-protocol.html";
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}


#pragma mark - 请求数据
- (void)reqUsdtConfig
{
    [[NetWorkManage shareSingleNetWork] reqDepositUSDTConfig:self symbol:@"" targetUid:@"" finishedCallback:@selector(reqUsdtConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqUsdtConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.configEntity = [[[TradeConfigInfoEntity alloc] initWithJson:dataDic] autorelease];
        _assetsLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"可用USDT:%@"),_configEntity.holdUsdt];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqFollowOrderOperation
{
//    NSString *stopWin = [TradeUtil stringRoundDownFloatValue:_profitRateSlider.value dotBits:2];
//    NSString *lossWin = [TradeUtil stringRoundDownFloatValue:_lossRateSlider.value dotBits:2];
//    [[NetWorkManage shareSingleNetWork] reqFollowOrderOperation:self followUid:_followUid balance:_tolBalanceTF.text maxfollowBalance:_perMaxBalanceTF.text stopWin:stopWin stopLoss:lossWin finishedCallback:@selector(reqFollowOrderOperationFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderOperationFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"跟单成功");
        }
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *orderId = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"orderId"]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self putValueToParamDictionary:FollowOrderDict value:@"1" forKey:@"PersonMainControllerNeedUpdate"];
            [self putValueToParamDictionary:CoinTradeDic value:orderId forKey:@"FollowOrderDetailOrderId"];
            [self pageToViewControllerForNameAndPopCurrentController:@"FollowOrderDetailController"];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }else{
        if(![self checkIsNotEnoughCash:json]){
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }else{              //资金不足
            NSDictionary *dataDic = [json objectForKey:@"data"];
            if(dataDic && [dataDic isKindOfClass:[NSDictionary class]]){
                //重新获取充值金额
                NSString *recharge = @"";
                if([[dataDic allKeys] containsObject:@"recharge"]){
                    recharge = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"recharge"]];
                }
                NSDictionary *infoDic = @{@"CMDepositRecharge":recharge};
                [self notEnoughMoneyJson:json toPageName:@"FundMainController" pageParams:infoDic];
            }
            
        }
    }
}

#pragma mark - text field tool bar delegate
- (void)TFDonePressed
{
    [_tolBalanceTF resignFirstResponder];
    [_perMaxBalanceTF resignFirstResponder];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL success = [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:4];
    if(success){
        NSMutableString *inputString = [NSMutableString stringWithString:textField.text];
        if([string isEqualToString:@""] && range.length != NSNotFound){         //按下退格键
            [inputString deleteCharactersInRange:range];
        }else{
            [inputString insertString:string atIndex:range.location];
        }
        [self localCalculateDataWithTextField:textField inputString:inputString];
    }
    return success;
}


#pragma mark - 本地计算信息
- (void)localCalculateDataWithTextField:(UITextField *)textfield inputString:(NSString *)inputString
{
    if(textfield == _tolBalanceTF){
        CGFloat tolBalance = [inputString doubleValue] * [_configEntity.usdtRate doubleValue];
        _tolBalanceCNYLabel.text = [NSString stringWithFormat:@"≈¥%.2f",tolBalance];
    }else{
        CGFloat perMaxBalance = [inputString doubleValue] * [_configEntity.usdtRate doubleValue];
        _perMaxBalanceCNYLabel.text = [NSString stringWithFormat:@"≈¥%.2f",perMaxBalance];
    }
}

@end
