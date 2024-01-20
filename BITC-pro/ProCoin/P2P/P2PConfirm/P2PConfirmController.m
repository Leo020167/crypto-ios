//
//  P2PConfirmController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PConfirmController.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "P2PConfirmOrderModel.h"
#import "VeDateUtil.h"
#import "OrderPayWayAlertView.h"
#import "P2PPayWayEntity.h"
#import "P2PAlertView.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "UserInfoSQL.h"
#import "FPDMarkPaidAlertView.h"
#import "FPDCancelOrderAlertView.h"
#import "LewPopupViewAnimationSpring.h"
#import "CircleSocket.h"

@interface P2PConfirmController ()<OrderPayWayAlertViewDelegate, P2PAlertViewDelegate>{
    NSTimer *timer;
    NSInteger timerCount;
    BOOL bReqFinished;
}

@property (retain, nonatomic) IBOutlet UILabel *lbPayTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbPayTimeTips;
@property (retain, nonatomic) IBOutlet UILabel *lbPayTime;
@property (retain, nonatomic) IBOutlet UILabel *lbTotalPrice;
@property (retain, nonatomic) IBOutlet UILabel *lbPrice;
@property (retain, nonatomic) IBOutlet UILabel *lbAmount;
@property (retain, nonatomic) IBOutlet UILabel *lbOrderId;
@property (retain, nonatomic) IBOutlet UILabel *lbOrderTime;
@property (retain, nonatomic) IBOutlet UILabel *LbCustomerName;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivCustomerLogo;
@property (retain, nonatomic) IBOutlet UILabel *lbCustomerRealName;
@property (retain, nonatomic) IBOutlet UILabel *lbPayWay;
@property (retain, nonatomic) IBOutlet UILabel *lbBuySellTitle;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivPayWay;
@property (retain, nonatomic) IBOutlet UIButton *btnBottomLetf;
@property (retain, nonatomic) IBOutlet UIButton *btnBottomRight;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *bottomBuyView;
@property (retain, nonatomic) IBOutlet UIView *bottomSellView;
@property (retain, nonatomic) IBOutlet UIView *bottomAppealView;
@property (retain, nonatomic) IBOutlet UIView *payView;
@property (retain, nonatomic) IBOutlet UIButton *btnBottom;
@property (retain, nonatomic) IBOutlet UIImageView *ivTimeLogo;
@property (retain, nonatomic) IBOutlet UIImageView *ivPayWayMoreLogo;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutPayWayMoreLogoLeading;
@property (retain, nonatomic) IBOutlet UIButton *btnPayWay;

@property (copy, nonatomic) NSString *orderId;
@property (retain, nonatomic) P2PConfirmOrderModel* model;
@property (retain, nonatomic) OrderPayWayAlertView* payWayView;
@property (retain, nonatomic) P2PAlertView* alertView;
@property (copy, nonatomic) NSString* selectedPaymentId;
@property (copy, nonatomic) NSString* paySecondTime;

/// 右上角消息按钮
@property (retain, nonatomic) IBOutlet UIButton *messageBtn;
@property (retain, nonatomic) PrivateChatDataEntity *chatDataEntity;    //私聊对象
@end

@implementation P2PConfirmController

- (void)viewDidLoad {
    [super viewDidLoad];

    bReqFinished = YES;
    
    if([self getValueFromModelDictionary:P2PDict forKey:@"orderId"]){
        self.orderId = [self getValueFromModelDictionary:P2PDict forKey:@"orderId"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"orderId"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessageCountData) name:@"ReloadMessageCount" object:nil];
    
    self.messageBtn.qmui_badgeTextColor = UIColor.whiteColor;
    self.messageBtn.qmui_badgeBackgroundColor = UIColor.redColor;
    /// 默认 badge 的布局处于 view 右上角（x = view.width, y = -badge height），通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
    self.messageBtn.qmui_badgeOffset = CGPointMake(-25, 18);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reqGetOrderDetailData:_orderId];
}

- (void)reloadMessageCountData{
    NSArray *listArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"OrderMessageList"];
    for (NSDictionary *dict in listArray) {
        if ([dict[@"chatTopic"] isEqualToString:_chatDataEntity.chatTopic]) {
            self.messageBtn.qmui_badgeInteger = [dict[@"count"] intValue];
        }
    }
}

- (void)dealloc{
    [_chatDataEntity release];
    [self closeTimer];
    [_paySecondTime release];
    [_selectedPaymentId release];
    [_orderId release];
    [timer release];
    [_lbPayTitle release];
    [_lbPayTimeTips release];
    [_lbPayTime release];
    [_lbTotalPrice release];
    [_lbPrice release];
    [_lbAmount release];
    [_lbOrderId release];
    [_lbOrderTime release];
    [_LbCustomerName release];
    [_ivCustomerLogo release];
    [_lbCustomerRealName release];
    [_lbPayWay release];
    [_ivPayWay release];
    [_btnBottomLetf release];
    [_btnBottomRight release];
    [_scrollView release];
    [_model release];
    [_lbBuySellTitle release];
    [_bottomBuyView release];
    [_bottomSellView release];
    [_bottomAppealView release];
    [_payWayView release];
    [_payView release];
    [_btnBottom release];
    [_ivTimeLogo release];
    [_ivPayWayMoreLogo release];
    [_layoutPayWayMoreLogoLeading release];
    [_btnPayWay release];
    [_messageBtn release];
    [super dealloc];
}

#pragma mark - 懒加载
- (OrderPayWayAlertView *)payWayView
{
    if(!_payWayView){
        _payWayView = [[[[NSBundle mainBundle] loadNibNamed:@"OrderPayWayAlertView" owner:nil options:nil] lastObject] retain];
        _payWayView.delegate = self;
    }
    return _payWayView;
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
    [self goBack];
}
- (IBAction)orderNumCopyBtnClicked:(id)sender {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_lbOrderId.text];
    [self showToast:NSLocalizedStringForKey(@"已复制")];
}

/// 点击头像
- (IBAction)customerBtnClicked:(id)sender {
        PrivateChatDataEntity * item = [[[PrivateChatDataEntity alloc]init]autorelease];
        item.chatTopic = _chatDataEntity.chatTopic;
        item.userId = _chatDataEntity.userId;
        item.headurl = _chatDataEntity.headurl;
        item.name = _chatDataEntity.name;
        [PrivateChatSQL createPrivateChatSQL:item];
        [UserInfoSQL insertOrUpdateUserInfoWithUserId:_chatDataEntity.userId userName:_chatDataEntity.name userLevel:0 headerUrl:_chatDataEntity.headurl];
        [self putValueToParamDictionary:ChatDict value:item.chatTopic forKey:@"chatTopic"];
        [self putValueToParamDictionary:ChatDict value:item.name forKey:@"userName"];
        [self putValueToParamDictionary:ChatDict value:item.userId forKey:@"taUserId"];
        [self pageToOrBackWithName:@"ChatViewController"];
    
//    [self putValueToParamDictionary:ProCoinBaseDict value:_model.showUserId forKey:@"PersonalMainTargetUid"];
//    [self pageToViewControllerForName:@"PersonalMainController"];
}
- (IBAction)bottomBtnClicked:(id)sender {
    if ((_model.state == 1 && [_model.buySell isEqualToString:@"buy"]) || (_model.state == 0 && [_model.buySell isEqualToString:@"sell"])){
        [self putValueToParamDictionary:P2PDict value:_model.orderId forKey:@"orderId"];
        [self pageToOrBackWithName:@"P2PAppealController"];
    }
}
- (IBAction)appealBtnClicked:(id)sender {
    [self putValueToParamDictionary:P2PDict value:_model.orderId forKey:@"orderId"];
    [self pageToOrBackWithName:@"P2PAppealController"];
}
- (IBAction)gotPayBtnClicked:(id)sender {
    self.alertView.tag = 400;
    [self.alertView show:self.view];
    [_alertView reloadUIData:NSLocalizedStringForKey(@"确认收款并放行") tips1:NSLocalizedStringForKey(@"请务必登录网上银行或第三方支付账号确认收到该笔款项") tips2:@"" btnTips:NSLocalizedStringForKey(@"我确定已登录收款账户，并核对收款无误") btnLeftTips:NSLocalizedStringForKey(@"取消") btnRightTips:NSLocalizedStringForKey(@"确定")];
}
- (IBAction)cancelBtnClicked:(id)sender {
    self.alertView.tag = 401;
    [self.alertView show:self.view];
    [_alertView reloadUIData:NSLocalizedStringForKey(@"确认取消订单") tips1:NSLocalizedStringForKey(@"如您已经向卖家付款，请不要取消订单") tips2:NSLocalizedStringForKey(@"取消规则：买家当日累计4笔取消，会限制当日买入功能。") btnTips:NSLocalizedStringForKey(@"我确认还没有付款给对方") btnLeftTips:NSLocalizedStringForKey(@"我再想想") btnRightTips:NSLocalizedStringForKey(@"确定")];
}

- (IBAction)toPayBtnClicked:(id)sender {
    [self reqToPayOrderData:_model.orderId];
}

- (IBAction)chatBtnClicked:(id)sender {

        [self putValueToParamDictionary:ChatDict value:_chatDataEntity.chatTopic forKey:@"chatTopic"];
        [self putValueToParamDictionary:ChatDict value:_chatDataEntity.name forKey:@"userName"];
        [self putValueToParamDictionary:ChatDict value:_chatDataEntity.userId forKey:@"taUserId"];
        _chatDataEntity.chatNews = 0;
        [PrivateChatSQL updatePrivateTopicNews:_chatDataEntity.chatTopic chatNews:_chatDataEntity.chatNews];
        [self pageToOrBackWithName:@"ChatViewController"];
}

- (IBAction)payWayBtnClicked:(id)sender {
    [self.payWayView showInView:self.view];
    
    [self.payWayView reloadUIData:_model.payWayArray selectedPaymentId:_selectedPaymentId];
}

#pragma mark - P2PAlertView delegate
- (void)p2pAlertView:(P2PAlertView *)alertView okButtonClicked:(id)sender{
    if (self.alertView.tag == 400) {
        [self reqToConfirmReceivedPayData:_model.orderId];
    }else if (self.alertView.tag == 401) {
        [self reqCancelOrderData:_model.orderId];
    }
    
    
}

- (void)p2pAlertView:(P2PAlertView *)alertView cancelButtonClicked:(id)sender{
    
}

#pragma mark - OrderPayWayAlertView delegate
- (void)p2pView:(OrderPayWayAlertView *)alertView selectedPaymentId:(NSString*) selectedPaymentId{
    for (P2PPayWayEntity* pay in _model.payWayArray) {
        
        if ([pay.paymentId isEqualToString:selectedPaymentId]) {
            _lbPayWay.text = pay.receiptTypeValue;
            [_ivPayWay showImageWithUrl:pay.receiptLogo];
            self.selectedPaymentId = pay.paymentId;
        }
    }
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
    if (timerCount >= 0) {
        NSDictionary* timeDic = [VeDateUtil getHourMinuteSecondDictionaryFromSeconds:timerCount];
        NSString* str = [NSString stringWithFormat:@"%@:%@:%@",[timeDic objectForKey:@"hour"],[timeDic objectForKey:@"minute"],[timeDic objectForKey:@"second"]];
        [_lbPayTime setText:str];
        
        [[NetWorkManage shareSingleNetWork] reqP2PGetOrderDetail:self orderId:self.orderId  finishedCallback:@selector(reqGetOrderDetailTimerFinished:) failedCallback:@selector(reqGetOrderDetailTimerFailed:)];
    }
    if (timerCount == 0) {
        [self closeTimer];
    }
}

- (void)reqGetOrderDetailTimerFinished:(id)result {
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSDictionary *dic = [dataDic objectForKey:@"order"];
        P2PConfirmOrderModel *entity = [[[P2PConfirmOrderModel alloc] initWithJson:dic]autorelease];
        self.model = entity;
        if (self.model.state == 2) {
            [self closeTimer];
            [self refreshUI];
            self.lbPayTime.text = @"";
        }
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqGetOrderDetailTimerFailed:(NSDictionary *)json {
    
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

        [self refreshUI];
        
        if (_model.state == 1) {
            [self startTimer];
        }
        
        [self bindChat:dataDic];
        

    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)refreshUI {
    self.paySecondTime = _model.paySecondTime;
    _lbPayTitle.text = _model.stateValue;
    _lbPayTimeTips.text = _model.stateTip;
    _lbBuySellTitle.text = _model.buySellValue;
    _lbTotalPrice.text = [NSString stringWithFormat:@"%@%@", _model.currencySign, _model.tolPrice];
    _lbPrice.text = [NSString stringWithFormat:@"%@%@", _model.currencySign, _model.price];
    _lbAmount.text = [NSString stringWithFormat:@"%@ USDT", _model.amount];
    _lbOrderId.text = _model.orderId;
    _lbOrderTime.text = [VeDateUtil formatterDate:_model.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    [_ivCustomerLogo showImageWithUrl:_model.showUserLogo];
    _LbCustomerName.text = _model.showUserName;
    _lbCustomerRealName.text = _model.showRealName;
    
    if (_model.payWayArray.count>0) {
        P2PPayWayEntity* pay = [_model.payWayArray firstObject];
        _lbPayWay.text = pay.receiptTypeValue;
        [_ivPayWay showImageWithUrl:pay.receiptLogo];
        
        self.selectedPaymentId = pay.paymentId;
    }
    
    _bottomBuyView.hidden = YES;
    _bottomSellView.hidden = YES;
    _bottomAppealView.hidden = YES;
    _btnBottom.enabled = YES;
    _ivPayWayMoreLogo.hidden = YES;
    _layoutPayWayMoreLogoLeading.constant = 0;
    _btnPayWay.enabled = NO;
    
    if (_model.state == 0) {
        if ([_model.buySell isEqualToString:@"buy"]) {
            _bottomBuyView.hidden = NO;
            _ivPayWayMoreLogo.hidden = NO;
            _layoutPayWayMoreLogoLeading.constant = 15;
            _btnPayWay.enabled = YES;
        } else if ([_model.buySell isEqualToString:@"sell"]) {
            _bottomAppealView.hidden = NO;
            [_btnBottom setTitle:NSLocalizedStringForKey(@"申诉") forState:UIControlStateNormal];
        }
        _ivTimeLogo.image = [UIImage imageNamed:@"p2p_logo_clock"];
    } else if (_model.state == 1){
        if ([_model.buySell isEqualToString:@"buy"]) {
            _bottomAppealView.hidden = NO;
            [_btnBottom setTitle:NSLocalizedStringForKey(@"申诉") forState:UIControlStateNormal];
        } else if ([_model.buySell isEqualToString:@"sell"]) {
            _bottomSellView.hidden = NO;
        }
        _ivTimeLogo.image = [UIImage imageNamed:@"p2p_logo_clock"];
    } else if (_model.state == 2){
        _ivTimeLogo.image = [UIImage imageNamed:@"p2p_logo_ok_big"];
    } else if (_model.state == 3){
        _bottomAppealView.hidden = NO;
        [_btnBottom setTitle:NSLocalizedStringForKey(@"申诉") forState:UIControlStateNormal];
    } else if (_model.state == -1){
        _bottomAppealView.hidden = NO;
        _btnBottom.enabled = NO;
        [_btnBottom setTitle:NSLocalizedStringForKey(@"已过期") forState:UIControlStateDisabled];
        _ivTimeLogo.image = [UIImage imageNamed:@"p2p_logo_cancel"];
    } else if (_model.state == -2){
        _bottomAppealView.hidden = NO;
        _btnBottom.enabled = NO;
        [_btnBottom setTitle:NSLocalizedStringForKey(@"已撤销") forState:UIControlStateDisabled];
        _ivTimeLogo.image = [UIImage imageNamed:@"p2p_logo_cancel"];
    } else if (_model.state == -3){
        _bottomAppealView.hidden = NO;
        _btnBottom.enabled = NO;
        [_btnBottom setTitle:NSLocalizedStringForKey(@"系统撤销") forState:UIControlStateDisabled];
        _ivTimeLogo.image = [UIImage imageNamed:@"p2p_logo_cancel"];
    }
    
    NSArray *listArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"OrderMessageList"];
    for (NSDictionary *dict in listArray) {
        if ([dict[@"chatTopic"] isEqualToString:_chatDataEntity.chatTopic]) {
            self.messageBtn.qmui_badgeInteger = [dict[@"count"] intValue];
        }
    }
}

- (void)bindChat: (NSDictionary *)dataDic {
    
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
}

- (void)reqGetOrderDetailFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 【广告市场】付款第2步：点击“我已付款成功”按钮
- (void)reqToPayOrderData:(NSString*)orderId
{

    if (bReqFinished && TTIsStringWithAnyText(_selectedPaymentId)) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PToPayOrder:self orderId:_model.orderId showUserId:_model.showUserId showPaymentId:_selectedPaymentId finishedCallback:@selector(reqToPayOrderFinished:) failedCallback:@selector(reqOrderFailed:)];
    }
    
}

- (void)reqToPayOrderFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [self putValueToParamDictionary:P2PDict value:_orderId forKey:@"orderId"];
        [self putValueToParamDictionary:P2PDict value:_selectedPaymentId forKey:@"selectedPaymentId"];
        
        [self pageToOrBackWithName:@"P2PPayController"];
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
        [self reqGetOrderDetailData:_orderId];
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

#pragma mark - 【广告市场】出售第2步：点击“我确认已收到付款”按钮
- (void)reqToConfirmReceivedPayData:(NSString*)orderId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PToConfirmReceivedPay:self orderId:orderId  finishedCallback:@selector(reqToConfirmReceivedPayFinished:) failedCallback:@selector(reqOrderFailed:)];
    }
    
}

- (void)reqToConfirmReceivedPayFinished:(id)result
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

@end
