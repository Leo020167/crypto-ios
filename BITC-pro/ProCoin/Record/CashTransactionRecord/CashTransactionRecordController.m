//
//  CashTransactionRecordController.m
//  Cropyme
//
//  Created by Hay on 2019/5/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CashTransactionRecordController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+Trade.h"
#import "CashTradeOrderEntity.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"

@interface CashTransactionRecordController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray *orderTableData;             //全部委托数组
    NSMutableArray *historyTableData;           //历史记录数组
    NSInteger orderPageNo;                      //委托页数
    NSInteger historyPageNo;                    //历史页数
}

@property (copy, nonatomic) NSString *isDone;       //0:全部委托,1:历史记录
@property (assign, nonatomic) CGFloat tableViewCellHeight;          //cell的高度
@property (retain, nonatomic) IBOutlet UIScrollView *coreScrollView;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *orderTableView;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *historyTableView;
@property (retain, nonatomic) IBOutlet UIButton *orderButton;           //订单按钮
@property (retain, nonatomic) IBOutlet UIButton *historyButton;         //历史记录按钮

@end

@implementation CashTransactionRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    orderPageNo = 1;
    historyPageNo = 1;
    orderTableData = [[NSMutableArray alloc] init];
    historyTableData = [[NSMutableArray alloc] init];
    _coreScrollView.delegate = self;
    [_orderTableView setTableViewDelegate:self];
    [_historyTableView setTableViewDelegate:self];
    
    [self showProgressDefaultText];
    [self reqTradeCashOrderList];
    
}

- (void)dealloc
{
    [orderTableData release];
    [historyTableData release];
    [_isDone release];
    [_coreScrollView release];
    [_orderTableView release];
    [_historyTableView release];
    [_orderButton release];
    [_historyButton release];
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

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _orderButton){
        if(_orderButton.isSelected){
            return;
        }
        _orderButton.selected = YES;
        _historyButton.selected = NO;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_coreScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        if([orderTableData count] == 0){
            [self reqTradeCashOrderList];
        }
        
    }else{
        if(_historyButton.isSelected){
            return;
        }
        _orderButton.selected = NO;
        _historyButton.selected = YES;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width, 0.0) animated:YES];
        if([historyTableData count] == 0){
            [self  reqTradeCashOrderList];
        }
    }
}

#pragma mark - 请求数据
- (void)reqTradeCashOrderList
{
    NSString *reqPapgeNo = @"";
    if(_orderButton.isSelected){
        reqPapgeNo = [NSString stringWithFormat:@"%@",@(orderPageNo)];
        self.isDone = @"0";
    }else{
        reqPapgeNo = [NSString stringWithFormat:@"%@",@(historyPageNo)];
        self.isDone = @"1";
    }
    [[NetWorkManage shareSingleNetWork] reqCashCoinTradeOrderHistoryList:self symbol:@"" state:@"" isDone:_isDone pageNo:reqPapgeNo type:@"2" finishedCallback:@selector(reqTradeCashOrderListFinished:) failedCallback:@selector(reqTradeCashOrderListFailed:)];
}

- (void)reqTradeCashOrderListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(self.orderButton.isSelected){
            if(_orderTableView.dragOrientation){
                [orderTableData removeAllObjects];
            }
            for(NSDictionary *dic in dataArr){
                CashTradeOrderEntity *entity = [[[CashTradeOrderEntity alloc] initWithJson:dic] autorelease];
                [orderTableData addObject:entity];
            }
            [_orderTableView reloadData];
            if(!_orderTableView.dragOrientation && [dataArr count] == 0){
                [_orderTableView tableViewFooterEndRefreshingWithNoData];
            }else{
                [_orderTableView tableViewEndRefreshing];
            }
            
        }else{
            if(_historyTableView.dragOrientation){
                [historyTableData removeAllObjects];
            }
            for(NSDictionary *dic in dataArr){
                CashTradeOrderEntity *entity = [[[CashTradeOrderEntity alloc] initWithJson:dic] autorelease];
                [historyTableData addObject:entity];
            }
            
            [_historyTableView reloadData];
            if(!_historyTableView.dragOrientation && [dataArr count] == 0){
                [_historyTableView tableViewFooterEndRefreshingWithNoData];
            }else{
                [_historyTableView tableViewEndRefreshing];
            }
        }
       
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        [_orderTableView tableViewEndRefreshing];
        [_historyTableView tableViewEndRefreshing];
    }
}

- (void)reqTradeCashOrderListFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_orderTableView tableViewEndRefreshing];
    [_historyTableView tableViewEndRefreshing];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_orderTableView == tableView){
        return [orderTableData count];
    }else{
        return [historyTableData count];
    }
    
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
    CashTradeOrderEntity *entity = nil;
    if(_orderButton.isSelected){
        entity = [orderTableData objectAtIndex:indexPath.row];
    }else{
        entity = [historyTableData objectAtIndex:indexPath.row];
    }
    UILabel *buySellLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *stateDescLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *arrowIV = (UIImageView *)[cell viewWithTag:103];
    UILabel *balanceTitleLabel = (UILabel *)[cell viewWithTag:201];
    UILabel *balanceLabel = (UILabel *)[cell viewWithTag:200];
    UILabel *priceCashLabel = (UILabel *)[cell viewWithTag:300];
    UILabel *createTimeLabel = (UILabel *)[cell viewWithTag:400];
    if([entity.buySell isEqualToString:@"1"]){
        buySellLabel.text = NSLocalizedStringForKey(@"买入");
        balanceTitleLabel.text = NSLocalizedStringForKey(@"买入总金额");
        buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:1.0];
        arrowIV.hidden = NO;
    }else{
        buySellLabel.text = NSLocalizedStringForKey(@"卖出");
        buySellLabel.textColor = [TradeUtil textColorWithQuotationNumber:-1.0];
        arrowIV.hidden = YES;
    }
    titleLabel.text = entity.symbol;
    stateDescLabel.text = entity.stateDesc;
    balanceLabel.text = entity.balanceCny;
    priceCashLabel.text = entity.priceCny;
    createTimeLabel.text = [VeDateUtil formatterDate:entity.createTime inStytle:@"" outStytle:@"HH:mm MM/dd" isTimestamp:YES];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CashTradeOrderEntity *entity = nil;
    if(_orderButton.isSelected){
        entity = [orderTableData objectAtIndex:indexPath.row];
    }else{
        entity = [historyTableData objectAtIndex:indexPath.row];
    }
    if([entity.buySell isEqualToString:@"1"]){
        [self putValueToParamDictionary:FundExchangeDic value:entity.orderCashId forKey:@"FundPayDetailOrderCashId"];
        [self pageToViewControllerForName:@"FundPayDetailController"];
    }
    
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo = 1;
    }
    
    if(_historyButton.isSelected){
        historyPageNo = 1;
        
    }
    [self reqTradeCashOrderList];
    
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo++;
    }
    
    if(_historyButton.isSelected){
        historyPageNo++;
        
    }
    [self reqTradeCashOrderList];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == _coreScrollView){
        CGPoint point = scrollView.contentOffset;
        if(point.x <= 0){
            if(_orderButton.isSelected){
                return;
            }
            _orderButton.selected = YES;
            _historyButton.selected = NO;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            if([orderTableData count] == 0){
                [self reqTradeCashOrderList];
            }
        }else{
            if(_historyButton.isSelected){
                return;
            }
            _orderButton.selected = NO;
            _historyButton.selected = YES;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            if([historyTableData count] == 0){
                [self  reqTradeCashOrderList];
            }
        }
    }
}


@end
