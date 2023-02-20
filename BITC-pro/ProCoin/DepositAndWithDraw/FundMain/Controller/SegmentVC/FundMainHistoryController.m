//
//  FundMainHistoryController.m
//  Cropyme
//
//  Created by Hay on 2019/7/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FundMainHistoryController.h"
#import "NetWorkManage+Trade.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"
#import <YNPageViewController.h>
#import "PrivateChatSQL.h"
#import "PrivateChatDataEntity.h"

@interface FundMainHistoryController ()
{
    BOOL isFirstLoad;
    NSInteger historyPageNo;
    NSMutableArray *tableData;
}

@property (assign, nonatomic) CGFloat tableViewCellHeight;

@end

@implementation FundMainHistoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isFirstLoad = YES;
    historyPageNo = 1;
    tableData = [[NSMutableArray alloc] init];
    [_historyTableView setTableViewDelegate:self];
    
    
    [self reqCashCoinTransactionHistoryRecord];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    /** 以下代码防止refreshTableView与YNPageViewController计算frame不兼容问题*/
//    if(isFirstLoad){
//        isFirstLoad = NO;
//        YNPageViewController *vc = (YNPageViewController *)self.parentViewController;
//        [vc reloadSuspendHeaderViewFrame];
//    }
}

- (void)dealloc
{
    [tableData removeAllObjects];
    [_historyTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)tableViewCellHeight
{
    if(_tableViewCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CashTradeOrderCell" owner:nil options:nil] lastObject];
        _tableViewCellHeight = cell.frame.size.height;
    }
    return _tableViewCellHeight;
}

#pragma mark - 请求数据
- (void)reqCashCoinTransactionFirstPageHistoryRecord
{
    historyPageNo = 1;
    [self reqCashCoinTransactionHistoryRecord];
}
/** 请求历史记录*/
- (void)reqCashCoinTransactionHistoryRecord
{
    [[NetWorkManage shareSingleNetWork] reqCashCoinTradeOrderHistoryList:self symbol:@"USDT" state:@"" isDone:@"1" pageNo:[NSString stringWithFormat:@"%@",@(historyPageNo)] type:@"1" finishedCallback:@selector(reqCashCoinTransactionHistoryRecordFinished:) failedCallback:@selector(reqCashCoinTransactionRecordFailed:)];
}

- (void)reqCashCoinTransactionHistoryRecordFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_historyTableView.dragOrientation){
            [tableData removeAllObjects];
        }
        for(NSDictionary *dic in dataArr){
            CashTradeOrderEntity *entity = [[[CashTradeOrderEntity alloc] initWithJson:dic] autorelease];
            [tableData addObject:entity];
        }
        
        [_historyTableView reloadData];
        if(!_historyTableView.dragOrientation && [dataArr count] == 0){
            [_historyTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_historyTableView tableViewEndRefreshing];
        }
        
    }else{
        [_historyTableView tableViewEndRefreshing];
    }
}

- (void)reqCashCoinTransactionRecordFailed:(NSDictionary *)json
{
    [_historyTableView tableViewEndRefreshing];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CashTradeOrderCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CashTradeOrderCell" owner:nil options:nil] lastObject];
    }
    CashTradeOrderEntity *entity = [tableData objectAtIndex:indexPath.row];
    UILabel *buySellLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *stateDescLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *arrowIV = (UIImageView *)[cell viewWithTag:103];
    UIImageView *msgStateIV = (UIImageView *)[cell viewWithTag:104];
    UILabel *balanceTitleLabel = (UILabel *)[cell viewWithTag:201];
    UILabel *balanceLabel = (UILabel *)[cell viewWithTag:200];
    UILabel *priceCashLabel = (UILabel *)[cell viewWithTag:300];
    UILabel *createTimeLabel = (UILabel *)[cell viewWithTag:400];
    if([entity.buySell isEqualToString:@"1"]){
        buySellLabel.text = NSLocalizedStringForKey(@"买入");
        balanceTitleLabel.text = NSLocalizedStringForKey(@"充值金额");
        buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:1.0];
        arrowIV.hidden = NO;
    }else{
        buySellLabel.text = NSLocalizedStringForKey(@"卖出");
        balanceTitleLabel.text = NSLocalizedStringForKey(@"提现金额");
        buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:-1.0];
        arrowIV.hidden = YES;
    }
    titleLabel.text = entity.symbol;
    stateDescLabel.text = entity.stateDesc;
    balanceLabel.text = entity.balanceCny;
    priceCashLabel.text = entity.priceCny;
    createTimeLabel.text = [VeDateUtil formatterDate:entity.createTime inStytle:@"" outStytle:@"HH:mm MM/dd" isTimestamp:YES];
    PrivateChatDataEntity *chatDataEntity = [PrivateChatSQL getSinglePrivateChatDataWithChatTopic:entity.chatTopic];
    if(chatDataEntity.chatNews > 0){
        msgStateIV.hidden = NO;
    }else{
        msgStateIV.hidden = YES;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CashTradeOrderEntity *entity = [tableData objectAtIndex:indexPath.row];
    if([_delegate respondsToSelector:@selector(historyControllerTableViewDidSelectedWithEntity:)]){
        [_delegate historyControllerTableViewDidSelectedWithEntity:entity];
    }
    //    CashTradeOrderEntity *entity = nil;
    //    if(_orderButton.isSelected){
    //        entity = [orderTableData objectAtIndex:indexPath.row];
    //    }else{
    //        entity = [historyTableData objectAtIndex:indexPath.row];
    //    }
    //    if([entity.buySell isEqualToString:@"1"]){
    //        [self putValueToParamDictionary:FundExchangeDic value:entity.orderCashId forKey:@"FundPayDetailOrderCashId"];
    //        [self pageToViewControllerForName:@"FundPayDetailController"];
    //    }
    
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    historyPageNo = 1;
    [self reqCashCoinTransactionHistoryRecord];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    historyPageNo++;
    [self reqCashCoinTransactionHistoryRecord];
}
@end