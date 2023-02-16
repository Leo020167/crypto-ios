//
//  PersonalMainController.m
//  Cropyme
//
//  Created by Hay on 2019/6/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "PersonalMainController.h"
#import "PersonalInfoHeaderView.h"
#import "PersonalLineHeaderView.h"
#import "NetWorkManage+Personal.h"
#import "NetWorkManage+Trade.h"
#import "TradeCountEntity.h"
#import "TradeUtil.h"
#import "FollowOrderView.h"
#import "TradeConfigInfoEntity.h"
#import "NetWorkManage+FollowOrder.h"
#import "NetWorkManage+Share.h"
#import "MHShareViewController.h"
#import "CommonUtil.h"
#import "PCSubscribeUserAlertView.h"
#import "NetWorkManage+TransferCoin.h"
#import "PersonalMainFollowController.h"


@interface PersonalMainController ()<UITableViewDelegate,UITableViewDataSource,PersonalInfoHeaderViewDelegate,PersonalLineHeaderViewDelegate,FollowOrderViewDelegate,PCSubscribeUserAlertViewDelegate>
{
    NSMutableArray *trendDataArr;                       //业绩走势数组
    NSMutableArray *coinKindDataArr;                    //币种次数汇总数组
}


@property (retain, nonatomic) PCPersonalInfoModel *infoEntity;                 //个人信息对象
@property (retain, nonatomic) TradeConfigInfoEntity *configEntity;          //usdt信息对象
@property (copy, nonatomic) NSString *shareUrl;         //分享链接
@property (copy, nonatomic) NSString *targetUid;        //uid


@property (copy, nonatomic) NSString *type;             //请求类型参数
@property (copy, nonatomic) NSString *timeType;         //请求数据时间参数
@property (copy, nonatomic) NSString *holdAmount;       //账户余额

/** 懒加载*/
@property (retain, nonatomic) PersonalInfoHeaderView *infoHeaderView;
@property (retain, nonatomic) PersonalLineHeaderView *lineHeaderView;
@property (assign, nonatomic) CGFloat tacticsCellHeight;

@property (retain, nonatomic) IBOutlet UITableView *coreTableView;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;           //分享按钮


@end

@implementation PersonalMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"PersonalMainTargetUid"]){
        self.targetUid = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"PersonalMainTargetUid"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"PersonalMainTargetUid"];
    }
    
    self.type = @"1";
    self.timeType = @"month";
    trendDataArr = [[NSMutableArray alloc] init];
    coinKindDataArr = [[NSMutableArray alloc] init];
    _coreTableView.delegate = self;
    _coreTableView.dataSource = self;
    [self showProgressDefaultText];
    [self reqPersonalHomePageData];
    [self reqPersonalLineChartData];
    /** 预请求分享接口数据*/
//    [self reqViewShareData];
    /** 请求余额*/
    [self reqAccountHold];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self getValueFromModelDictionary:FollowOrderDict forKey:@"PersonMainControllerNeedUpdate"]){
        [self showProgressDefaultText];
        [self reqPersonalHomePageData];
        [self reqPersonalLineChartData];
        [self removeParamFromModelDictionary:FollowOrderDict forKey:@"PersonMainControllerNeedUpdate"];
    }
}

- (void)dealloc
{
    [trendDataArr release];
    [coinKindDataArr release];
    [_infoEntity release];
    [_configEntity release];
    [_shareUrl release];
    [_targetUid release];
    [_type release];
    [_timeType release];
    [_holdAmount release];
    [_infoHeaderView release];
    [_lineHeaderView release];
    [_coreTableView release];
    [_shareButton release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)shareButtonPressed:(id)sender
{
    MHShareViewController *shareViewController = [[[MHShareViewController alloc] init] autorelease];
    [shareViewController controllerShowInController:self withShareUrl:self.shareUrl withShareType:MHShareViewShareTypeOthers withInfo:@{MHShareViewUserNameKey:_infoEntity.userName,MHShareViewUserIdKey:_infoEntity.userId,MHShareViewUserHeadLogoKey:_infoEntity.headUrl}];
}

#pragma mark - 懒加载
- (PersonalInfoHeaderView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = (PersonalInfoHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"PersonalInfoHeaderView" owner:nil options:nil] lastObject] retain];
        _infoHeaderView.delegate = self;
    }
    return _infoHeaderView;
}

- (PersonalLineHeaderView *)lineHeaderView
{
    if(!_lineHeaderView){
        _lineHeaderView = (PersonalLineHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"PersonalLineHeaderView" owner:nil options:nil] lastObject] retain];
        _lineHeaderView.delegate = self;
    }
    return _lineHeaderView;
}

- (CGFloat)tacticsCellHeight
{
    if(_tacticsCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCPersonalTacticsCell" owner:nil options:nil] lastObject];
        _tacticsCellHeight = cell.frame.size.height;
    }
    return _tacticsCellHeight;
}

#pragma mark - 获取数据
- (void)reqPersonalHomePageData
{
    [[NetWorkManage shareSingleNetWork] reqPersonalMainData:self targetUid:_targetUid finishedCallback:@selector(reqPersonalHomePageDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqPersonalHomePageDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *userRadarDic = [dataDic objectForKey:@"userRadar"];
        self.infoEntity = [[[PCPersonalInfoModel alloc] initWithJson:userRadarDic] autorelease];
        [self.infoHeaderView reloadInfoHeaderView:self.infoEntity];
        
        [_coreTableView reloadData];

    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 请求账户余额*/
- (void)reqAccountHold
{
    [[NetWorkManage shareSingleNetWork] reqTransferAccountHoldAmount:self accountType:PCAccountBalanceType finishedCallback:@selector(reqAccountHoldFinished:) failedCallback:nil];
}

- (void)reqAccountHoldFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        TJRBaseEntity *parserJson = [[[TJRBaseEntity alloc] init] autorelease];
        self.holdAmount = [parserJson stringParser:@"holdAmount" json:dataDic];
    }
}

/**获取走势图数据*/
- (void)reqPersonalLineChartData
{
    [[NetWorkManage shareSingleNetWork] reqPersonalLineChartData:self targetUid:_targetUid timeType:_timeType type:_type finishedCallback:@selector(reqPersonalLineChartDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqPersonalLineChartDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *trendsArr = [dataDic objectForKey:@"trendData"];
        [trendDataArr removeAllObjects];
        for(NSDictionary *trendDic in trendsArr){
            LineDataEntity *entity = [[[LineDataEntity alloc] initWithJson:trendDic] autorelease];
            [trendDataArr addObject:entity];
        }

        [self.lineHeaderView reloadLineHeaderViewData:trendDataArr];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 请求跟单操作*/
- (void)reqFollowOrderOperation
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderOperation:self dvUid:_infoEntity.userId finishedCallback:@selector(reqFollowOrderOperationFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderOperationFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"申请跟单绑定信息已成功发送，请耐心等待通过");
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 解除跟单绑定*/
- (void)reqStopFollowOrderOperation
{
    [[NetWorkManage shareSingleNetWork] reqStopFollowOrder:self dvUid:_infoEntity.userId finishedCallback:@selector(reqStopFollowOrderOperationFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqStopFollowOrderOperationFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 请求分享数据*/
- (void)reqViewShareData
{
    [[NetWorkManage shareSingleNetWork] reqShareData:self shareType:NetWorkManageShareType_Invite params:@"" finishedCallback:@selector(reqViewShareDataFinished:) failedCallback:nil];
}

- (void)reqViewShareDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        TJRBaseEntity *baseParser = [[[TJRBaseEntity alloc] init] autorelease];
        self.shareUrl = [baseParser stringParser:@"shareUrl" json:dataDic];
        if(checkIsStringWithAnyText(_shareUrl)){
            _shareButton.hidden = NO;
        }else{
            _shareButton.hidden = YES;
        }
    }
}

/** 订阅/续费*/
- (void)reqSubscribeUser:(NSString *)num
{
    [[NetWorkManage shareSingleNetWork] reqSubscribeUser:self attentionUid:_infoEntity.userId num:num finishedCallback:@selector(reqSubscribeUserFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSubscribeUserFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"操作成功")];
        }
        [self reqPersonalHomePageData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"订阅/续费请求数据错误")];
    }
}


#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){       //个人顶部信息
        return [self.infoHeaderView infoHeaderViewCurrentHeight];
    }else if(section == 1){ //线状图
        return self.lineHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){       //个人顶部信息
        return self.infoHeaderView;
    }else if(section == 1){
        return self.lineHeaderView;
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
    if(section == 2){       //交易策略
        if(checkIsStringWithAnyText(_infoEntity.recommend)){
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2){     //交易策略
        CGSize size = [CommonUtil getPerfectSizeByText:_infoEntity.recommend andFontSize:13.0f andWidth:SCREEN_WIDTH - 24];
        size.height = MAX(20, size.height);
        return self.tacticsCellHeight + (size.height - 20);
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCPersonalTacticsCell" owner:nil options:nil] lastObject];
    
    UILabel *tacticsLabel = (UILabel *)[cell viewWithTag:100];
    tacticsLabel.text = _infoEntity.recommend;
    return cell;
}


#pragma mark - info header view delegate
- (void)infoHeaderViewFollowOrderDidSelected
{
    if(![ROOTCONTROLLER getLoginStatus]){
        return;
    }
    PersonalMainFollowController *follow = [[PersonalMainFollowController alloc] init];
    follow.uid = _targetUid;
    [QMUIHelper.visibleViewController.navigationController pushViewController:follow animated:YES];
    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"是否解除跟单绑定？" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [self reqStopFollowOrderOperation];
//    }]];
//    [self presentViewController:alertController animated:YES completion:nil];
    
//    if(_infoEntity != nil){
//        if(_infoEntity.myIsFollow){
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"是否解除跟单绑定？" preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                [self reqStopFollowOrderOperation];
//            }]];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }else{
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:_infoEntity.followNotice preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                [self reqFollowOrderOperation];
//            }]];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//    }
}

- (void)infoHeaderViewSubscribeUserDidSelected
{
    if(_infoEntity.subIsFee){       //收费
        PCSubscribeUserAlertView *alertView = [[[PCSubscribeUserAlertView alloc] init] autorelease];
        alertView.delegate = self;
        [alertView showInController:self subInfo:_infoEntity holdAmount:_holdAmount];
    }else{
        if(!_infoEntity.myIsAttention){         //未订阅情况下
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定订阅该用户？") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showProgressDefaultText];
                [self reqSubscribeUser:@"0"];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    

    
}

- (void)infoHeaderViewRadarInfoDidSelected
{
    [self pageToViewControllerForName:@"RadarIntroController"];
}


#pragma mark - line header view delegate
- (void)lineHeaderViewOptionDidChangedWithKindType:(KindButtonType)kindType timeType:(TimeButtonType)timeType
{
    switch (timeType) {
        case TimeButtonType_OneMonth:
            self.timeType = @"month";
            break;
        case TimeButtonType_ThreeMonth:
            self.timeType = @"month3";
            break;
        case TimeButtonType_SixMonth:
            self.timeType = @"month6";
            break;
        case TimeButtonType_OneYear:
            self.timeType = @"year";
            break;
        default:
            break;
    }
    
    if(kindType == KindButtonType_Trend){
        self.type = @"1";
        [self reqPersonalLineChartData];
    }else if(kindType == KindButtonType_Follow){
        self.type = @"2";
        [self reqPersonalLineChartData];
    }else if(kindType == KindButtonType_Trade){
        self.type = @"3";
        [self reqPersonalLineChartData];
    }
}

#pragma mark - PCSubscribeUserAlertView delegate
- (void)subscribeUserAlertViewDidCommit:(PCSubscribeUserAlertView *)alertView buyNum:(NSString *)buyNum
{
    if(!checkIsStringWithAnyText(buyNum) || [buyNum integerValue] == 0){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入订阅的周期数")];
        return;
    }
    
    NSString *msg = @"";
    if(_infoEntity.myIsAttention){
        msg = [NSString stringWithFormat:NSLocalizedStringForKey(@"确定续费%@%@吗？"),buyNum,_infoEntity.subFeeTypeUnit];
    }else{
        msg = [NSString stringWithFormat:NSLocalizedStringForKey(@"确定订阅%@%@吗？"),buyNum,_infoEntity.subFeeTypeUnit];
    }
    [alertView dismissViewWithAnimation];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqSubscribeUser:buyNum];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
