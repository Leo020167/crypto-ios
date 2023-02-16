//
//  CircleMemberController.m
//  Redz
//
//  Created by taojinroad on 2018/10/30.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "CircleMemberController.h"
#import "RZRefreshTableView.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Circle.h"
#import "CommonUtil.h"
#import "CircleMemberEntity.h"
#import "RZWebImageView.h"
#import "VeDateUtil.h"
#import "ChatUtil.h"


@interface CircleMemberController (){
    BOOL bReqFinished;
    NSInteger status;
    NSMutableArray* tableData;
}

@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;

@property (copy, nonatomic) NSString *circleId;
@property (assign, nonatomic) NSInteger myRole;

@property (retain, nonatomic) CircleMemberEntity *selectEntity;
@end

@implementation CircleMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableData = [[NSMutableArray alloc] init];
    bReqFinished = YES;
    
    [_refreshTableView setTableViewDelegate:self];
    [CommonUtil setExtraCellLineHidden:_refreshTableView];
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"role"]){
        self.myRole = [[self getValueFromModelDictionary:CircleDict  forKey:@"role"] integerValue];
        [self removeParamFromModelDictionary:CircleDict forKey:@"role"];
    }
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        if (TTIsStringWithAnyText(_circleId)) {
            _refreshTableView.pageNo = 1;
            [self reqCircleMemberListData:_refreshTableView.pageNo circleId:_circleId];
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
- (void)reqCircleMemberListData:(NSInteger)pageNo circleId:(NSString*)circleId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleMemberList:self circleId:circleId pageNo:[NSString stringWithFormat:@"%@",@(pageNo)]  finishedCallback:@selector(reqCircleMemberListFinished:) failedCallback:@selector(reqCircleMemberListFailed:)];
    }
    
}

- (void)reqCircleMemberListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSArray *list = [dataDic objectForKey:@"data"];
        
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            CircleMemberEntity *entity = [[[CircleMemberEntity alloc] initWithJson:dic]autorelease];
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
        _lbTitle.text = [NSString stringWithFormat:@"圈子成员(%@)",@([parser integerParser:dataDic name:@"total"])];
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

- (void)reqCircleMemberListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}


#pragma mark - 审批入圈申请
- (void)reqJoinApplyCricle:(NSString*)circleId applyId:(NSString*)applyId status:(NSInteger)status
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleApproveApply:self circleId:circleId applyId:applyId status:status finishedCallback:@selector(reqCricleOppFinished:) failedCallback:@selector(reqCricleOppFailed:)];
    }
    
}

#pragma mark - 设置管理员
- (void)reqCricleUpdateRole:(NSString*)circleId targetUid:(NSString*)targetUid role:(NSInteger)role
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleUpdateRole:self circleId:circleId targetUid:targetUid role:role  finishedCallback:@selector(reqCricleOppFinished:) failedCallback:@selector(reqCricleOppFailed:)];
    }
    
}

#pragma mark - 移除圈子成员
- (void)reqCircleRemoveMember:(NSString*)circleId targetUid:(NSString*)targetUid addToBlackList:(BOOL)addToBlackList
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleRemoveMember:self circleId:circleId targetUid:targetUid addToBlackList:addToBlackList  finishedCallback:@selector(reqCricleOppFinished:) failedCallback:@selector(reqCricleOppFailed:)];
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
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleMemberCell" owner:nil options:nil] lastObject];
    CGFloat height = cell.frame.size.height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    static NSString *cellIdentifier = @"CircleMemberCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleMemberCell" owner:nil options:nil] lastObject];
        
        UIButton* chatBtn = (UIButton *)[cell viewWithTag:200];
        [chatBtn addTarget:self action:@selector(chatBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    CircleMemberEntity *entity = [tableData objectAtIndex:indexPath.row];

    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:100];
    [headView showImageWithUrl:entity.headUrl];
    
    UIButton* chatBtn = (UIButton *)[cell viewWithTag:200];

    UILabel *lbRoleName = (UILabel *)[cell viewWithTag:101];
    CGFloat width = 0;
    
    if (entity.role == CRICLE_ROLE_ROOT) {
        
        lbRoleName.text = @"圈主";
        chatBtn.hidden = NO;
        chatBtn.hidden = [entity.userId isEqualToString:ROOTCONTROLLER_USER.userId];
        lbRoleName.backgroundColor = RGBA(255, 201, 12, 1);
        lbRoleName.textColor = RGBA(38, 38, 38, 1);
        width = 35;
        
    }else if (entity.role == CRICLE_ROLE_ADMIN) {
        
        lbRoleName.text = @"管理员";
        chatBtn.hidden = NO;
        chatBtn.hidden = [entity.userId isEqualToString:ROOTCONTROLLER_USER.userId];
        lbRoleName.backgroundColor = RGBA(51, 51, 51, 1);
        lbRoleName.textColor = [UIColor whiteColor];
        width = 47;
        
    }else if (entity.role == CRICLE_ROLE_ILLEGAL) {
        
        lbRoleName.text = @"无效";
        chatBtn.hidden = YES;
        width = 0;
    }else {
        lbRoleName.text = @"成员";
        chatBtn.hidden = YES;
        width = 0;
    }
    
    [CommonUtil viewWidthForAutoLayout:lbRoleName width:width];
    
    UILabel *lbName = (UILabel *)[cell viewWithTag:102];
    lbName.text = entity.userName;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CircleMemberEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    if (_myRole == CRICLE_ROLE_ROOT && ![entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"权限操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __block typeof(self) weakSelf = self;
        NSString* roleStr = (entity.role == CRICLE_ROLE_ADMIN)?@"撤销管理员":@"设为管理员";
        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:roleStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger role = (entity.role == CRICLE_ROLE_ADMIN)?CRICLE_ROLE_MEMBER:CRICLE_ROLE_ADMIN;
            [weakSelf reqCricleUpdateRole:weakSelf.circleId targetUid:entity.userId role:role];
        }];
        [alertController addAction:alertAction1];
        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"踢出圈子" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf reqCircleRemoveMember:weakSelf.circleId targetUid:entity.userId addToBlackList:NO];
        }];
        [alertController addAction:alertAction2];
        UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"设为黑名单并踢出圈子" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf reqCircleRemoveMember:weakSelf.circleId targetUid:entity.userId addToBlackList:YES];
        }];
        [alertController addAction:alertAction3];
        UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"查看个人资料" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf pageToPersonPage:entity.userId];
        }];
        [alertController addAction:alertAction4];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:alertController completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (_myRole == CRICLE_ROLE_ADMIN && ![entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]&& entity.role == CRICLE_ROLE_MEMBER) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"权限操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __block typeof(self) weakSelf = self;
        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"踢出圈子" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf reqCircleRemoveMember:weakSelf.circleId targetUid:entity.userId addToBlackList:NO];
        }];
        [alertController addAction:alertAction2];
        UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"设为黑名单并踢出圈子" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf reqCircleRemoveMember:weakSelf.circleId targetUid:entity.userId addToBlackList:YES];
        }];
        [alertController addAction:alertAction3];
        UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"查看个人资料" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf pageToPersonPage:entity.userId];
        }];
        [alertController addAction:alertAction4];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:alertController completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if(![entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"权限操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __block typeof(self) weakSelf = self;
        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"查看个人资料" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf pageToPersonPage:entity.userId];
        }];
        [alertController addAction:alertAction1];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:alertController completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
  
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    _refreshTableView.pageNo = 1;
    [self reqCircleMemberListData:1 circleId:_circleId];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;
    [self reqCircleMemberListData:_refreshTableView.pageNo circleId:_circleId];
}


- (void)chatBtnClicked:(id)sender
{
    UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
    CircleMemberEntity *entity = [tableData objectAtIndex:indexPath.row];
    
    if (TTIsStringWithAnyText(entity.userId)) {
        [ChatUtil createChatTopicWithUserId:entity.userId userName:entity.userName headurl:entity.headUrl ctr:self];
    }
}

- (void)pageToPersonPage:(NSString*)targetUid
{
    if (TTIsStringWithAnyText(targetUid)) {
        [self putValueToParamDictionary:PersonalDict value:targetUid forKey:@"targetUid"];
        [self pageToViewControllerForName:@"PersonViewController"];
    }
}

- (void)dealloc
{
    [_selectEntity release];
    [tableData release];
    [_circleId release];
    [_refreshTableView release];
    [_tipsView release];
    [_lbTitle release];
    [super dealloc];
}
@end
