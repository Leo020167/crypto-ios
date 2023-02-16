//
//  CircleJoinRecordController.m
//  Redz
//
//  Created by taojinroad on 2018/10/30.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "CircleJoinRecordController.h"
#import "RZRefreshTableView.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Circle.h"
#import "CommonUtil.h"
#import "CircleJoinRecordEntity.h"
#import "RZWebImageView.h"
#import "VeDateUtil.h"
#import "CircleSocket.h"
#import "CircleBaseDataEntity.h"

@interface CircleJoinRecordController (){
    BOOL bReqFinished;
    NSInteger status;
    NSMutableArray* tableData;
}

@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (copy, nonatomic) NSString *circleId;

@property (retain, nonatomic) CircleJoinRecordEntity *selectEntity;
@end

@implementation CircleJoinRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableData = [[NSMutableArray alloc] init];
    bReqFinished = YES;
    
    [_refreshTableView setTableViewDelegate:self];
    [CommonUtil setExtraCellLineHidden:_refreshTableView];
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        if (TTIsStringWithAnyText(_circleId)) {
            _refreshTableView.pageNo = 1;
            [self reqFindApplyJoinListData:_refreshTableView.pageNo circleId:_circleId];
        }
        [self removeParamFromModelDictionary:CircleDict forKey:@"circleId"];
    }
    
    CircleBaseDataEntity *item = [CircleSocket shareCircleSocket].circleDetail[self.circleId];
    item.applyNews = 0;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

#pragma mark - 请求数据接口
- (void)reqFindApplyJoinListData:(NSInteger)pageNo circleId:(NSString*)circleId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleFindApplyJoinList:self circleId:circleId pageNo:[NSString stringWithFormat:@"%@",@(pageNo)]  finishedCallback:@selector(reqFindApplyJoinListFinished:) failedCallback:@selector(reqFindApplyJoinListFailed:)];
    }
    
}

- (void)reqFindApplyJoinListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSArray *list = [dataDic objectForKey:@"data"];
        
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            CircleJoinRecordEntity *entity = [[[CircleJoinRecordEntity alloc] initWithJson:dic]autorelease];
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

- (void)reqFindApplyJoinListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}


#pragma mark - 申请
- (void)reqJoinApplyCricle:(NSString*)circleId applyId:(NSString*)applyId status:(NSInteger)status
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleApproveApply:self circleId:circleId applyId:applyId status:status finishedCallback:@selector(reqJoinApplyCricleFinished:) failedCallback:@selector(reqJoinApplyCricleFailed:)];
    }
    
}

- (void)reqJoinApplyCricleFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([parser parseBaseIsOk:result]) {
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        _selectEntity.status = status;
        _selectEntity.handleUserName = ROOTCONTROLLER_USER.name;
        [_refreshTableView reloadData];
        [self putValueToParamDictionary:CircleDict value:[NSNumber numberWithBool:YES] forKey:RELOADDATA_DIC_KEY];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqJoinApplyCricleFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    CircleJoinRecordEntity *entity = [tableData objectAtIndex:indexPath.row];
    CGSize size;
    if (entity.status == HAVE_APPLY) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinRecordCell" owner:nil options:nil] lastObject];
        size = [CommonUtil getPerfectSizeByText:entity.reason andFontSize:13.0f andWidth:phoneRectScreen.size.width - 100];
    }else{
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinRecordInCell" owner:nil options:nil] lastObject];
        size = [CommonUtil getPerfectSizeByText:entity.reason andFontSize:13.0f andWidth:phoneRectScreen.size.width - 50];
    }
    CGFloat height = cell.frame.size.height;
    height = height + size.height - 15;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    CircleJoinRecordEntity *entity = [tableData objectAtIndex:indexPath.row];
    if (entity.status == HAVE_APPLY) {
        
        static NSString *cellIdentifier = @"CircleJoinRecordCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinRecordCell" owner:nil options:nil] lastObject];
            
            UIButton* applyBtn = (UIButton *)[cell viewWithTag:200];
            [applyBtn addTarget:self action:@selector(applyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton* cancelBtn = (UIButton *)[cell viewWithTag:201];
            [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }else{
        static NSString *cellIdentifier = @"CircleJoinRecordInCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleJoinRecordInCell" owner:nil options:nil] lastObject];
        }
    }

    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:100];
    [headView showImageWithUrl:entity.headUrl];

    UILabel *lbName = (UILabel *)[cell viewWithTag:101];
    lbName.text = entity.userName;
    
    UILabel *lbReason = (UILabel *)[cell viewWithTag:102];
    lbReason.text = [NSString stringWithFormat:@"申请理由: %@",entity.reason];
    
    UILabel *lbHandleUserName = (UILabel *)[cell viewWithTag:103];
    lbHandleUserName.text = [NSString stringWithFormat:@"处理人: %@",entity.handleUserName];
    
    UILabel *lbTime = (UILabel *)[cell viewWithTag:104];
    lbTime.text = [VeDateUtil getLongDateToYYYYMMDDHHMMSS:entity.createTime];
    
    UILabel *lbStateValue = (UILabel *)[cell viewWithTag:300];
    if (entity.status == PASS_APPLY) {
        lbStateValue.text = @"已通过";
    }else if (entity.status == CANCEL_APPLY) {
        lbStateValue.text = @"已拒绝";
    }else{
        lbStateValue.text = @"";
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshTableViewHeaderRefreshingDidTrigger{
    _refreshTableView.pageNo = 1;
    [self reqFindApplyJoinListData:1 circleId:_circleId];
}

- (void)refreshTableViewFooterRefreshingDidTrigger{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;
    [self reqFindApplyJoinListData:_refreshTableView.pageNo circleId:_circleId];
}


- (void)applyBtnClicked:(id)sender{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    CircleJoinRecordEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    self.selectEntity = entity;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:@"是否同意 %@ 加入圈子的请求?",_selectEntity.userName] preferredStyle:UIAlertControllerStyleAlert];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        status = PASS_APPLY;
        [weakSelf reqJoinApplyCricle:entity.circleId applyId:entity.applyId status:status];
    }];
    [alertController addAction:alertAction];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)cancelBtnClicked:(id)sender{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    CircleJoinRecordEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    self.selectEntity = entity;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:@"是否拒绝 %@ 加入圈子?",_selectEntity.userName] preferredStyle:UIAlertControllerStyleAlert];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        status = CANCEL_APPLY;
        [weakSelf reqJoinApplyCricle:entity.circleId applyId:entity.applyId status:status];
    }];
    [alertController addAction:alertAction];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dealloc {
    [_selectEntity release];
    [tableData release];
    [_circleId release];
    [_refreshTableView release];
    [_tipsView release];
    [super dealloc];
}
@end
