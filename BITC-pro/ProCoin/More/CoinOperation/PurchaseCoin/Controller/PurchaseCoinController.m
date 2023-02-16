//
//  PurchaseCoinController.m
//  Cropyme
//
//  Created by Hay on 2019/9/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "PurchaseCoinController.h"
#import "NetWorkManage+Trade.h"
#import "OTCTradeEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"

@interface PurchaseCoinController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *businessDataArr;             //
}

@property (retain, nonatomic) IBOutlet UITableView *dataTableView;


/** 懒加载*/
@property (assign, nonatomic) CGFloat businessInfoCellHeight;

@end

@implementation PurchaseCoinController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    businessDataArr = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    [self showProgressDefaultText];
    [self reqOTCPurchaseList];
}


- (void)dealloc
{
    [businessDataArr release];
    [_dataTableView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)purchaseButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_dataTableView indexPathForCell:cell];
    OTCTradeEntity *entity = [businessDataArr objectAtIndex:indexPath.row];
    NSString *tips = [NSString stringWithFormat:@"%@-%@",entity.minCny,entity.maxCny];
    [self putValueToParamDictionary:FundExchangeDic value:tips forKey:@"CMDepositPlaceHolder"];
    [self putValueToParamDictionary:FundExchangeDic value:entity.receiptTypeArr forKey:@"CMDepositReceiptWayList"];
    [self pageToViewControllerForName:@"CMDepositController"];
}

#pragma mark - 懒加载
- (CGFloat)businessInfoCellHeight
{
    if(_businessInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PurchaseCoinCell" owner:nil options:nil] lastObject];
        _businessInfoCellHeight = cell.frame.size.height;
    }
    return _businessInfoCellHeight;
}

#pragma mark - 请求网络数据
- (void)reqOTCPurchaseList
{
    [[NetWorkManage shareSingleNetWork] reqOTCUSDTList:self finishedCallback:@selector(reqOTCPurchaseListFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqOTCPurchaseListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *otcList = [dataDic objectForKey:@"otcList"];
        for(NSDictionary *dic in otcList){
            OTCTradeEntity *entity = [[[OTCTradeEntity alloc] initWithJson:dic] autorelease];
            [businessDataArr addObject:entity];
        }
        [_dataTableView reloadData];
    }else{
        [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
    }
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [businessDataArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.businessInfoCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PurchaseCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PurchaseCoinCell" owner:nil options:nil] lastObject];
        UIButton *purchaseButton = (UIButton *)[cell viewWithTag:107];
        [purchaseButton addTarget:self action:@selector(purchaseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    RZWebImageView *headLogo = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *limitPriceLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];

    
    OTCTradeEntity *entity = [businessDataArr objectAtIndex:indexPath.row];
    [headLogo showImageWithUrl:entity.headUrl];
    nameLabel.text = entity.userName;
    limitPriceLabel.text = [NSString stringWithFormat:@"¥%@-¥%@",entity.minCny,entity.maxCny];
    priceLabel.text = entity.price;
    
    for(int i = 0; i < 3; i++){
        RZWebImageView *receiptLogo = [cell viewWithTag:104 + i];
        if(i < [entity.receiptTypeArr count]){
            receiptLogo.hidden = NO;
            OTCReceiptEntity *receiptEntity = [entity.receiptTypeArr objectAtIndex:i];
            [receiptLogo showImageWithUrl:receiptEntity.receiptTypeLogo];
        }else{
            receiptLogo.hidden = YES;
        }
    }
    
    return cell;
}

@end
