//
//  CircleInfoViewController.m
//  TJRtaojinroad
//
//  Created by Wgh on 15-3-26.
//  Copyright (c) 2015年 Redz. All rights reserved.
//

#import "CircleInfoViewController.h"
#import "RZWebImageView.h"
#import "NetWorkManage+Circle.h"
#import "CommonUtil.h"
#import "CircleEntity.h"
#import "TJRBaseParserJson.h"
#import "CircleSQL.h"
#import "CircleMemberEntity.h"
#import "CircleSettingRemindEntity.h"
#import "UIButton+NewNum.h"
#import "CircleBaseDataEntity.h"
#import "ShareButton.h"
#import "ShareToWeixin.h"
#import "ShareBase.h"

#define HEADER_BG_HEIGHT    120.0

@interface CircleInfoViewController ()<ShareButtonDelegate>{

    BOOL bReqFinished;
    BOOL bLoadListFinished;
    
    NSMutableArray *tableData;
    
    ShareBase* shareBase;
    
    NSInteger selectRow;
    BOOL bIsStateBarWhite;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivCircleBG;

@property (copy, nonatomic) NSString *circleId;
@property (assign, nonatomic) NSInteger role;

@property (retain, nonatomic) IBOutlet UIView *statusBarView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutHeaderBGHeight;

@property (retain, nonatomic) CircleEntity* circleEntity;
@end

@implementation CircleInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableData = [[NSMutableArray alloc]init];

    shareBase = [[ShareBase alloc]init];
    
    bReqFinished = YES;
    bIsStateBarWhite = YES;
    selectRow = -1;
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        if (TTIsStringWithAnyText(_circleId)) {
            [self reqCircleData:_circleId];
        }
        [self removeParamFromModelDictionary:CircleDict forKey:@"circleId"];
    }
    
    [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self getValueFromModelDictionary:CircleDict forKey:RELOADDATA_DIC_KEY]){
        if (TTIsStringWithAnyText(_circleId)) {
            [self reqCircleData:_circleId];
        }
        [self removeParamFromModelDictionary:CircleDict forKey:RELOADDATA_DIC_KEY];
    }
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return bIsStateBarWhite ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - 请求圈子数据
- (void)reqCircleData:(NSString*)circleId{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleOppGet:self circleId:circleId finishedCallback:@selector(requestCircleFinish:) failedCallback:@selector(requestCircleFalid:)];
    }
}

- (void)requestCircleFinish:(NSDictionary *)result {
    
    bReqFinished = YES;
    bLoadListFinished = YES;
    [self dismissProgress];
    
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    
    NSDictionary* json = [result objectForKey:@"data"];
    
    if ([jsonParser parseBaseIsOk:result]) {
        
        for (NSString *key in [json keyEnumerator]) {
            
            if ([key isEqualToString:@"circle"]) {
                NSDictionary *dic = [json objectForKey:key];
                CircleEntity* item = [[[CircleEntity alloc]initWithJson:dic]autorelease];
                self.circleEntity = item;
            }

            if ([key isEqualToString:@"circleRole"]) {
                NSDictionary *dic = [json objectForKey:key];
                self.role = [jsonParser integerParser:dic name:@"role"];
            }
        }
        
        [_ivCircleBG showImageWithUrl:_circleEntity.circleBg];
        [_tableView reloadData];
    }
}

- (void)requestCircleFalid:(NSError *)error {
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 设置圈子加入方式
- (void)reqCircleJoinModeData:(NSString*)circleId joinMode:(NSInteger)joinMode{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqCircleSetupJoinMode:self circleId:circleId joinMode:joinMode  finishedCallback:@selector(requestCircleJoinModeFinish:) failedCallback:@selector(requestCircleJoinModeFalid:)];
    }
}

- (void)requestCircleJoinModeFinish:(NSDictionary *)result {
    
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    if ([jsonParser parseBaseIsOk:result]) {
        _circleEntity.joinMode = !_circleEntity.joinMode;
        [_tableView reloadData];
    }
}

- (void)requestCircleJoinModeFalid:(NSError *)error {
    bReqFinished = YES;
}

#pragma mark - 设置圈子成员发言状态
- (void)reqCircleSpeakStatus:(NSString*)circleId speakStatus:(NSInteger)speakStatus{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqCircleSetSpeakStatus:self circleId:circleId speakStatus:speakStatus finishedCallback:@selector(requestCircleSpeakStatusFinish:) failedCallback:@selector(requestCircleSpeakStatusFalid:)];
    }
}

- (void)requestCircleSpeakStatusFinish:(NSDictionary *)result {
    
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    if ([jsonParser parseBaseIsOk:result]) {
        _circleEntity.speakStatus = !_circleEntity.speakStatus;
        [_tableView reloadData];
    }
}

- (void)requestCircleSpeakStatusFalid:(NSError *)error {
    bReqFinished = YES;
}

#pragma mark - 设置圈子消息提醒状态
- (void)reqCircleMsgAlert:(NSString*)circleId msgAlert:(NSInteger)msgAlert{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [[NetWorkManage shareSingleNetWork] reqCircleSetMsgAlert:self circleId:circleId msgAlert:msgAlert finishedCallback:@selector(requestCircleMsgAlertFinish:) failedCallback:@selector(requestCircleSpeakStatusFalid:)];
    }
}

- (void)requestCircleMsgAlertFinish:(NSDictionary *)result {
    
    bReqFinished = YES;
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    if ([jsonParser parseBaseIsOk:result]) {
        CircleSettingRemindEntity* item = [CircleSQL queryCircleSettingWithCircleId:_circleId];
        item.circleId = _circleId;
        item.chatRemind = !item.chatRemind;
        [CircleSQL updateCircleSetting:_circleId chatRemind:item.chatRemind];
        [_tableView reloadData];
    }
}

#pragma mark - 退出圈子
- (void)reqCircleExit:(NSString*)circleId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqCircleExit:self circleId:circleId finishedCallback:@selector(reqCricleExitFinished:) failedCallback:@selector(reqCricleOppFailed:)];
    }
    
}

- (void)reqCricleExitFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([parser parseBaseIsOk:result]) {
        [self performSelector:@selector(exitCricle) withObject:nil afterDelay:1.0];
        self.view.userInteractionEnabled = NO;
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
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

- (void)exitCricle{
    [CircleSQL exitCircleWithCircleId:_circleId];
    [CircleSQL clearCircleChatWithCircleId:_circleId];
    [self goBackToViewControllerForName:@"HomeViewController" animated:YES];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoHeaderView" owner:self options:nil] lastObject];
        
        RZWebImageView *ivCircleLogo = (RZWebImageView *)[header viewWithTag:100];
        [ivCircleLogo showImageWithUrl:_circleEntity.circleLogo];
        
        UILabel* lbCircleName = (UILabel *)[header viewWithTag:101];
        lbCircleName.text = _circleEntity.circleName;
        
        UILabel* lbCircleId = (UILabel *)[header viewWithTag:102];
        lbCircleId.text = [NSString stringWithFormat:@"（圈子D：%@）", _circleEntity.circleId];
        
        UILabel* lbBrief = (UILabel *)[header viewWithTag:103];
        lbBrief.text = [NSString stringWithFormat:@"简介：%@", _circleEntity.brief];
        
        UILabel* lbReviewState = (UILabel *)[header viewWithTag:104];
        if (_circleEntity.reviewState == 2) {
            lbReviewState.text = @"审核不通过";
        } else if (_circleEntity.reviewState == 0) {
            lbReviewState.text = NSLocalizedStringForKey(@"审核中");
        } else {
            lbReviewState.text = @"";
        }
        
        UIButton *btnBack = (UIButton *)[header viewWithTag:50];
        [btnBack addTarget:self action:@selector(buttonBackClicked:) forControlEvents:UIControlEventTouchUpInside];

        UIButton *btnEdit = (UIButton *)[header viewWithTag:51];
        [btnEdit addTarget:self action:@selector(buttonEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnEdit.hidden = !(_role == CRICLE_ROLE_ROOT || _role == CRICLE_ROLE_ADMIN);
        
        return header;
    }else if (section == 1) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoOptHeaderView" owner:self options:nil] lastObject];
        
        UILabel* lbMemberAmount = (UILabel *)[header viewWithTag:100];
        lbMemberAmount.text = [NSString stringWithFormat:@"共%@名成员",_circleEntity.memberAmount];
        
        UIButton* memberBtn = (UIButton *)[header viewWithTag:50];
        [memberBtn addTarget:self action:@selector(buttonMemberClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        ShareButton* shareBtn = (ShareButton *)[header viewWithTag:51];
        NSArray *shareButtonImageNameArray = [NSArray arrayWithObjects:@"share_logo_weixin", @"share_logo_pengyouquan", nil];
        NSArray *shareButtonTitleArray = [NSArray arrayWithObjects:@"微信好友", @"微信朋友圈", nil];
        [shareBtn setShareMenu:ShareBtnCircle itemTitles:shareButtonTitleArray itemIcons:shareButtonImageNameArray];
        shareBtn.delegate = self;
        
        return header;
    }else if (section == 2) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoSetUpHeaderView" owner:self options:nil] lastObject];

        UISwitch *swOption1 = (UISwitch *)[header viewWithTag:300];
        UISwitch *swOption2 = (UISwitch *)[header viewWithTag:301];
        [swOption1 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [swOption2 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        CircleSettingRemindEntity* item = [CircleSQL queryCircleSettingWithCircleId:_circleId];
        swOption1.on = item.chatRemind;
        
        swOption2.on = _circleEntity.speakStatus;
        
        UILabel* lbJoinMode = (UILabel *)[header viewWithTag:100];
        lbJoinMode.text = (_circleEntity.joinMode == 1)?@"自由加入":@"审核加入";
        
        UIButton *btnNew = (UIButton *)[header viewWithTag:400];
        
        CircleBaseDataEntity *d = [CircleBaseDataEntity circleBaseDataWithCircleId:item.circleId];
        NSInteger newNum = d.applyNews;
        btnNew.hidden = (newNum == 0);
        if (newNum > 0) {
            [btnNew showNewNum:newNum isShowDot:NO];
        }
        
        UIButton* joinerBtn = (UIButton *)[header viewWithTag:50];
        [joinerBtn addTarget:self action:@selector(buttonJoinerClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* joinWayBtn = (UIButton *)[header viewWithTag:51];
        [joinWayBtn addTarget:self action:@selector(buttonJoinWayClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* blackBtn = (UIButton *)[header viewWithTag:52];
        [blackBtn addTarget:self action:@selector(buttonBlackListClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return header;
    }else if (section == 3) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoExitHeaderView" owner:self options:nil] lastObject];
        
        UIButton* exitBtn = (UIButton *)[header viewWithTag:51];
        [exitBtn addTarget:self action:@selector(buttonExitClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* cleanBtn = (UIButton *)[header viewWithTag:50];
        [cleanBtn addTarget:self action:@selector(buttonCleanClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoHeaderView" owner:self options:nil] lastObject];
        CGFloat height = header.frame.size.height;
        CGSize size = [CommonUtil getPerfectSizeByText:_circleEntity.brief andFontSize:15.0f andWidth:phoneRectScreen.size.width - 50];
        height = height + size.height - 18;
        if (CURRENT_DEVICE_VERSION < 11.0) height += STATUS_BAR_HEIGHT;
        return height;
    }else if (section == 1) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoOptHeaderView" owner:self options:nil] lastObject];
        return header.frame.size.height;
    }else if (section == 2) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoSetUpHeaderView" owner:self options:nil] lastObject];
        return (_role == CRICLE_ROLE_ROOT || _role == CRICLE_ROLE_ADMIN)?header.frame.size.height:50;
    }else if (section == 3) {
        UIView* header = [[[NSBundle mainBundle] loadNibNamed:@"CircleInfoExitHeaderView" owner:self options:nil] lastObject];
        return header.frame.size.height;
    }
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 0;
    }
    return 2.50001f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)buttonBackClicked:(id)sender{
    [self goBack];
}

- (void)buttonEditClicked:(id)sender{
    if (TTIsStringWithAnyText(_circleId)) {
        [self putValueToParamDictionary:CircleDict value:_circleId forKey:@"circleId"];
        [self pageToViewControllerForName:@"CircleEditViewController"];
    }
}

- (void)buttonMemberClicked:(id)sender{
    if (TTIsStringWithAnyText(_circleId)) {
        [self putValueToParamDictionary:CircleDict value:[NSNumber numberWithInteger:_role] forKey:@"role"];
        [self putValueToParamDictionary:CircleDict value:_circleId forKey:@"circleId"];
        [self pageToViewControllerForName:@"CircleMemberController"];
    }
}

- (void)buttonShareClicked:(id)sender{
    
}

- (void)buttonJoinWayClicked:(id)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置加入圈方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"自由加入" style:(_circleEntity.joinMode == 1)?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reqCircleJoinModeData:weakSelf.circleId joinMode:1];
    }];
    [alertController addAction:alertAction1];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"审核加入" style:(_circleEntity.joinMode == 0)?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reqCircleJoinModeData:weakSelf.circleId joinMode:0];
    }];
    [alertController addAction:alertAction2];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)buttonJoinerClicked:(id)sender{
    if (TTIsStringWithAnyText(_circleId)) {
        [self putValueToParamDictionary:CircleDict value:_circleId forKey:@"circleId"];
        [self pageToViewControllerForName:@"CircleJoinRecordController"];
    }
}

- (void)buttonBlackListClicked:(id)sender{
    if (TTIsStringWithAnyText(_circleId)) {
        [self putValueToParamDictionary:CircleDict value:_circleId forKey:@"circleId"];
        [self pageToViewControllerForName:@"CircleBlackListController"];
    }
}

- (void)buttonCleanClicked:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"清空该圈子的聊天记录吗？" preferredStyle:UIAlertControllerStyleAlert];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:(_circleEntity.joinMode == 1)?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([CircleSQL clearCircleChatWithCircleId:weakSelf.circleId]){
            [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_NOTIFACATION_KEY_CIRCLE_CHAT_CLEAR object:nil];
        }
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)buttonExitClicked:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"确定退出该圈子吗？" preferredStyle:UIAlertControllerStyleAlert];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:(_circleEntity.joinMode == 1)?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reqCircleExit:weakSelf.circleId];
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - swith事件
- (void)switchValueChanged:(id)sender {
    UISwitch *switchTemp = (UISwitch *)sender;

    switch (switchTemp.tag) {
        case 300:// 聊天提醒
        {
            BOOL bOn = switchTemp.on;
            [self reqCircleMsgAlert:_circleId msgAlert:bOn];
            break;
        }
        case 301: // 圈子发言权限
        {
            BOOL bOn = switchTemp.on;
            [self reqCircleSpeakStatus:_circleId speakStatus:bOn];
            break;
        }
        default:
            break;
    }
}

#pragma mark - observeValue
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _tableView && [keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat offset = self.tableView.contentOffset.y;
        
        if(offset < 0){
            _layoutHeaderBGHeight.constant = HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT - offset;
            _statusBarView.alpha = 0;
            bIsStateBarWhite = YES;
            
        }else if(offset == 0){
            _layoutHeaderBGHeight.constant = HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT;
            _statusBarView.alpha = 0;
            bIsStateBarWhite = YES;
            
        }else{
            
            if(offset > (HEADER_BG_HEIGHT + 6)){
                
                CGFloat percentage;
                if(offset > HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT){
                    percentage = 1;
                }else{
                    percentage = (offset - (HEADER_BG_HEIGHT + 6))/NAVIGATION_BAR_HEIGHT;
                }
                _statusBarView.alpha = percentage;
                bIsStateBarWhite = NO;
            }else{
                
                _statusBarView.alpha = 0;
                bIsStateBarWhite = YES;
            }
            
            if(HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT - offset <= 0){
                _layoutHeaderBGHeight.constant = 0.0;
            }else{
                _layoutHeaderBGHeight.constant = HEADER_BG_HEIGHT + STATUS_BAR_HEIGHT - offset;
            }
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - ShareButton Delegate Methods
- (void)shareTouchType:(ShareTouchType)type {
    switch (type) {
            
        case ShareTouchPengyouquan:
        {
            if (TTIsStringWithAnyText(_circleId)) {
                shareBase.shareParams = [CommonUtil jsonToString:@{@"circleId":_circleId}];
                shareBase.shareType = [NSString stringWithFormat:@"%@",@(SHARETYPE_CIRCLE)];
                shareBase.isSession = NO;
                [shareBase share:self.view];
            }
        }
            break;
        case ShareTouchWeixin:
        {
            if (TTIsStringWithAnyText(_circleId)) {
                shareBase.shareParams = [CommonUtil jsonToString:@{@"circleId":_circleId}];
                shareBase.shareType = [NSString stringWithFormat:@"%@",@(SHARETYPE_CIRCLE)];
                shareBase.isSession = YES;
                [shareBase share:self.view];
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)dealloc {
    [_tableView removeObserver:self forKeyPath:@"contentOffset"];
    [shareBase release];
    [_circleEntity release];
    [tableData release];
    [_tableView release];
    [_circleId release];
    [_statusBarView release];
    [_layoutHeaderBGHeight release];
    [_ivCircleBG release];
    [super dealloc];
}


@end
