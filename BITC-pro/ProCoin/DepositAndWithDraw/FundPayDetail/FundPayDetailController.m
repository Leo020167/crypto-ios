//
//  FundPayThirdDetailController.m
//  Cropyme
//
//  Created by Hay on 2019/7/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FundPayDetailController.h"
#import "RZWebImageView.h"
#import "NetWorkManage+Trade.h"
#import "FundExchangeWayEntity.h"
#import "FundExchangeOrderEntity.h"
#import "VeDateUtil.h"
#import "TradeUtil.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "UserInfoSQL.h"
#import "FPDMarkPaidAlertView.h"
#import "FPDCancelOrderAlertView.h"
#import "LewPopupViewAnimationSpring.h"
#import "CircleSocket.h"

@interface FundPayDetailController ()<FPDMarkPaidAlertViewDelegate,FPDCancelOrderAlertViewDelegate>
{
    NSTimer *downCountTimer;
}
/** value*/
@property (copy, nonatomic) NSString *orderCashId;
@property (retain, nonatomic) FundExchangeWayEntity *wayEntity;         //收款方式对象
@property (retain, nonatomic) FundExchangeOrderEntity *orderEntity;     //收款订单信息
@property (retain, nonatomic) PrivateChatDataEntity *chatDataEntity;    //私聊对象
/** topView*/
@property (retain, nonatomic) IBOutlet UIImageView *stateIV;            //状态图片
@property (retain, nonatomic) IBOutlet UILabel *stateLabel;             //状态文字
@property (retain, nonatomic) IBOutlet UILabel *stateTipsLabel;         //状态提示文字
/** contentView*/
@property (retain, nonatomic) IBOutlet UILabel *buyPriceLabel;          //购买金额
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;             //买入单价
@property (retain, nonatomic) IBOutlet UILabel *buyAmountLabel;         //购买数量
@property (retain, nonatomic) IBOutlet RZWebImageView *buyWayIV;        //购买方式图片
@property (retain, nonatomic) IBOutlet UILabel *buyWayLabel;            //购买方式
@property (retain, nonatomic) IBOutlet UILabel *receiptNameLabel;       //收款人
@property (retain, nonatomic) IBOutlet UIView *qrCodeView;              //收款二维码view
@property (retain, nonatomic) IBOutlet RZWebImageView *receiptQRCodeIV; //收款二维码
@property (retain, nonatomic) IBOutlet UIView *bankNameView;            //开户行view
@property (retain, nonatomic) IBOutlet UILabel *bankNameLabel;          //开户行
@property (retain, nonatomic) IBOutlet UILabel *accountTitleLabel;      //账号标题
@property (retain, nonatomic) IBOutlet UILabel *accountLabel;           //账号
@property (retain, nonatomic) IBOutlet UILabel *orderIdLabel;           //订单号
@property (retain, nonatomic) IBOutlet UILabel *orderTimeLabel;         //下单时间
@property (retain, nonatomic) IBOutlet UIView *payTipsView;             //付款提示
/** 功能差不多一致的页面,除了支付宝显示bottomView，其他情况都隐藏bottomView*/
@property (retain, nonatomic) IBOutlet UIView *bottomView;              //底部操作view
@property (retain, nonatomic) IBOutlet UIView *bottomNoPayView;         //底部没有去支付按钮view
@property (retain, nonatomic) IBOutlet UIButton *NPCancelOrderButton;   //bottomNoPayView中的取消订单按钮
@property (retain, nonatomic) IBOutlet UIButton *cancelOrderButton;     //bottomView中的取消订单按钮
@property (retain, nonatomic) IBOutlet UIButton *NPMarkHadPaiedButton;  //bottomNoPayView中的标记支付按钮
@property (retain, nonatomic) IBOutlet UIButton *markHadPaiedButton;    //bottomView中的标记支付按钮
@property (retain, nonatomic) IBOutlet UIButton *goToPayButton;         //去支付按钮

/** alertView*/
@property (retain, nonatomic) IBOutlet UIView *alertTipsView;           //提示view
@property (retain, nonatomic) IBOutlet UILabel *atvPriceLabel;          //提示金额
/** 消息提醒view*/
@property (retain, nonatomic) IBOutlet UIView *remindMsgTipsView;       //提醒消息view
@property (retain, nonatomic) IBOutlet UILabel *remindMsgCountLabel;    //提醒消息数字label


@end

@implementation FundPayDetailController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.alertTipsView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH - 50, _alertTipsView.frame.size.height);
    
    [self addBorderToLayer:_payTipsView];
    
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"FundPayDetailOrderCashId"]){
        self.orderCashId = [self getValueFromModelDictionary:FundExchangeDic forKey:@"FundPayDetailOrderCashId"];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"FundPayDetailOrderCashId"];
    }
    
    if(checkIsStringWithAnyText(_orderCashId)){
        [self showProgressDefaultText];
        [self reqCashOrderDetail];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startDownCountTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self closeDownCountTimer];
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [_orderCashId release];
    [_wayEntity release];
    [_orderEntity release];
    [_chatDataEntity release];
    [_stateIV release];
    [_stateLabel release];
    [_stateTipsLabel release];
    [_buyPriceLabel release];
    [_priceLabel release];
    [_buyAmountLabel release];
    [_buyWayIV release];
    [_buyWayLabel release];
    [_receiptNameLabel release];
    [_receiptQRCodeIV release];
    [_accountLabel release];
    [_accountTitleLabel release];
    [_orderIdLabel release];
    [_orderTimeLabel release];
    [_payTipsView release];
    [_qrCodeView release];
    [_bankNameView release];
    [_bankNameLabel release];
    [_bottomView release];
    [_bottomNoPayView release];
    [_NPCancelOrderButton release];
    [_cancelOrderButton release];
    [_markHadPaiedButton release];
    [_NPMarkHadPaiedButton release];
    [_goToPayButton release];
    [_alertTipsView release];
    [_atvPriceLabel release];
    [_remindMsgTipsView release];
    [_remindMsgCountLabel release];
    [super dealloc];
}

/** 为view添加虚线描边边框*/
- (void)addBorderToLayer:(UIView *)view
{
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = RGBA(97, 117, 174, 1).CGColor;
    border.fillColor = nil;
    CGRect frame = view.bounds;
    frame.size.width = SCREEN_WIDTH - 40;
    border.path = [UIBezierPath bezierPathWithRect:frame].CGPath;
    border.frame = view.bounds;
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

- (IBAction)chatServiceButtonPressed:(id)sender
{
//    PrivateChatDataEntity *entity = [PrivateChatSQL getPrivateTopic:_chatDataEntity.chatTopic];
//    if (entity) {
    [self putValueToParamDictionary:ChatDict value:_chatDataEntity.chatTopic forKey:@"chatTopic"];
    [self putValueToParamDictionary:ChatDict value:_chatDataEntity.name forKey:@"userName"];
    [self putValueToParamDictionary:ChatDict value:_chatDataEntity.userId forKey:@"taUserId"];
//    }
    _chatDataEntity.chatNews = 0;
    [PrivateChatSQL updatePrivateTopicNews:_chatDataEntity.chatTopic chatNews:_chatDataEntity.chatNews];
    _remindMsgTipsView.hidden = YES;
    [self putValueToParamDictionary:FundExchangeDic value:@"1" forKey:@"FundMainNeedUpdate"];       //回到充值提现首页，提示刷新一下
    [self pageToOrBackWithName:@"ChatViewController"];
}

/** 拷贝按钮点击事件*/
- (IBAction)contentCopyButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    switch (targetButton.tag) {
        case 300:           //拷贝购买金额
            pboard.string = _buyPriceLabel.text;
            break;
        case 301:           //拷贝收款人
            pboard.string = _receiptNameLabel.text;
            break;
        case 302:           //拷贝账户
            pboard.string = _accountLabel.text;
            break;
        case 303:           //拷贝订单号
            pboard.string = _orderIdLabel.text;
            break;
        case 304:           //拷贝开户行
            pboard.string = _bankNameLabel.text;
            break;
        default:
            break;
    }
    [self showToastCenter:NSLocalizedStringForKey(@"已成功复制到粘贴板")];
}

/** 二维码点击*/
- (IBAction)qrCodeButtonPressed:(id)sender
{
    [self putValueToParamDictionary:FundExchangeDic value:_wayEntity.qrCode forKey:@"FundQRCodeImageURL"];
    [self pageToViewControllerForName:@"FundQRCodeController"];
}

/** 标记已支付*/
- (IBAction)markHadPaidButtonPressed:(id)sender
{
    FPDMarkPaidAlertView *alertView = (FPDMarkPaidAlertView *)[[[NSBundle mainBundle] loadNibNamed:@"FPDMarkPaidAlertView" owner:nil options:nil] lastObject];
    alertView.delegate = self;
    [self lew_presentPopupView:alertView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];
}

/** 取消订单*/
- (IBAction)cancelOrderButtonPressed:(id)sender
{
    FPDCancelOrderAlertView *alertView = (FPDCancelOrderAlertView *)[[[NSBundle mainBundle] loadNibNamed:@"FPDCancelOrderAlertView" owner:nil options:nil] lastObject];
    alertView.delegate = self;
    [self lew_presentPopupView:alertView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];
}

/** 去支付按钮点击事件*/
- (IBAction)goToPayButtonPressed:(id)sender
{
    [self putValueToParamDictionary:TJRWebViewDict value:_wayEntity.qrContent forKey:@"webURL"];
    [self pageToViewControllerForName:@"RedzInOutWebController"];
}

- (IBAction)alertViewCopyBalanceButtonPressed:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = _orderEntity.balanceCny;
    [self hidePopView];
    [self showToastCenter:NSLocalizedStringForKey(@"已成功复制到粘贴板")];
}

- (IBAction)alertViewIKnowButtonPressed:(id)sender
{
    [self hidePopView];
}


#pragma mark - 请求数据
- (void)reqCashOrderDetail
{
    [[NetWorkManage shareSingleNetWork] reqCashTradeOrderDetil:self orderCashId:_orderCashId finishedCallback:@selector(reqCashOrderDetailFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCashOrderDetailFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *orderDic = [dataDic objectForKey:@"order"];
        NSDictionary *receiptDic = [orderDic objectForKey:@"receipt"];
        NSDictionary *chatStaffDic = [dataDic objectForKey:@"chatStaff"];
        self.wayEntity = [[[FundExchangeWayEntity alloc] initWithJson:receiptDic] autorelease];
        self.orderEntity = [[[FundExchangeOrderEntity alloc] initWithJson:orderDic] autorelease];

        //设置私聊数据
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
        
        
        /** 更新页面数据*/
        [self updateViewInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqCancelDepositOrder
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqCancelDepositOrder:self orderCashId:_orderCashId finishedCallback:@selector(reqCancelDepositOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCancelDepositOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"取消订单成功")];
        }
        [self showProgressDefaultText];
        [self reqCashOrderDetail];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"取消订单错误")];
    }
}

- (void)reqMarkPay
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqUserMarkPay:self orderCashId:_orderEntity.orderCashId finishedCallback:@selector(reqMarkPayFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqMarkPayFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"标记成功")];
        }
        [self showProgressDefaultText];
        [self reqCashOrderDetail];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}




#pragma mark - 更新数据
- (void)updateViewInfo
{
    if(_orderEntity.state == 0){                //当在待付款状态时，提示其金额
        _atvPriceLabel.text = [TradeUtil stringByAppendingRMBSymbolString:_orderEntity.balanceCny];
        [self lew_presentPopupView:self.alertTipsView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];
    }
    
    // (0, "待付款"),(1, "已标记付款"),(2, "已完成"), (-1, "已过期"),(-2, "已撤销"), (-3, "系统撤销");
    if(_orderEntity.state == 0 || _orderEntity.state == 1){
        _stateIV.image = [UIImage imageNamed:@"fund_detail_icon_clock"];
        if(_orderEntity.state == 0){
            [self downCountTimerUpdate];
            [self fundPayDetailMarkHadPaidButtonInfoWithTitle:NSLocalizedStringForKey(@"标记已支付") isEnable:YES];
            [self fundPayDetailCancelOrderButtonInfoWithTitle:NSLocalizedStringForKey(@"取消订单") isEnable:YES];
        }else{
            _stateTipsLabel.text = NSLocalizedStringForKey(@"已通知卖家，请耐心等待卖家为你放币");
            [self fundPayDetailMarkHadPaidButtonInfoWithTitle:NSLocalizedStringForKey(@"已标记付款") isEnable:NO];
            [self fundPayDetailCancelOrderButtonInfoWithTitle:NSLocalizedStringForKey(@"取消订单") isEnable:YES];
        }
    }else if(_orderEntity.state == 2){
        _stateIV.image = [UIImage imageNamed:@"fund_detail_icon_done"];
        _stateTipsLabel.text = NSLocalizedStringForKey(@"已完成交易");
        [self fundPayDetailMarkHadPaidButtonInfoWithTitle:NSLocalizedStringForKey(@"已完成") isEnable:NO];
        [self fundPayDetailCancelOrderButtonInfoWithTitle:NSLocalizedStringForKey(@"取消订单") isEnable:NO];
    }else{
        _stateIV.image = [UIImage imageNamed:@"fund_detail_icon_cancel"];
        if(_orderEntity.state == -1){
            _stateTipsLabel.text = NSLocalizedStringForKey(@"订单已过期");
            [self fundPayDetailMarkHadPaidButtonInfoWithTitle:NSLocalizedStringForKey(@"已过期") isEnable:NO];
            [self fundPayDetailCancelOrderButtonInfoWithTitle:NSLocalizedStringForKey(@"取消订单") isEnable:NO];
        }else if(_orderEntity.state == -2){
            _stateTipsLabel.text  = NSLocalizedStringForKey(@"订单已撤销");
            [self fundPayDetailMarkHadPaidButtonInfoWithTitle:NSLocalizedStringForKey(@"已撤销") isEnable:NO];
            [self fundPayDetailCancelOrderButtonInfoWithTitle:NSLocalizedStringForKey(@"取消订单") isEnable:NO];
        }else{
            _stateTipsLabel.text = NSLocalizedStringForKey(@"订单已被系统撤销");
            [self fundPayDetailMarkHadPaidButtonInfoWithTitle:NSLocalizedStringForKey(@"系统撤销") isEnable:NO];
            [self fundPayDetailCancelOrderButtonInfoWithTitle:NSLocalizedStringForKey(@"取消订单") isEnable:NO];
        }
    }
    _stateLabel.text = _orderEntity.stateDesc;
    _buyPriceLabel.text = [TradeUtil stringByAppendingRMBSymbolString:_orderEntity.balanceCny];
    _priceLabel.text = _orderEntity.priceCny;
    _buyAmountLabel.text = _orderEntity.amount;
    [_buyWayIV showImageWithUrl:_wayEntity.receiptTypeLogo];
    _buyWayLabel.text = _wayEntity.receiptTypeValue;
    _receiptNameLabel.text = _wayEntity.receiptName;
    if(_wayEntity.receiptType == 3){     //收款方式:1支付宝，2微信，3银行卡
        _qrCodeView.hidden = YES;
        _bankNameView.hidden = NO;
        _bankNameLabel.text = _wayEntity.bankName;
    }else{
        _qrCodeView.hidden = NO;
        _bankNameView.hidden = YES;
        [_receiptQRCodeIV showImageWithUrl:_wayEntity.qrCode];
    }
    _accountTitleLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedStringForKey(@"账号"), _wayEntity.receiptTypeValue];
    _accountLabel.text = _wayEntity.receiptNo;
    _orderIdLabel.text = _orderEntity.orderCashId;
    _orderTimeLabel.text = [VeDateUtil formatterDate:_orderEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    
    if(_wayEntity.receiptType == 1 && checkIsStringWithAnyText(_wayEntity.qrContent)){     //收款方式:1支付宝，2微信，3银行卡
        _bottomView.hidden = NO;
        _bottomNoPayView.hidden = YES;
    }else{
        _bottomView.hidden = YES;
        _bottomNoPayView.hidden = NO;
    }
    
    if(_chatDataEntity.chatNews > 0){
        _remindMsgTipsView.hidden = NO;
        _remindMsgCountLabel.text = [NSString stringWithFormat:@"%@",@(_chatDataEntity.chatNews)];
    }else{
        _remindMsgTipsView.hidden = YES;
    }
    
}

#pragma mark - 倒计时开始,结束,更新
- (void)startDownCountTimer
{
    [self closeDownCountTimer];
    downCountTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(downCountTimerUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:downCountTimer forMode:NSRunLoopCommonModes];
    
}

- (void)closeDownCountTimer
{
    if(downCountTimer && downCountTimer.isValid){
        [downCountTimer invalidate];
        downCountTimer = nil;
    }
}

- (void)downCountTimerUpdate
{
    if(!checkIsStringWithAnyText(_orderEntity.expireTime)){
        _stateTipsLabel.text = @"---";
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:[_orderEntity.expireTime doubleValue]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *result = [formatter stringFromDate:theDate];
    RELEASE(formatter);
    NSInteger diffSeconds = [VeDateUtil componentsSecondNowWithDateContainNegative:result];           //现在时间离结束时间相差的秒数
    NSInteger days = (diffSeconds / 60 / 60 / 24);
    NSInteger hours = (diffSeconds / 60 / 60 - (24 * days));
    NSInteger minutes = (diffSeconds /60 - (24 * 60 * days) - (60 * hours));
    NSInteger seconds = (diffSeconds - (24 * 60 * 60 * days) - (60 * 60 * hours) - (60 * minutes));
    
    NSString *minutesStr;
    NSString *secondsStr;
    
    // (0, "待付款"),(1, "已标记付款"),(2, "已完成"), (-1, "已过期"),(-2, "已撤销"), (-3, "系统撤销");
    if(_orderEntity.state == 0){
        if(days <= 0 && hours <= 0 && minutes <=  0 && seconds <= 0){
            _stateTipsLabel.text = NSLocalizedStringForKey(@"订单已过期");
            _orderEntity.state = -1;
            return;
        }
    }else{          //其他情况不需要再继续倒计时
        return;
    }
    
    
    
    if (minutes < 10) {
        minutesStr = [NSString stringWithFormat:@"0%ld", (long)minutes];
    } else {
        minutesStr = [NSString stringWithFormat:@"%ld", (long)minutes];
    }
    
    if (seconds < 10) {
        secondsStr = [NSString stringWithFormat:@"0%ld", (long)seconds];
    } else {
        secondsStr = [NSString stringWithFormat:@"%ld", (long)seconds];
    }
    _stateTipsLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"请在 %@:%@ 内付款给卖家"),minutesStr,secondsStr];
}

#pragma mark - 设置按钮信息
- (void)fundPayDetailMarkHadPaidButtonInfoWithTitle:(NSString *)title isEnable:(BOOL)isEnable
{
    _markHadPaiedButton.enabled = isEnable;
    _NPMarkHadPaiedButton.enabled = isEnable;
    if(isEnable){
        [_markHadPaiedButton setTitle:title forState:UIControlStateNormal];
        [_markHadPaiedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _markHadPaiedButton.backgroundColor = RGBA(97, 117, 174, 1);
        
        [_NPMarkHadPaiedButton setTitle:title forState:UIControlStateNormal];
        [_NPMarkHadPaiedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _NPMarkHadPaiedButton.backgroundColor = RGBA(97, 117, 174, 1);
    }else{
        [_markHadPaiedButton setTitle:title forState:UIControlStateNormal];
        [_markHadPaiedButton setTitleColor:RGBA(61, 58, 80, 0.2) forState:UIControlStateNormal];
        _markHadPaiedButton.backgroundColor = RGBA(247, 247, 247, 1);
        
        [_NPMarkHadPaiedButton setTitle:title forState:UIControlStateNormal];
        [_NPMarkHadPaiedButton setTitleColor:RGBA(61, 58, 80, 0.2) forState:UIControlStateNormal];
        _NPMarkHadPaiedButton.backgroundColor = RGBA(247, 247, 247, 1);
    }
    if(!isEnable){           //如果标记付款按钮不能点击，则去支付也不能点击了
        _goToPayButton.enabled = NO;
        _goToPayButton.backgroundColor = RGBA(247, 247, 247, 1);
        [_goToPayButton setTitleColor:RGBA(61, 58, 80, 0.2) forState:UIControlStateNormal];
    }else{
        _goToPayButton.enabled = YES;
        _goToPayButton.backgroundColor = RGBA(97, 117,174, 1.0);
        [_goToPayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)fundPayDetailCancelOrderButtonInfoWithTitle:(NSString *)title isEnable:(BOOL)isEnable
{
    _cancelOrderButton.enabled = isEnable;
    _NPCancelOrderButton.enabled = isEnable;
    if(isEnable){
        [_cancelOrderButton setTitle:title forState:UIControlStateNormal];
        [_cancelOrderButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _cancelOrderButton.backgroundColor = RGBA(247, 247, 247, 1);
        
        [_NPCancelOrderButton setTitle:title forState:UIControlStateNormal];
        [_NPCancelOrderButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _NPCancelOrderButton.backgroundColor = RGBA(247, 247, 247, 1);
    }else{
        [_cancelOrderButton setTitle:title forState:UIControlStateNormal];
        [_cancelOrderButton setTitleColor:RGBA(61, 58, 80, 0.2) forState:UIControlStateNormal];
        _cancelOrderButton.backgroundColor = RGBA(247, 247, 247, 1);
        
        [_NPCancelOrderButton setTitle:title forState:UIControlStateNormal];
        [_NPCancelOrderButton setTitleColor:RGBA(61, 58, 80, 0.2) forState:UIControlStateNormal];
        _NPCancelOrderButton.backgroundColor = RGBA(247, 247, 247, 1);
    }
}

#pragma mark - FPDMarkPaidAlertView delegate
- (void)markPaidAlertViewDidCertain
{
    [self hidePopView];
    [self reqMarkPay];
}

- (void)markPaidAlertViewDidCancel
{
    [self hidePopView];
}


#pragma mark - FPDCancelOrderAlertView delegate
- (void)cancelOrderAlertViewDidCertain
{
    [self hidePopView];
    [self reqCancelDepositOrder];
}

- (void)cancelOrderAlertViewDidCancel
{
    [self hidePopView];
}


#pragma mark - 隐藏所有popView
- (void)hidePopView
{
    [self lew_dismissPopupView];
}
@end
