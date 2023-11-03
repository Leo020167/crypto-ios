//
//  HomeMineViewController.m
//  TJRtaojinroad
//
//  Created by Hay on 15-3-26.
//  Copyright (c) 2015年 Taojinroad. All rights reserved.
//

#import "HomeMineViewController.h"
#import "RZWebImageView.h"
#import "HomeNewNumEntity.h"
#import "UIButton+NewNum.h"
#import "NewbieHelpView.h"
#import "UIImage+Size.h"
#import "TJRBaseEntity.h"
#import "NetWorkManage+Home.h"
#import "CommonUtil.h"
#import "UserInfoSQL.h"
#import "LoginSQLModel.h"
#import "TJRBaseParserJson.h"
#import "HomeViewController.h"
#import "CircleSocket.h"
#import "PrivateChatDataEntity.h"
#import "PrivateChatSQL.h"
#import "CircleChatEntity.h"
#import "HomeMineHeaderView.h"
#import "NetWorkManage+Circle.h"
#import "MHShareViewController.h"
#import "ServiceQRController.h"
#import "HomeMineDataEntity.h"
#import "TYMineCommunityViewController.h"

#define HeaderHeight 160

@implementation HomeMineEntity

+ (HomeMineEntity *)createWithName:(NSString *)name iconName:(NSString *)iconName toPageName:(NSString *)toPageName {
    HomeMineEntity *item = [[HomeMineEntity alloc] init];
    item.name = name;
    item.iconImage = [UIImage imageNamed:iconName];
    item.toPageName = toPageName;
    return [item autorelease];
}

+ (HomeMineEntity *)createWithName:(NSString *)name iconName:(NSString *)iconName toPageName:(NSString *)toPageName tips:(NSString *)tips{
    HomeMineEntity *item = [[HomeMineEntity alloc] init];
    item.name = name;
    item.iconImage = [UIImage imageNamed:iconName];
    item.toPageName = toPageName;
    item.tips = tips;
    return [item autorelease];
}

- (void)dealloc
{
    RELEASE(_tips);
    RELEASE(_toPageName);
    RELEASE(_iconImage);
    RELEASE(_name);
    [super dealloc];
}

@end

@interface HomeMineViewController ()<HomeMineHeaderViewDelegate>
{

    NSInteger questionCount;
    NSInteger chatCount;
    BOOL bReqFinished;
    CGFloat tableHeaderViewOriginHeight;
    CGFloat headerHeight;
}

@property (retain, nonatomic) HomeMineDataEntity *dataEntity;               //数据对象

@property (assign, nonatomic) CGFloat otherCellHeight;
@property (retain, nonatomic) HomeMineHeaderView *tableHeaderView;


@end


@implementation HomeMineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self createPrivateChatData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrivateChatListData:) name:[CircleSocket circleNotifacationKey:ReceiveModelPushRecordList] object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataArray = [[NSMutableArray alloc] init];
    
    if (@available(iOS 11.0, *)) {
        _tvHome.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrivateChatData:) name:SOCKET_NOTIFACATION_KEY_PRIVATE_CHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotification:) name:HomeRefreshNewDotKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataNewNum) name:@"ReloadMessageCount" object:nil];
    
    [self createTableViewOptions];
    
    bReqFinished = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reqHomeMineData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateTopViewUserInfo];
    //    [self reqUserData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(_tableHeaderView == nil){
        self.tableHeaderView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, self.tableHeaderView.frame.size.height + STATUS_BAR_HEIGHT);
        _tvHome.tableHeaderView = self.tableHeaderView;
    }
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [dataArray release];
    [_dataEntity release];
    [_tableHeaderView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (HomeMineHeaderView *)tableHeaderView
{
    if(_tableHeaderView == nil){
        _tableHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"HomeMineHeaderView" owner:nil options:nil] lastObject] retain];
        _tableHeaderView.delegate = self;
        
    }
    return _tableHeaderView;
}

- (CGFloat)otherCellHeight
{
    if(_otherCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeMineOtherCell" owner:nil options:nil] lastObject];
        _otherCellHeight =  cell.frame.size.height;
    }
    return _otherCellHeight;
}


#pragma mark - 创建选项显数据
- (void)createTableViewOptions
{
    [dataArray removeAllObjects];
    NSArray *array0 = @[
               [HomeMineEntity createWithName:NSLocalizedStringForKey(@"交易记录") iconName:@"home_mine_icon_digital" toPageName:@"PCDigitalRecordController"],
//               [HomeMineEntity createWithName:NSLocalizedStringForKey(@"资产") iconName:@"mine_main_assets" toPageName:@"PCDigitalRecordController"],
               ];
    
    [dataArray addObject:array0];
    
    NSArray *array1 = @[
                        [HomeMineEntity createWithName:NSLocalizedStringForKey(@"系统通知") iconName:@"home_mine_icon_system_message" toPageName:@"MyMessageController"],
                        [HomeMineEntity createWithName:NSLocalizedStringForKey(@"帮助中心") iconName:@"home_mine_icon_help_center" toPageName:@"HelpCenterListViewController"],
                        ];
    [dataArray addObject:array1];
    
    NSArray *array2 = @[
//                        [HomeMineEntity createWithName:NSLocalizedStringForKey(@"客服") iconName:@"home_mine_icon_service" toPageName:@""],
                        [HomeMineEntity createWithName:NSLocalizedStringForKey(@"设置") iconName:@"home_mine_icon_setting" toPageName:@"TJRSetUpViewController"]
                        ];
    [dataArray addObject:array2];
    NSArray *array3 = @[
                        [HomeMineEntity createWithName:NSLocalizedStringForKey(@"实名认证") iconName:@"mine_main_cert" toPageName:@"MyOauthController"],
                        [HomeMineEntity createWithName:NSLocalizedStringForKey(@"绑定邮箱") iconName:@"mine_main_email" toPageName:@"EmailVerificationViewController"]
                        ];
    [dataArray addObject:array3];
    
    [_tvHome reloadData];

}

- (void)createPrivateChatData
{
    
    NSArray *chatArray = [PrivateChatSQL queryPrivateChatInfo];
    if (chatArray) {
        if ([CircleSocket shareCircleSocket].privateDetail.count == 0) {
            for (PrivateChatDataEntity *item in chatArray) {
                if (TTIsStringWithAnyText(item.chatTopic)) {
                    [[CircleSocket shareCircleSocket].privateDetail setObject:item forKey:item.chatTopic];
                }
            }
        }
    }
}

- (void)updatePrivateChatListData:(NSNotification *)notification {
    
    @synchronized(self){
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            if ([[userInfo objectForKey:CircleNotifyKeySuccess]boolValue]) {
                NSArray *arr = [userInfo objectForKey:CircleNotifyKeyReceive];
                NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
                for (NSString* str in arr) {
                    NSDictionary* dic = [CommonUtil jsonValue:str];
                    if ([[dic objectForKey:CircleNotifyKeyType] integerValue] == ReceiveModelPrivateChatRecord) {
                        NSDictionary* d = [CommonUtil jsonValue:[dic objectForKey:CircleNotifyKeyReceive]];
                        CircleChatEntity *item = [[CircleChatEntity alloc] initWithJson:d];
                        [array addObject:item];
                    }
                }
                [PrivateChatSQL insertChatList:array];
                
                if (array.count>0 && [CircleSocket shareCircleSocket].privateDetail.count == 0) {
                    //没有数据库时，重新生成全局变量
                    [self createPrivateChatData];
                    [PrivateChatSQL updatePrivateTopicNewsInArrayForNoDB:array];
                }
            }
        }
    }
}

- (void)updatePrivateChatData:(NSNotification *)notification {
    
    @synchronized(self){
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            CircleChatEntity *entity = userInfo[SOCKET_NOTIFACATION_KEY_PRIVATE_USERINFO];
            if (entity) {
                PrivateChatDataEntity * item = nil;
                if ([[CircleSocket shareCircleSocket].privateDetail objectForKey:entity.chatTopic]) {
                    item = [[CircleSocket shareCircleSocket].privateDetail objectForKey:entity.chatTopic];
                }else{
                    item = [[[PrivateChatDataEntity alloc]init]autorelease];
                    item.userId = entity.userId;
                    item.headurl = entity.headUrl;
                    item.name = entity.userName;
                    item.chatNews = 1;
                    [[CircleSocket shareCircleSocket].privateDetail setObject:item forKey:entity.chatTopic];
                }
                item.chatTopic = entity.chatTopic;
                item.content = entity.say;
                item.sayType = entity.sayType;
                item.mark = entity.mark;
                item.createTime = entity.createTime;
                item.isPush = entity.isPush;
                [PrivateChatSQL updatePrivateTopicNews:item.chatTopic chatNews:item.chatNews];
            }
            
            NSArray *listArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"OrderMessageList"];
            NSLog(@"listArray ; %@", listArray);
            NSMutableArray *array = [NSMutableArray arrayWithArray:listArray];
            if (array.count) {
                NSMutableArray *chatTopics = [NSMutableArray array];
                for (NSDictionary *dict in array) {
                    [chatTopics addObject:dict[@"chatTopic"]];
                }
                if ([chatTopics containsObject:entity.chatTopic]) {
                    for (int i = 0; i < array.count; i ++) {
                        NSDictionary *dict = array[i];
                        if ([dict[@"chatTopic"] isEqualToString:entity.chatTopic]) {
                            NSString *count = dict[@"count"];
                            NSDictionary *messageInfo = @{@"chatTopic" : entity.chatTopic, @"count" : [NSString stringWithFormat:@"%d", count.intValue + 1]};
                            [array replaceObjectAtIndex:i withObject:messageInfo];
                        }
                    }
                }else{
                    [array addObject:@{@"chatTopic" : entity.chatTopic, @"count" : @"1"}];
                }
            }else{
                [array addObject:@{@"chatTopic" : entity.chatTopic, @"count" : @"1"}];
            }
            NSLog(@"array ; %@", array);
            NSInteger count = 0;
            for (NSDictionary *dict in array) {
                count = count + [dict[@"count"] integerValue];
            }
            [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"MessageCount"];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"OrderMessageList"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updataNewNum];
        }
    }
}

- (void)refreshNotification:(NSNotification *)notification
{
    HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    [self.tableHeaderView reloadHeaderViewBaseData];
    [self loadNewNum:item];
    [_tvHome reloadData];
}

#pragma mark - 更新个人信息
- (void)updateTopViewUserInfo
{
    [_tableHeaderView reloadHeaderViewBaseData];
}

#pragma mark - 请求数据
- (void)reqHomeMineData
{
    [[NetWorkManage shareSingleNetWork] reqHomeMineData:self finishedCallback:@selector(reqHomeMineDataFninshed:) failedCallback:nil];
}

- (void)reqHomeMineDataFninshed:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.dataEntity = [[[HomeMineDataEntity alloc] initWithJson:dataDic] autorelease];
        _tvHome.tableHeaderView = self.tableHeaderView;
        
        [self createTableViewOptions];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 刻豆兑换*/
- (void)reqAbilityToAward
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqAbilityToKBT:self finishedCallback:@selector(reqAbilityToAwardFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqAbilityToAwardFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"换取成功")];
        }
        [self reqHomeMineData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


//- (void)reqUserData{
//
//    if (bReqFinished) {
//        bReqFinished = NO;
//        [[NetWorkManage shareSingleNetWork] reqGetMyAccountInfo:self finishedCallback:@selector(requestUserFinish:) failedCallback:@selector(requestUserFalid:)];
//    }
//}
//
//- (void)requestUserFinish:(NSDictionary *)result {
//
//    bReqFinished = YES;
//
//    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
//
//    NSDictionary* json = [result objectForKey:@"data"];
//
//    if ([jsonParser parseBaseIsOk:result]) {
//
//
//        HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
//        [self loadNewNum:item];
//
//        [dataArray removeAllObjects];
//        [self createData];
//
//        [_tvHome reloadData];
//    }
//}

//- (void)requestUserFalid:(NSError *)error {
//    bReqFinished = YES;
//}

- (void)loadNewNum:(HomeNewNumEntity*)item {

    if (item) {
//        NSUInteger count = 0;

        /* 直播 的消息提示 */
//        if([dataArray[0] count] != 0){
//            NSArray *array0 = dataArray[0];
//            HomeMineEntity *order = array0[0];
//            order.msgNumber = count;
//        }


        /* 我的私信 的消息提示 */
//        NSArray *array2 = dataArray[2];
//        HomeMineEntity *chat = array2[0];
//        count = MIN(item.chatCount, 99);
//        chat.msgNumber = count;

        /* 通知消息 的消息提示 */
//        HomeMineEntity *msg = array2[1];
//        count = MIN(item.msgCount, 99);
//        msg.msgNumber = count;
    }
}

- (void)updataNewNum
{
    HomeNewNumEntity *item = [[TJRCache shareTJRCache] getCacheValueForKey:HomeNewNumKey];
    [self.tableHeaderView reloadHeaderViewBaseData];
    [self loadNewNum:item];
    [_tvHome reloadData];

    for (id object in [self.navigationController.viewControllers objectEnumerator]) {
        if ([object isKindOfClass:[HomeViewController class]]) {
            [item postNotification];
            break;
        }
    }
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

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
    return [[dataArray objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.otherCellHeight;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"HomeMineOtherCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeMineOtherCell" owner:self options:nil] lastObject];
    }
    HomeMineEntity *item = [dataArray[indexPath.section] objectAtIndex:indexPath.row];
    UIImageView *ivIcon = (UIImageView *)[cell viewWithTag:1];
    ivIcon.image = item.iconImage;
    UILabel *lbName = (UILabel *)[cell viewWithTag:2];
    lbName.text = item.name;
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *dotLabel = (UILabel *)[cell viewWithTag:4];
    UIView *equityLevelView = (UIView *)[cell viewWithTag:200];
    UILabel *equityLevelLabel = (UILabel *)[cell viewWithTag:201];
    tipsLabel.text = @"";
    equityLevelView.hidden = YES;
    equityLevelLabel.text = @"";
    dotLabel.layer.cornerRadius = 10;
    dotLabel.layer.masksToBounds = YES;
    dotLabel.textAlignment = NSTextAlignmentCenter;
    dotLabel.font = UIFontMake(10);
    
    if([item.name isEqualToString:NSLocalizedStringForKey(@"系统通知")]){              //系统通知
        tipsLabel.textColor = RGBA(29, 49, 85, 0.4);
        if(checkIsStringWithAnyText(_dataEntity.latestMsgTitle)){
            dotLabel.hidden = NO;
            dotLabel.text = [NSString stringWithFormat:@"%ld", _dataEntity.msgCount];
            tipsLabel.text = _dataEntity.latestMsgTitle;
        }else{
            tipsLabel.qmui_shouldShowUpdatesIndicator = NO;
            dotLabel.hidden = YES;
            tipsLabel.text = @"";
        }
    }else{
        dotLabel.hidden = YES;
        tipsLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HomeMineEntity *item = [dataArray[indexPath.section] objectAtIndex:indexPath.row];
    if(checkIsStringWithAnyText(item.toPageName)){
        [self pageToOrBackWithName:item.toPageName];
    }else{
        if([item.name isEqualToString:NSLocalizedStringForKey(@"客服")]){
            [self reqPrivateChatService];
        }else if([item.name isEqualToString:NSLocalizedStringForKey(@"优惠券")]){
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.isNavHidden = YES;
            NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&token=%@",CouponWebUrl, ROOTCONTROLLER_USER.userId, ROOTCONTROLLER_USER.token];
            web.url = urlStr;
            [self.navigationController pushViewController:web animated:YES];
        }else if([item.name isEqualToString:NSLocalizedStringForKey(@"分享应用")]){
            MHShareViewController *shareViewController = [[[MHShareViewController alloc] init] autorelease];
            if(checkIsStringWithAnyText(_dataEntity.shareUrl)){
                [shareViewController controllerShowInController:self.tabBarController withShareUrl:_dataEntity.shareUrl withShareType:MHShareViewShareTypePersonalInvite withInfo:@{MHShareViewUserNameKey:ROOTCONTROLLER_USER.name,MHShareViewUserIdKey:ROOTCONTROLLER_USER.userId,MHShareViewUserHeadLogoKey:ROOTCONTROLLER_USER.headurl}];
            }
        }else if([item.name isEqualToString:NSLocalizedStringForKey(@"帮助中心")]){
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.title = NSLocalizedStringForKey(@"帮助中心");
            web.url = _dataEntity.helpCenterUrl;
            [self.navigationController pushViewController:web animated:YES];
        }
    }
}


#pragma mark - 按钮点击事件
//- (void)buttonMyPersonClicked:(id)sender
//{
//    [self putValueToParamDictionary:PersonalDict value:ROOTCONTROLLER_USER.userId forKey:@"targetUid"];
//    [self pageToOrBackWithName:@"PersonViewController"];
//}



#pragma mark - HomeMineHeaderViewDelegate
- (void)mineHeaderViewEventDidSeleted:(MineHeaderViewEvent)event
{
    switch (event) {
        case MineHeaderViewEditInfoEvent:           //编辑资料
            [self pageToViewControllerForName:@"MyHomeViewController"];
            break;
        case MineHeaderViewPersonalMainEvent:        //个人主页
            [self putValueToParamDictionary:ProCoinBaseDict value:ROOTCONTROLLER_USER.userId forKey:@"PersonalMainTargetUid"];
            [self pageToViewControllerForName:@"PersonalMainController"];
            break;
        case MineHeaderViewChargeCoinEvent:
            [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ChargeCoinSymbol"];
            [self pageToViewControllerForName:@"ChargeCoinController"];
            break;
        case MineHeaderViewExtractCoinEvent:
            [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ExtractCoinSymbol"];
            [self pageToViewControllerForName:@"ExtractCoinController"];
            break;
        case MineHeaderViewTransferCoinEvent:
             [self pageToViewControllerForName:@"PCTransferCoinController"];
            break;
        case MineHeaderViewP2PInOutEvent:
             [self pageToViewControllerForName:@"P2PMainController"];
            break;
        default:
            break;
    }
}




#pragma mark - 请求客服数据
- (void)reqPrivateChatService
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqGetPrivateChatService:self finishedCallback:@selector(reqPrivateChatServiceFinished:) failedCallback:@selector(reqPrivateChatServiceFailed:)];
}

- (void)reqPrivateChatServiceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc]init] autorelease];
    
    if([parser parseBaseIsOk:json]){
        
        NSDictionary *data = [json objectForKey:@"data"];
        NSString *chatTopicId = [parser stringParser:data name:@"chatTopic"];
        
        if (TTIsStringWithAnyText(chatTopicId)) {
            
            NSString* userId =  [parser stringParser:data name:@"userId"];
            NSString* headUrl =  [parser stringParser:data name:@"headUrl"];
            NSString* userName =  [parser stringParser:data name:@"userName"];
            NSInteger type = [parser integerParser:data name:@"type"];
            
            if(type == 0){                  //私聊
                PrivateChatDataEntity * item = [[[PrivateChatDataEntity alloc]init]autorelease];
                item.chatTopic = chatTopicId;
                item.userId = userId;
                item.headurl = headUrl;
                item.name = userName;
                [PrivateChatSQL createPrivateChatSQL:item];
                [UserInfoSQL insertOrUpdateUserInfoWithUserId:userId userName:userName userLevel:0 headerUrl:headUrl];
                
                [self putValueToParamDictionary:ChatDict value:item.chatTopic forKey:@"chatTopic"];
                [self putValueToParamDictionary:ChatDict value:item.name forKey:@"userName"];
                [self putValueToParamDictionary:ChatDict value:item.userId forKey:@"taUserId"];
                [self pageToOrBackWithName:@"ChatViewController"];

            }else if(type == 1){        //二维码
                ServiceQRController *qrController = [[ServiceQRController alloc] init];
                [qrController showServiceQRControllerInController:self.tabBarController title:chatTopicId content:userName qrUrl:headUrl];
            }
            
        }
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqPrivateChatServiceFailed:(NSDictionary *)json
{
    [self  dismissProgress];
    [self showToast:NSLocalizedStringForKey(@"请求失败")];
}



@end
