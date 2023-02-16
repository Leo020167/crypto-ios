//
//  LeverageTransactionRecordVC.m
//  BYY
//
//  Created by Hay on 2019/12/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageTransactionRecordVC.h"
#import "NetWorkManage+Leverage.h"
#import "LeverageTransactionRecordModel.h"
#import "RZRefreshTableView.h"
#import "VeDateUtil.h"
#import "LeverageRecordScreening.h"

@interface LeverageTransactionRecordVC ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate,LeverageRecordScreeningDelegate>
{
    NSInteger orderPageNo;
    NSInteger historyPageNo;
    NSMutableArray *orderDataArr;       //当前开仓数据
    NSMutableArray *historyDataArr;     //历史记录数据
    LeverageRecordScreeningType screeningType;
}
/** 当前开仓没筛选，历史才有筛选*/
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *buySell;


/** 懒加载*/
@property (assign, nonatomic) CGFloat recordCellHeight;

@property (retain, nonatomic) IBOutlet RZRefreshTableView *orderTableView;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *historyTableView;
@property (retain, nonatomic) IBOutlet UIView *orderNoDataView;
@property (retain, nonatomic) IBOutlet UIView *historyNoDataView;
@property (retain, nonatomic) IBOutlet UIButton *orderButton;
@property (retain, nonatomic) IBOutlet UIButton *historyButton;
@property (retain, nonatomic) IBOutlet UIScrollView *coreScrollView;
@property (retain, nonatomic) IBOutlet UIButton *screeningButton;           //筛选按钮

@end

@implementation LeverageTransactionRecordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    orderPageNo = 1;
    historyPageNo = 1;
    orderDataArr = [[NSMutableArray alloc] init];
    historyDataArr = [[NSMutableArray alloc] init];
    _orderButton.selected = YES;
    _historyButton.selected = NO;
    self.symbol = @"";
    self.buySell = @"";
    screeningType = LeverageRecordScreeningTypeNothing;
    _orderTableView.hidden = NO;
    _historyTableView.hidden = NO;
    _orderNoDataView.hidden = YES;
    _historyNoDataView.hidden = YES;
    [_orderTableView setTableViewDelegate:self];
    [_historyTableView setTableViewDelegate:self];
    _coreScrollView.delegate = self;
    _screeningButton.hidden = YES;
    
    [self showProgressDefaultText];
    [self reqLeverageTransactionOrderRecord];
    [self reqLeverageTransactionHistoryRecord];
}

- (void)dealloc
{
    [orderDataArr release];
    [historyDataArr release];
    [_symbol release];
    [_buySell release];
    [_orderTableView release];
    [_historyTableView release];
    [_orderNoDataView release];
    [_historyNoDataView release];
    [_orderButton release];
    [_historyButton release];
    [_coreScrollView release];
    [_screeningButton release];
    [super dealloc];
}

#pragma mark - 懒加载
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

- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _orderButton){
        if(_orderButton.isSelected){
            return;
        }
        _screeningButton.hidden = YES;
        _orderButton.selected = YES;
        _historyButton.selected = NO;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_coreScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        if([orderDataArr count] == 0){
            [self reqLeverageTransactionOrderRecord];
        }
        
    }else{
        if(_historyButton.isSelected){
            return;
        }
        _screeningButton.hidden = NO;
        _orderButton.selected = NO;
        _historyButton.selected = YES;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width, 0.0) animated:YES];
        if([historyDataArr count] == 0){
            [self reqLeverageTransactionHistoryRecord];
        }
    }
}

/** 筛选按钮点击事件*/
- (IBAction)screeningButtonPressed:(id)sender
{
    LeverageRecordScreening *controller = [[[LeverageRecordScreening alloc] init] autorelease];
    controller.delegate = self;
    controller.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [controller addSelfToParentViewController:self viewType:screeningType inputSymbol:_symbol];
}

#pragma mark - 请求数据
/** 请求开仓数据*/
- (void)reqLeverageTransactionOrderRecord
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeRecord:self symbol:@"" buySell:@"" isDone:@"0" pageNo:[NSString stringWithFormat:@"%@",@(orderPageNo)] finishedCallback:@selector(reqLeverageTransactionRecordFinished:) failedCallback:@selector(reqLeverageTransactionRecordFailed:)];
}

- (void)reqLeverageTransactionRecordFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        
        if(_orderTableView.dragOrientation){
            [orderDataArr removeAllObjects];
        }
        for(NSDictionary *dic in dataArr){
            LeverageTransactionRecordModel *recordItem = [[[LeverageTransactionRecordModel alloc] initWithJson:dic] autorelease];
            [orderDataArr addObject:recordItem];
        }
        [_orderTableView reloadData];
        
        if(!_orderTableView.dragOrientation && [dataArr count] == 0){
            [_orderTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_orderTableView tableViewEndRefreshing];
        }
        
        if([orderDataArr count] == 0){
            _orderTableView.hidden = YES;
            _orderNoDataView.hidden = NO;
        }else{
            _orderTableView.hidden = NO;
            _orderNoDataView.hidden = YES;
        }
        
    }else{
        [_orderTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)reqLeverageTransactionRecordFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_orderTableView tableViewEndRefreshing];
}

/**  请求历史数据*/
- (void)reqLeverageTransactionHistoryRecord
{
    [[NetWorkManage shareSingleNetWork] reqLeverageTradeRecord:self symbol:_symbol buySell:_buySell isDone:@"1" pageNo:[NSString stringWithFormat:@"%@",@(historyPageNo)] finishedCallback:@selector(reqLeverageTransactionHistoryRecordFinished:) failedCallback:@selector(reqLeverageTransactionHistoryRecordFailed:)];
}

- (void)reqLeverageTransactionHistoryRecordFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_historyTableView.dragOrientation){
            [historyDataArr removeAllObjects];
        }
        for(NSDictionary *dic in dataArr){
            LeverageTransactionRecordModel *recordItem = [[[LeverageTransactionRecordModel alloc] initWithJson:dic] autorelease];
            [historyDataArr addObject:recordItem];
        }
        [_historyTableView reloadData];
        
        if(!_historyTableView.dragOrientation && [dataArr count] == 0){
            [_historyTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_historyTableView tableViewEndRefreshing];
        }
        
        if([historyDataArr count] == 0){
            _historyTableView.hidden = YES;
            _historyNoDataView.hidden = NO;
        }else{
            _historyTableView.hidden = NO;
            _historyNoDataView.hidden = YES;
        }
        
    }else{
        [_historyTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqLeverageTransactionHistoryRecordFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_historyTableView tableViewEndRefreshing];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _orderTableView){
        return [orderDataArr count];
    }else if(tableView == _historyTableView){
        return [historyDataArr count];
    }
    return 0;
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.recordCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordCellIdentifier = @"LeverageTransactionRecordCellIdentifier";
    UITableViewCell *cell = nil;
    LeverageTransactionRecordModel *recordModel = nil;
    if(tableView == _orderTableView){
        recordModel = [orderDataArr objectAtIndex:indexPath.row];
    }else{
        recordModel = [historyDataArr objectAtIndex:indexPath.row];
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LeverageTransactionRecordCell" owner:nil options:nil] lastObject];
    }
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LeverageTransactionRecordModel *recordModel = nil;
    if(tableView == _orderTableView){
        recordModel = [orderDataArr objectAtIndex:indexPath.row];
    }else{
        recordModel = [historyDataArr objectAtIndex:indexPath.row];
    }
    [self putValueToParamDictionary:ProCoinBaseDict value:recordModel.orderId forKey:@"LeverageTradeDetailOrderId"];
    [self putValueToParamDictionary:ProCoinBaseDict value:[NSString stringWithFormat:@"%@ %@X",recordModel.symbol,recordModel.multiNum] forKey:@"LeverageTradeDetailTitle"];
    [self pageToViewControllerForName:@"LeverageTradeDetailVC"];
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo = 1;
        [self reqLeverageTransactionOrderRecord];
    }else{
        historyPageNo = 1;
        [self reqLeverageTransactionHistoryRecord];
    }
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo++;
        [self reqLeverageTransactionOrderRecord];
    }else{
        historyPageNo++;
        [self reqLeverageTransactionHistoryRecord];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == _coreScrollView){
        CGPoint point = scrollView.contentOffset;
        if(point.x <= 0){
            if(_orderButton.isSelected){
                return;
            }
            _screeningButton.hidden = YES;
            _orderButton.selected = YES;
            _historyButton.selected = NO;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            if([orderDataArr count] == 0){
                orderPageNo = 1;
                [self reqLeverageTransactionOrderRecord];
            }
        }else{
            if(_historyButton.isSelected){
                return;
            }
            _screeningButton.hidden = NO;
            _orderButton.selected = NO;
            _historyButton.selected = YES;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            if([historyDataArr count] == 0){
                historyPageNo = 1;
                [self reqLeverageTransactionHistoryRecord];
            }
        }
    }
}

#pragma mark - LeverageRecordScreening delegate
- (void)recordScreeningDidSubmitWithType:(LeverageRecordScreeningType)type screeningSymbol:(NSString *)screeningSymbol
{
    screeningType = type;
    self.symbol = screeningSymbol;
    switch (screeningType) {
        case LeverageRecordScreeningTypeNothing:
            self.buySell = @"";
            break;
        case LeverageRecordScreeningTypeSell:
            self.buySell = @"-1";
            break;
        case LeverageRecordScreeningTypeBuy:
            self.buySell = @"1";
            break;
        default:
            break;
    }
    //根据筛选条件重新请求
    [self showProgressDefaultText];
    historyPageNo = 1;
    [self reqLeverageTransactionHistoryRecord];
}


@end
