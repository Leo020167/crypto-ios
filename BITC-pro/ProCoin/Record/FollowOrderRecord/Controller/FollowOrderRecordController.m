//
//  FollowOrderRecordController.m
//  Cropyme
//
//  Created by Hay on 2019/6/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FollowOrderRecordController.h"
#import "RZRefreshTableView.h"
#import "RZWebImageView.h"
#import "NetWorkManage+FollowOrder.h"
#import "FollowOrderRecordEntity.h"
#import "TradeUtil.h"
#import "VeDateUtil.h"

@interface FollowOrderRecordController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate>
{
    NSMutableArray *tableData;
    NSInteger pageNo;
}

@property (assign, nonatomic) CGFloat tableViewCellHeight;

@property (retain, nonatomic) UIView *recordHeaderView;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *coreTableView;
@property (retain, nonatomic) IBOutlet UIView *noDataTipsView;

@end

@implementation FollowOrderRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _noDataTipsView.hidden = YES;
    pageNo = 1;
    tableData = [[NSMutableArray alloc] init];
    [_coreTableView setTableViewDelegate:self];
    [self showProgressDefaultText];
    [self reqFollowOrderRecordList];
}

- (void)dealloc
{
    [tableData release];
    [_recordHeaderView release];
    [_coreTableView release];
    [_noDataTipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)tableViewCellHeight
{
    if(_tableViewCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FollowOrderRecordCell" owner:nil options:nil] lastObject];
        _tableViewCellHeight = cell.frame.size.height;
    }
    return _tableViewCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - 请求数据
- (void)reqFollowOrderRecordList
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderRecordList:self pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqFollowOrderRecordListFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderRecordListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_coreTableView.dragOrientation){
            [tableData removeAllObjects];
        }
        
        for(NSDictionary *dic in dataArr){
            FollowOrderRecordEntity *entity = [[[FollowOrderRecordEntity alloc] initWithJson:dic] autorelease];
            [tableData addObject:entity];
        }
        
        [_coreTableView reloadData];
        if(!_coreTableView.dragOrientation && [dataArr count] == 0){
            [_coreTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_coreTableView tableViewEndRefreshing];
        }
        
        if([tableData count] > 0){
            _coreTableView.hidden = NO;
            _noDataTipsView.hidden = YES;
        }else{
            _coreTableView.hidden = YES;
            _noDataTipsView.hidden = NO;
        }
        
    }else{
        [_coreTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqFollowOrderRecordListFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
    if(pageNo > 1){
        pageNo--;
    }
    [_coreTableView tableViewEndRefreshing];
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FollowOrderRecordCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FollowOrderRecordCell" owner:nil options:nil] lastObject];
    }
    FollowOrderRecordEntity *entity = [tableData objectAtIndex:indexPath.row];
    RZWebImageView *headLogo = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *endTimeLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *profitLabel = (UILabel *)[cell viewWithTag:103];
    
    [headLogo showHeaderImageViewWithUrl:entity.followHeadUrl];
    nameLabel.text = entity.followName;
    endTimeLabel.text = [VeDateUtil formatterDate:entity.doneTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:entity.profit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FollowOrderRecordEntity *entity = [tableData objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:CoinTradeDic value:@"1" forKey:@"FollowOrderDetailLimit"];
    [self putValueToParamDictionary:CoinTradeDic value:entity.orderId forKey:@"FollowOrderDetailOrderId"];
    [self pageToViewControllerForName:@"FollowOrderDetailController"];

}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    
    [self reqFollowOrderRecordList];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    if([tableData count] == 0){
        pageNo = 1;
        [self reqFollowOrderRecordList];
        return;
    }
    pageNo++;
    [self reqFollowOrderRecordList];
}

@end
