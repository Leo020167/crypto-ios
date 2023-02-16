//
//  LeverageTransactionVC.m
//  BYY
//
//  Created by Hay on 2019/12/23.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageTransactionVC.h"
#import "NetWorkManage+Leverage.h"
#import "LeverageTransactionHeaderView.h"
#import "QuotationSocketManager.h"
#import "CoinTradeGearEntity.h"
#import "CoinQuotationDataEntity.h"
#import "LewPopupViewAnimationSpring.h"
#import "PayAlertView.h"
#import "LeverageTransactionRecordModel.h"
#import "VeDateUtil.h"
#import "RZButtonMenu.h"

@interface LeverageTransactionVC ()<UITableViewDelegate,UITableViewDataSource,LeverageTransactionHeaderViewDelegate>
{
    NSMutableArray<NSString *> *bondBalanceArr;         //保证金数组
    NSMutableArray<NSString *> *multiNumArr;            //倍数数组
    NSMutableArray *leverageTradeRecordArr;             //杠杆开仓记录
    NSTimer *gearTimer;
    NSMutableArray *buyGearDataArr;
    NSMutableArray *sellGearDataArr;
}

@property (copy, nonatomic) NSString *symbol;           //交易对
@property (copy, nonatomic) NSString *originSymbol;     //币种
@property (copy, nonatomic) NSString *buySell;          //1为看涨，-1看跌
@property (copy, nonatomic) NSString *holdCash;
@property (copy, nonatomic) NSString *holdUsdt;
@property (retain, nonatomic) LeverageCheckOutModel *checkOutModel;
@property (retain, nonatomic) CoinQuotationDataEntity *quotationEntity;
@property (copy, nonatomic) NSString *selectedBondBalance;      //选择的保证金
@property (copy, nonatomic) NSString *selectedMultiNum;         //选择的倍数

/** 懒加载*/
@property (retain, nonatomic) LeverageTransactionHeaderView *transactionInfoView;
@property (retain, nonatomic) UIView *recordHeaderView;
@property (assign, nonatomic) CGFloat nodataCellHeight;
@property (assign, nonatomic) CGFloat recordCellHeight;

@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet UITableView *coreTableView;
@property (retain, nonatomic) IBOutlet UIView *tradeAlertView;              //最后交易提示框
@property (retain, nonatomic) IBOutlet UILabel *tradeAlertTitleLabel;       //标题
@property (retain, nonatomic) IBOutlet UILabel *tradeAlertContentLabel;     //内容

@end

@implementation LeverageTransactionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    bondBalanceArr = [[NSMutableArray alloc] init];
    multiNumArr = [[NSMutableArray alloc] init];
    leverageTradeRecordArr = [[NSMutableArray alloc] init];
    buyGearDataArr = [[NSMutableArray alloc] init];
    sellGearDataArr = [[NSMutableArray alloc] init];
    _coreTableView.delegate = self;
    _coreTableView.dataSource = self;
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionSymbol"]){
        self.symbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionSymbol"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionSymbol"];
        
        _navigationTitleLabel.text = [NSString stringWithFormat:@"%@杠杆",self.symbol];
        [self showProgressDefaultText];
        [self reqLeverageTradeConfig];
    }
    self.buySell = @"1";                    //默认看涨
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionBuySell"]){
        self.buySell = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionBuySell"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionBuySell"];
    }
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionOriginSymbol"]){
        self.originSymbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionOriginSymbol"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTransactionOriginSymbol"];
        
        [self.transactionInfoView initHeaderViewWithBuySell:self.buySell originSymbol:self.originSymbol];
    }
    
    //请求交易记录
    [self reqLeverageTradeRecord];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reqOrderList) name:[CircleSocket circleNotifacationKey:ReceiveModelPushRecordList] object:nil];       //添加一个type为5000的监听，用来刷新订单状态
    
    //启动socket连接
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDidConnectedToServer:self selector:@selector(socketDidConnectedToServer)];
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDisconnectedToServer:self selector:@selector(socketDidDisconnected)];

    [self startGearTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self closeGearTimer];
    [[QuotationSocket shareQuotationSocket] cancelAllNotifcationOfSocket:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}


- (void)dealloc
{
    [bondBalanceArr release];
    [multiNumArr release];
    [buyGearDataArr release];
    [sellGearDataArr release];
    [leverageTradeRecordArr release];
    [_symbol release];
    [_originSymbol release];
    [_buySell release];
    [_holdCash release];
    [_holdUsdt release];
    [_checkOutModel release];
    [_quotationEntity release];
    [_selectedBondBalance release];
    [_selectedMultiNum release];
    [_transactionInfoView release];
    [_recordHeaderView release];
    [_navigationTitleLabel release];
    [_coreTableView release];
    [_tradeAlertView release];
    [_tradeAlertTitleLabel release];
    [_tradeAlertContentLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (LeverageTransactionHeaderView *)transactionInfoView
{
    if(!_transactionInfoView){
        _transactionInfoView = [[[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionHeaderView" owner:nil options:nil] lastObject] retain];
        _transactionInfoView.delegate = self;
    }
    return _transactionInfoView;
}

- (UIView *)recordHeaderView
{
    if(!_recordHeaderView){
        _recordHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionRecordHeaderView" owner:nil options:nil] lastObject] retain];
        UIButton *allButton = [_recordHeaderView viewWithTag:100];
        [allButton addTarget:self action:@selector(allRecordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordHeaderView;
}

- (CGFloat)nodataCellHeight
{
    if(_nodataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionRecordNoDataCell" owner:nil options:nil] lastObject];
        _nodataCellHeight = cell.frame.size.height;
    }
    return _nodataCellHeight;
}

- (CGFloat)recordCellHeight
{
    if(_recordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionRecordCell" owner:nil options:nil] lastObject];
        _recordCellHeight = cell.frame.size.height;
    }
    return _recordCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/** 最终提交确定交易按钮点击事件*/
- (IBAction)finalCommitTradeButtonPressed:(id)sender
{
    [self lew_dismissPopupView];
    [self showProgressDefaultText];
    [self reqCommitLeverageTradeOrder:@""];

}

- (IBAction)cancelTradeButtonPressed:(id)sender
{
    [self lew_dismissPopupView];
}


- (IBAction)moreOptionsButtonPressed:(id)sender
{
    [[[RZButtonMenu alloc] initRZButtonMenu:self showView:sender menuTitles:@[NSLocalizedStringForKey(@"功能介绍"),NSLocalizedStringForKey(@"如何交易")] menuIcon:nil menuFont:[UIFont systemFontOfSize:16] menuFontColor:RGBA(97, 117, 174, 1.0) menuBackgroundColor:RGBA(230, 230, 230, 1.0) menuSegmentingLineColor:RGBA(230, 230, 230, 1.0) menuPlacement:ShowAtBottom] autorelease];
}

/** 数字资产借贷服务协议*/
- (IBAction)digitalAssetsDebitAndCreditProtocolButtonPressed:(id)sender
{
    [self lew_dismissPopupView];
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = DigitalAssetsDebitCreditProtocolWebURL;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

/** 杠杆交易协议*/
- (IBAction)leverageTradeProtocolButtonPressed:(id)sender
{
    
//    TYWebViewController *web = [[TYWebViewController alloc] init];
//    web.url = LeverageTradeProtocolWebURL;
//    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

- (void)allRecordButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"LeverageTransactionRecordVC"];
}

#pragma mark - 请求数据
- (void)reqLeverageTradeConfig
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeConfig:self symbol:self.symbol finishedCallback:@selector(reqLeverageTradeConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqLeverageTradeConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataJson = [json objectForKey:@"data"];
        NSArray *bailBalanceList = [dataJson objectForKey:@"bailBalanceList"];
        NSArray *multiNumList = [dataJson objectForKey:@"multiNumList"];
        [bondBalanceArr removeAllObjects];
        [multiNumArr removeAllObjects];
        for(id item in bailBalanceList){
            [bondBalanceArr addObject:[NSString stringWithFormat:@"%@",@([item doubleValue])]];
        }
        if([bondBalanceArr count] > 0){
            self.selectedBondBalance = [bondBalanceArr firstObject];
        }
        
        
        for(id item in multiNumList){
            [multiNumArr addObject:[NSString stringWithFormat:@"%@",@([item doubleValue])]];
        }
        if([multiNumArr count] > 0){
            self.selectedMultiNum = [multiNumArr firstObject];
        }
        
        TJRBaseEntity *parserJson = [[[TJRBaseEntity alloc] init] autorelease];
        self.holdCash = [parserJson stringParser:@"holdCash" json:dataJson];
        self.holdUsdt = [parserJson stringParser:@"holdUsdt" json:dataJson];
        
        [self.transactionInfoView reloadHeaderViewBondBalanceArr:bondBalanceArr multiNumArr:multiNumArr];
        [self.transactionInfoView reloadHeaderViewHoldCash:self.holdCash holdUsdt:self.holdUsdt];
        
        [self reqLeverageTradeCheckOut];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqLeverageTradeCheckOut
{
    if(!checkIsStringWithAnyText(self.selectedBondBalance) || !checkIsStringWithAnyText(self.selectedMultiNum))
        return;
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeCheckOut:self symbol:_symbol bailBalance:self.selectedBondBalance buySell:self.buySell multiNum:self.selectedMultiNum finishedCallback:@selector(reqLeverageTradeCheckOutFinished:) failedCallback:nil];
}

- (void)reqLeverageTradeCheckOutFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.checkOutModel = [[[LeverageCheckOutModel alloc] initWithJson:dataDic] autorelease];
        [self.transactionInfoView reloadCheckOutInfo:self.checkOutModel];
        
        [_coreTableView reloadData];
    }
}

/** 交易记录*/
- (void)reqLeverageTradeRecord
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeRecord:self symbol:@"" buySell:@"" isDone:@"0" pageNo:@"1" finishedCallback:@selector(reqLeverageTradeRecordFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqLeverageTradeRecordFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        [leverageTradeRecordArr removeAllObjects];
        for(NSDictionary *dic in dataArr){
            LeverageTransactionRecordModel *recordItem = [[[LeverageTransactionRecordModel alloc] initWithJson:dic] autorelease];
            [leverageTradeRecordArr addObject:recordItem];
        }
        [_coreTableView reloadData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


- (void)reqCommitLeverageTradeOrder:(NSString *)payPass
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqCommitLeverageTrade:self symbol:_symbol bailBalance:self.selectedBondBalance buySell:self.buySell multiNum:self.selectedMultiNum payPass:payPass finishedCallback:@selector(reqCommitLeverageTradeOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCommitLeverageTradeOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"操作成功")];
        }
        //交易请求成功后立即请求记录
        [self reqLeverageTradeRecord];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if([self checkIsNotEnoughCash:json]){         //不够资金
            [self notEnoughMoneyJson:json toPageName:@"FundMainController" pageParams:nil];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}


#pragma mark - socket
- (void)socketDidConnectedToServer
{
    [self reqTransactionGearData];
}

- (void)socketReconnect
{
}

- (void)socketDidDisconnected
{
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
    [self performSelector:@selector(socketReconnect) withObject:nil afterDelay:5.0];
    
}

/** 买卖档*/
- (void)reqTransactionGearData
{

}

- (void)socketLoadGearDataFinished:(NSNotification *)notification
{
    NSDictionary *infoDic = notification.userInfo;
    NSDictionary *json = [infoDic objectForKey:MHSocketJsonKey];
    [buyGearDataArr removeAllObjects];
    [sellGearDataArr removeAllObjects];
    NSDictionary *quoteDic = [json objectForKey:_symbol];
    NSArray *buysArr = [quoteDic objectForKey:@"buys"];
    NSArray *sellsArr = [quoteDic objectForKey:@"sells"];
    if([buysArr isKindOfClass:[NSArray class]]){
        for(NSDictionary *buyDic in buysArr){
            CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:buyDic] autorelease];
            [buyGearDataArr addObject:gearEntity];
        }
        
    }
    if([sellsArr isKindOfClass:[NSArray class]]){
        for(NSDictionary *sellDic in sellsArr){
            CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:sellDic] autorelease];
            [sellGearDataArr addObject:gearEntity];
        }
    }
    
    self.quotationEntity = [[[CoinQuotationDataEntity alloc] initWithJson:quoteDic] autorelease];
    
    [self.transactionInfoView realoadGearData:buyGearDataArr sellGearData:sellGearDataArr currentQuotation:_quotationEntity];
}


#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.transactionInfoView.frame.size.height;
    }else if(section == 1){
        return self.recordHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return self.transactionInfoView;
    else if(section == 1)
        return self.recordHeaderView;
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
    if([leverageTradeRecordArr count] == 0)
        return 1;
    return [leverageTradeRecordArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        if([leverageTradeRecordArr count] == 0)
            return self.nodataCellHeight;
        return self.recordCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordCellIdentifier = @"LeverageTransactionRecordCellIdentifier";
    UITableViewCell *cell = nil;
    if([leverageTradeRecordArr count] == 0){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionRecordNoDataCell" owner:nil options:nil] lastObject];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionRecordCell" owner:nil options:nil] lastObject];
        }
        LeverageTransactionRecordModel *recordModel = [leverageTradeRecordArr objectAtIndex:indexPath.row];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *dirStateLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *costPriceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
        titleLabel.text = [NSString stringWithFormat:@"%@ %@X",recordModel.symbol,recordModel.multiNum];
        timeLabel.text = [VeDateUtil formatterDate:recordModel.time inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
        dirStateLabel.text = recordModel.buySellStr;
        costPriceLabel.text = recordModel.openCostPrice;
        profitLabel.text = recordModel.profit;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LeverageTransactionRecordModel *recordModel = [leverageTradeRecordArr objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:recordModel.orderId forKey:@"LeverageTradeDetailOrderId"];
    [self putValueToParamDictionary:ProCoinBaseDict value:[NSString stringWithFormat:@"%@ %@X",recordModel.symbol,recordModel.multiNum] forKey:@"LeverageTradeDetailTitle"];
    [self pageToViewControllerForName:@"LeverageTradeDetailVC"];
}

#pragma mark - LeverageTransactionHeaderView
- (void)commitOrderButtonDidPressedWithBondBalance:(NSString *)bondBalance buySell:(NSString *)buySell multiNum:(NSString *)multiNum
{
    self.buySell = buySell;
    self.selectedBondBalance = bondBalance;
    self.selectedMultiNum = multiNum;
    
    if(!checkIsStringWithAnyText(bondBalance)){
        [self showToastCenter:@"请选择保证金"];
        return;
    }
    if(!checkIsStringWithAnyText(multiNum)){
        [self showToastCenter:@"请选择正确的倍数"];
        return;
    }
    NSString *stateString = @"";
    if([buySell isEqualToString:@"1"]){
        stateString = NSLocalizedStringForKey(@"看涨(做多)");
    }else{
        stateString = NSLocalizedStringForKey(@"看跌(做空)");
    }
    _tradeAlertTitleLabel.text = [NSString stringWithFormat:@"%@概要",stateString];
    _tradeAlertContentLabel.text = [NSString stringWithFormat:@"你将以%@USDT保证金开%@倍杠杆%@",bondBalance,multiNum,stateString];
    [self lew_presentPopupView:self.tradeAlertView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];

}

- (void)buySellButtonDidPressedWithBuySell:(NSString *)buySell
{
    self.buySell = buySell;
    
    [self reqLeverageTradeCheckOut];
}

- (void)bondBalanceDidSelectedWithBondBalance:(NSString *)bondBalance
{
    self.selectedBondBalance = bondBalance;
    
    [self reqLeverageTradeCheckOut];
}

- (void)multiNumDidSelectedWithMultiNum:(NSString *)multiNum
{
    self.selectedMultiNum = multiNum;
    
    [self reqLeverageTradeCheckOut];
}


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

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqCommitLeverageTradeOrder:password];
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
            web.url = LeverageTradeInfoWebURL;
            [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
        }
            break;
        case 1:{
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.url = LeverageHowTradeWebURL;
            [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
        }
            
            break;
        default:
            break;
    }
}
@end
