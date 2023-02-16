//
//  PCTransactionDetailController.m
//  ProCoin
//
//  Created by Hay on 2020/2/28.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransactionDetailController.h"
#import "NetWorkManage+Trade.h"
#import "PCTransactionDetailModel.h"
#import "CommonUtil.h"
#import "TradeUtil.h"
#import "VeDateUtil.h"
#import "PCTransactionStopWinLossSettingView.h"
#import "PayAlertView.h"
#import "PCNormalCloseView.h"
#import "PCCloseOrderDetailModel.h"

@interface PCTransactionDetailController ()<UITableViewDelegate,UITableViewDataSource,PCTransactionStopWinLossSettingViewDelegate,PCNormalCloseViewDelegate>
{
    NSTimer *refreshTimer;
    NSMutableArray *closeDetailDataArr;
}

/** 变量*/
@property (copy, nonatomic) NSString *orderId;
@property (retain, nonatomic) PCTransactionDetailModel *detailEntity;
@property (assign, nonatomic) PCTDStopWinLossType winLossType;         //止盈止损类型
@property (copy, nonatomic) NSString *winLossPrice;                    //止盈止损价格
@property (copy, nonatomic) NSString *closeHand;                       //平仓手数，0为快捷，>0为普通平仓

/** 懒加载*/
@property (assign, nonatomic) CGFloat profitInfoCellHeight;
@property (assign, nonatomic) CGFloat openInfoCellHeight;
@property (assign, nonatomic) CGFloat currentPriceCellHeight;
@property (retain, nonatomic) UIView *closeHeaderView;
@property (assign, nonatomic) CGFloat closeDetailCellHeight;

/** UI*/
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet UIView *operationView;               //可操作性view

@end

@implementation PCTransactionDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    closeDetailDataArr = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    //reloadData 视图漂移或者闪动解决方法
    _dataTableView.estimatedRowHeight = 0;
    _dataTableView.estimatedSectionHeaderHeight = 0;
    _dataTableView.estimatedSectionFooterHeight = 0;
    [CommonUtil viewHeightForAutoLayout:_operationView height:0];           //默认先隐藏
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"TransactionDetailOrderId"]){
        self.orderId = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"TransactionDetailOrderId"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"TransactionDetailOrderId"];
        
        [self reqTransactionDetailInfo];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startRefreshTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self closeRefreshTimer];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [closeDetailDataArr release];
    [_orderId release];
    [_detailEntity release];
    [_winLossPrice release];
    [_closeHand release];
    [_closeHeaderView release];
    [_dataTableView release];
    [_navigationTitleLabel release];
    [_operationView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)stopLossPriceSettingButtonPressed:(UIButton *)sender
{
    PCTransactionStopWinLossSettingView *settingView = (PCTransactionStopWinLossSettingView *)[[[NSBundle mainBundle] loadNibNamed:@"PCTransactionStopWinLossSettingView" owner:nil options:nil] lastObject];
    settingView.delegate = self;
    settingView.priceDecimals = _detailEntity.priceDecimals;
    [settingView showViewInView:self.view settingType:PCTDStopLossType];
}

- (void)stopWinPriceSettingButtonPressed:(UIButton *)sender
{
    PCTransactionStopWinLossSettingView *settingView = (PCTransactionStopWinLossSettingView *)[[[NSBundle mainBundle] loadNibNamed:@"PCTransactionStopWinLossSettingView" owner:nil options:nil] lastObject];
    settingView.delegate = self;
    settingView.priceDecimals = _detailEntity.priceDecimals;
    [settingView showViewInView:self.view settingType:PCTDStopWinType];
}

/** 普通平仓*/
- (IBAction)normalCloseOrderButtonPressed:(id)sender
{
    PCNormalCloseView *closeView = [[[PCNormalCloseView alloc] init] autorelease];
    closeView.delegate = self;
    [closeView showInController:self holdAmount:_detailEntity.openHand];
}

/** 快捷平仓点击事件*/
- (IBAction)closeOrderButtonPressed:(id)sender
{
    self.closeHand = @"0";      //快捷平仓
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定进行快捷平仓操作？") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqStopOrderOperation:@""];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 懒加载
- (CGFloat)profitInfoCellHeight
{
    if(_profitInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDProfitInfoCell" owner:nil options:nil] lastObject];
        _profitInfoCellHeight = cell.frame.size.height;
    }
    return _profitInfoCellHeight;
}

- (CGFloat)openInfoCellHeight
{
    if(_openInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDOpenInfoCell" owner:nil options:nil] lastObject];
        _openInfoCellHeight = cell.frame.size.height;
    }
    return _openInfoCellHeight;
}

- (CGFloat)currentPriceCellHeight
{
    if(_currentPriceCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCurrentPriceCell" owner:nil options:nil] lastObject];
        _currentPriceCellHeight = cell.frame.size.height;
    }
    return _currentPriceCellHeight;
}

- (UIView *)closeHeaderView
{
    if(_closeHeaderView == nil){
        self.closeHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCloseHeaderView" owner:nil options:nil] lastObject];
    }
    return _closeHeaderView;
}

- (CGFloat)closeDetailCellHeight
{
    if(_closeDetailCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCloseInfoCell" owner:nil options:nil] lastObject];
        _closeDetailCellHeight = cell.frame.size.height;
    }
    return _closeDetailCellHeight;
}

#pragma mark - 请求数据
- (void)reqTransactionDetailInfo
{
    [[NetWorkManage shareSingleNetWork] reqTransactionDetail:self orderId:_orderId finishedCallback:@selector(reqTradeDetailInfoFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqTradeDetailInfoFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *orderDic = [dataDic objectForKey:@"order"];
        NSArray *closeDetailsArr = [orderDic objectForKey:@"closeDetails"];
        [closeDetailDataArr removeAllObjects];
        for(NSDictionary *closeDetailDic in closeDetailsArr){
            PCCloseOrderDetailModel *entity = [[[PCCloseOrderDetailModel alloc] initWithJson:closeDetailDic] autorelease];
            [closeDetailDataArr addObject:entity];
        }
        
        self.detailEntity = [[[PCTransactionDetailModel alloc] initWithJson:orderDic] autorelease];
        if(_detailEntity.openDone && !_detailEntity.closeDone){ //持仓状态中
            [CommonUtil viewHeightForAutoLayout:_operationView height:54];           //开启
        }else{      //已平仓状态
            [CommonUtil viewHeightForAutoLayout:_operationView height:0];           //隐藏
        }
        _navigationTitleLabel.text = self.detailEntity.symbol;
        [_dataTableView reloadData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqSetStopLossPrice:(NSString *)price payPass:(NSString *)payPass
{
    [[NetWorkManage shareSingleNetWork] reqSetStopLossPriceOperation:self orderId:_orderId stopLossPrice:price payPass:payPass finishedCallback:@selector(reqSetStopLossPriceFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSetStopLossPriceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        [self showToastCenter:msg];
        /**更新数据*/
        [self reqTransactionDetailInfo];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

- (void)reqSetStopWinPrice:(NSString *)price payPass:(NSString *)payPass
{
    [[NetWorkManage shareSingleNetWork] reqSetStopWinPriceOperation:self orderId:_orderId stopWinPrice:price payPass:payPass finishedCallback:@selector(reqSetStopWinPriceFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSetStopWinPriceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        [self showToastCenter:msg];
        /**更新数据*/
        [self reqTransactionDetailInfo];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

- (void)reqStopOrderOperation:(NSString *)payPass
{
    [[NetWorkManage shareSingleNetWork] reqStopOrderOperation:self orderId:_orderId closeHand:_closeHand payPass:payPass finishedCallback:@selector(reqStopOrderOperationFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqStopOrderOperationFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        [self showToastCenter:msg];
        /**更新数据*/
        [self reqTransactionDetailInfo];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            payAlertView.tag = 10010;
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([closeDetailDataArr count] > 0){
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        return self.closeHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        return self.closeHeaderView;
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
    if(section == 0){
        if(_detailEntity != nil){
            if(_detailEntity.openDone && !_detailEntity.closeDone){     //持仓状态中包含现价
                return 3;
            }else{
                return 2;
            }
        }
    }else if(section == 1){
        return [closeDetailDataArr count];
    }
    return  0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){             //盈亏
            return self.profitInfoCellHeight;
        }else if(indexPath.row == 1){       //开仓信息
            return self.openInfoCellHeight;
        }else if(indexPath.row == 2){       //现价信息
            return self.currentPriceCellHeight;
        }
    }else if(indexPath.section == 1){
        return self.closeDetailCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *closeInfoCellIdentifier = @"PCTDCloseInfoCellIdentifier";
    if(indexPath.section == 0){
        if(indexPath.row == 0){             //盈亏
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDProfitInfoCell" owner:nil options:nil] lastObject];
            UILabel *profitLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *profitRateLabel = (UILabel * )[cell viewWithTag:101];
            profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:self.detailEntity.profit];
            profitRateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:self.detailEntity.profitRate]];
            profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[self.detailEntity.profit doubleValue]];
            profitRateLabel.textColor = [TradeUtil textColorWithQuotationNumber:[self.detailEntity.profitRate doubleValue]];
            return cell;
        }else if(indexPath.row == 1){       //开仓信息
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDOpenInfoCell" owner:nil options:nil] lastObject];
            UILabel *openPriceLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *buySellLabel = (UILabel *)[cell viewWithTag:101];
            UILabel *openBailLabel = (UILabel *)[cell viewWithTag:102];
            UILabel *openHandLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *openFeeLabel = (UILabel *)[cell viewWithTag:104];
            UILabel *openTimeLabel = (UILabel *)[cell viewWithTag:105];
            UILabel *stopLossLabel = (UILabel *)[cell viewWithTag:106];
            UILabel *stopWinLabel = (UILabel *)[cell viewWithTag:107];
            UILabel *openStateLabel = (UILabel *)[cell viewWithTag:108];
            UIButton *stopLossSettingButton = (UIButton *)[cell viewWithTag:200];
            UIButton *stopWinSettingButton = (UIButton *)[cell viewWithTag:201];
            [stopLossSettingButton addTarget:self action:@selector(stopLossPriceSettingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [stopWinSettingButton addTarget:self action:@selector(stopWinPriceSettingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if(_detailEntity.openDone && !_detailEntity.closeDone){     //持仓状态中
                stopLossSettingButton.hidden = NO;
                stopWinSettingButton.hidden = NO;
            }else{
                stopLossSettingButton.hidden = YES;
                stopWinSettingButton.hidden = YES;
            }
            openPriceLabel.text = _detailEntity.openPrice;
            buySellLabel.text = _detailEntity.buySellValue;
            buySellLabel.textColor = [_detailEntity.buySell isEqualToString:@"buy"] ? [TradeUtil textColorWithQuotationNumber:1.0] : [TradeUtil textColorWithQuotationNumber:-1.0];
            openBailLabel.text = _detailEntity.openBail;
            openHandLabel.text = _detailEntity.openHand;
            openFeeLabel.text = _detailEntity.openFee;
            openTimeLabel.text = [VeDateUtil formatterDate:_detailEntity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
            stopLossLabel.text = [_detailEntity.stopLossPrice doubleValue] == 0 ? NSLocalizedStringForKey(@"未设置"):_detailEntity.stopLossPrice;
            stopWinLabel.text = [_detailEntity.stopWinPrice doubleValue] == 0 ? NSLocalizedStringForKey(@"未设置"):_detailEntity.stopWinPrice;
            openStateLabel.text = _detailEntity.openStateDesc;
            
            return cell;
        }else{                              //现价信息
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCurrentPriceCell" owner:nil options:nil] lastObject];
            UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *currentPriceLabel = (UILabel *)[cell viewWithTag:101];
            UIImageView *stateIV = (UIImageView *)[cell viewWithTag:102];
            symbolLabel.text = [NSString stringWithFormat:@"%@%@",_detailEntity.symbol, NSLocalizedStringForKey(@"现价")];
            currentPriceLabel.text = [NSString stringWithFormat:@"%@ %@%%",_detailEntity.last,[TradeUtil stringByAppendingPlusSymbolString:_detailEntity.rate]];
            currentPriceLabel.textColor = [TradeUtil textColorWithQuotationNumber:[_detailEntity.rate doubleValue]];
            if([_detailEntity.rate doubleValue] >= 0){
                stateIV.image = [UIImage imageNamed:@"leverage_icon_rise"];
            }else{
                stateIV.image = [UIImage imageNamed:@"leverage_icon_down"];
            }
            return cell;
        }
    }else{              //平仓详细
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:closeInfoCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCloseInfoCell" owner:nil options:nil] lastObject];
        }
        PCCloseOrderDetailModel *entity = [closeDetailDataArr objectAtIndex:indexPath.row];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *closePriceLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *closeHandLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *closeFeeLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *closeTimeLabel = (UILabel *)[cell viewWithTag:104];
        UILabel *profitShareLabel = (UILabel *)[cell viewWithTag:105];
        UILabel *subsidyLabel = (UILabel *)[cell viewWithTag:106];
        profitLabel.text = entity.profit;
        profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[entity.profit doubleValue]];
        closePriceLabel.text = entity.closePrice;
        closeHandLabel.text = [NSString stringWithFormat:@"%@手",entity.closeHand];
        closeFeeLabel.text = entity.closeFee;
        closeTimeLabel.text = [VeDateUtil formatterDate:entity.closeTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
        profitShareLabel.text = fabsf(entity.profitShare.floatValue) > 0 ? [NSString stringWithFormat:@"-%f",fabsf(entity.profitShare.floatValue)] : entity.profitShare;
        subsidyLabel.text = [NSString stringWithFormat:@"%f",fabsf(entity.lossShare.floatValue)];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_detailEntity.openDone && !_detailEntity.closeDone && indexPath.section == 0 && indexPath.row == 2){     //持仓状态中并点击了现价
        [self putValueToParamDictionary:CoinTradeDic value:[TradeUtil originSymbolAccquireBySymbol:_detailEntity.symbol] forKey:@"CoinQuotationsDetailOriginSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:_detailEntity.symbol forKey:@"CoinQuotationsDetailSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:_detailEntity.marketType forKey:@"CoinQuotationDetailMarketType"];
        [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
    }
}

#pragma mark - PCTransactionStopWinLossSettingView delegate
- (void)stopWinLossSettingView:(PCTransactionStopWinLossSettingView *_Nonnull)settingView commitDataButtonPressedWithSettingType:(PCTDStopWinLossType)type limitPrice:(NSString *)limitPrice
{
    if(!checkIsStringWithAnyText(limitPrice)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入价格")];
        return;
    }

    NSString *msg = @"";
    if(type == PCTDStopLossType){
        msg = [NSString stringWithFormat:@"%@:%@？", NSLocalizedStringForKey(@"是否确定设置止损价"), limitPrice];
    }else{
        msg = [NSString stringWithFormat:@"%@:%@？", NSLocalizedStringForKey(@"是否确定设置止盈价"), limitPrice];
    }
    self.winLossType = type;
    self.winLossPrice = limitPrice;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [settingView dimissViewWithAnimation];
        [self showProgressDefaultText];
        if(type == PCTDStopLossType){
            [self reqSetStopLossPrice:limitPrice payPass:@""];
        }else{
            [self reqSetStopWinPrice:limitPrice payPass:@""];
        }
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self showProgressDefaultText];
        if(toolView.tag == 10010){
            [self reqStopOrderOperation:password];
        }else{
            if(_winLossType == PCTDStopLossType){
                [self reqSetStopLossPrice:self.winLossPrice payPass:password];
            }else{
                [self reqSetStopWinPrice:self.winLossPrice payPass:password];
            }
        }
        
        
        [toolView close];
    }else{
        [toolView reset];
    }
}

#pragma mark - 定时器
- (void)startRefreshTimer
{
    [self closeRefreshTimer];
    refreshTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(reqTransactionDetailInfo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:refreshTimer forMode:NSRunLoopCommonModes];
}

- (void)closeRefreshTimer
{
    if(refreshTimer && [refreshTimer isValid]){
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}

#pragma mark - PCNormalCloseView delegate
- (void)normalCloseViewDidCommit:(PCNormalCloseView *)closeView handAmount:(NSString *)handAmount
{
    if(!checkIsStringWithAnyText(handAmount) || [handAmount integerValue] == 0){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入大于0的平仓手数")];
        return;
    }
    self.closeHand = handAmount;
    [closeView dismissViewWithAnimation];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"是否以当前市价成交平仓%@手"),handAmount] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqStopOrderOperation:@""];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
