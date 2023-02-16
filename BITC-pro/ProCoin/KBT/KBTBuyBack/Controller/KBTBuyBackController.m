//
//  KBTBuyBackController.m
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTBuyBackController.h"
#import "NetWorkManage+KBT.h"
#import "BuyBackMainChartView.h"
#import "KBTPoolEntity.h"
#import "KBTTrendDataEntity.h"
#import "RZRefreshTableView.h"
#import "KBTAnnouceEntity.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"
#import "KBTBuyBackInputView.h"

@interface KBTBuyBackController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate,KBTBuyBackInputViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *trendDataArr;                   //画图数据
    NSMutableArray *announceDataArr;                //公告数组
   
}

@property (retain, nonatomic) KBTPoolEntity *poolEntity;
@property (copy, nonatomic) NSString *holdAmount;           //持有数量
@property (copy, nonatomic) NSString *repoAmount;           //可回购数量
/** 懒加载*/
@property (retain, nonatomic) UIView *infoHeaderView;
@property (retain, nonatomic) BuyBackMainChartView *chartHeaderView;
@property (retain, nonatomic) UIView *announceHeaderView;
@property (assign, nonatomic) CGFloat announceCellHeight;               //cell高度

@property (retain, nonatomic) IBOutlet RZRefreshTableView *dataTableView;

@end

@implementation KBTBuyBackController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    [_dataTableView setTableViewDelegate:self];
    announceDataArr = [[NSMutableArray alloc] init];
    trendDataArr = [[NSMutableArray alloc] init];
    [self showProgressDefaultText];
    [self reqBuyBackMainInfo];
}

- (void)dealloc
{
    [announceDataArr release];
    [trendDataArr release];
    [_poolEntity release];
    [_holdAmount release];
    [_repoAmount release];
    [_dataTableView release];
    [_infoHeaderView release];
    [_chartHeaderView release];
    [_announceHeaderView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)buyBackButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(_holdAmount) && checkIsStringWithAnyText(_repoAmount)){
//        CoinSubscribeInputView *inputView = (CoinSubscribeInputView *)[[[NSBundle mainBundle] loadNibNamed:@"KBTBuyBackInputView" owner:nil options:nil] lastObject];
//        inputView.delegate = self;
//        [inputView showBuyBackInputViewInView:self.view];
//        [inputView reloadInputViewWithHoldAmount:_holdAmount repoAmount:_repoAmount];
    }
}

#pragma mark - 懒加载
- (UIView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"BuyBackMainInfoHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _infoHeaderView;
}

- (BuyBackMainChartView *)chartHeaderView
{
    if(!_chartHeaderView){
        _chartHeaderView = (BuyBackMainChartView *)[[[[NSBundle mainBundle] loadNibNamed:@"BuyBackMainChartView" owner:nil options:nil] lastObject] retain];
    }
    return _chartHeaderView;
}

- (UIView *)announceHeaderView
{
    if(!_announceHeaderView){
        _announceHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 40)];
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)] autorelease];
        titleLabel.textColor = RGBA(61, 58, 80, 1.0);
        titleLabel.font = [UIFont systemFontOfSize:16.0f];
        titleLabel.text = NSLocalizedStringForKey(@"公告");
        [_announceHeaderView addSubview:titleLabel];
    }
    return _announceHeaderView;
}

- (CGFloat)announceCellHeight
{
    if(_announceCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyBackAnnounceCell" owner:nil options:nil] lastObject];
        _announceCellHeight = cell.frame.size.height;
    }
    return _announceCellHeight;
}

#pragma mark - 请求数据
- (void)reqBuyBackMainInfo
{
    //[[NetWorkManage shareSingleNetWork] reqKBTBuyBackMainInfo:self finishedCallback:@selector(reqBuyBackMainInfoFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqBuyBackMainInfoFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *kbtPoolDic = [dataDic objectForKey:@"kbtPool"];
        self.poolEntity = [[[KBTPoolEntity alloc] initWithJson:kbtPoolDic] autorelease];
        self.holdAmount = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"holdAmount"]];
        self.repoAmount = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"repoAmount"]];
        NSArray *kbtTrendList = [dataDic objectForKey:@"kbtTrendList"];
        [trendDataArr removeAllObjects];
        for(NSDictionary *dic in kbtTrendList){
            KBTTrendDataEntity *dataEntity = [[[KBTTrendDataEntity alloc] initWithJson:dic] autorelease];
            [trendDataArr addObject:dataEntity];
        }
        
        [self updateMainInfoHeaderView];
        [self updateMainChartView];
        //请求公告数据
        [self reqAnnounceData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 请求公告*/
- (void)reqAnnounceData
{
    //[[NetWorkManage shareSingleNetWork] reqKBTAnnounceData:self pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqAnnounceDataFinished:) failedCallback:@selector(reqAnnounceDataFailed:)];
}

- (void)reqAnnounceDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataList = [dataDic objectForKey:@"data"];
        if(_dataTableView.dragOrientation){
            [announceDataArr removeAllObjects];
        }
        for(NSDictionary *dic in dataList){
            KBTAnnouceEntity *announceEntity = [[[KBTAnnouceEntity alloc] initWithJson:dic] autorelease];
            [announceDataArr addObject:announceEntity];
        }
        [_dataTableView reloadData];
        
        if(!_dataTableView.dragOrientation && [dataList count] == 0){
            [_dataTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_dataTableView tableViewEndRefreshing];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        [_dataTableView tableViewEndRefreshing];
    }
}

- (void)reqAnnounceDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_dataTableView tableViewEndRefreshing];
}

/** 请求认购*/
- (void)reqSubBuy:(NSString *)amount
{
    [self showProgressDefaultText];
    
//    [[NetWorkManage shareSingleNetWork] reqSubBuy:self subId:@"" symbol:_pool amount:<#(nonnull NSString *)#> finishedCallback:@selector(reqKBTRepoFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqKBTRepoFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        [self showToastCenter:msg];
        [self reqBuyBackMainInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}



#pragma mark - 更新头部数据
- (void)updateMainInfoHeaderView
{
    UILabel *repoPriceLabel = (UILabel *)[self.infoHeaderView viewWithTag:100];
    UILabel *repoPriceCNYLabel = (UILabel *)[self.infoHeaderView viewWithTag:101];
    UILabel *produceAmountLabel = (UILabel *)[self.infoHeaderView viewWithTag:102];
    UILabel *destroyAmount = (UILabel *)[self.infoHeaderView viewWithTag:103];
    
    repoPriceLabel.text = _poolEntity.repoPrice;
    repoPriceCNYLabel.text = _poolEntity.repoPriceCny;
    produceAmountLabel.text = _poolEntity.produceAmount;
    destroyAmount.text = _poolEntity.destroyAmount;
}

#pragma mark - 更新图表
- (void)updateMainChartView
{
    [self.chartHeaderView reloadChartView:trendDataArr];
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){           //信息
        return self.infoHeaderView.frame.size.height;
    }else if(section == 1){     //图表
        return self.chartHeaderView.frame.size.height;
    }else if(section == 2){     //公告
        if([announceDataArr count] > 0){
            return self.announceHeaderView.frame.size.height;
        }
        
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){           //信息
        return self.infoHeaderView;
    }else if(section == 1){     //图表
        return self.chartHeaderView;
    }else if(section == 2){     //公告
        if([announceDataArr count] > 0){
            return self.announceHeaderView;
        }
        
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
    if(section == 2){
        return [announceDataArr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KBTAnnouceEntity *announceEntity = [announceDataArr objectAtIndex:indexPath.row];
    CGSize size = [CommonUtil getPerfectSizeByText:announceEntity.title andFontSize:12.0f andWidth:SCREEN_WIDTH - 30];
    size.height =  MAX(size.height, 16);
    
    return self.announceCellHeight + (size.height - 16);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BuyBackAnnounceCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyBackAnnounceCell" owner:nil options:nil] lastObject];
    }
    KBTAnnouceEntity *announceEntity = [announceDataArr objectAtIndex:indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *impLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *publisherLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:103];
    
    titleLabel.text = announceEntity.title;
    if(announceEntity.isTop == 1){
        impLabel.text = NSLocalizedStringForKey(@"重要");
    }else{
        impLabel.text = @"";
    }
    publisherLabel.text = NSLocalizedStringForKey(@"BYY官方");
    timeLabel.text = [VeDateUtil formatterDate:announceEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KBTAnnouceEntity *announceEntity = [announceDataArr objectAtIndex:indexPath.row];
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = announceEntity.url;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqBuyBackMainInfo];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqAnnounceData];
}

#pragma mark - KBTBuyBackInputView delegate
- (void)buyBackInputViewErrorMsg:(NSString *)msg
{
    [self showToastCenter:msg];
}

- (void)buyBackInputViewCertainButtonDidPressedWithAmount:(NSString *)amount
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"确定要回购%@数量的KBT吗？"),amount] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqSubBuy:amount];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
