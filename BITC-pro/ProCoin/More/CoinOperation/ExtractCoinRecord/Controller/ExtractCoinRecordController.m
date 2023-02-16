//
//  ExtractCoinRecordController.m
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "ExtractCoinRecordController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+ExtractCoin.h"
#import "ExtractCoinRecordEntity.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"

@interface ExtractCoinRecordController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *tableData;
    NSInteger cancelIndex;              //撤销索引
}

@property (assign, nonatomic) CGFloat recordCellHeight;        //cell的高度
@property (retain, nonatomic) IBOutlet RZRefreshTableView *coreTableView;

@end

@implementation ExtractCoinRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    tableData = [[NSMutableArray alloc] init];
    [_coreTableView setTableViewDelegate:self];
    
    [self showProgressDefaultText];
    [self reqExtractCoinRecord];
}

- (void)dealloc
{
    [tableData release];
    [_coreTableView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)cancelExtractCoinButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_coreTableView indexPathForCell:cell];
    cancelIndex = indexPath.row;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否撤销提币?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqCancelExtractCoin];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 懒加载
- (CGFloat)recordCellHeight
{
    if(_recordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ExtractCoinRecordCell" owner:nil options:nil] lastObject];
        _recordCellHeight = cell.frame.size.height;
    }
    return _recordCellHeight;
}

#pragma mark - 请求数据
- (void)reqExtractCoinRecord
{
    [[NetWorkManage shareSingleNetWork] reqExtractCoinRecordList:self pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqExtractCoinRecordFinished:) failedCallback:@selector(reqExtractCoinRecordFailed:)];
}

- (void)reqExtractCoinRecordFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *dataArr = [dataDic objectForKey:@"data"];
        if(_coreTableView.dragOrientation){
            [tableData removeAllObjects];
        }
        for(NSDictionary *dic in dataArr){
            ExtractCoinRecordEntity *recordEntity = [[[ExtractCoinRecordEntity alloc] initWithJson:dic] autorelease];
            [tableData addObject:recordEntity];
        }
        
        [_coreTableView reloadData];
        if(_coreTableView.dragOrientation && [dataArr count] == 0){
            [_coreTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_coreTableView tableViewEndRefreshing];
        }
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        [_coreTableView tableViewEndRefreshing];
    }
}

- (void)reqExtractCoinRecordFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
    [_coreTableView tableViewEndRefreshing];
}

- (void)reqCancelExtractCoin
{
    [self showProgressDefaultText];
    ExtractCoinRecordEntity *recordEntity = [tableData objectAtIndex:cancelIndex];
    [[NetWorkManage shareSingleNetWork] reqCancelExtractCoin:self withdrawId:recordEntity.dwId finishedCallback:@selector(reqCancelExtractCoinFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCancelExtractCoinFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:@"撤销成功"];
        }
        ExtractCoinRecordEntity *recordEntity = [tableData objectAtIndex:cancelIndex];
        recordEntity.state = -1;
        [_coreTableView reloadData];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}



#pragma mark - table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExtractCoinRecordEntity *recordEntity = [tableData objectAtIndex:indexPath.row];
    if(recordEntity.inOut == 1){                //充币不能撤销
         return self.recordCellHeight - 50;
    }else{
        if(recordEntity.state == 0){                //有撤销按钮
            return self.recordCellHeight;
        }
        return self.recordCellHeight - 50;          //没撤销按钮
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ExtractCoinRecordCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ExtractCoinRecordCell" owner:nil options:nil] lastObject];
        UIButton *cancelButton = (UIButton *)[cell viewWithTag:208];
        [cancelButton addTarget:self action:@selector(cancelExtractCoinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    ExtractCoinRecordEntity *recordEntity = [tableData objectAtIndex:indexPath.row];

    UILabel *operationStateLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *symbolLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *stateDesc = (UILabel *)[cell viewWithTag:102];
    UILabel *coinAmountTitleLabel = (UILabel *)[cell viewWithTag:200];
    UILabel *coinAmountLabel = (UILabel *)[cell viewWithTag:201];
    UILabel *createTimeLabel = (UILabel *)[cell viewWithTag:203];
    UILabel *addressTitleLabel = (UILabel *)[cell viewWithTag:204];
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:205];
    UILabel *feeTitleLabel = (UILabel *)[cell viewWithTag:206];
    UILabel *feeLabel = (UILabel *)[cell viewWithTag:207];
    UIButton *cancelButton = (UIButton *)[cell viewWithTag:208];
    
    if(recordEntity.inOut ==  1){       //充币
        operationStateLabel.text = NSLocalizedStringForKey(@"充币");
        coinAmountTitleLabel.text = [NSString stringWithFormat:@"充币数量(%@)",recordEntity.symbol];
        addressTitleLabel.text = @"充币地址";
        operationStateLabel.textColor = [TradeUtil textColorWithQuotationNumber:1.0];;
    }else{          //提币
        operationStateLabel.text = NSLocalizedStringForKey(@"提币");
        coinAmountTitleLabel.text = [NSString stringWithFormat:@"提币数量(%@)",recordEntity.symbol];
        addressTitleLabel.text = @"提币地址";
        operationStateLabel.textColor = [TradeUtil textColorWithQuotationNumber:-1.0];;
    }
    
    symbolLabel.text = recordEntity.symbol;
    stateDesc.text = recordEntity.stateDesc;
    
    
    coinAmountLabel.text = recordEntity.amount;
    createTimeLabel.text = [VeDateUtil formatterDate:recordEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    addressLabel.text = recordEntity.address;
    feeTitleLabel.text = [NSString stringWithFormat:@"手续费(%@)",recordEntity.symbol];
    feeLabel.text = recordEntity.fee;
    
    if(recordEntity.state == 0){
        cancelButton.hidden = NO;
    }else{
        cancelButton.hidden = YES;
    }
    
    return cell;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqExtractCoinRecord];
    
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    if([tableData count] == 0){
        pageNo = 1;
    }else{
        pageNo++;
    }
    [self reqExtractCoinRecord];
}

@end
