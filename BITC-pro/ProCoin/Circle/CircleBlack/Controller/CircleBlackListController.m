//
//  CircleBlackListController.m
//  Redz
//
//  Created by taojinroad on 2018/10/30.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "CircleBlackListController.h"
#import "RZRefreshTableView.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Circle.h"
#import "CommonUtil.h"
#import "CircleBlackListEntity.h"
#import "RZWebImageView.h"
#import "VeDateUtil.h"
#import "ChatUtil.h"

@interface CircleBlackListController (){
    BOOL bReqFinished;
    NSInteger status;
    NSMutableArray* tableData;
}

@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (copy, nonatomic) NSString *circleId;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;

@end

@implementation CircleBlackListController

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
            [self reqCircleBlackListData:_refreshTableView.pageNo circleId:_circleId];
        }
        [self removeParamFromModelDictionary:CircleDict forKey:@"circleId"];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

#pragma mark - 请求数据接口
- (void)reqCircleBlackListData:(NSInteger)pageNo circleId:(NSString*)circleId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleBlackList:self circleId:circleId pageNo:[NSString stringWithFormat:@"%@",@(pageNo)]  finishedCallback:@selector(reqCircleBlackListFinished:) failedCallback:@selector(reqCircleBlackListFailed:)];
    }
    
}

- (void)reqCircleBlackListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSArray *list = [dataDic objectForKey:@"data"];
        
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            CircleBlackListEntity *entity = [[[CircleBlackListEntity alloc] initWithJson:dic]autorelease];
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

- (void)reqCircleBlackListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}


#pragma mark - 拉黑/取消拉黑,int status(-1拉黑,1取消拉黑)
- (void)reqCircleHandleBlack:(NSString*)circleId blackUserId:(NSString*)blackUserId status:(NSInteger)status
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleHandleBlack:self circleId:circleId blackUserId:blackUserId status:status  finishedCallback:@selector(reqCricleOppFinished:) failedCallback:@selector(reqCricleOppFailed:)];
    }
    
}

- (void)reqCricleOppFinished:(id)result
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
        [self refreshTableViewHeaderRefreshingDidTrigger];
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqCricleOppFailed:(NSDictionary *)json
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
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleBlackListCell" owner:nil options:nil] lastObject];
    CGFloat height = cell.frame.size.height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    static NSString *cellIdentifier = @"CircleBlackListCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleBlackListCell" owner:nil options:nil] lastObject];
        
        UIButton* cancelBtn = (UIButton *)[cell viewWithTag:200];
        [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    CircleBlackListEntity *entity = [tableData objectAtIndex:indexPath.row];

    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:100];
    [headView showImageWithUrl:entity.headUrl];
    
    UILabel *lbName = (UILabel *)[cell viewWithTag:101];
    lbName.text = entity.userName;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshTableViewHeaderRefreshingDidTrigger{
    _refreshTableView.pageNo = 1;
    [self reqCircleBlackListData:1 circleId:_circleId];
}

- (void)refreshTableViewFooterRefreshingDidTrigger{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;
    [self reqCircleBlackListData:_refreshTableView.pageNo circleId:_circleId];
}

- (void)cancelBtnClicked:(id)sender{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    CircleBlackListEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:@"是否将 %@ 从黑名单中移除?",entity.userName] preferredStyle:UIAlertControllerStyleAlert];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reqCircleHandleBlack:weakSelf.circleId blackUserId:entity.userId status:1];
    }];
    [alertController addAction:alertAction];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dealloc {
    [tableData release];
    [_circleId release];
    [_refreshTableView release];
    [_tipsView release];
    [_lbTitle release];
    [super dealloc];
}
@end
