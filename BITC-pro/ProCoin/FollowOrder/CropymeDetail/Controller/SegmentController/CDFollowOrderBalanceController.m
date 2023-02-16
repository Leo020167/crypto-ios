//
//  CDFollowOrderBalanceController.m
//  Cropyme
//
//  Created by Hay on 2019/8/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CDFollowOrderBalanceController.h"
#import "NetWorkManage+FollowOrder.h"
#import "CDFollowBalanceInfoEntity.h"
#import "BalanceInfoHeaderView.h"

@interface CDFollowOrderBalanceController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *balanceInfoArray;               //资金数组
}

@property (copy, nonatomic) NSString *usableBalanceRate;        //可用资金比例
@property (copy, nonatomic) NSString *usedBalanceRate;          //已用资金比例

/** 懒加载*/
@property (retain, nonatomic) BalanceInfoHeaderView *infoHeaderView;      //信息header View
@property (retain, nonatomic) UIView *detailHeaderView;                  //详细header View

@end

@implementation CDFollowOrderBalanceController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _balanceTableView.delegate = self;
    _balanceTableView.dataSource = self;
    balanceInfoArray = [[NSMutableArray alloc] init];
    [self reqFollowOrderBalance];
}

- (void)dealloc
{
    [_balanceTableView release];
    [balanceInfoArray release];
    [_usableBalanceRate release];
    [_usedBalanceRate release];
    [_infoHeaderView release];
    [_detailHeaderView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (BalanceInfoHeaderView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = (BalanceInfoHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"BalanceInfoHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _infoHeaderView;
}

- (UIView *)detailHeaderView
{
    if(!_detailHeaderView){
        _detailHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"BalanceDetailHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _detailHeaderView;
}

#pragma mark - 请求数据
- (void)reqFollowOrderBalance
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderUsersFollowBalance:self finishedCallback:@selector(reqFollowOrderBalanceFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderBalanceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.usableBalanceRate = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"usableBalanceRate"]];
        self.usedBalanceRate = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"usedBalanceRate"]];
        NSArray *followBalanceList = [dataDic objectForKey:@"copyBalanceList"];
        for(NSDictionary *dic in followBalanceList){
            CDFollowBalanceInfoEntity *infoEntity = [[[CDFollowBalanceInfoEntity alloc] initWithJson:dic] autorelease];
            [balanceInfoArray addObject:infoEntity];
        }
        if(checkIsStringWithAnyText(_usableBalanceRate) && checkIsStringWithAnyText(_usedBalanceRate)){
            [self.infoHeaderView reloadInfoHeaderViewWithUsableBalanceRate:_usableBalanceRate usedBalanceRate:_usedBalanceRate];
        }
        
        [_balanceTableView reloadData];
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
        return self.detailHeaderView.frame.size.height;
    }
    
    return CGFLOAT_MIN;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.infoHeaderView;
    }else if(section == 1){
        return self.detailHeaderView;
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
       return [balanceInfoArray count];
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *balanceInfoCellIdentifier = @"BalanceDetailCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:balanceInfoCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BalanceDetailCell" owner:nil options:nil] lastObject];
    }
    UILabel *userNameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *totalBalanceLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *usableBalanceLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *nextUsableBalanceLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
    CDFollowBalanceInfoEntity *infoEntity = [balanceInfoArray objectAtIndex:indexPath.row];
    userNameLabel.text = infoEntity.userName;
    totalBalanceLabel.text = infoEntity.totalBalance;
    usableBalanceLabel.text = infoEntity.usableBalance;
    nextUsableBalanceLabel.text = infoEntity.nextUsableBalance;
    profitLabel.text = infoEntity.profit;
    
    return cell;
}



@end
