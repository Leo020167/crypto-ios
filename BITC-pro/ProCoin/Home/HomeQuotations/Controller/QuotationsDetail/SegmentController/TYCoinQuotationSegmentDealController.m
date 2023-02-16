//
//  CoinQuotationSegmentDealController.m
//  ProCoin
//
//  Created by Hay on 2020/3/26.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TYCoinQuotationSegmentDealController.h"
#import "VeDateUtil.h"
#import "PCQuotationDealModel.h"
#import "CommonUtil.h"

@interface TYCoinQuotationSegmentDealController ()<UITableViewDelegate,UITableViewDataSource>

@property (copy, nonatomic) NSArray *tableData;

/** 懒加载*/
@property (retain, nonatomic) UIView *dealHeaderView;
@property (assign, nonatomic) CGFloat dealCellHeight;
@end

@implementation TYCoinQuotationSegmentDealController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dealTableView.delegate = self;
    _dealTableView.dataSource = self;
}

- (void)dealloc
{
    [_dealTableView release];
    [_tableData release];
    [_dealHeaderView release];
    [super dealloc];
}

#pragma mark - 更新数据
- (void)reloadDealData:(NSArray *)dealData
{
    self.tableData = dealData;
    [_dealTableView reloadData];
}

#pragma mark - 懒加载
- (UIView *)dealHeaderView
{
    if(_dealHeaderView == nil){
        self.dealHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"TYQuotationsTradeDealHeaderView" owner:nil options:nil] lastObject];
    }
    return _dealHeaderView;
}

- (CGFloat)dealCellHeight
{
    if(_dealCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationsTradeDealDataCell" owner:nil options:nil] lastObject];
        _dealCellHeight = cell.frame.size.height;
    }
    return _dealCellHeight;
}

#pragma mark - table view delegate and data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.dealHeaderView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.dealHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dealCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *dealCellIdentifier = @"QuotationsTradeDealDataCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dealCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationsTradeDealDataCell" owner:nil options:nil] lastObject];
    }
    PCQuotationDealModel *entity = [_tableData objectAtIndex:indexPath.row];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *buySellLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:103];
    timeLabel.text = [VeDateUtil formatterDate:entity.time inStytle:nil outStytle:@"HH:mm:ss" isTimestamp:YES];
    buySellLabel.text = [entity.buySell isEqualToString:PCQuotationTransactionBuyType] ? @"买入":@"卖出";
    buySellLabel.textColor = [entity.buySell isEqualToString:PCQuotationTransactionBuyType] ? QuotationRedColor:QuotationGreenColor;
    priceLabel.text = entity.price;
    amountLabel.text = entity.amount;
    return cell;
}
@end
