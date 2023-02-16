//
//  FundWithdrawWayListController.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundWithdrawWayListController.h"
#import "NetWorkManage+Trade.h"
#import "WithdrawWayEnity.h"
#import "RZWebImageView.h"

@interface FundWithdrawWayListController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *tableData;
}
@property (assign, nonatomic) CGFloat withdrawWayCellHeight;                //收款列表cell的高度
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation FundWithdrawWayListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tableData = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    
    [self showProgressDefaultText];
    [self reqAbleToAddReceiptList];
}

- (void)dealloc
{
    [tableData release];
    [_dataTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)withdrawWayCellHeight
{
    if(_withdrawWayCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"WithdrawWayCell" owner:nil options:nil] lastObject];
        _withdrawWayCellHeight = cell.frame.size.height;
    }
    return _withdrawWayCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - 请求数据
- (void)reqAbleToAddReceiptList
{
    [[NetWorkManage shareSingleNetWork] reqUserAbleAddReceiptList:self finishedCallback:@selector(reqAbleToAddReceiptListFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqAbleToAddReceiptListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [tableData removeAllObjects];
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *receiptList = [dataDic objectForKey:@"receiptList"];
        for(NSDictionary *dic in receiptList){
            WithdrawWayEnity *wayEntity = [[[WithdrawWayEnity alloc] initWithJson:dic] autorelease];
            [tableData addObject:wayEntity];
        }
        [_dataTableView reloadData];
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
    return self.withdrawWayCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *withdrawWayCellIdentifier = @"WithdrawWayCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:withdrawWayCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WithdrawWayCell" owner:nil options:nil] lastObject];
    }
    WithdrawWayEnity *entity = [tableData objectAtIndex:indexPath.row];
    RZWebImageView *logo = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:102];
    
    [logo showImageWithUrl:entity.receiptLogo];
    titleLabel.text = entity.receiptTypeValue;
    if(checkIsStringWithAnyText(entity.receiptDesc)){
        tipsLabel.text = entity.receiptDesc;
    }else{
        tipsLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WithdrawWayEnity *entity = [tableData objectAtIndex:indexPath.row];
    if(entity.receiptType == 3){
        [self putValueToParamDictionary:FundExchangeDic value:[NSString stringWithFormat:@"%@",@(entity.receiptType)] forKey:@"AddBankWithdrawReceiptType"];
        [self pageToViewControllerForName:@"AddBankWithdrawController"];
    }else if(entity.receiptType == 1 || entity.receiptType == 2){
        [self putValueToParamDictionary:FundExchangeDic value:[NSString stringWithFormat:@"%@",@(entity.receiptType)] forKey:@"AddThirdWithdrawReceiptType"];
        [self pageToViewControllerForName:@"AddThirdWithdrawController"];
    }else{
        [self showToastCenter:NSLocalizedStringForKey(@"该版本暂不支持该功能，请更新版本.")];
    }
    
}
@end
