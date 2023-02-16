//
//  FundWithdrawDetailController.m
//  Cropyme
//
//  Created by Hay on 2019/5/26.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundWithdrawDetailController.h"
#import "CommonUtil.h"
#import "NetWorkManage+Trade.h"
#import "FundExchangeOrderEntity.h"
#import "FundExchangeWayEntity.h"
#import "PrivateChatDataEntity.h"
#import "TradeUtil.h"
#import "VeDateUtil.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "UserInfoSQL.h"
#import "CircleSocket.h"

@interface FundWithdrawDetailController ()

@property (copy, nonatomic) NSString *orderCashId;          //订单id

@property (retain, nonatomic) FundExchangeWayEntity *wayEntity;
@property (retain, nonatomic) FundExchangeOrderEntity *orderEntity;
@property (retain, nonatomic) PrivateChatDataEntity *chatDataEntity;

@property (retain, nonatomic) IBOutlet UILabel *stateDescLabel;             //状态提示
@property (retain, nonatomic) IBOutlet UILabel *stateTipsLabel;             //状态描述
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;                //提现数量
@property (retain, nonatomic) IBOutlet UILabel *usdtRateLabel;              //USDT市价
@property (retain, nonatomic) IBOutlet UILabel *balanceLabel;               //金额
@property (retain, nonatomic) IBOutlet UILabel *receiptNameLabel;           //收款人
@property (retain, nonatomic) IBOutlet UILabel *receiptWayLabel;            //收款方式
@property (retain, nonatomic) IBOutlet UILabel *receiptAccountTitleLabel;   //收款账号标题
@property (retain, nonatomic) IBOutlet UILabel *receiptAccountLabel;        //收款账号
@property (retain, nonatomic) IBOutlet UILabel *receiptOrderIdLabel;        //订单号
@property (retain, nonatomic) IBOutlet UILabel *createTimeLabel;            //提交时间

@property (retain, nonatomic) IBOutlet UIView *remindMsgTipsView;
@property (retain, nonatomic) IBOutlet UILabel *remindMsgCountLabel;

@end

@implementation FundWithdrawDetailController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawDetailCashId"]){
        self.orderCashId = [self getValueFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawDetailCashId"];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawDetailCashId"];
    }
    
    if(checkIsStringWithAnyText(_orderCashId)){
        [self reqWithdrawDetail];
    }
}
- (void)dealloc
{
    [_orderCashId release];
    [_wayEntity release];
    [_orderEntity release];
    [_chatDataEntity release];
    [_amountLabel release];
    [_usdtRateLabel release];
    [_balanceLabel release];
    [_receiptNameLabel release];
    [_receiptWayLabel release];
    [_receiptAccountLabel release];
    [_receiptOrderIdLabel release];
    [_createTimeLabel release];
    [_stateDescLabel release];
    [_stateTipsLabel release];
    [_receiptAccountTitleLabel release];
    [_remindMsgTipsView release];
    [_remindMsgCountLabel release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)chatServiceButtonPressed:(id)sender
{
    [PrivateChatSQL createPrivateChatSQL:_chatDataEntity];
    [UserInfoSQL insertOrUpdateUserInfoWithUserId:_chatDataEntity.userId userName:_chatDataEntity.name userLevel:0 headerUrl:_chatDataEntity.headurl];
    
    PrivateChatDataEntity *entity = [PrivateChatSQL getPrivateTopic:_chatDataEntity.chatTopic];
    if (entity) {
        [self putValueToParamDictionary:ChatDict value:entity.chatTopic forKey:@"chatTopic"];
        [self putValueToParamDictionary:ChatDict value:entity.name forKey:@"userName"];
        [self putValueToParamDictionary:ChatDict value:entity.userId forKey:@"taUserId"];
    }
    _chatDataEntity.chatNews = 0;
    [PrivateChatSQL updatePrivateTopicNews:_chatDataEntity.chatTopic chatNews:_chatDataEntity.chatNews];
    _remindMsgTipsView.hidden = YES;
    [self putValueToParamDictionary:FundExchangeDic value:@"1" forKey:@"FundMainNeedUpdate"];       //回到充值提现首页，提示刷新一下
    [self pageToOrBackWithName:@"ChatViewController"];
}

#pragma mark - 请求数据
- (void)reqWithdrawDetail
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqCashTradeOrderDetil:self orderCashId:_orderCashId finishedCallback:@selector(reqWithdrawDetailFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqWithdrawDetailFinished:(NSDictionary *)json
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
        [self updateViewInfoData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - 更新页面页面
- (void)updateViewInfoData
{
    _stateDescLabel.text = _orderEntity.stateDesc;
    if(_orderEntity.state == 0){
        _stateTipsLabel.text = NSLocalizedStringForKey(@"提现申请已提交，等待平台放款");
    }else{
        _stateTipsLabel.text = NSLocalizedStringForKey(@"提现申请处理已完成");
    }
    
    _amountLabel.text = _orderEntity.amount;
    _usdtRateLabel.text = [TradeUtil stringByAppendingRMBSymbolString:_orderEntity.priceCny];
    _balanceLabel.text = [TradeUtil stringByAppendingRMBSymbolString:_orderEntity.balanceCny];
    _receiptNameLabel.text = _wayEntity.receiptName;
    _receiptWayLabel.text = _wayEntity.receiptTypeValue;
    _receiptAccountTitleLabel.text = [NSString stringWithFormat:@"%@%@",_wayEntity.receiptTypeValue, NSLocalizedStringForKey(@"账号")];
    _receiptAccountLabel.text = _wayEntity.receiptNo;
    _receiptOrderIdLabel.text = _orderEntity.orderCashId;
    _createTimeLabel.text = [VeDateUtil formatterDate:_orderEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd  HH:mm:ss" isTimestamp:YES];
    
    if(_chatDataEntity.chatNews > 0){
        _remindMsgTipsView.hidden = NO;
        _remindMsgCountLabel.text = [NSString stringWithFormat:@"%@",@(_chatDataEntity.chatNews)];
    }else{
        _remindMsgTipsView.hidden = YES;
    }
}


@end
