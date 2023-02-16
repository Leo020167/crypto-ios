//
//  P2PCreateADController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PCreateADController.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "P2PPayWayEntity.h"
#import "RZWebImageView.h"
#import "P2POrderEntity.h"

@interface P2PCreateADController ()<UITextFieldDelegate,UITextViewDelegate,TextFieldToolBarDelegate>{
    
    BOOL bReqFinished;
    TextFieldToolBar* toolBar;
    
    NSMutableArray* tableData;
}
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UIButton *btnBuy;
@property (retain, nonatomic) IBOutlet UIButton *btnSell;
@property (retain, nonatomic) IBOutlet UITextField *tfPrice;
@property (retain, nonatomic) IBOutlet UITextField *tfAmount;
@property (retain, nonatomic) IBOutlet UITextField *tfMinMoney;
@property (retain, nonatomic) IBOutlet UITextField *tfMaxMoney;
@property (retain, nonatomic) IBOutlet UIButton *btnBank;
@property (retain, nonatomic) IBOutlet UIButton *btnAlipay;
@property (retain, nonatomic) IBOutlet UIButton *btnWechatPay;
@property (retain, nonatomic) IBOutlet UILabel *lbReasonTips;
@property (retain, nonatomic) IBOutlet UIView *buySellView;
@property (retain, nonatomic) IBOutlet UITextView *tvReason;
@property (retain, nonatomic) IBOutlet UILabel *lbPriceTips;

@property (copy, nonatomic) NSString* buySell;
@property (copy, nonatomic) NSString* adId;
@property (copy, nonatomic) NSString* currentPrice;
@end

@implementation P2PCreateADController

- (void)viewDidLoad {
    [super viewDidLoad];

    tableData = [[NSMutableArray alloc] init];
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:4];
    _tfPrice.inputAccessoryView = toolBar;
    _tfAmount.inputAccessoryView = toolBar;
    _tfMaxMoney.inputAccessoryView = toolBar;
    _tfMinMoney.inputAccessoryView = toolBar;
    
    bReqFinished = YES;
    
    
    if([self getValueFromModelDictionary:P2PDict forKey:@"adId"]){
        self.adId = [self getValueFromModelDictionary:P2PDict forKey:@"adId"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"adId"];
    }
    
    [self reqFindMyPaymentList];
    
    if (TTIsStringWithAnyText(_adId)) {
        _buySellView.userInteractionEnabled = NO;
    }else{
        self.buySell = @"buy";
        [self reqGetAdPrice:_buySell];
    }
}

- (void)dealloc{

    [_currentPrice release];
    [_adId release];
    [tableData release];
    [_buySell release];
    [toolBar release];
    [_btnBuy release];
    [_btnSell release];
    [_tfPrice release];
    [_tfAmount release];
    [_tfMinMoney release];
    [_tfMaxMoney release];
    [_btnBank release];
    [_btnAlipay release];
    [_btnWechatPay release];
    [_lbReasonTips release];
    [_tvReason release];
    [_btnConfirm release];
    [_scrollView release];
    [_buySellView release];
    [_lbPriceTips release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}
- (IBAction)buyBtnClicked:(id)sender {
    
    _btnBuy.selected = ! _btnBuy.selected;
    _btnSell.selected = ! _btnBuy.selected;
    
    self.buySell = @"buy";
    _tfPrice.text = @"";
    [self reqGetAdPrice:_buySell];
}

- (IBAction)sellBtnClicked:(id)sender {
    _btnSell.selected = ! _btnSell.selected;
    _btnBuy.selected = ! _btnSell.selected;
    
    self.buySell = @"sell";
    _tfPrice.text = @"";
    [self reqGetAdPrice:_buySell];
}

- (IBAction)priceSetupBtnClicked:(id)sender {
    _tfPrice.text = _currentPrice;
}

- (IBAction)bankBtnClicked:(id)sender {
    _btnBank.selected = ! _btnBank.selected;
    
    if (_btnBank.selected) {
        [CommonUtil viewMasksToBounds:_btnBank cornerRadius:0 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    }else{
        [CommonUtil viewMasksToBounds:_btnBank cornerRadius:0 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
}

- (IBAction)alipayBtnClicked:(id)sender {
    _btnAlipay.selected = ! _btnAlipay.selected;
    
    if (_btnAlipay.selected) {
        [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:0 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    }else{
        [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:0 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
}

- (IBAction)wechatPayBtnClicked:(id)sender {
    _btnWechatPay.selected = ! _btnWechatPay.selected;
    
    if (_btnWechatPay.selected) {
        [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:0 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    }else{
        [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:0 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
}

- (IBAction)confirmBtnClicked:(id)sender {
    if (!_btnBank.selected && !_btnAlipay.selected && !_btnWechatPay.selected) {
        [self showToast:NSLocalizedStringForKey(@"请选择支付方式")];
        return;
    }
    [self viewTouchDown:nil];
    
    NSString *payWay = @"";
    for (int i = 0; i < tableData.count; i++) {
        P2PPayWayEntity *item = [tableData objectAtIndex:i];
        if (i>3) break;
        UIButton* btn = (UIButton*)[self.view viewWithTag:i + 50];
        if (btn.selected) {
            if (TTIsStringWithAnyText(payWay)) {
                payWay = [NSString stringWithFormat:@"%@,%@",payWay,item.paymentId];
            }else{
                payWay = item.paymentId;
            }
        }
    }
    if (TTIsStringWithAnyText(_adId)) {
        [self reqUpdateMyAd:_adId buySell:_buySell payWay:payWay price:_tfPrice.text minCny:_tfMinMoney.text maxCny:_tfMaxMoney.text amount:_tfAmount.text content:_tvReason.text];
    }else{
        [self reqAddMyAdData:_buySell payWay:payWay price:_tfPrice.text minCny:_tfMinMoney.text maxCny:_tfMaxMoney.text amount:_tfAmount.text content:_tvReason.text];
    }

}

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_tfAmount resignFirstResponder];
    [_tfPrice resignFirstResponder];
    [_tfMinMoney resignFirstResponder];
    [_tfMaxMoney resignFirstResponder];
    [_tvReason resignFirstResponder];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}


#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)textField {
    if (TTIsStringWithAnyText(_tfPrice.text) && TTIsStringWithAnyText(_tfAmount.text) && TTIsStringWithAnyText(_tfMinMoney.text) && TTIsStringWithAnyText(_tfMaxMoney.text) ) {
        _btnConfirm.enabled = YES;
    }else{
        _btnConfirm.enabled = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_tfPrice becomeFirstResponder];
            break;
        case 2:
            [_tfAmount becomeFirstResponder];
            break;
        case 3:
            [_tfMaxMoney becomeFirstResponder];
            break;
        case 4:
            [_tfMinMoney becomeFirstResponder];
            break;
        case 5:
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
            distance = 60;
            break;
        case 2:
            distance = 120;
            break;
        case 3:
        case 4:
            distance = 180;
            break;
        case 5:
            distance = 250;
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

#pragma mark - text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSUInteger tag = [textView tag];
    [self animateView:tag];
}

- (void)textViewDidChange:(UITextView *)textView{
    _lbReasonTips.hidden = textView.text.length>0;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self viewTouchDown:nil];
        return NO;
    }
    return YES;
}

#pragma mark - 【我的广告】发布广告
- (void)reqAddMyAdData:(NSString*)buySell payWay:(NSString*)payWay price:(NSString*)price minCny:(NSString*)minCny maxCny:(NSString*)maxCny amount:(NSString*)amount content:(NSString*)content
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PAddMyAd:self buySell:buySell price:price minCny:minCny maxCny:maxCny amount:amount payWay:payWay content:content finishedCallback:@selector(reqMyAdFinished:) failedCallback:@selector(reqMyAdFailed:)];
    }
    
}

#pragma mark - 【我的广告】编辑广告
- (void)reqUpdateMyAd:(NSString*)adId buySell:(NSString*)buySell payWay:(NSString*)payWay price:(NSString*)price minCny:(NSString*)minCny maxCny:(NSString*)maxCny amount:(NSString*)amount content:(NSString*)content
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PUpdateMyAd:self adId:adId buySell:buySell price:price minCny:minCny maxCny:maxCny amount:amount payWay:payWay content:content finishedCallback:@selector(reqMyAdFinished:) failedCallback:@selector(reqMyAdFailed:)];
    }
    
}

- (void)reqMyAdFinished:(id)result
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
        self.view.userInteractionEnabled = NO;
        [self performSelector:@selector(goBack) withObject:nil afterDelay:0.1];
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqMyAdFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 【收款方式】获取我的收款方式列表
- (void)reqFindMyPaymentList
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PFindMyPaymentList:self finishedCallback:@selector(reqPaymentListFinished:) failedCallback:@selector(reqPaymentListFailed:)];
    }
    
}

- (void)reqPaymentListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [tableData removeAllObjects];
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSArray *list = [dataDic objectForKey:@"myPaymentList"];
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            P2PPayWayEntity *entity = [[[P2PPayWayEntity alloc] initWithJson:dic]autorelease];
            [array addObject:entity];
        }
        [tableData addObjectsFromArray:array];
        for (int i = 0; i < tableData.count; i++) {
            P2PPayWayEntity *item = [tableData objectAtIndex:i];
            UILabel* lb = (UILabel*)[self.view viewWithTag:100 +i];
            lb.text = item.receiptTypeValue;
            RZWebImageView* logo = (RZWebImageView*)[self.view viewWithTag:200 + i];
            [logo showImageWithUrl:item.receiptLogo];
            UIView* view = (UIView*)[self.view viewWithTag:300 + i];
            view.hidden = NO;
            UIButton* btn = (UIButton*)[self.view viewWithTag:i + 50];
            btn.selected = NO;
        }
        
        if (TTIsStringWithAnyText(_adId)) {
            [self reqMyAdInfo:_adId];
        }
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqPaymentListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}


#pragma mark - 【我的广告】我的广告详情
- (void)reqMyAdInfo:(NSString*)adId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PGetMyAdInfo:self adId:adId finishedCallback:@selector(reqMyAdInfoFinished:) failedCallback:@selector(reqMyAdInfoFailed:)];
    }
    
}

- (void)reqMyAdInfoFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dic = [result objectForKey:@"data"];
        P2POrderEntity *entity = [[[P2POrderEntity alloc] initWithJson:dic]autorelease];
        self.adId = entity.adId;
        self.buySell = entity.buySell;
        _tfPrice.text = entity.price;
        _tfAmount.text = entity.amount;
        _tfMinMoney.text = entity.minCny;
        _tfMaxMoney.text = entity.maxCny;
        _tvReason.text = entity.content;
        _lbReasonTips.hidden = TTIsStringWithAnyText(_tvReason.text);
        _btnConfirm.enabled = YES;
        
        if ([_buySell isEqualToString:@"buy"]) {
            _btnBuy.selected = YES;
        }else{
            _btnSell.selected = YES;
        }
        if(entity.isPayWx == 1) [self wechatPayBtnClicked:nil];
        if(entity.isPayAli == 1) [self alipayBtnClicked:nil];
        if(entity.isPayBank == 1) [self bankBtnClicked:nil];
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqMyAdInfoFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 【我的广告】获取广告最高最低价格
- (void)reqGetAdPrice:(NSString*)buySell
{
    [[NetWorkManage shareSingleNetWork] reqP2PGetAdPrice:self buySell:buySell  finishedCallback:@selector(reqGetAdPriceFinished:) failedCallback:@selector(reqGetAdPriceFailed:)];
    
}

- (void)reqGetAdPriceFinished:(id)result
{
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){
        NSDictionary *dic = [result objectForKey:@"data"];
        self.currentPrice = [parser stringParser:dic name:@"price"];
        NSString* bs = [self.buySell isEqualToString:@"buy"]?NSLocalizedStringForKey(@"购买最低价"):NSLocalizedStringForKey(@"出售最高价");
        _lbPriceTips.text = [NSString stringWithFormat:@"%@%@ %@ HKD/USDT", NSLocalizedStringForKey(@"当前"), bs, _currentPrice];
    }
}

- (void)reqGetAdPriceFailed:(NSDictionary *)json
{
}

@end
