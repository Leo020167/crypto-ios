//
//  PCFollowOrderRecordController.m
//  ProCoin
//
//  Created by Hay on 2020/3/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCFollowOrderRecordController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+Trade.h"
#import "PCFollowOrderRecordScreenView.h"
#import "PCBaseTransactionRecordModel.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"
#import "PayAlertView.h"

@interface PCFollowOrderRecordController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate,UIScrollViewDelegate,PCFollowOrderRecordScreenViewDelegate>
{
    NSMutableArray *orderTableData;
    NSMutableArray *historyTableData;
    NSInteger orderPageNo;          //委托页数
    NSInteger historyPageNo;        //历史页数
}

/** 变量*/
@property (copy, nonatomic) NSString *screenSymbol;       //筛选的交易队
@property (copy, nonatomic) NSString *screenOrderType;    //筛选的订单类型
@property (copy, nonatomic) NSString *screenAccountType;  //筛选的账户类型
@property (copy, nonatomic) NSString *cancelOrderId;      //撤单id

/** 懒加载*/
@property (assign, nonatomic) CGFloat orderCellHeight;      //委托cell高度
@property (assign, nonatomic) CGFloat historyFilledCellHeight;      //历史已完成cell高度
@property (assign, nonatomic) CGFloat historyCanceledCellHeight;    //历史已撤销cell高度

/** UI */
@property (retain, nonatomic) IBOutlet UIButton *screenButton;  //筛选按钮
@property (retain, nonatomic) IBOutlet UIButton *orderButton;   //委托按钮
@property (retain, nonatomic) IBOutlet UIButton *historyButton; //历史按钮
@property (retain, nonatomic) IBOutlet UIScrollView *coreScrollView;    //核心scrollView
@property (retain, nonatomic) IBOutlet RZRefreshTableView *orderTableView;      //委托tableView
@property (retain, nonatomic) IBOutlet UIView *orderTipsView;                   //委托提示view
@property (retain, nonatomic) IBOutlet RZRefreshTableView *historyTableView;    //历史tableView
@property (retain, nonatomic) IBOutlet UIView *historyTipsView;                 //历史提示view

@end

@implementation PCFollowOrderRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _screenButton.hidden = NO;         //在历史记录才显示
    _orderTipsView.hidden = YES;
    _historyTipsView.hidden = YES;
    [_orderTableView setTableViewDelegate:self];
    [_historyTableView setTableViewDelegate:self];
    orderTableData = [[NSMutableArray alloc] init];
    historyTableData = [[NSMutableArray alloc] init];
    _coreScrollView.delegate = self;
    orderPageNo = 1;
    historyPageNo = 1;
    self.screenSymbol = @"";
    self.screenOrderType = @"";
    self.screenAccountType = @"";
    /** 请求委托和历史数据*/
    [self showProgressDefaultText];
    [self reqTransactionOrderData];
    [self reqTransactionHistoryData];
    
}

- (void)dealloc
{
    [orderTableData release];
    [historyTableData release];
    [_screenSymbol release];
    [_screenOrderType release];
    [_screenAccountType release];
    [_cancelOrderId release];
    [_screenButton release];
    [_orderButton release];
    [_historyButton release];
    [_coreScrollView release];
    [_orderTableView release];
    [_orderTipsView release];
    [_historyTableView release];
    [_historyTipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)orderCellHeight
{
    if(_orderCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
        _orderCellHeight = cell.frame.size.height;
    }
    return _orderCellHeight;
    
}

- (CGFloat)historyFilledCellHeight
{
    if(_historyFilledCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordFilledCell" owner:nil options:nil] lastObject];
        _historyFilledCellHeight = cell.frame.size.height;
    }
    return _historyFilledCellHeight;
}

- (CGFloat)historyCanceledCellHeight
{
    if(_historyCanceledCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordCanceledCell" owner:nil options:nil] lastObject];
        _historyCanceledCellHeight =  cell.frame.size.height;
    }
    return _historyCanceledCellHeight;
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
        _screenButton.hidden = YES;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width, 0.0) animated:YES];
        if([orderTableData count] == 0){
            [self reqTransactionOrderData];
        }
        
    }else{
        if(_historyButton.isSelected){
            return;
        }
        _orderButton.selected = NO;
        _historyButton.selected = YES;
        _screenButton.hidden = NO;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_coreScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        if([historyTableData count] == 0){
            [self  reqTransactionHistoryData];
        }
    }
}

/** 筛选按钮点击事件*/
- (IBAction)screenButtonPressed:(id)sender
{
    PCFollowOrderRecordScreenView *screenView = [[[PCFollowOrderRecordScreenView alloc] init] autorelease];
    screenView.delegate = self;
    screenView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [screenView addSelfToParentViewController:self inputSymbol:self.screenSymbol orderType:self.screenOrderType accounType:self.screenAccountType];
}

/** 取消订单按钮点击事件*/
- (void)cancelOrderButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSInteger cancelIndex = [_orderTableView indexPathForCell:cell].row;
    PCBaseTransactionRecordModel *entity = [orderTableData objectAtIndex:cancelIndex];
    self.cancelOrderId = entity.orderId;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定取消该委托订单吗?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqCancelOrder:@""];          //取消订单
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
   
}
#pragma mark - 请求数据
/** 请求委托数据*/
- (void)reqTransactionOrderData
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderTransactionRecord:self symbol:@"" accountType:@"" isDone:[NSString stringWithFormat:@"%@",@(PCTransactionDoneStateCurrentOrder)] pageNo:[NSString stringWithFormat:@"%@",@(orderPageNo)] buySell:@"" orderState:@"" finishedCallback:@selector(reqTransactionOrderDataFinished:) failedCallback:@selector(reqTransactionOrderDataFailed:)];
}

- (void)reqTransactionOrderDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *containDataArr = [dataDic objectForKey:@"data"];
        if(_orderTableView.dragOrientation){
            [orderTableData removeAllObjects];
        }
        for(NSDictionary *dic in containDataArr){
            PCBaseTransactionRecordModel *entity = [PCBaseTransactionRecordModel yy_modelWithDictionary:dic];
            [orderTableData addObject:entity];
        }
        [_orderTableView reloadData];

        if([containDataArr count] == 0 && !_orderTableView.dragOrientation){
            [_orderTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_orderTableView tableViewEndRefreshing];
        }
        if([orderTableData count] > 0){
            _orderTableView.hidden = NO;
            _orderTipsView.hidden = YES;
        }else{
            _orderTableView.hidden = YES;
            _orderTipsView.hidden = NO;
        }
    }else{
        [_orderTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTransactionOrderDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_orderTableView tableViewEndRefreshing];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}

/** 请求历史数据*/
- (void)reqTransactionHistoryData
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderTransactionRecord:self symbol:self.screenSymbol accountType:self.screenAccountType isDone:[NSString stringWithFormat:@"%@",@(PCTransactionDoneStateHistory)] pageNo:[NSString stringWithFormat:@"%@",@(historyPageNo)] buySell:@"" orderState:self.screenOrderType finishedCallback:@selector(reqTransactionHistoryDataFinished:) failedCallback:@selector(reqTransactionHistoryDataFailed:)];
}

- (void)reqTransactionHistoryDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *containDataArr = [dataDic objectForKey:@"data"];
        if(_historyTableView.dragOrientation){
            [historyTableData removeAllObjects];
        }
        for(NSDictionary *dic in containDataArr){
            PCBaseTransactionRecordModel *entity = [PCBaseTransactionRecordModel yy_modelWithDictionary:dic];
            [historyTableData addObject:entity];
        }
        [_historyTableView reloadData];
        
        if([containDataArr count] == 0 && !_historyTableView.dragOrientation){
            [_historyTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_historyTableView tableViewEndRefreshing];
        }
        if([historyTableData count] > 0){
            _historyTableView.hidden = NO;
            _historyTipsView.hidden = YES;
        }else{
            _historyTableView.hidden = YES;
            _historyTipsView.hidden = NO;
        }
    }else{
        [_historyTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTransactionHistoryDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_historyTableView tableViewEndRefreshing];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}

- (void)reqCancelOrder:(NSString *)payPass
{
    if(checkIsStringWithAnyText(self.cancelOrderId)){
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqTradeCancelOrder:self orderId:self.cancelOrderId payPass:payPass type:@"" finishedCallback:@selector(reqCancelOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
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
        orderPageNo = 1;
        [self reqTransactionOrderData];
        
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _orderTableView){
        return [orderTableData count];
    }else if(tableView == _historyTableView){
        return [historyTableData count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _orderTableView){
        return self.orderCellHeight;
    }else if(tableView == _historyTableView){
        PCBaseTransactionRecordModel *entity = [historyTableData objectAtIndex:indexPath.row];
        if([entity.closeState isEqualToString:PCTransactionHistoryOrderFilledState]){        //已完成
            return self.historyFilledCellHeight;
        }else{      //已撤销
            return self.historyCanceledCellHeight;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *orderCellIdentifier = @"PCBaseTransactionOrderCellIdentifier";
    static NSString *historyFilledCellIdentifier = @"PCBaseHistoryRecordFilledCellIdentifier";
    static NSString *historyCanceledCellIdentifier = @"PCBaseHistoryRecordCanceledCellIdentifier";
    if(tableView == _orderTableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
            UIButton *cancelOrderButton = (UIButton *)[cell viewWithTag:500];
            [cancelOrderButton addTarget:self action:@selector(cancelOrderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        PCBaseTransactionRecordModel *entity = [orderTableData objectAtIndex:indexPath.row];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
        NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
        NSRange range = [titleString rangeOfString:@"/"];
        NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
        if(range.location != NSNotFound){
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
        }
        titleLabel.attributedText = titleAttributed;
        dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
        handAmountLabel.text = entity.openHand;
        priceLabel.text = entity.price;
        openBailLabel.text = entity.openBail;
        return cell;
    }else{
        PCBaseTransactionRecordModel *entity = [historyTableData objectAtIndex:indexPath.row];
        if([entity.closeState isEqualToString:PCTransactionHistoryOrderFilledState]){    //已完成
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyFilledCellIdentifier];
            if(cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordFilledCell" owner:nil options:nil] lastObject];
            }
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
            UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
            UILabel *openPriceLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
            UILabel *closeStateLabel = (UILabel *)[cell viewWithTag:105];
            NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
            NSRange range = [titleString rangeOfString:@"/"];
            NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
            if(range.location != NSNotFound){
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
            }
            titleLabel.attributedText = titleAttributed;
            dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
            handAmountLabel.text = entity.openHand;
            openPriceLabel.text = entity.openPrice;
            profitLabel.text = entity.profit;
            closeStateLabel.text = entity.closeStateDesc;
            return cell;
        }else{      //已撤销
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCanceledCellIdentifier];
            if(cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordCanceledCell" owner:nil options:nil] lastObject];
            }
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
            UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
            UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
            UILabel *closeStateLabel = (UILabel *)[cell viewWithTag:105];
            NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
            NSRange range = [titleString rangeOfString:@"/"];
            NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
            if(range.location != NSNotFound){
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
            }
            titleLabel.attributedText = titleAttributed;
            dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
            handAmountLabel.text = entity.openHand;
            priceLabel.text = entity.price;
            openBailLabel.text = entity.openBail;
            closeStateLabel.text = entity.closeStateDesc;
            return cell;
        }

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == _historyTableView){     //只有历史才能点击
        PCBaseTransactionRecordModel *entity = [historyTableData objectAtIndex:indexPath.row];
        if([entity.closeState isEqualToString:PCTransactionHistoryOrderFilledState]){    //已完成才能进详情
            [self putValueToParamDictionary:ProCoinBaseDict value:entity.orderId forKey:@"TransactionDetailOrderId"];
            [self pageToViewControllerForName:@"PCTransactionDetailController"];
        }
    }
}


- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo = 1;
        [self reqTransactionOrderData];
    }else{
        historyPageNo = 1;
        [self reqTransactionHistoryData];
    }
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo++;
        [self reqTransactionOrderData];
    }else{
        historyPageNo++;
        [self reqTransactionHistoryData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == _coreScrollView){
        CGPoint point = scrollView.contentOffset;
        if(point.x <= 0){
            if(_historyButton.isSelected){
                return;
            }
            _orderButton.selected = NO;
            _historyButton.selected = YES;
            _screenButton.hidden = NO;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            if([historyTableData count] == 0){
                historyPageNo = 1;
                [self  reqTransactionHistoryData];
            }
        }else{
            if(_orderButton.isSelected){
                return;
            }
            _orderButton.selected = YES;
            _historyButton.selected = NO;
            _screenButton.hidden = YES;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            if([orderTableData count] == 0){
                orderPageNo = 1;
                [self reqTransactionOrderData];
            }
        }
    }
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqCancelOrder:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}



#pragma mark - PCFollowOrderRecordScreenView delegate
- (void)followOrderRecordScreenCommitDataWithSymbol:(NSString *)symbol orderType:(NSString *)orderType accountType:(NSString *)accountType
{
    self.screenSymbol = symbol;
    self.screenOrderType = orderType;
    self.screenAccountType = accountType;
    
    historyPageNo = 1;
    [self reqTransactionHistoryData];
}

@end
