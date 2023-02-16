//
//  PCTransferRecordController.m
//  ProCoin
//
//  Created by Hay on 2020/3/5.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransferRecordController.h"
#import "NetWorkManage+TransferCoin.h"
#import "RZRefreshTableView.h"
#import "PCTransferRecordModel.h"
#import "VeDateUtil.h"
#import "PCTransferRecordScreenView.h"

@interface PCTransferRecordController ()<UITableViewDelegate,UITableViewDataSource,PCTransferRecordScreenViewDelegate>
{
    NSMutableArray *tableData;
    NSMutableArray *transferAccountDataArr;
    NSInteger transferRecordPageNo;
}
/** 懒加载*/
@property (assign, nonatomic) CGFloat transferRecordCellHeight;

/** 变量*/
@property (copy, nonatomic) NSString *fromAccountType;          //划转账户开始点
@property (copy, nonatomic) NSString *toAccountType;            //划转账户结束点

/** UI*/
@property (retain, nonatomic) IBOutlet RZRefreshTableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIView *noDataTipsView;

@end

@implementation PCTransferRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_dataTableView setTableViewDelegate:self];
    tableData = [[NSMutableArray alloc] init];
    transferAccountDataArr = [[NSMutableArray alloc] init];
    transferRecordPageNo = 1;
    self.fromAccountType = @"";
    self.toAccountType = @"";
    
    /** 获取账号类型*/
    [self reqAccountTypeData];
    /** 请求记录*/
    [self reqTransferRecordData];
}

- (void)dealloc
{
    [tableData release];
    [transferAccountDataArr release];
    [_fromAccountType release];
    [_toAccountType release];
    [_dataTableView release];
    [_noDataTipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)transferRecordCellHeight
{
    if(_transferRecordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTransferDataCell" owner:nil options:nil] lastObject];
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
- (IBAction)screenButtonPressed:(id)sender
{
    if([transferAccountDataArr count] == 0){
        [self showToastCenter:NSLocalizedStringForKey(@"筛选数据出错，请返回再重试")];
        return;
    }
    PCTransferRecordScreenView *screenView = [[[PCTransferRecordScreenView alloc] init] autorelease];
    screenView.delegate = self;
    screenView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [screenView addSelfToParentViewController:self fromAcountArr:transferAccountDataArr toAccountArr:transferAccountDataArr fromAccountType:_fromAccountType toAccountType:_toAccountType];
}

#pragma mark - 请求数据
- (void)reqAccountTypeData
{
    [[NetWorkManage shareSingleNetWork] reqTransferAccountList:self finishedCallback:@selector(reqAccountTypeDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqAccountTypeDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [transferAccountDataArr removeAllObjects];
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *accountTypeList = [dataDic objectForKey:@"accountTypeList"];
        [transferAccountDataArr removeAllObjects];
        for(NSDictionary *dic in accountTypeList){
            PCTransferAccountModel *accountEntity = [[[PCTransferAccountModel alloc] initWithJson:dic] autorelease];
            [transferAccountDataArr addObject:accountEntity];
        }
       }else{
           [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
       }
}


/** 获取记录*/
- (void)reqTransferRecordData
{
    [[NetWorkManage shareSingleNetWork] reqTransferRecord:self fromAccountType:self.fromAccountType toAccountType:self.toAccountType pageNo:[NSString stringWithFormat:@"%@",@(transferRecordPageNo)] finishedCallback:@selector(reqTransferRecordDataFinished:) failedCallback:@selector(reqTransferRecordDataFailed:)];
}

- (void)reqTransferRecordDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_dataTableView.dragOrientation){
            [tableData removeAllObjects];
        }
        for(NSDictionary *dic in dataArr){
            PCTransferRecordModel *entity = [[[PCTransferRecordModel alloc] initWithJson:dic] autorelease];
            [tableData addObject:entity];
        }
        
        [_dataTableView reloadData];
        
        if([dataArr count] == 0 && !_dataTableView.dragOrientation){
            [_dataTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_dataTableView tableViewEndRefreshing];
        }
        if([tableData count] > 0){
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

- (void)reqTransferRecordDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_dataTableView tableViewEndRefreshing];
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
    static NSString *transferRecordCellIdentifier = @"PCTransferDataCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:transferRecordCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTransferDataCell" owner:nil options:nil] lastObject];
    }
    PCTransferRecordModel *entity = [tableData objectAtIndex:indexPath.row];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:102];
    amountLabel.text = entity.amount;
    typeLabel.text = entity.typeValue;
    dateLabel.text = [VeDateUtil formatterDate:entity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    
    return cell;
    
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    transferRecordPageNo = 1;
    [self reqTransferRecordData];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    transferRecordPageNo++;
    [self reqTransferRecordData];
}

#pragma mark - PCTransferRecordScreenView delegate
- (void)transferRecordScreenCommitDataWithFromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType
{
    self.fromAccountType = fromAccountType;
    self.toAccountType = toAccountType;
    transferRecordPageNo = 1;
    [self showProgressDefaultText];
    [self reqTransferRecordData];
}

@end
