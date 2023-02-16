//
//  P2PHistoryController.m
//  ProCoin
//
//  Created by Hay on 2020/3/5.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "P2PHistoryController.h"
#import "NetWorkManage+P2P.h"
#import "RZRefreshTableView.h"
#import "P2PHistoryModel.h"
#import "VeDateUtil.h"
#import "P2PHistoryAlertView.h"

@interface P2PHistoryController ()<UITableViewDelegate,UITableViewDataSource,P2PHistoryAlertViewDelegate>
{
    NSMutableArray *tableData;
}
/** 懒加载*/
@property (assign, nonatomic) CGFloat transferRecordCellHeight;

/** 变量*/
@property (copy, nonatomic) NSString *buySell;

@property (retain, nonatomic) P2PHistoryAlertView *historyAlertView;

/** UI*/
@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *noDataTipsView;



@end

@implementation P2PHistoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_refreshTableView setTableViewDelegate:self];
    tableData = [[NSMutableArray alloc] init];
    self.buySell = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableViewHeaderRefreshingDidTrigger) name:@"ReloadMessageCount" object:nil];

    
    /** 请求记录*/
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

- (void)dealloc
{
    [_historyAlertView release];
    [tableData release];
    [_buySell release];
    [_refreshTableView release];
    [_noDataTipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (P2PHistoryAlertView *)historyAlertView
{
    if(!_historyAlertView){
        _historyAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"P2PHistoryAlertView" owner:nil options:nil] lastObject] retain];
        _historyAlertView.delegate = self;
    }
    return _historyAlertView;
}

#pragma mark - 懒加载
- (CGFloat)transferRecordCellHeight
{
    if(_transferRecordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PHistoryDataCell" owner:nil options:nil] lastObject];
        _transferRecordCellHeight = cell.frame.size.height;
    }
    return _transferRecordCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}


/** 筛选按钮*/
- (IBAction)screenButtonPressed:(id)sender {
    [self.historyAlertView showInView:self.view];
}


/** 获取记录*/
- (void)reqTransferRecordData:(NSInteger)pageNo
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqP2PFindOrderList:self buySell:_buySell pageNo:[NSString stringWithFormat:@"%@", @(pageNo)] finishedCallback:@selector(reqTransferRecordDataFinished:) failedCallback:@selector(reqTransferRecordDataFailed:)];
}

- (void)reqTransferRecordDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_refreshTableView.dragOrientation){
            [tableData removeAllObjects];
        }
        NSArray *listArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"OrderMessageList"];
        for(NSDictionary *dic in dataArr){
            P2PHistoryModel *entity = [[[P2PHistoryModel alloc] initWithJson:dic] autorelease];
            for (NSDictionary *dict in listArray) {
                if ([dict[@"chatTopic"] isEqualToString:entity.chatTopic]) {
                    entity.count = [dict[@"count"] intValue];
                }
            }
            [tableData addObject:entity];
        }
        
        [_refreshTableView reloadData];
        
        if([dataArr count] == 0 && !_refreshTableView.dragOrientation){
            [_refreshTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_refreshTableView tableViewEndRefreshing];
        }
        if([tableData count] > 0){
            _refreshTableView.hidden = NO;
            _noDataTipsView.hidden = YES;
        }else{
            _refreshTableView.hidden = YES;
            _noDataTipsView.hidden = NO;
        }
        
    }else{
        [_refreshTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTransferRecordDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_refreshTableView tableViewEndRefreshing];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.transferRecordCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *transferRecordCellIdentifier = @"P2PHistoryDataCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:transferRecordCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PHistoryDataCell" owner:nil options:nil] lastObject];
    }
    P2PHistoryModel *entity = [tableData objectAtIndex:indexPath.row];
    UILabel *lbTitle = (UILabel *)[cell viewWithTag:100];
    UILabel *lbStatus = (UILabel *)[cell viewWithTag:101];
    UILabel *lbTime = (UILabel *)[cell viewWithTag:102];
    UILabel *lbAmount = (UILabel *)[cell viewWithTag:103];
    UILabel *lbMoney = (UILabel *)[cell viewWithTag:104];
    UILabel *lbMoneyDdesc = (UILabel *)[cell viewWithTag:105];
    lbAmount.text = entity.amount;
    lbTitle.text = entity.buySellValue;
    lbStatus.text = entity.stateValue;
    lbStatus.qmui_badgeInteger = entity.count;
    lbStatus.qmui_badgeTextColor = UIColor.whiteColor;
    lbStatus.qmui_badgeBackgroundColor = UIColor.redColor;
    lbStatus.qmui_badgeOffset = CGPointMake(-10, 5);
    lbMoneyDdesc.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"交易金额"), entity.currencySign];
    lbMoney.text = entity.tolPrice;
    lbTime.text = [VeDateUtil formatterDate:entity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    lbStatus.textColor = entity.state == 0?RGBA(97, 117, 174, 1):[UIColor darkGrayColor];
    return cell;
    
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    _refreshTableView.pageNo = 1;
    [self reqTransferRecordData: _refreshTableView.pageNo];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;
    [self reqTransferRecordData: _refreshTableView.pageNo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!TTIsArrayWithItems(tableData)) return;
    
    P2PHistoryModel *entity = [tableData objectAtIndex:indexPath.row];
    
    [self putValueToParamDictionary:P2PDict value:entity.orderId forKey:@"orderId"];
    [self pageToOrBackWithName:@"P2PConfirmController"];
}

#pragma mark - P2PHistoryAlertView delegate
- (void)p2pView:(P2PHistoryAlertView *)alertView buySell:(NSString*)buySell {
    self.buySell = buySell;
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

@end
