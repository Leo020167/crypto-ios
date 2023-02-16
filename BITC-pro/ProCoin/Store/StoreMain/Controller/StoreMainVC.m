//
//  StoreMainVC.m
//  BYY
//
//  Created by Hay on 2019/12/18.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "StoreMainVC.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+Store.h"
#import "AccountStoreModel.h"
#import "StoreRecordModel.h"
#import "VeDateUtil.h"

@interface StoreMainVC ()<RZRefreshTableViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *recordDataArr;
}

@property (nonatomic, copy) NSString *storeSymbol;
@property (nonatomic, retain) AccountStoreModel *storeInfoModel;

/** 懒加载*/
@property (nonatomic,retain) UIView *assetsHeaderView;
@property (nonatomic,retain) UIView *recordHeaderView;
@property (nonatomic,assign) CGFloat recordCellHeight;

@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *storeTableView;

@end

@implementation StoreMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    [_storeTableView setTableViewDelegate:self];
    _storeTableView.tableHeaderView = self.assetsHeaderView;
    recordDataArr = [[NSMutableArray alloc] init];
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"StoreMainStoreSymbol"]){
        self.storeSymbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"StoreMainStoreSymbol"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"StoreMainStoreSymbol"];
        _navigationTitleLabel.text = [NSString stringWithFormat:@"%@%@",_storeSymbol, NSLocalizedStringForKey(@"存币宝")];
        [self showProgressDefaultText];
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(checkIsStringWithAnyText(_storeSymbol)){
        [self reqStoreSymbolAssetsInfo];
    }
}



- (void)dealloc
{
    [_storeSymbol release];
    [_storeInfoModel release];
    [_assetsHeaderView release];
    [_storeTableView release];
    [_navigationTitleLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (UIView *)assetsHeaderView
{
    if(!_assetsHeaderView){
        _assetsHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"StoreMainAssetsHeaderView" owner:nil options:nil] lastObject] retain];
        UIButton *transferOutButton = (UIButton *)[_assetsHeaderView viewWithTag:200];
        UIButton *transferInButton = (UIButton *)[_assetsHeaderView viewWithTag:201];
        [transferOutButton addTarget:self action:@selector(transferOutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [transferInButton addTarget:self action:@selector(transferInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _assetsHeaderView;
}

- (UIView *)recordHeaderView
{
    if(!_recordHeaderView){
        _recordHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"StoreMainRecordHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _recordHeaderView;
}

- (CGFloat)recordCellHeight
{
    if(_recordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"StoreMainRecordCell" owner:nil options:nil] lastObject];
        _recordCellHeight = cell.frame.size.height;
    }
    return _recordCellHeight;
}


#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)transferOutButtonPressed:(UIButton *)sender
{
    [self putValueToParamDictionary:ProCoinBaseDict value:_storeSymbol forKey:@"StoreTransferOutStoreSymbol"];
    [self pageToViewControllerForName:@"StoreTransferOutVC"];
}

- (void)transferInButtonPressed:(UIButton *)sender
{
    [self putValueToParamDictionary:ProCoinBaseDict value:_storeSymbol forKey:@"StoreTransferStoreSymbol"];
    [self pageToViewControllerForName:@"StoreTransferInVC"];
}

- (IBAction)questionButtonPressed:(id)sender
{
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = StoreIntroWebURL;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

#pragma mark - 请求数据
- (void)reqStoreSymbolAssetsInfo
{
    [[NetWorkManage shareSingleNetWork] reqStoreSymbolAssetInfo:self storeSymbol:self.storeSymbol pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqStoreSymbolAssetsInfoFinished:) failedCallback:@selector(reqStoreSymbolAssetsInfoFailed:)];
}

- (void)reqStoreSymbolAssetsInfoFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *storeResultDic = [dataDic objectForKey:@"storeResult"];
        NSArray *recordList = [dataDic objectForKey:@"recordList"];
        if(_storeTableView.dragOrientation){            //头部刷新
            [recordDataArr removeAllObjects];
            self.storeInfoModel = [[[AccountStoreModel alloc] initWithJson:storeResultDic] autorelease];
            [self reloadAssetsHeaderView];
        }
        for(NSDictionary *itemDic in recordList){
            StoreRecordModel *model = [[[StoreRecordModel alloc] initWithJson:itemDic] autorelease];
            [recordDataArr addObject:model];
        }
        [_storeTableView reloadData];
        
        if(!_storeTableView.dragOrientation && [recordList count] == 0){
            [_storeTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_storeTableView tableViewEndRefreshing];
        }
        
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqStoreSymbolAssetsInfoFailed:(NSDictionary *)json
{
    [self dismissProgress];
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
    static NSString *recordCellIdentifier = @"StoreMainRecordCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StoreMainRecordCell" owner:nil options:nil] lastObject];
    }
    StoreRecordModel *model = [recordDataArr objectAtIndex:indexPath.row];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *transferTipLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:102];
    
    timeLabel.text = [VeDateUtil formatterDate:model.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    transferTipLabel.text = model.remark;
    amountLabel.text = model.amount;
    
    return cell;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqStoreSymbolAssetsInfo];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqStoreSymbolAssetsInfo];
}



#pragma mark - reload UI
- (void)reloadAssetsHeaderView
{
    UILabel *amountTipLabel = (UILabel *)[self.assetsHeaderView viewWithTag:100];
    UILabel *amountLabel = (UILabel *)[self.assetsHeaderView viewWithTag:101];
    UILabel *profitTipLabel = (UILabel *)[self.assetsHeaderView viewWithTag:102];
    UILabel *profitLabel = (UILabel *)[self.assetsHeaderView viewWithTag:103];
    amountTipLabel.text = self.storeInfoModel.amountTip;
    amountLabel.text = self.storeInfoModel.amount;
    profitTipLabel.text = self.storeInfoModel.profitTip;
    profitLabel.text = self.storeInfoModel.profit;
}

@end
