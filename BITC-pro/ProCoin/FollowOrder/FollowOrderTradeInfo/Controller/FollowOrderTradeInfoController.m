//
//  FollowOrderTradeInfoController.m
//  Cropyme
//
//  Created by Hay on 2019/7/25.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FollowOrderTradeInfoController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+FollowOrder.h"
#import "CoinTradeOrderEntity.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"

@interface FollowOrderTradeInfoController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate>
{
    NSInteger pageNo;           //tableView页数
    NSMutableArray *tableData;
}

@property (copy, nonatomic) NSString *orderId;

@property (assign, nonatomic) CGFloat tradeInfoCellHeight;

@property (retain, nonatomic) IBOutlet RZRefreshTableView *dataTableView;

@end

@implementation FollowOrderTradeInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    [_dataTableView setTableViewDelegate:self];
    tableData = [[NSMutableArray alloc] init];
    
    if([self getValueFromModelDictionary:FollowOrderDict forKey:@"FollowOrderTradeInfoOrderId"]){
        self.orderId = [self getValueFromModelDictionary:FollowOrderDict forKey:@"FollowOrderTradeInfoOrderId"];
        [self removeParamFromModelDictionary:FollowOrderDict forKey:@"FollowOrderTradeInfoOrderId"];
    }
    
    if(checkIsStringWithAnyText(_orderId)){
        [self showProgressDefaultText];
        [self reqFollowOrderTradeDetail];
    }
    
}



- (void)dealloc
{
    [tableData release];
    [_orderId release];
    [_dataTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)tradeInfoCellHeight
{
    if(_tradeInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FODTradeDetailCell" owner:nil options:nil] lastObject];
        _tradeInfoCellHeight = cell.frame.size.height;
    }
    return _tradeInfoCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}


#pragma mark - 网络请求
/** 请求跟单明细*/
- (void)reqFollowOrderTradeDetail
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderTradeDetailList:self symbol:@"" buySell:@"" orderId:_orderId pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqFollowOrderTradeDetailFinished:) failedCallback:nil];
}

- (void)reqFollowOrderTradeDetailFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_dataTableView.dragOrientation){
            [tableData removeAllObjects];
        }
        for(NSDictionary *dataDic in dataArr){
            CoinTradeOrderEntity *entity = [[[CoinTradeOrderEntity alloc] initWithJson:dataDic] autorelease];
            [tableData addObject:entity];
        }
        [_dataTableView reloadData];
        if(!_dataTableView.dragOrientation && [dataArr count] == 0){
            [_dataTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_dataTableView tableViewEndRefreshing];
        }
        
    }else{
        [_dataTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqFollowOrderTradeDetailFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
    [_dataTableView tableViewEndRefreshing];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tradeInfoCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tradeInfoCellIdentifier = @"FODTradeDetailCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tradeInfoCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FODTradeDetailCell" owner:nil options:nil] lastObject];
        }
        UILabel *buySellLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *symbolLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *stateDescLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *orderPriceTitleLabel = (UILabel *)[cell viewWithTag:200];
        UILabel *orderPriceLabel = (UILabel *)[cell viewWithTag:201];
        UILabel *orderAmountTitleLabel = (UILabel *)[cell viewWithTag:202];
        UILabel *orderAmountLabel = (UILabel *)[cell viewWithTag:203];
        UILabel *createTime = (UILabel *)[cell viewWithTag:205];
        UILabel *dealAvgPriceTitleLabel = (UILabel *)[cell viewWithTag:206];
        UILabel *dealAvgPriceLabel = (UILabel *)[cell viewWithTag:207];
        UILabel *dealAmountTitleLabel = (UILabel *)[cell viewWithTag:208];
        UILabel *dealAmountLabel = (UILabel *)[cell viewWithTag:209];
        UILabel *dealBalanceTitleLabel = (UILabel *)[cell viewWithTag:210];
        UILabel *dealBalanceLabel = (UILabel *)[cell viewWithTag:211];
        UILabel *feeTitleLabel = (UILabel *)[cell viewWithTag:212];
        UILabel *feeLabel = (UILabel *)[cell viewWithTag:213];
        UIView *profitView = (UIView *)[cell viewWithTag:300];
        UILabel *profitTitleLabel = (UILabel *)[cell viewWithTag:301];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:302];
        UIView *profitShareView = (UIView *)[cell viewWithTag:400];
        UILabel *profitShareTitleLabel = (UILabel *)[cell viewWithTag:401];
        UILabel *profitShareLabel = (UILabel *)[cell viewWithTag:402];

        CoinTradeOrderEntity *entity = [tableData objectAtIndex:indexPath.row];
        if([entity.buySell isEqualToString:@"1"]){
            buySellLabel.text = NSLocalizedStringForKey(@"买入");
            buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:1.0];;
            orderAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"委托额"), entity.unitSymbol];
            orderAmountLabel.text = entity.balance;
            feeTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"手续费"), entity.unitSymbol];
            profitView.hidden = YES;
            profitShareView.hidden = YES;
        }else{
            buySellLabel.text = NSLocalizedStringForKey(@"卖出");
            buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:-1.0];;
            orderAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"委托数量"), entity.originSymbol];
            orderAmountLabel.text = entity.amount;
            feeTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"手续费")];
            profitView.hidden = NO;
            profitShareView.hidden = NO;
            profitTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"盈利")];
            profitLabel.text = entity.profit;
            profitShareTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"跟单分成")];
            profitShareLabel.text = entity.profitShare;
        }
        symbolLabel.text = [NSString stringWithFormat:@"%@",entity.symbol];
        stateDescLabel.text = entity.stateDesc;
    orderPriceTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"委托价格")];
        orderPriceLabel.text = entity.price;
        createTime.text = [VeDateUtil formatterDate:entity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    dealAvgPriceTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"成交均价")];
        dealAvgPriceLabel.text = entity.dealAvgPrice;
        dealAmountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交数量"), entity.originSymbol];
        dealAmountLabel.text = entity.dealAmount;
    dealBalanceTitleLabel.text = [NSString stringWithFormat:@"%@(USDT)", NSLocalizedStringForKey(@"成交额")];
        dealBalanceLabel.text = entity.dealBalance;
        feeLabel.text = entity.dealFee;

        return cell;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqFollowOrderTradeDetail];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqFollowOrderTradeDetail];
}

@end
