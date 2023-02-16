//
//  CoinTransactionController.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TYCoinTransactionController.h"
#import "TYQuotationTransactionHeaderView.h"
#import "NetWorkManage+Trade.h"
#import "NetWorkManage+Quotation.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"
#import "PayAlertView.h"
#import "QuotationSocket.h"
#import "PCBaseTransactionRecordModel.h"
#import "TradeUtil.h"
#import "LewPopupViewAnimationSpring.h"
#import "RZButtonMenu.h"
#import "TYMinePositionCell.h"
#import "TYMinePositionDetailViewController.h"
#import "PCDigitalRecordController.h"
#import "PCAccountModel.h"
#import "TYMinePositionModel.h"
#import "BBMinePositionCell.h"

@interface TYCoinTransactionController ()<UITableViewDelegate,UITableViewDataSource,QuotationTransactionHeaderViewDelegate>
{
    NSTimer *gearTimer;
    NSTimer *refreshTransactionTimer;
    NSMutableArray *orderDataArr;           //委托数组
    NSMutableArray *holdDataArr;            //开仓数组
    NSMutableArray *buyGearDataArr;
    NSMutableArray *sellGearDataArr;
}

@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *originSymbol;
@property (copy, nonatomic) NSString *buySell;          //1为买，2为卖
@property (copy, nonatomic) NSString *price;            //价格
@property (copy, nonatomic) NSString *handAmount;       //手数
@property (copy, nonatomic) NSString *orderType;        //交易类型，为market时，price应该为0
@property (copy, nonatomic) NSString *multiNum;         //倍数
@property (copy, nonatomic) NSString *balance;          //交易额
@property (copy, nonatomic) NSString *recharge;         //充值金额
@property (retain, nonatomic) PCTradeConfigModel *configEntity;       //交易配置信息
@property (retain, nonatomic) CoinQuotationDataEntity *quotationEntity;
@property (retain, nonatomic) PCTradeCheckOutModel *checkOutEntity;              //检查校验数据对象
@property (copy, nonatomic) NSString *cancelOrderId;        //撤销订单的id

@property (assign, nonatomic) CGFloat undoneCellHeight;     //未完成cell高度
@property (retain, nonatomic) TYQuotationTransactionHeaderView *transactionHeaderView;              //买卖信息页


@property (retain, nonatomic) UIView *orderHeaderView;              //当前委托持仓headerView
@property (retain, nonatomic) UIButton *orderButton;        //当前委托按钮
@property (retain, nonatomic) UIButton *holdButton;         //当前持仓按钮

@property (retain, nonatomic) IBOutlet UILabel *navigationTitle;
@property (retain, nonatomic) IBOutlet UITableView *coreTableView;
@property (retain, nonatomic) IBOutlet UIView *tradeTipsView;
@property (retain, nonatomic) IBOutlet UILabel *tradeTipsTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *tradeTipsContentLabel;

/// 是否是新币
@property (nonatomic, assign) BOOL isNewCoin;

@end

@implementation TYCoinTransactionController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.canDragBack = NO;
    _coreTableView.delegate = self;
    _coreTableView.dataSource = self;
    //reloadData 视图漂移或者闪动解决方法
    _coreTableView.estimatedRowHeight = 0;
    _coreTableView.estimatedSectionHeaderHeight = 0;
    _coreTableView.estimatedSectionFooterHeight = 0;
    [_coreTableView registerClass:[TYMinePositionCell class] forCellReuseIdentifier:NSStringFromClass([TYMinePositionCell class])];
    [_coreTableView registerClass:[BBMinePositionCell class] forCellReuseIdentifier:NSStringFromClass([BBMinePositionCell class])];
    
    orderDataArr = [[NSMutableArray alloc] init];
    holdDataArr = [[NSMutableArray alloc] init];
    buyGearDataArr = [[NSMutableArray alloc] init];
    sellGearDataArr = [[NSMutableArray alloc] init];
    self.buySell = PCQuotationTransactionBuyType;
    self.orderType = PCTradeLimitOrderType;        //默认限价
    self.price = @"0";
    self.handAmount = @"0";
    self.multiNum = @"";
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionSymbol"]){
        self.symbol = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionSymbol"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionSymbol"];
    }else{
        
    }
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionBuySell"]){
        NSString *param = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionBuySell"];
        if([param isEqualToString:@"1"]){
            self.buySell = PCQuotationTransactionBuyType;
        }else{
            self.buySell = PCQuotationTransactionSellType;
        }
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionBuySell"];
    }
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionOriginSymbol"]){
        self.originSymbol = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionOriginSymbol"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinTransactionOriginSymbol"];
    }
    
    _navigationTitle.text = self.symbol;
    
    [self.transactionHeaderView initHeaderViewWithbuySell:_buySell];

    
    if(checkIsStringWithAnyText(_symbol)){
        [self showProgressDefaultText];
        [self reqTradeConfig];      //获取交易配置
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reqOrderList) name:[CircleSocket circleNotifacationKey:ReceiveModelPushRecordList] object:nil];       //添加一个type为5000的监听，用来刷新订单状态
    
    //启动socket连接
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDidConnectedToServer:self selector:@selector(socketDidConnectedToServer)];
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDisconnectedToServer:self selector:@selector(socketDidDisconnected)];
    [self reqTransactionGearData];
    [self reqHoldAndOrderList];
    
    [self startGearTimer];
    [self startRefreshTransactionTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self closeGearTimer];
    [self closeRefreshTransactionTimer];
    [[QuotationSocket shareQuotationSocket] cancelAllNotifcationOfSocket:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    
    [orderDataArr release];
    [holdDataArr release];
    [buyGearDataArr release];
    [sellGearDataArr release];
    [_symbol release];
    [_originSymbol release];
    [_buySell release];
    [_price release];
    [_handAmount release];
    [_orderType release];
    [_multiNum release];
    [_balance release];
    [_recharge release];
    [_configEntity release];
    [_quotationEntity release];
    [_checkOutEntity release];
    [_cancelOrderId release];
    [_transactionHeaderView release];
    [_orderHeaderView release];
    [_orderButton release];
    [_holdButton release];
    [_navigationTitle release];
    [_coreTableView release];
    [_tradeTipsView release];
    [_tradeTipsTitleLabel release];
    [_tradeTipsContentLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (TYQuotationTransactionHeaderView *)transactionHeaderView
{
    if(!_transactionHeaderView){
        _transactionHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"TYQuotationTransactionHeaderView" owner:nil options:nil] lastObject] retain];
        _transactionHeaderView.delegate = self;
    }
    return _transactionHeaderView;
}



- (UIView *)orderHeaderView
{
    if(!_orderHeaderView){
        _orderHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"CurrentOrderHeaderView" owner:nil options:nil] lastObject] retain];
        UIButton *allRecordButton = (UIButton *)[_orderHeaderView viewWithTag:100];
        UIButton *orderButton = (UIButton *)[_orderHeaderView viewWithTag:101];
        UIButton *holdButton = (UIButton *)[_orderHeaderView viewWithTag:102];
        self.orderButton = orderButton;
        self.holdButton = holdButton;
        [allRecordButton addTarget:self action:@selector(allRecordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [orderButton addTarget:self action:@selector(recordOptionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [holdButton addTarget:self action:@selector(recordOptionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _orderHeaderView;
}


- (CGFloat)undoneCellHeight
{
    if(_undoneCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
        _undoneCellHeight = cell.frame.size.height;
    }
    return _undoneCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)cancelOrderButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSInteger cancelIndex = [_coreTableView indexPathForCell:cell].row;
    PCBaseTransactionRecordModel *entity = [orderDataArr objectAtIndex:cancelIndex];
    self.cancelOrderId = entity.orderId;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定取消该委托订单吗") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqCancelOrder:@""];          //取消订单
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 记录选项按钮点击事件*/
- (void)recordOptionsButtonPressed:(UIButton *)sender
{
    if(sender.isSelected){
        return;
    }
    if(self.orderButton == sender){          //当前委托
        _orderButton.selected = YES;
        _holdButton.selected = NO;
        
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_orderButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _holdButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_holdButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    }else{                              //当前持仓
        _holdButton.selected = YES;
        _orderButton.selected = NO;
        
        _holdButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_holdButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_orderButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    }
    
    [_coreTableView reloadData];
}

- (void)allRecordButtonPressed:(UIButton *)sender
{
    if(_configEntity){
        
    //        NSArray *accountArray = @[@"follow", @"stock", @"digital", @"spot"];
    //        NSArray *titleArray = @[NSLocalizedStringForKey(@"跟单交易记录"), NSLocalizedStringForKey(@"全球期指交易记录"), NSLocalizedStringForKey(@"合约交易记录"), NSLocalizedStringForKey(@"币币交易记录")];
        /// 账户类型  stock 全球指数 digital 合约 spot 币币
        PCDigitalRecordController *record = [[PCDigitalRecordController alloc] init];
        record.accountType = @"spot";
        record.accountName = NSLocalizedStringForKey(@"币币交易记录");
        [self.navigationController pushViewController:record animated:YES];
    }
}

- (IBAction)tradeTipsViewCommitButtonPressed:(id)sender
{
    [self lew_dismissPopupView];
    [self reqTradeOrder:@""];
}

- (IBAction)tradeTipsViewCancelButtonPressed:(id)sender
{
    [self lew_dismissPopupView];
}

/** 交易服务协议*/
- (IBAction)tradeServiceProtocolButtonPressed:(id)sender
{
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = TradeServiceProtocolWebURL;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

/** 更多功能按钮事件*/
- (IBAction)moreButtonPressed:(id)sender
{
    
    
    [[[RZButtonMenu alloc] initRZButtonMenu:self showView:sender menuTitles:@[NSLocalizedStringForKey(@"交易规则")] menuIcon:nil menuFont:[UIFont systemFontOfSize:16] menuFontColor:RGBA(97, 117, 174, 1.0) menuBackgroundColor:RGBA(230, 230, 230, 1.0) menuSegmentingLineColor:RGBA(230, 230, 230, 1.0) menuPlacement:ShowAtBottom] autorelease];
}


#pragma mark - socket
- (void)socketDidConnectedToServer
{
    [self reqTransactionGearData];
    [self reqHoldAndOrderList];
    [self startGearTimer];
    [self startRefreshTransactionTimer];
}

- (void)socketDidDisconnected
{
    [self dismissProgress];
    [self closeGearTimer];
    [self closeRefreshTransactionTimer];
    
}

/** 买卖档*/
- (void)reqTransactionGearData
{
    if(checkIsStringWithAnyText(_symbol)){
        [[NetWorkManage shareSingleNetWork] reqQuotationRealData:self symbol:_symbol depth:[NSString stringWithFormat:@"%@",@(5)] klineType:PCQuotationKLineTypeShareTime finishedCallback:@selector(reqTransactionGearDataFinished:) failedCallback:nil];
    }
}

- (void)reqTransactionGearDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *quoteDic = [dataDic objectForKey:_symbol];
        NSArray *buysArr = [quoteDic objectForKey:@"buys"];
        NSArray *sellsArr = [quoteDic objectForKey:@"sells"];
        [buyGearDataArr removeAllObjects];
        if([buysArr isKindOfClass:[NSArray class]]){
            for(NSDictionary *buyDic in buysArr){
                CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:buyDic] autorelease];
                [buyGearDataArr addObject:gearEntity];
            }
        }
        [sellGearDataArr removeAllObjects];
        if([sellsArr isKindOfClass:[NSArray class]]){
            for(NSDictionary *sellDic in sellsArr){
                CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:sellDic] autorelease];
                [sellGearDataArr addObject:gearEntity];
            }
        }
        self.quotationEntity = [[[CoinQuotationDataEntity alloc] initWithJson:quoteDic] autorelease];
        [self.transactionHeaderView realoadGearData:buyGearDataArr sellGearData:sellGearDataArr currentQuotation:_quotationEntity];
    }

}

#pragma mark - 请求数据
/** 交易页面配置信息*/
- (void)reqTradeConfig
{
    [[NetWorkManage shareSingleNetWork] reqTradeConfig:self symbol:_symbol type:@"2" finishedCallback:@selector(reqTradeConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqTradeConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.configEntity = [[[PCTradeConfigModel alloc] initWithJson:dataDic] autorelease];
        self.multiNum = [self.configEntity.multiNumList firstObject];       //默认使用第一个
        self.configEntity.symbol = self.symbol;
        [self.transactionHeaderView reloadHeaderViewConfig:self.configEntity];
        /** 获取委托与持仓列表*/
        [self reqHoldAndOrderList];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 获取基本数据信息*/
- (void)reqCheckOutInfo
{
    NSString *price = @"";
    if([self.orderType isEqualToString:PCTradeMarketOrderType]){       //如果为市价，price必须为0
        price = @"0";
    }else{
        price = self.price;
    }
    if(!checkIsStringWithAnyText(self.price) || !checkIsStringWithAnyText(self.multiNum)){    //保证不存在空字符
        return;
    }
    if(!checkIsStringWithAnyText(self.handAmount)){ //数量如果为空需要传0
        self.handAmount = @"0";
    }
    
    [[NetWorkManage shareSingleNetWork] reqTradeCheckOut:self symbol:_symbol price:price hand:self.handAmount multiNum:self.multiNum buySell:self.buySell orderType:self.orderType type:@"2" finishedCallback:@selector(reqTradeCheckOutFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqTradeCheckOutFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.checkOutEntity = [PCTradeCheckOutModel yy_modelWithDictionary:dataDic];
        self.checkOutEntity.buySell = self.buySell;
        [self.transactionHeaderView reloadCheckOutData:_checkOutEntity];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 下单接口*/
- (void)reqTradeOrder:(NSString *)payPass
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqTradeOrder:self symbol:_symbol price:self.price hand:self.handAmount buySell:self.buySell multiNum:self.multiNum orderType:self.orderType payPass:payPass type:@"2" finishedCallback:@selector(reqTradeOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
    
}

- (void)reqTradeOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [self showToastCenter:json[@"msg"]];
        [self reqOrderList];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            payAlertView.tag = 10000;
            [payAlertView show];
        }else if([self checkIsNotEnoughCash:json]){         //不够资金
            NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"充币") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ChargeCoinSymbol"];
                [self pageToViewControllerForName:@"ChargeCoinController"];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"Transfers") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self pageToViewControllerForName:@"PCTransferCoinController"];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }else if([[NSString stringWithFormat:@"%@",[json objectForKey:@"code"]] isEqualToString:@"40090"]){
            NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去认证") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self pageToViewControllerForName:@"MyOauthController"];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

- (void)reqCancelOrder:(NSString *)payPass
{
    if(checkIsStringWithAnyText(self.cancelOrderId)){
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqTradeCancelOrder:self orderId:self.cancelOrderId payPass:payPass type:@"2" finishedCallback:@selector(reqCancelOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
    }
    
    
}

- (void)reqCancelOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"已成功发送撤销")];
        }
        /** 请求数据立即刷新*/
        [self reqOrderList];
        
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            payAlertView.tag = 10001;
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

/** 请求委托与持仓订单*/
- (void)reqHoldAndOrderList
{
    [self getData];
    [self reqOrderList];
}

- (void)getData{
    if (!ROOTCONTROLLER_USER.userId) {
        return;
    }
    [YYRequestUtility Post:@"home/account.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            
            NSDictionary *spotDic = [responseDict[@"data"] objectForKey:@"spotAccount"];
            PCAccountModel *spotModel = [PCAccountModel yy_modelWithDictionary:spotDic];
            [holdDataArr removeAllObjects];
            for(NSDictionary *dic in spotModel.openList){
                TYMinePositionModel *entity = [TYMinePositionModel yy_modelWithDictionary:dic];
                [holdDataArr addObject:entity];
            }
            if(_holdButton.isSelected){
                [_coreTableView reloadData];
            }
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

/** 请求委托订单*/
- (void)reqOrderList
{
    if(_configEntity == nil)
        return;
    [[NetWorkManage shareSingleNetWork] reqDigitalStockTransactionRecord:self symbol:@"" accountType:_configEntity.accountType isDone:@"1" pageNo:@"1" buySell:@"" orderState:@"0" type:@"2" finishedCallback:@selector(reqOrderListFinished:) failedCallback:nil];
}

- (void)reqOrderListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        [orderDataArr removeAllObjects];
        for(NSDictionary *dic in dataArr){
            PCBaseTransactionRecordModel *entity = [PCBaseTransactionRecordModel yy_modelWithDictionary:dic];
            [orderDataArr addObject:entity];
        }
        if(_orderButton.isSelected){
            [_coreTableView reloadData];
        }
        
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

/** 请求持仓订单*/
//- (void)reqHoldCoinData
//{
//    if(_configEntity == nil)
//        return;
//    [[NetWorkManage shareSingleNetWork] reqDigitalStockTransactionRecord:self symbol:_symbol accountType:_configEntity.accountType isDone:@"0" pageNo:@"1" buySell:@"" orderState:@"1" type:@"2" finishedCallback:@selector(reqHoldCoinDataFinished:) failedCallback:nil];
//}
//
//- (void)reqHoldCoinDataFinished:(NSDictionary *)json
//{
//    if([self checkJsonIsSuccess:json]){
//        NSDictionary *dataDic = [json objectForKey:@"data"];
//        NSArray *dataArr = [dataDic objectForKey:@"data"];
//        [holdDataArr removeAllObjects];
//        for(NSDictionary *dic in dataArr){
//            TYMinePositionModel *model = [TYMinePositionModel yy_modelWithDictionary:dic];
//            [holdDataArr addObject:model];
//        }
//        if(_holdButton.isSelected){
//            [_coreTableView reloadData];
//        }
//    }
//}



#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return [self.transactionHeaderView transactionHeaderViewCurrentHeight];
    }else if(section == 1){
       return self.orderHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.transactionHeaderView;
    }else if(section == 1){
        return self.orderHeaderView;
    }
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1){               //委托，持仓
        if(self.orderButton.isSelected){
            return [orderDataArr count];
        }else{          //当前持仓
            return [holdDataArr count];
        }
        
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        if(self.orderButton.isSelected){
            return self.undoneCellHeight;
        }else{
            return 120;
        }
    }
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *unDoneCellIdentifier = @"PCBaseTransactionOrderCellIdentifier";
    if(_orderButton.isSelected){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unDoneCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
            UIButton *cancelOrderButton = (UIButton *)[cell viewWithTag:500];
            [cancelOrderButton addTarget:self action:@selector(cancelOrderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        PCBaseTransactionRecordModel *entity = [orderDataArr objectAtIndex:indexPath.row];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
        titleLabel.text = [NSString stringWithFormat:@"%@·%@", entity.symbol, entity.buySellValue];
        dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
        handAmountLabel.text = entity.amount;
        priceLabel.text = entity.price;
        openBailLabel.text = entity.sum;
        return cell;
    }else{
//        TYMinePositionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMinePositionCell class]) forIndexPath:indexPath];
//        TYMinePositionModel *model = holdDataArr[indexPath.row];
//        cell.model = model;
        
        BBMinePositionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BBMinePositionCell class]) forIndexPath:indexPath];
        TYMinePositionModel *model = holdDataArr[indexPath.row];
        cell.model = model;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 1){         //开仓与委托数据
        if(_holdButton.isSelected){    //开仓成功的才能看详情，委托不能点击
            TYMinePositionModel *entity = [holdDataArr objectAtIndex:indexPath.row];
            TYMinePositionDetailViewController *detail = [[TYMinePositionDetailViewController alloc] init];
            detail.symbol = entity.symbol;
            [QMUIHelper.visibleViewController.navigationController pushViewController:detail animated:YES];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_coreTableView == scrollView){
        [self.transactionHeaderView inputTextResignFirstResponder];
    }
}

#pragma mark - QuotationTransactionHeaderViewDelegate
- (void)transactionHeaderViewDidChangedOrderType:(NSString *)orderType inputPrice:(NSString *)inputPrice handAmount:(NSString *)handAmount multiNum:(NSString *)multiNum buySell:(NSString *)buySell
{
    if (!ROOTCONTROLLER_USER.userId) {
        return;
    }
    self.orderType = orderType;
    self.price = inputPrice;
    self.handAmount = handAmount;
    self.multiNum = multiNum;
    self.buySell = buySell;
    [self reqCheckOutInfo];
}

/** 交易提交*/
- (void)commitOrderButtonPressedOrderType:(NSString *)orderType inputPrice:(NSString *)inputPrice handAmount:(NSString *)handAmount multiNum:(NSString *)multiNum buySell:(NSString *)buySell openBond:(NSString *)openBond
{
    if(!checkIsStringWithAnyText(inputPrice)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入价格")];
        return;
    }
    if(!checkIsStringWithAnyText(handAmount)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入数量")];
        return;
    }
    if(!checkIsStringWithAnyText(multiNum)){
        [self showToastCenter:NSLocalizedStringForKey(@"Please choose a multiplier")];
        return;
    }
    
    self.orderType = orderType;
    self.price = inputPrice;
    self.handAmount = handAmount;
    self.multiNum = multiNum;
    self.buySell = buySell;

    NSString *stateString = @"";
    
    if([buySell isEqualToString:PCQuotationTransactionBuyType]){
        stateString = NSLocalizedStringForKey(@"买入");
    }else{
        stateString = NSLocalizedStringForKey(@"卖出");
        if (handAmount.floatValue > self.checkOutEntity.availableAmount.floatValue) {
            [QMUITips showError:[NSString stringWithFormat:@"%@%@", self.symbol, NSLocalizedStringForKey(@"数量不足")]];
            return;
        }
    }
    _tradeTipsTitleLabel.text = [NSString stringWithFormat:@"%@%@",stateString, NSLocalizedStringForKey(@"提示")];
    _tradeTipsContentLabel.text = NSLocalizedStringForKey(@"是否确定下单？");
//    [self lew_presentPopupView:self.tradeTipsView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];
    [self reqTradeOrder:@""];

}

/** 划转按钮点击回调*/
- (void)transactionHeaderViewTransferCoinButtonDidPressed
{
    [self pageToViewControllerForName:@"PCTransferCoinController"];
}

//#pragma mark - 接收post信息
//- (void)transactionOrderStateDidChanged:(NSNotification *)notifi
//{
//    [self reqOrderList];
//    [self reqHoldCoinData];
//}

#pragma mark - 开启关闭定时器
- (void)startGearTimer
{
    [self closeGearTimer];
    gearTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(reqTransactionGearData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:gearTimer forMode:NSRunLoopCommonModes];
}

- (void)closeGearTimer
{
    if(gearTimer && [gearTimer isValid]){
        [gearTimer invalidate];
        gearTimer = nil;
    }
}

- (void)startRefreshTransactionTimer
{
    [self closeRefreshTransactionTimer];
    refreshTransactionTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(reqHoldAndOrderList) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:refreshTransactionTimer forMode:NSRunLoopCommonModes];
}

- (void)closeRefreshTransactionTimer
{
    if(refreshTransactionTimer && [refreshTransactionTimer isValid]){
        [refreshTransactionTimer invalidate];
        refreshTransactionTimer = nil;
    }
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        if(toolView.tag == 10000){
            [self reqTradeOrder:password];
        }else{
            [self reqCancelOrder:password];
        }
        
        [toolView close];
    }else{
        [toolView reset];
    }
}

#pragma mark - menu button delegate
- (void)menu:(BaseMenuViewController *)menu didClickedItemUnitWithTag:(NSInteger)tag andItemUnitTitle:(NSString *)title
{
    switch (tag) {
        case 0:{
                TYWebViewController *web = [[TYWebViewController alloc] init];
                web.url = TradeRulesWebURL;
                [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
            }
            break;
        default:
            break;
    }
}

@end
