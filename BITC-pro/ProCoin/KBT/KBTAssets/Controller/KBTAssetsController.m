//
//  KBTAssetsController.m
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTAssetsController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+KBT.h"
#import "KBTRecordEntity.h"
#import "VeDateUtil.h"
#import "AccountAssetsInfoEntity.h"
#import "TradeUtil.h"

@interface KBTAssetsController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *recordDataArr;              //记录数组
}

@property (copy, nonatomic) NSString *symbol;                           //币种

@property (retain, nonatomic) AccountAssetsInfoEntity *assetsInfoEntity;          //资产信息

/** 懒加载*/
@property (retain, nonatomic) UIView *assetsInfoHeaderView;             //资产信息
@property (retain, nonatomic) UIView *recordHeaderView;                 //记录header view
@property (assign, nonatomic) CGFloat recordCellHeight;                 //记录cell高度

@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *assetsTableView;

@end

@implementation KBTAssetsController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    [_assetsTableView setTableViewDelegate:self];
    _assetsTableView.tableHeaderView = self.assetsInfoHeaderView;
    recordDataArr = [[NSMutableArray alloc] init];
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"KBTAssetsSymbol"]){
        self.symbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"KBTAssetsSymbol"];
        _navigationTitleLabel.text = [NSString stringWithFormat:@"%@%@",_symbol, NSLocalizedStringForKey(@"资产")];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"KBTAssetsSymbol"];
    }
    
    [self showProgressDefaultText];
    [self reqAssetsInfo];
}

- (void)dealloc
{
    [recordDataArr release];
    [_symbol release];
    [_assetsInfoEntity release];
    [_assetsInfoHeaderView release];
    [_recordHeaderView release];
    [_assetsTableView release];
    [_navigationTitleLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (UIView *)assetsInfoHeaderView
{
    if(!_assetsInfoHeaderView){
        _assetsInfoHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"KBTAssetsInfoHeaderView" owner:nil options:nil] lastObject] retain];

    }
    return _assetsInfoHeaderView;
}

- (UIView *)recordHeaderView
{
    if(!_recordHeaderView){
        _recordHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"KBTRecordHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _recordHeaderView;
}

- (CGFloat)recordCellHeight
{
    if(_recordCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"KBTRecordCell" owner:nil options:nil] lastObject];
        _recordCellHeight = cell.frame.size.height;
    }
    return _recordCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/** 去回购按钮点击事件*/
- (void)buyBackButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"KBTBuyBackController"];
}

/** 去转让按钮点击事件*/
- (void)transferButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(_symbol)){
        [self putValueToParamDictionary:CoinTradeDic value:_symbol forKey:@"CoinTransactionSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:[TradeUtil originSymbolAccquireBySymbol:_symbol] forKey:@"CoinTransactionOriginSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:@"1" forKey:@"CoinTransactionBuySell"];
        [self pageToViewControllerForName:@"CoinTransactionController"];
    }
    
}


#pragma mark - 请求数据
- (void)reqAssetsInfo
{
    [[NetWorkManage shareSingleNetWork] reqAccountAssetsInfo:self symbol:_symbol pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqAssetsInfoFinished:) failedCallback:@selector(reqAssetsInfoFailed:)];
}

- (void)reqAssetsInfoFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.assetsInfoEntity = [[[AccountAssetsInfoEntity alloc] initWithJson:dataDic] autorelease];
        [self reloadAssetsInfoHeaderView];
        
        if(_assetsTableView.dragOrientation){
            [recordDataArr removeAllObjects];
        }
        NSArray *acquireRecordList =  [dataDic objectForKey:@"acquireRecordList"];
        for(NSDictionary *dic in acquireRecordList){
            KBTRecordEntity *entity = [[[KBTRecordEntity alloc] initWithJson:dic] autorelease];
            [recordDataArr addObject:entity];
        }
        [_assetsTableView reloadData];
        
        if(!_assetsTableView.dragOrientation && [acquireRecordList count] == 0){
            [_assetsTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_assetsTableView tableViewEndRefreshing];
        }
        
    }else{
        [_assetsTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqAssetsInfoFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_assetsTableView tableViewEndRefreshing];
}

#pragma mark - 更新header View
- (void)reloadAssetsInfoHeaderView
{
    UILabel *totalAmountLabel = (UILabel *)[self.assetsInfoHeaderView viewWithTag:100];
    UILabel *totalCnyLabel = (UILabel *)[self.assetsInfoHeaderView viewWithTag:101];
    UILabel *holdAmountLabel = (UILabel *)[self.assetsInfoHeaderView viewWithTag:102];
    UILabel *frozenAmountLabel = (UILabel *)[self.assetsInfoHeaderView viewWithTag:103];
    UILabel *lockAmountLabel = (UILabel *)[self.assetsInfoHeaderView viewWithTag:104];
    UIView *equityLevelView = (UIView *)[self.assetsInfoHeaderView viewWithTag:200];
    UILabel *equityLeveLabel = (UILabel *)[self.assetsInfoHeaderView viewWithTag:201];
    
    totalAmountLabel.text = _assetsInfoEntity.totalAmount;
    totalCnyLabel.text =  _assetsInfoEntity.totalCny;
    holdAmountLabel.text = _assetsInfoEntity.holdAmount;
    frozenAmountLabel.text = _assetsInfoEntity.frozenAmount;
    lockAmountLabel.text = _assetsInfoEntity.lockAmount;
    if(checkIsStringWithAnyText(_assetsInfoEntity.equityLevel)){
        equityLevelView.hidden = NO;
        equityLeveLabel.text = _assetsInfoEntity.equityLevel;
    }else{
        equityLevelView.hidden = YES;
    }
}

#pragma mark - table view delegate and data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.recordHeaderView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.recordHeaderView;
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
    return [recordDataArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.recordCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"KBTRecordCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(cell == nil){
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"KBTRecordCell" owner:nil options:nil] lastObject];
    }
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:102];
    KBTRecordEntity *entity = [recordDataArr objectAtIndex:indexPath.row];
    tipsLabel.text = [NSString stringWithFormat:@"%@",entity.tradeTypeDesc];
    timeLabel.text = [VeDateUtil formatterDate:entity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    amountLabel.text = entity.amount;
    
    return cell;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqAssetsInfo];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqAssetsInfo];
}

@end
