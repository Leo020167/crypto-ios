//
//  P2PPayController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PPayController.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "P2PConfirmOrderModel.h"
#import "VeDateUtil.h"
#import "P2PPayWayEntity.h"
#import "PayQRcodeAlertView.h"
#import "P2PAlertView.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "UserInfoSQL.h"
#import "FPDMarkPaidAlertView.h"
#import "FPDCancelOrderAlertView.h"
#import "LewPopupViewAnimationSpring.h"
#import "CircleSocket.h"

@interface P2PPayController () <P2PAlertViewDelegate>{
    NSTimer *timer;
    NSInteger timerCount;
    BOOL bReqFinished;
}


@property (retain, nonatomic) IBOutlet UILabel *lbMoney;
@property (retain, nonatomic) IBOutlet UILabel *lbPayTimeTips;
@property (retain, nonatomic) IBOutlet UILabel *lbPayTime;
@property (retain, nonatomic) IBOutlet UILabel *lbAmount;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivCustomerLogo;
@property (retain, nonatomic) IBOutlet UILabel *lbCustomerName;
@property (retain, nonatomic) IBOutlet UILabel *lbCustomerRealName;
@property (retain, nonatomic) IBOutlet UILabel *lbCustomerPayWay;
@property (retain, nonatomic) IBOutlet UILabel *lbCustomerPayNum;
@property (retain, nonatomic) IBOutlet UILabel *lbTips;
@property (retain, nonatomic) IBOutlet UILabel *lbPayWayNumTips;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;

@property (copy, nonatomic) NSString *orderId;
@property (retain, nonatomic) P2PConfirmOrderModel* model;
@property (copy, nonatomic) NSString* selectedPaymentId;
@property (copy, nonatomic) NSString* paySecondTime;
@property (retain, nonatomic) IBOutlet UIView *bankView;
@property (retain, nonatomic) IBOutlet UIView *qrcodeView;

@property (retain, nonatomic) PayQRcodeAlertView* qrcodeAlertView;
@property (retain, nonatomic) P2PAlertView* alertView;

@property (retain, nonatomic) PrivateChatDataEntity *chatDataEntity;    //私聊对象

/// 认证商家
@property (retain, nonatomic) IBOutlet UILabel *authShopLabel;

@end

@implementation P2PPayController

- (void)viewDidLoad {
    [super viewDidLoad];

    bReqFinished = YES;
    
    if([self getValueFromModelDictionary:P2PDict forKey:@"orderId"]){
        self.orderId = [self getValueFromModelDictionary:P2PDict forKey:@"orderId"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"orderId"];
    }
    
    if([self getValueFromModelDictionary:P2PDict forKey:@"selectedPaymentId"]){
        self.selectedPaymentId = [self getValueFromModelDictionary:P2PDict forKey:@"selectedPaymentId"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"selectedPaymentId"];
    }
    
    self.authShopLabel.text = NSLocalizedStringForKey(@"AiCoin认证商家");
    
    [self reqGetOrderDetailData:_orderId];
}

- (void)dealloc{

    [_chatDataEntity release];
    [_qrcodeAlertView release];
    [self closeTimer];
    [_orderId release];
    [_model release];
    [_selectedPaymentId release];
    [_paySecondTime release];
    [_lbMoney release];
    [_lbPayTimeTips release];
    [_lbPayTime release];
    [_lbAmount release];
    [_ivCustomerLogo release];
    [_lbCustomerName release];
    [_lbCustomerRealName release];
    [_lbCustomerPayWay release];
    [_lbCustomerPayNum release];
    [_lbTips release];
    [_lbPayWayNumTips release];
    [_bankView release];
    [_qrcodeView release];
    [_btnConfirm release];
    [_authShopLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (PayQRcodeAlertView *)qrcodeAlertView
{
    if(!_qrcodeAlertView){
        _qrcodeAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"PayQRcodeAlertView" owner:nil options:nil] lastObject] retain];
    }
    return _qrcodeAlertView;
}

- (P2PAlertView *)alertView
{
    if(!_alertView){
        _alertView = [[[[NSBundle mainBundle] loadNibNamed:@"P2PAlertView" owner:nil options:nil] lastObject] retain];
        _alertView.delegate = self;
    }
    return _alertView;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    if (_model.state == 0) {
        [self.alertView show:self.view];
        NSString* time = [NSString stringWithFormat:NSLocalizedStringForKey(@"订单将在%@后超时取消"),_lbPayTime.text];
        [_alertView reloadUIData:NSLocalizedStringForKey(@"确认离开支付") tips1:NSLocalizedStringForKey(@"如您已付款，请务必先点击“我已付款成功”") tips2:time btnTips:NSLocalizedStringForKey(@"我确认还没有付款给对方") btnLeftTips:NSLocalizedStringForKey(@"取消") btnRightTips:NSLocalizedStringForKey(@"确认离开")];
    } else {
        [self goBack];
    }
}
- (IBAction)moneyCopyBtnClicked:(id)sender {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_model.tolPrice];
    [self showToast:NSLocalizedStringForKey(@"已复制")];
}

- (IBAction)comfirmBtnClicked:(id)sender {
    [self reqToMarkPayOrderSuccessData:_model.orderId];
}

- (IBAction)chatBtnClicked:(id)sender {
    [self putValueToParamDictionary:ChatDict value:_chatDataEntity.chatTopic forKey:@"chatTopic"];
    [self putValueToParamDictionary:ChatDict value:_chatDataEntity.name forKey:@"userName"];
    [self putValueToParamDictionary:ChatDict value:_chatDataEntity.userId forKey:@"taUserId"];
    _chatDataEntity.chatNews = 0;
    [PrivateChatSQL updatePrivateTopicNews:_chatDataEntity.chatTopic chatNews:_chatDataEntity.chatNews];
    [self pageToOrBackWithName:@"ChatViewController"];
}

- (IBAction)customerNameBtnClicked:(id)sender {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_model.showRealName];
    [self showToast:NSLocalizedStringForKey(@"已复制")];
}
- (IBAction)customerNumBtnClicked:(id)sender {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    for (P2PPayWayEntity* pay in _model.payWayArray) {
        if ([pay.paymentId isEqualToString:_selectedPaymentId]) {
            [pasteboard setString:pay.receiptNo];
        }
    }
    [self showToast:NSLocalizedStringForKey(@"已复制")];
}
- (IBAction)customerPayWayBtnClicked:(id)sender {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    for (P2PPayWayEntity* pay in _model.payWayArray) {
        if ([pay.paymentId isEqualToString:_selectedPaymentId]) {
            [pasteboard setString:pay.receiptTypeValue];
        }
    }
    [self showToast:NSLocalizedStringForKey(@"已复制")];
}
- (IBAction)customerQRCodeBtnClicked:(id)sender {
    for (P2PPayWayEntity* pay in _model.payWayArray) {
        if ([pay.paymentId isEqualToString:_selectedPaymentId]) {
            [self.qrcodeAlertView reloadUIData:pay.qrCode];
        }
    }
    [self.qrcodeAlertView showInView:self.view];
}
#pragma mark - P2PAlertView delegate
- (void)p2pAlertView:(P2PAlertView *)alertView okButtonClicked:(id)sender{
    [self reqCancelOrderData:_model.orderId];
}

- (void)p2pAlertView:(P2PAlertView *)alertView cancelButtonClicked:(id)sender{
    
}
#pragma mark - 定时器
- (void)startTimer
{
    timerCount = [_model.paySecondTime integerValue];
    [self closeTimer];
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)closeTimer
{
    if(timer && [timer isValid]){
        [timer invalidate];
        timer = nil;
    }
}

- (void)onTimer:(NSTimer *)timer {
    
    timerCount--;
    if (timerCount>=0) {
        NSDictionary* timeDic = [VeDateUtil getDayHourMinuteSecondDictionaryFromSeconds:timerCount];
        NSString* str = [NSString stringWithFormat:@"%@:%@:%@",[timeDic objectForKey:@"hour"],[timeDic objectForKey:@"minute"],[timeDic objectForKey:@"second"]];
        [_lbPayTime setText:str];
        
        NSString* time = [NSString stringWithFormat:NSLocalizedStringForKey(@"订单将在%@后超时取消"),_lbPayTime.text];
        [_alertView reloadUIData:time];
    }
    if (timerCount == 0) {
        [self closeTimer];
    }
}

#pragma mark - 【广告市场】获取订单详情
- (void)reqGetOrderDetailData:(NSString*)orderId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PGetOrderDetail:self orderId:orderId  finishedCallback:@selector(reqGetOrderDetailFinished:) failedCallback:@selector(reqGetOrderDetailFailed:)];
    }
    
}

- (void)reqGetOrderDetailFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSDictionary *dic = [dataDic objectForKey:@"order"];
        P2PConfirmOrderModel *entity = [[[P2PConfirmOrderModel alloc] initWithJson:dic]autorelease];
        self.model = entity;

        _lbPayTimeTips.text = _model.stateTip;
        _lbMoney.text = [NSString stringWithFormat:@"%@%@", _model.currencySign,  _model.tolPrice];
        _lbAmount.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"您正在向AiCoin认证卖家购买%@ USDT"), _model.amount];
        [_ivCustomerLogo showImageWithUrl:_model.showUserLogo];
        _lbCustomerName.text = _model.showUserName;
        _lbCustomerRealName.text = _model.showRealName;
        _lbTips.text = _model.alertTip;
        
        for (P2PPayWayEntity* pay in _model.payWayArray) {
            
            if ([pay.paymentId isEqualToString:_selectedPaymentId]) {
                _lbCustomerPayWay.text = pay.bankName;
                _lbCustomerPayNum.text = pay.receiptNo;
                self.selectedPaymentId = pay.paymentId;
                
                if ([pay.receiptType isEqualToString:@"3"]) {
                    _bankView.hidden = NO;
                    _qrcodeView.hidden = YES;
                }else{
                    _bankView.hidden = YES;
                    _qrcodeView.hidden = NO;
                }
                _lbPayWayNumTips.text = [NSString stringWithFormat:@"%@%@",pay.receiptTypeValue, NSLocalizedStringForKey(@"号码")];
            }
        }
        //_btnConfirm.enabled = NO;
        //[_btnConfirm setTitle:_model.stateValue forState:UIControlStateDisabled];

        [self startTimer];
        
        //设置私聊数据
        NSDictionary *chatStaffDic = [dataDic objectForKey:@"chatStaff"];
        TJRBaseEntity *baseParser = [[[TJRBaseEntity alloc] init] autorelease];;
        self.chatDataEntity = [[[PrivateChatDataEntity alloc] init] autorelease];
        _chatDataEntity.chatTopic = [baseParser stringParser:@"chatTopic" json:chatStaffDic];
        _chatDataEntity.userId = [baseParser stringParser:@"userId" json:chatStaffDic];
        _chatDataEntity.headurl = [baseParser stringParser:@"headUrl" json:chatStaffDic];
        _chatDataEntity.name = [baseParser stringParser:@"userName" json:chatStaffDic];
        /** 获取到私聊信息后，将其入数据库，当收到全局push时，可以保存并通知*/
        if([PrivateChatSQL getSinglePrivateChatDataWithChatTopic:_chatDataEntity.chatTopic] == nil){
            [PrivateChatSQL createPrivateChatSQL:_chatDataEntity];
            [UserInfoSQL insertOrUpdateUserInfoWithUserId:_chatDataEntity.userId userName:_chatDataEntity.name userLevel:0 headerUrl:_chatDataEntity.headurl];
            if([[CircleSocket shareCircleSocket].privateDetail objectForKey:_chatDataEntity.chatTopic] == nil){
                [[CircleSocket shareCircleSocket].privateDetail setObject:_chatDataEntity forKey:_chatDataEntity.chatTopic];
            }
        }else{
            PrivateChatDataEntity *tempChatEntity = [PrivateChatSQL getSinglePrivateChatDataWithChatTopic:_chatDataEntity.chatTopic];
            _chatDataEntity.chatNews = tempChatEntity.chatNews;
        }
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqGetOrderDetailFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 【广告市场】付款第1步：点击“订单取消”按钮
- (void)reqCancelOrderData:(NSString*)orderId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PCancelOrder:self orderId:orderId  finishedCallback:@selector(reqCancelOrderFinished:) failedCallback:@selector(reqOrderFailed:)];
    }
    
}

- (void)reqCancelOrderFinished:(id)result
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

#pragma mark - 【广告市场】付款第2步：点击“我已付款成功”按钮
- (void)reqToMarkPayOrderSuccessData:(NSString*)orderId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PToMarkPayOrderSuccess:self orderId:orderId  finishedCallback:@selector(reqToMarkPayOrderSuccessFinished:) failedCallback:@selector(reqOrderFailed:)];
    }
    
}

- (void)reqToMarkPayOrderSuccessFinished:(id)result
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
        [self reqGetOrderDetailData:_orderId];
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqOrderFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}
@end
