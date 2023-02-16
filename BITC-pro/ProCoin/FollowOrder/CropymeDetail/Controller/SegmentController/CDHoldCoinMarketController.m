//
//  CDHoldCoinMarketController.m
//  Cropyme
//
//  Created by Hay on 2019/8/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CDHoldCoinMarketController.h"
#import "MarketInfoHeaderView.h"
#import "NetWorkManage+FollowOrder.h"
#import "FollowOrderDistributeChartEntity.h"

@interface CDHoldCoinMarketController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *chartDataArray;         //图标数组
    NSMutableArray *holdCoinArray;          //持仓数组
}

/** 懒加载*/
@property (retain, nonatomic) MarketInfoHeaderView *infoHeaderView;
@property (retain, nonatomic) UIView *holdCoinHeaderView;
@property (assign, nonatomic) CGFloat holdCoinCellHeight;      //hold coin cell的高度
/** 对象*/
@property (copy, nonatomic) NSString *totalMarketValue;         ///总市值
@property (copy, nonatomic) NSString *totalMarketValueCNY;      //总市值用¥显示

@end

@implementation CDHoldCoinMarketController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _marketTableView.delegate = self;
    _marketTableView.dataSource = self;
    chartDataArray = [[NSMutableArray alloc] init];
    holdCoinArray = [[NSMutableArray alloc] init];

    [self reqHoldCoinMarketData];
}



- (void)dealloc
{
    [_marketTableView release];
    [chartDataArray release];
    [holdCoinArray release];
    [_infoHeaderView release];
    [_holdCoinHeaderView release];
    [_totalMarketValue release];
    [_totalMarketValueCNY release];
    [super dealloc];
}

#pragma mark - 懒加载
- (MarketInfoHeaderView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = [(MarketInfoHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"MarketInfoHeaderView" owner:nil options:nil] lastObject]  retain];
    }
    return _infoHeaderView;
}

- (UIView *)holdCoinHeaderView
{
    if(!_holdCoinHeaderView){
        _holdCoinHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"MarketHoldCoinHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _holdCoinHeaderView;
}

- (CGFloat)holdCoinCellHeight
{
    if(_holdCoinCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MarketHoldCoinCell" owner:nil options:nil] lastObject];
        _holdCoinCellHeight = cell.frame.size.height;
    }
    return _holdCoinCellHeight;
}


#pragma mark - 请求数据
- (void)reqHoldCoinMarketData
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderUsersMarket:self finishedCallback:@selector(reqHoldCoinMarketDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqHoldCoinMarketDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *chartList = [dataDic objectForKey:@"chartList"];
        NSArray *holdList = [dataDic objectForKey:@"holdList"];
        self.totalMarketValue = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"totalMarketValue"]];
        self.totalMarketValueCNY = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"totalMarketValueCny"]];
        for(NSDictionary *dic in chartList){
            FollowOrderDistributeChartEntity *chartData = [[[FollowOrderDistributeChartEntity alloc] initWithJson:dic] autorelease];
            [chartDataArray addObject:chartData];
        }
        
        for(NSDictionary *dic in holdList){
            FollowOrderDistributeChartEntity *holdCoinData = [[[FollowOrderDistributeChartEntity alloc] initWithJson:dic] autorelease];
            [holdCoinArray addObject:holdCoinData];
        }
        [self.infoHeaderView reloadInfoHeaderViewData:chartDataArray totalMarket:_totalMarketValue totalMarketCNY:_totalMarketValueCNY];
        
        [_marketTableView reloadData];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.infoHeaderView.frame.size.height;
    }else if(section == 1){
        return self.holdCoinHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.infoHeaderView;
    }else if(section == 1){
        return self.holdCoinHeaderView;
    }
    return nil;
    
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
    if(section == 1){
        return [holdCoinArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        return self.holdCoinCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *holdCoinCellIdentifier = @"MarketHoldCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:holdCoinCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MarketHoldCoinCell" owner:nil options:nil] lastObject];
    }
    FollowOrderDistributeChartEntity *holdCoinData = [holdCoinArray objectAtIndex:indexPath.row];
    UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *marketLabel = (UILabel *)[cell viewWithTag:102];
    symbolLabel.text = holdCoinData.symbol;
    amountLabel.text = holdCoinData.amount;
    marketLabel.text = holdCoinData.balance;
    return cell;
}

@end
