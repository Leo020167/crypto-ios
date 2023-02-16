//
//  PCCoinOperationRecordController.m
//  ProCoin
//
//  Created by Hay on 2020/3/10.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCCoinOperationRecordController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+ExtractCoin.h"
#import "PCCoinOperationRecordModel.h"
#import "VeDateUtil.h"
#import "PCCoinOperationRecordScreenView.h"

@interface PCCoinOperationRecordController ()<PCCoinOperationRecordScreenViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *recordDataArr;
}
/** 变量*/
@property (copy, nonatomic) NSString *inOut;        //充币提币

/** 懒加载*/
@property (assign, nonatomic) CGFloat recordCellHeight;

/** UI*/
@property (retain, nonatomic) IBOutlet RZRefreshTableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIView *noDataTipsView;

@end

@implementation PCCoinOperationRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_dataTableView setTableViewDelegate:self];
    pageNo = 1;
    self.inOut = @"";
    recordDataArr = [[NSMutableArray alloc] init];
    [self showProgressDefaultText];
    [self reqCoinOperationRecord];
}

- (void)dealloc
{
    [recordDataArr release];
    [_inOut release];
    [_dataTableView release];
    [_noDataTipsView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)screenButtonPressed:(id)sender
{
    PCCoinOperationRecordScreenView *screenView = [[[PCCoinOperationRecordScreenView alloc] init] autorelease];
    screenView.delegate = self;
    screenView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [screenView addSelfToParentViewController:self inOut:self.inOut];
}

#pragma mark - 懒加载
- (CGFloat)recordCellHeight
{
    if(_recordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeBalanceRecordCell" owner:nil options:nil] lastObject];
        _recordCellHeight = cell.frame.size.height;
    }
    return _recordCellHeight;
}

#pragma mark - 请求数据
- (void)reqCoinOperationRecord
{
    [[NetWorkManage shareSingleNetWork] reqCoinOperationRecord:self inOut:self.inOut pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqCoinOperationRecordFinished:) failedCallback:@selector(reqCoinOperationRecordFailed:)];
}

- (void)reqCoinOperationRecordFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_dataTableView.dragOrientation){
            [recordDataArr removeAllObjects];
        }
        for(NSDictionary *dic in dataArr){
            PCCoinOperationRecordModel *entity = [[[PCCoinOperationRecordModel alloc] initWithJson:dic] autorelease];
            [recordDataArr addObject:entity];
        }
        [_dataTableView reloadData];
        
        if([dataArr count] == 0 && !_dataTableView.dragOrientation){
            [_dataTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_dataTableView tableViewEndRefreshing];
        }
        if([recordDataArr count] > 0){
            _dataTableView.hidden = NO;
            _noDataTipsView.hidden = YES;
        }else{
            _dataTableView.hidden = YES;
            _noDataTipsView.hidden = NO;
        }
    }else{
        [_dataTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqCoinOperationRecordFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_dataTableView tableViewEndRefreshing];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recordDataArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.recordCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordCellIdentifier = @"PCHomeBalanceRecordCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier];
    if(cell == nil){
       cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeBalanceRecordCell" owner:nil options:nil] lastObject];
    }
    PCCoinOperationRecordModel *recordEntity = [recordDataArr objectAtIndex:indexPath.row];
    UILabel *orientationLabel = (UILabel *)[cell viewWithTag:99];
    UILabel *numbersLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *stateLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:103];
    orientationLabel.text = recordEntity.inOut == PCCoinOperationTypeOut ? NSLocalizedStringForKey(@"提币"):NSLocalizedStringForKey(@"充币");
    amountLabel.text = recordEntity.amount;
    stateLabel.text = recordEntity.stateDesc;
    timeLabel.text = [VeDateUtil formatterDate:recordEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    numbersLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"数量"), recordEntity.symbol];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCoinOperationRecordModel *entity = [recordDataArr objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:entity forKey:@"PCCoinOperationDetailEntity"];
    [self pageToViewControllerForName:@"PCCoinOperationDetailController"];
}


- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqCoinOperationRecord];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqCoinOperationRecord];
}

#pragma mark - PCCoinOperationRecordScreenView delegate
- (void)coinOperationRecordScreenDidSelectedWithInOut:(NSString *)inOut
{
    self.inOut = inOut;
    pageNo = 1;
    [self reqCoinOperationRecord];
}


@end
