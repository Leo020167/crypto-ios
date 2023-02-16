//
//  MyMessageController.m
//  taojinroad
//
//  Created by road taojin on 12-2-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TTGlobalCore.h"
#import "MyMessageController.h"
#import "CommonUtil.h"
#import "TJRHeadView.h"
#import "VeDateUtil.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+User.h"
#import "MyMessageEntity.h"
#import "TJRBaseParserJson.h"
#import "UIButton+NewNum.h"
#import "HomeViewController.h"
#import "HomeNewNumEntity.h"
#import "RZWebImageView.h"

@interface MyMessageController() {
    
    NSMutableArray* tableData;
    BOOL bReqFinished;
}
@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;

/** 懒加载*/
@property (assign, nonatomic) CGFloat messageCellHeight;

@end

@implementation MyMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = [[NSMutableArray alloc] init];
    bReqFinished = YES;
    
    [CommonUtil setExtraCellLineHidden:_refreshTableView];
    [_refreshTableView setTableViewDelegate:self];
    
    _refreshTableView.pageNo = 1;
    [self reqMyMsgData:_refreshTableView.pageNo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

- (void)dealloc
{
    [tableData release];
    [_refreshTableView release];
    [_tipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)messageCellHeight
{
    if(_messageCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCMyMessageCell" owner:nil options:nil] lastObject];
        _messageCellHeight = cell.frame.size.height;
    }
    return _messageCellHeight;
}

#pragma mark - 请求数据接口
- (void)reqMyMsgData:(NSInteger)pageNo
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqUserMyMsg:self pageNo:[NSString stringWithFormat:@"%@",@(pageNo)]  finishedCallback:@selector(reqMyMsgDataFinished:) failedCallback:@selector(reqMyMsgDataFailed:)];
    }
    
}

- (void)reqMyMsgDataFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){
        [self updataNewNum]; // 我的消息红点归0
        NSDictionary *dataDic = [result objectForKey:@"data"];

        NSArray *msgList = [dataDic objectForKey:@"data"];
        
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in msgList){
            MyMessageEntity *entity = [[[MyMessageEntity alloc] initWithJson:dic]autorelease];
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

- (void)reqMyMsgDataFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}


#pragma mark -
#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyMessageEntity *entity = [tableData objectAtIndex:indexPath.row];
    CGSize size = [CommonUtil getPerfectSizeByText:entity.content andFontSize:15.0f andWidth:SCREEN_WIDTH - 64];
    size.height = MAX(size.height, 20);

    return self.messageCellHeight + (size.height - 20);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"PCMyMessageCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PCMyMessageCell" owner:nil options:nil] lastObject];
    }
    MyMessageEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:100];
    [headView showHeaderImageViewWithUrl:entity.headUrl];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = entity.userName;
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:102];
    timeLabel.text = [VeDateUtil formatterDate:entity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    
    UILabel *lbTitle = (UILabel *)[cell viewWithTag:103];
    lbTitle.text = entity.title;
    
    UILabel *lbContent = (UILabel *)[cell viewWithTag:104];
    lbContent.text = entity.content;
    

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!TTIsArrayWithItems(tableData)) return;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger{
    _refreshTableView.pageNo = 1;
    [self reqMyMsgData:1];
}

- (void)refreshTableViewFooterRefreshingDidTrigger{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;
    [self reqMyMsgData:_refreshTableView.pageNo];
}

#pragma mark - 将我的消息红点归0
- (void)updataNewNum {
    
    HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    if (item) {
        //我的消息
        item.msgCount = 0;
    }
    
    for (id object in [self.navigationController.viewControllers objectEnumerator]) {
        if ([object isKindOfClass:[HomeViewController class]]) {
            [item postNotification];
            break;
        }
    }
}

@end

