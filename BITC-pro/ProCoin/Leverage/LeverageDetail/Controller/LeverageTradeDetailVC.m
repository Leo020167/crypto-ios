//
//  LeverageTradeDetailVC.m
//  BYY
//
//  Created by Hay on 2019/12/30.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageTradeDetailVC.h"
#import "LeverageDetailInfoHeaderView.h"
#import "NetWorkManage+Leverage.h"
#import "LeverageDetailOpenInfoCell.h"
#import "LeverageDetailBorrowInfoCell.h"
#import "LeverageDetailCloseInfoCell.h"
#import "LeverageDetailOperationCell.h"
#import "LeverageAddBondBalanceView.h"
#import "LeverageWinLossRateSettingView.h"
#import "TradeUtil.h"

@interface LeverageTradeDetailVC ()<UITableViewDelegate,UITableViewDataSource,LeverageDetailOperationCellDeleagte,LeverageDetailOpenInfoCellDelegate,LeverageAddBondBalanceViewDelegate,LeverageDetailBorrowInfoCellDelegate,LeverageWinLossRateSettingViewDelegate>
{
    NSMutableArray *bondBalanceArr;         //保证金数组
}

@property (copy, nonatomic) NSString *selectedBondBalance;
@property (retain, nonatomic) LeverageTradeDetailModel *detailModel;
@property (copy, nonatomic) NSString *holdUsdt;
@property (copy, nonatomic) NSString *stopWin;
@property (copy, nonatomic) NSString *stopLoss;


/** 懒加载*/
@property (retain, nonatomic) LeverageDetailInfoHeaderView *infoHeaderView;
@property (assign, nonatomic) CGFloat openInfoCellHeight;
@property (assign, nonatomic) CGFloat borrowInfoCellHeight;
@property (assign, nonatomic) CGFloat closeInfoCellHeight;
@property (assign, nonatomic) CGFloat operationCellHeight;

@property (copy, nonatomic) NSString *orderId;

@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet UITableView *detailTableView;

@end

@implementation LeverageTradeDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    bondBalanceArr = [[NSMutableArray alloc] init];
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTradeDetailOrderId"]){
        self.orderId = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTradeDetailOrderId"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTradeDetailOrderId"];
        
        [self showProgressDefaultText];
        [self reqLeverageTradeDetail];
    }
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTradeDetailTitle"]){
        _navigationTitleLabel.text = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTradeDetailTitle"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"LeverageTradeDetailTitle"];
    }
}

- (void)dealloc
{
    [bondBalanceArr release];
    [_selectedBondBalance release];
    [_detailModel release];
    [_holdUsdt release];
    [_stopWin release];
    [_stopLoss release];
    [_infoHeaderView release];
    [_orderId release];
    [_navigationTitleLabel release];
    [_detailTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (LeverageDetailInfoHeaderView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailInfoHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _infoHeaderView;
}

- (CGFloat)openInfoCellHeight
{
    if(_openInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailOpenInfoCell" owner:nil options:nil] lastObject];
        _openInfoCellHeight = cell.frame.size.height;
    }
    return _openInfoCellHeight;
}

- (CGFloat)borrowInfoCellHeight
{
    if(_borrowInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailBorrowInfoCell" owner:nil options:nil] lastObject];
        _borrowInfoCellHeight = cell.frame.size.height;
    }
    return _borrowInfoCellHeight;
}

- (CGFloat)closeInfoCellHeight
{
    if(_closeInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailCloseInfoCell" owner:nil options:nil] lastObject];
        _closeInfoCellHeight = cell.frame.size.height;
    }
    return _closeInfoCellHeight;
}

- (CGFloat)operationCellHeight
{
    if(_operationCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailOperationCell" owner:nil options:nil] lastObject];
        _operationCellHeight = cell.frame.size.height;
    }
    return _operationCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - 请求数据
- (void)reqLeverageTradeDetail
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeDetail:self orderId:self.orderId finishedCallback:@selector(reqLeverageTradeDetailFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqLeverageTradeDetailFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *orderDic = [dataDic objectForKey:@"order"];
        self.detailModel = [[[LeverageTradeDetailModel alloc] initWithJson:orderDic] autorelease];
        
        [self.infoHeaderView reloadInfoHeaderViewProfit:_detailModel.profit];
        
        [_detailTableView reloadData];
        
        [self reqLeverageTradeConfig];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqLeverageTradeConfig
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeConfig:self symbol:_detailModel.symbol finishedCallback:@selector(reqLeverageTradeConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqLeverageTradeConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataJson = [json objectForKey:@"data"];
        NSArray *bailBalanceList = [dataJson objectForKey:@"bailBalanceList"];
        [bondBalanceArr removeAllObjects];
        for(id item in bailBalanceList){
            [bondBalanceArr addObject:[NSString stringWithFormat:@"%@",@([item doubleValue])]];
        }
        
        TJRBaseEntity *parserJson = [[[TJRBaseEntity alloc] init] autorelease];
        self.holdUsdt = [parserJson stringParser:@"holdUsdt" json:dataJson];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 增加保证金*/
- (void)reqAddLeverageBondBalance
{
    if(checkIsStringWithAnyText(self.selectedBondBalance)){
        [[NetWorkManage shareSingleNetWork] reqLeverageAddBondBalance:self orderId:_orderId bailBalance:self.selectedBondBalance finishedCallback:@selector(reqAddLeverageBondBalanceFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
    }
}

- (void)reqAddLeverageBondBalanceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        [self showToastCenter:msg];
        //重新请求数据
        [self reqLeverageTradeDetail];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 平仓*/
- (void)reqCloseLeverageTrade
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeClose:self orderId:_orderId finishedCallback:@selector(reqCloseLeverageTradeFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCloseLeverageTradeFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showErrorToastCenter:json defaultErrorMsg:msg];
        }
        [self reqLeverageTradeDetail];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 获取设置止盈止损前的提示*/
- (void)reqCheckWinLoss
{
    [[NetWorkManage shareSingleNetWork] reqLeverageCheckWinLoss:self orderId:_orderId stopWin:self.stopWin stopLoss:self.stopLoss finishedCallback:@selector(reqCheckWinLossFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCheckWinLossFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSMutableString *msg = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]]];
        if(!checkIsStringWithAnyText(msg)){
            msg = [NSMutableString stringWithFormat:@"%@：", NSLocalizedStringForKey(@"是否确认设置")] ;
            if(!checkIsStringWithAnyText(self.stopWin) || [self.stopWin doubleValue] <= 0){
                [msg appendString:NSLocalizedStringForKey(@"止盈：不设置")];
            }else{
                [msg appendString:[NSString stringWithFormat:@"%@：%@%%", NSLocalizedStringForKey(@"止盈"), self.stopWin]];
            }
            
            if(!checkIsStringWithAnyText(self.stopLoss) || [self.stopLoss doubleValue] <= 0){
                [msg appendString:NSLocalizedStringForKey(@"止损：不设置")];
            }else{
                [msg appendString:[NSString stringWithFormat:@"%@：%@%%", NSLocalizedStringForKey(@"止损"), self.stopLoss]];
            }
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showProgressDefaultText];
            [self reqSetStopWinLoss];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqSetStopWinLoss
{
    [[NetWorkManage shareSingleNetWork] reqLeverageSetWinLoss:self orderId:_orderId stopWin:self.stopWin stopLoss:self.stopLoss finishedCallback:@selector(reqSetStopWinLossFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSetStopWinLossFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        [self showToastCenter:msg];
        [self reqLeverageTradeDetail];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


#pragma mark - table view delegate and data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.infoHeaderView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.infoHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_detailModel == nil)
        return 2;
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){         //资产与开仓信息
        return self.openInfoCellHeight;
    }else if(indexPath.row == 1){   //利息信息
        return self.borrowInfoCellHeight;
    }else if(indexPath.row == 2){   //操作或平仓信息
        if(_detailModel.closeDone == 0){        //未平仓
            return self.operationCellHeight;
        }
        return self.closeInfoCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){                 //资产与开仓信息
        LeverageDetailOpenInfoCell *cell = (LeverageDetailOpenInfoCell *)[[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailOpenInfoCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
        if(_detailModel != nil){
           [cell reloadOpenInfoData:_detailModel];
        }
        
        return cell;
    }else if(indexPath.row == 1){          //利息信息
        LeverageDetailBorrowInfoCell *cell = (LeverageDetailBorrowInfoCell *)[[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailBorrowInfoCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
        if(_detailModel != nil){
            [cell reloadBorrowInfoData:_detailModel];
        }
        return cell;
    }else{                                 //操作或平仓信息
        if(_detailModel.closeDone == 0){
            LeverageDetailOperationCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailOperationCell" owner:nil options:nil] lastObject];
            cell.delegate = self;
            if(_detailModel != nil){
                [cell reloadOpetationCellData:_detailModel];
            }
            return cell;
        }else{
            LeverageDetailCloseInfoCell *cell = (LeverageDetailCloseInfoCell *)[[[NSBundle mainBundle] loadNibNamed:@"LeverageDetailCloseInfoCell" owner:nil options:nil] lastObject];
            
            if(_detailModel != nil){
                [cell reloadCloseInfoData:_detailModel];
            }
            return cell;
        }
        
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    if(point.y < 0){
        [self.infoHeaderView backgrondImageViewHeightNeedDidChanged:fabs(point.y)];
    }
    
}

#pragma mark - LeverageDetailOperationCell delegate
- (void)operationCellCloseButtonPressed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确认平仓？") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reqCloseLeverageTrade];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)operationCellQuotationInfoButtonPressed
{
    [self putValueToParamDictionary:CoinTradeDic value:_detailModel.symbol forKey:@"CoinQuotationsDetailSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:[TradeUtil originSymbolAccquireBySymbol:_detailModel.symbol] forKey:@"CoinQuotationsDetailOriginSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:@"1" forKey:@"CoinQuotationsDetailLeverage"];
    [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
}

#pragma mark - LeverageDetailOpenInfoCell delegate
- (void)openInfoCellAddBondBalanceDidPressed
{
    if([bondBalanceArr count] == 0)
        return;
    LeverageAddBondBalanceView *addBalanceView = (LeverageAddBondBalanceView *)[[[NSBundle mainBundle] loadNibNamed:@"LeverageAddBondBalanceView" owner:nil options:nil] lastObject];
    addBalanceView.delegate = self;
    [addBalanceView showViewInView:self.view bondBalanceData:bondBalanceArr holdUsdt:self.holdUsdt];
}

#pragma mark - LeverageAddBondBalanceView delegate
- (void)addBondBalanceViewCommitButtonPressed:(LeverageAddBondBalanceView *)addBondBalanceView bondBalance:(NSString *)bondBalance
{
    self.selectedBondBalance = bondBalance;
    NSString *msg = [NSString stringWithFormat:NSLocalizedStringForKey(@"是否增加%@USDT的保证金？"),bondBalance];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [addBondBalanceView dismissViewWithAnimation];
        [self showProgressDefaultText];
        [self reqAddLeverageBondBalance];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addBondBalanceViewLeverageTradeProtocolButtonPressed
{
//    TYWebViewController *web = [[TYWebViewController alloc] init];
//    web.url = LeverageTradeProtocolWebURL;
//    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

- (void)addBondBalanceViewDigitalAssetsDebitAndCreditProtocolButtonPressed
{
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = DigitalAssetsDebitCreditProtocolWebURL;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

#pragma mark - LeverageDetailBorrowInfoCell delegate
- (void)borrowInfoCellInterestTipsButtonPressed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:_detailModel.interestBrief preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)borrowInfoCellStopWinLossRateButtonPressed
{
    if(_detailModel == nil)
        return;
    LeverageWinLossRateSettingView *settingView = (LeverageWinLossRateSettingView *)[[[NSBundle mainBundle] loadNibNamed:@"LeverageWinLossRateSettingView" owner:nil options:nil] lastObject];
    settingView.delegate = self;
    [settingView showViewInView:self.view currentWinRate:[NSString stringWithFormat:@"%@",@(_detailModel.stopWin)] currentLossRate:[NSString stringWithFormat:@"%@",@(_detailModel.stopLoss)] maxLossRate:[NSString stringWithFormat:@"%@",@(_detailModel.stopMaxLoss)] buySell:_detailModel.buySell openCostPriceValue:_detailModel.openCostPriceValue borrowBalanceValue:_detailModel.borrowBalanceValue bailBalanceValue:_detailModel.bailBalanceValue interestValue:_detailModel.interestValue priceDecimals:_detailModel.priceDecimals];

}

#pragma mark - LeverageWinLossRateSettingView delegate
- (void)settingViewCommitButtonPressed:(LeverageWinLossRateSettingView *)view WithWinRate:(NSString *)winRate lossRate:(NSString *)lossRate
{
    if([lossRate doubleValue] > _detailModel.stopMaxLoss){
        [self showToastCenter:[NSString stringWithFormat:NSLocalizedStringForKey(@"不能设置高于%@%%的止损比例"),@(_detailModel.stopMaxLoss)]];
        return;
    }
    self.stopWin = winRate;
    self.stopLoss = lossRate;
    [self reqCheckWinLoss];
    [view dismissViewFromSuperViewWithAnimation];
    
    
}

@end
