//
//  P2PMyADController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PMyADController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "P2POrderEntity.h"
#import "P2PPayWayEntity.h"

@interface P2PMyADController () {

    BOOL bReqFinished;

    NSMutableArray* tableData;
}
@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;

@end

@implementation P2PMyADController

- (void)viewDidLoad {
    [super viewDidLoad];
    bReqFinished = YES;

    tableData = [[NSMutableArray alloc] init];
    [_refreshTableView setTableViewDelegate:self];
    [_refreshTableView tableViewFooterRefreshViewHidden];
    
    [CommonUtil setExtraCellLineHidden:_refreshTableView];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

- (void)dealloc{

    [tableData release];
    [_refreshTableView release];
    [_tipsView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}
- (IBAction)createBtnClicked:(id)sender {
    
    [self pageToOrBackWithName:@"P2PCreateADController"];
}

#pragma mark - 请求数据接口
- (void)reqMyAdListData
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PFindMyAdList:self finishedCallback:@selector(reqMyAdListFinished:) failedCallback:@selector(reqMyAdListFailed:)];
    }
    
}

- (void)reqMyAdListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSArray *list = [dataDic objectForKey:@"myAdList"];
        
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            P2POrderEntity *entity = [[[P2POrderEntity alloc] initWithJson:dic]autorelease];
            [array addObject:entity];
        }
        
        if([_refreshTableView dragOrientation]){
            [_refreshTableView tableViewEndRefreshing];
            [tableData removeAllObjects];
        }else{
            [_refreshTableView tableViewFooterEndRefreshingWithNoData];
        }
        [tableData addObjectsFromArray:array];
        
        if (array.count <  [parser integerParser:dataDic name:@"pageSize"]) {
            [_refreshTableView tableViewFooterEndRefreshingWithNoData];
        }
        
    }else{
        [_refreshTableView tableViewEndRefreshing];
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    [_refreshTableView reloadData];
    
    if (tableData.count>0) {
        _tipsView.hidden = YES;
        _refreshTableView.hidden = NO;
    }else {
        _tipsView.hidden = NO;
        _refreshTableView.hidden = YES;
    }
}

- (void)reqMyAdListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}

#pragma mark - 【我的广告】我的广告设置上下架
- (void)reqSetOnline:(NSString*)adId online:(NSInteger)online
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PSetOnline:self adId:adId online:[NSString stringWithFormat:@"%@",@(online)] finishedCallback:@selector(reqMyAdFinished:) failedCallback:@selector(reqMyAdFailed:)];
    }
    
}

#pragma mark - 【我的广告】删除我的广告
- (void)reqDelMyAd:(NSString*)adId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PDelMyAd:self adId:adId finishedCallback:@selector(reqMyAdFinished:) failedCallback:@selector(reqMyAdFailed:)];
    }
    
}

- (void)reqMyAdFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self refreshTableViewHeaderRefreshingDidTrigger];
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqMyAdFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark -
#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PMyADCell" owner:nil options:nil] lastObject];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"P2PMyADCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PMyADCell" owner:nil options:nil] lastObject];
        UIButton *delBtn = (UIButton*)[cell viewWithTag:400];
        UIButton *downBtn = (UIButton*)[cell viewWithTag:401];
        UIButton *editBtn = (UIButton*)[cell viewWithTag:402];
        [delBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [downBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [editBtn addTarget:self action:@selector(editBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    P2POrderEntity *entity = [tableData objectAtIndex:indexPath.row];

    UILabel *lbUserName = (UILabel *)[cell viewWithTag:100];
    lbUserName.text = [NSString stringWithFormat:@"%@",entity.userName];

    UILabel *lbOrderNum = (UILabel *)[cell viewWithTag:101];
    lbOrderNum.text = [NSString stringWithFormat:@"%@ | %.2f%%",entity.orderNum, [entity.limitRate floatValue]*100];

    UILabel *lbAmount= (UILabel *)[cell viewWithTag:102];
    lbAmount.text = [NSString stringWithFormat:@"%@ %@ USDT", NSLocalizedStringForKey(@"数量"), entity.amount];

    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:200];
    [headView showImageWithUrl:entity.userLogo];

    UILabel *lbLimit = (UILabel *)[cell viewWithTag:104];
    lbLimit.text = [NSString stringWithFormat:@"%@ HK$%@-HK$%@", NSLocalizedStringForKey(@"限额"), entity.minCny, entity.maxCny];

    UILabel *lbPrice = (UILabel *)[cell viewWithTag:105];
    lbPrice.text = [NSString stringWithFormat:@"HK$%@",entity.price];
    
    
    RZWebImageView* pay1 = (RZWebImageView*)[cell viewWithTag:300];
    RZWebImageView* pay2 = (RZWebImageView*)[cell viewWithTag:301];
    RZWebImageView* pay3 = (RZWebImageView*)[cell viewWithTag:302];
    pay1.hidden = pay2.hidden = pay3.hidden = NO;

    [pay1 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:0]).receiptLogo];

    if (entity.payWayArray.count == 3) {
        [pay2 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:1]).receiptLogo];
        [pay3 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:2]).receiptLogo];
    }else if (entity.payWayArray.count == 2) {
        [pay2 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:1]).receiptLogo];
        pay3.hidden = YES;
    }else if (entity.payWayArray.count == 1) {
        pay2.hidden = pay3.hidden = YES;
    }

    UIView *viewStatus = (UIView *)[cell viewWithTag:500];
    UILabel *lbStatus = (UILabel *)[cell viewWithTag:501];
    
    UILabel *lbBuySell = (UILabel *)[cell viewWithTag:106];
    if([entity.buySell isEqual:@"buy"]){
        lbBuySell.text = NSLocalizedStringForKey(@"购买");
        viewStatus.backgroundColor = RGBA(226.0, 33.0, 78.0, 1);
        lbStatus.text = NSLocalizedStringForKey(@"购买中");
    }else{
        lbBuySell.text = NSLocalizedStringForKey(@"出售");
        viewStatus.backgroundColor = RGBA(0.0, 173.0, 136.0, 1);
        lbStatus.text = NSLocalizedStringForKey(@"出售中");
    }
    
    if (entity.isOnline == 0) {
        viewStatus.backgroundColor = RGBA(154.0, 154.0, 154.0, 1);
        lbStatus.text = NSLocalizedStringForKey(@"已下架");
    }
    
    UIButton *downBtn = (UIButton*)[cell viewWithTag:401];
    [downBtn setTitle:(entity.isOnline == 1?NSLocalizedStringForKey(@"下架"):NSLocalizedStringForKey(@"上架")) forState:UIControlStateNormal];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!TTIsArrayWithItems(tableData)) return;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger{
    _refreshTableView.pageNo = 1;

    [self reqMyAdListData];
}

- (void)refreshTableViewFooterRefreshingDidTrigger{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;

}

- (void)deleteBtnClicked:(id)sender{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    P2POrderEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确认是否删除该广告记录") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqDelMyAd:entity.adId];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)downBtnClicked:(id)sender{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    P2POrderEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    NSString* str = entity.isOnline == 1? NSLocalizedStringForKey(@"确认是否下架该广告记录"): NSLocalizedStringForKey(@"确认是否上架该广告记录");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:str preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (entity.isOnline == 1) {
            [self reqSetOnline:entity.adId online:0];
        }else{
            [self reqSetOnline:entity.adId online:1];
        }
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editBtnClicked:(id)sender{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    P2POrderEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    [self putValueToParamDictionary:P2PDict value:entity.adId forKey:@"adId"];
    [self pageToOrBackWithName:@"P2PCreateADController"];
}

@end
