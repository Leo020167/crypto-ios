//
//  FollowOrderDetailController.m
//  Cropyme
//
//  Created by Hay on 2019/5/8.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FollowOrderDetailController.h"
#import "FODAssetHeaderView.h"
#import "TJRBaseTitleView.h"
#import "NetWorkManage+FollowOrder.h"
#import "NetWorkManage+Trade.h"
#import "FollowOrderDetailEntity.h"
#import "HoldCoinEntity.h"
#import "FollowOrderDetailEntity.h"
#import "CoinTradeOrderEntity.h"
#import "VeDateUtil.h"
#import "RZRefreshTableView.h"
#import "FODModifyInfoView.h"
#import "FODFollowOrderSettingView.h"
#import "FollowOrderDistributeChartEntity.h"
#import "NetWorkManage+Share.h"
#import "MHShareViewController.h"
#import "LewPopupViewAnimationSpring.h"
#import "FODUserInfoView.h"

#define UserHiddenFollowOrderMinHoldCoinSetting        @"UserHiddenFollowOrderMinHoldCoinSetting"

@interface FollowOrderDetailController ()<UITableViewDataSource,UITableViewDelegate,FODAssetHeaderViewDelegate,FODModifyInfoViewDelegate,FODFollowOrderSettingViewDelegate,FODUserInfoViewDelegate>
{
    NSMutableArray *holdCoinArr;   //持仓数组
    NSInteger pageNo;
    BOOL functionLimit;         //是否功能限制
    NSMutableArray *distributeDataArray;            //资产分布数组
    BOOL isHiddenMinHold;               //是否隐藏小额持仓
}
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *appendBalance;            //追加金额
@property (copy, nonatomic) NSString *perMaxBalance;            //每笔最大金额
@property (copy, nonatomic) NSString *stopWin;                  //止盈
@property (copy, nonatomic) NSString *stopLoss;                 //止损

@property (copy, nonatomic) NSString *minMarketBalance;                                 //最小币种金额
@property (copy, nonatomic) NSString *shareUrl;                                         //分享链接
@property (retain, nonatomic) TradeConfigInfoEntity *configEntity;                      //USDT配置信息
@property (retain, nonatomic) FollowOrderDetailEntity *detailEntity;                    //详情数据
@property (retain, nonatomic) FODAssetHeaderView *assetHeaderView;                      //资产headerView
@property (retain, nonatomic) FODUserInfoView *userInfoView;                            //用户信息view
@property (retain, nonatomic) UIView *holdCoinHeaderView;                               //跟单持仓headerView
@property (retain, nonatomic) UIView *questionInfoView;

@property (assign, nonatomic) CGFloat followCoinCellHeight;        //跟单持仓cell高度

@property (retain, nonatomic) IBOutlet TJRBaseTitleView *navigationBar;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UILabel *navigationTitle;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundIV;           //背景图片

@property (retain, nonatomic) IBOutlet UIView *operationView;           //操作view
@property (retain, nonatomic) IBOutlet UIView *unOperateView;           //不能操作的view
@property (retain, nonatomic) IBOutlet UIButton *hadStoppedButton;      //已停止跟单的按钮

@end

@implementation FollowOrderDetailController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    holdCoinArr = [[NSMutableArray alloc] init];
    distributeDataArray = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    [_backgroundIV setFrame:CGRectMake(0.0, 0.0, SCREEN_HEIGHT, NAVIGATION_BAR_HEIGHT)];
    self.dataTableView.tableHeaderView = self.assetHeaderView;
    _operationView.hidden = NO;
    _unOperateView.hidden = YES;
    _shareButton.hidden = YES;
    [CommonUtil viewHeightForAutoLayout:_operationView height:_operationView.frame.size.height + IPHONEX_BOTTOM_HEIGHT];
    [CommonUtil viewHeightForAutoLayout:_unOperateView height:_unOperateView.frame.size.height + IPHONEX_BOTTOM_HEIGHT];
    
    
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"FollowOrderDetailOrderId"]){
        self.orderId = [self getValueFromModelDictionary:CoinTradeDic forKey:@"FollowOrderDetailOrderId"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"FollowOrderDetailOrderId"];
    }
    
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"FollowOrderDetailLimit"]){
        functionLimit = YES;
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"FollowOrderDetailLimit"];
    }else{
        functionLimit = NO;
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:UserHiddenFollowOrderMinHoldCoinSetting]){
        isHiddenMinHold = [[[NSUserDefaults standardUserDefaults] objectForKey:UserHiddenFollowOrderMinHoldCoinSetting] boolValue];
    }else{
        isHiddenMinHold = NO;
    }
    UIButton *hideButton =  (UIButton *)[self.holdCoinHeaderView viewWithTag:100];
    hideButton.selected = isHiddenMinHold;
    
    
    if(checkIsStringWithAnyText(_orderId)){
        [self showProgressDefaultText];

        [self reqFollowOrderDetail];
        /** 预请求分享接口数据*/
        [self reqViewShareData];
    }

}


- (void)dealloc
{
    [holdCoinArr release];
    [distributeDataArray release];
    [_orderId release];
    [_appendBalance release];
    [_perMaxBalance release];
    [_stopWin release];
    [_stopLoss release];
    [_minMarketBalance release];
    [_shareUrl release];
    [_configEntity release];
    [_detailEntity release];
    [_assetHeaderView release];
    [_userInfoView release];
    [_holdCoinHeaderView release];
    [_questionInfoView release];
    [_dataTableView release];
    [_navigationBar release];
    [_backButton release];
    [_navigationTitle release];
    [_backgroundIV release];
    [_operationView release];
    [_unOperateView release];
    [_hadStoppedButton release];
    [_shareButton release];
    [super dealloc];
}


#pragma mark - 懒加载
- (FODAssetHeaderView *)assetHeaderView
{
    if(!_assetHeaderView){
        _assetHeaderView = (FODAssetHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"FODAssetHeaderView" owner:nil options:nil] lastObject] retain];
        _assetHeaderView.delegate = self;
    }
    return _assetHeaderView;
}

- (FODUserInfoView *)userInfoView
{
    if(!_userInfoView){
        _userInfoView = (FODUserInfoView *)[[[[NSBundle mainBundle] loadNibNamed:@"FODUserInfoView" owner:nil options:nil] lastObject] retain];
        _userInfoView.delegate = self;
    }
    return _userInfoView;
}

- (UIView *)holdCoinHeaderView
{
    if(!_holdCoinHeaderView){
        _holdCoinHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"FODHoldCoinHeaderView" owner:nil options:nil] lastObject] retain];
        UIButton *hideButton =  (UIButton *)[_holdCoinHeaderView viewWithTag:100];
        UIButton *questionButton = (UIButton *)[_holdCoinHeaderView viewWithTag:101];
        [hideButton addTarget:self action:@selector(hiddenMinBalanceHoldCoinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [questionButton addTarget:self action:@selector(minBalanceQuestionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _holdCoinHeaderView;
}



- (CGFloat)followCoinCellHeight
{
    if(_followCoinCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FODFollowCoinCell" owner:nil options:nil] lastObject];
        _followCoinCellHeight = cell.frame.size.height;
    }
    return _followCoinCellHeight;
}

- (UIView *)questionInfoView
{
    if(!_questionInfoView){
        _questionInfoView = [[[[NSBundle mainBundle] loadNibNamed:@"AccountQuestionInfoView" owner:nil options:nil] lastObject] retain];
        UIButton *closeButton = (UIButton *)[_questionInfoView viewWithTag:100];
        [closeButton addTarget:self action:@selector(questionInfoViewCloseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionInfoView;
}



#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/** 隐藏小额持仓*/
- (void)hiddenMinBalanceHoldCoinButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    isHiddenMinHold = sender.isSelected;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isHiddenMinHold] forKey:UserHiddenFollowOrderMinHoldCoinSetting];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_dataTableView reloadData];
}

/** 小额持仓解释说明*/
- (void)minBalanceQuestionButtonPressed:(UIButton *)sender
{
    CGRect frame = self.questionInfoView.frame;
    frame.size.width = SCREEN_WIDTH - 40;
    [self.questionInfoView setFrame:frame];
    UILabel *contentLabel = (UILabel *)[self.questionInfoView viewWithTag:101];
    if(checkIsStringWithAnyText(_minMarketBalance)){
        contentLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"少于%@ USDT的币种"),_minMarketBalance];
    }else{
        contentLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"少于%@ USDT的币种"), @"--"];
    }
    
    [self lew_presentPopupView:self.questionInfoView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];
}

/** 关闭*/
- (void)questionInfoViewCloseButtonPressed:(UIButton *)sender
{
    [self lew_dismissPopupView];
}


/** 分享按钮点击事件*/
- (IBAction)shareButonPressed:(id)sender
{
    MHShareViewController *shareViewController = [[[MHShareViewController alloc] init] autorelease];
    [shareViewController controllerShowInController:self withShareUrl:self.shareUrl withShareType:MHShareViewShareTypeOthers withInfo:@{MHShareViewUserNameKey:_detailEntity.followName,MHShareViewUserIdKey:_detailEntity.followUid,MHShareViewUserHeadLogoKey:_detailEntity.followHeadUrl}];
}

/** 停止跟单点击事件*/
 - (void)cancelFollowOrderButtonPressed:(id)sender
 {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"停止跟单将以市价卖出您所有的跟单持仓") preferredStyle:UIAlertControllerStyleAlert];
     [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
     [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
         [self reqStopFollowOrder];
     }]];
     [self presentViewController:alertController animated:YES completion:nil];
 }



/** 停止跟单按钮点击*/
- (IBAction)stopFollowOrderButtonPressed:(id)sender
{
    /** 先获取停止跟单信息，再进行一次停止跟单*/
    [self reqStopFollowOrderTips];
//    [self reqStopFollowOrder];
}

/** 追加金额按钮点击*/
- (IBAction)addBalanceButtonPressed:(id)sender
{
    FODModifyInfoView *modifyInfoView = (FODModifyInfoView *)[[[NSBundle mainBundle] loadNibNamed:@"FODModifyInfoView" owner:nil options:nil] lastObject];
    modifyInfoView.delegate = self;
    [modifyInfoView updateModifyInfoViewData:self.configEntity];
    [modifyInfoView showModifyViewWithAnimationInView:self.view];
}

#pragma mark - 请求数据
/** 跟单详情请求*/
- (void)reqFollowOrderDetail
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderDetail:self orderId:_orderId finishedCallback:@selector(reqFollowOrderDetailFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderDetailFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *orderDetailDic = [dataDic objectForKey:@"orderDetail"];
        NSArray *holdList = [orderDetailDic objectForKey:@"holdList"];
        NSArray *holdDistribute = [orderDetailDic objectForKey:@"holdDistribute"];
        
        self.minMarketBalance = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"minMarketBalance"]];
        
        self.detailEntity = [[[FollowOrderDetailEntity alloc] initWithJson:orderDetailDic] autorelease];
        [holdCoinArr removeAllObjects];
        for(NSDictionary *holdDic in holdList){
            HoldCoinEntity *entity = [[[HoldCoinEntity alloc] initWithJson:holdDic] autorelease];
            [holdCoinArr addObject:entity];
        }
        
        /** 资产分布数组*/
        [distributeDataArray removeAllObjects];
        for(NSDictionary *chartDic in holdDistribute){
            FollowOrderDistributeChartEntity *distributeChartEntity = [[[FollowOrderDistributeChartEntity alloc] initWithJson:chartDic] autorelease];
            [distributeDataArray addObject:distributeChartEntity];
        }
        
        
        if(_detailEntity.isDone == 1 || _detailEntity.isDone == 2){         //正在取消或者已停止跟单都应该限制功能的使用
            functionLimit = YES;
            _operationView.hidden = YES;
            _unOperateView.hidden = NO;
            if(_detailEntity.isDone == 1){
                [_hadStoppedButton setTitle:NSLocalizedStringForKey(@"正在停止跟单") forState:UIControlStateNormal];
            }else{
                [_hadStoppedButton setTitle:NSLocalizedStringForKey(@"已停止跟单") forState:UIControlStateNormal];
            }
        }else{
            functionLimit = NO;
            _operationView.hidden = NO;
            _unOperateView.hidden = YES;
        }
        
        
        
        /** 更新头部信息*/
        [self.assetHeaderView reloadHeaderViewData:_detailEntity distributeChartData:distributeDataArray];
        [self.userInfoView reloadUserInfoData:_detailEntity isLimitFunction:functionLimit];
        
        [_dataTableView reloadData];
        //请求配置信息
        [self reqDepositConfig];
//        //请求交易明细
//        [self reqFollowOrderTradeDetail];
        
        
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqFollowOrderDetailFailed:(NSDictionary *)json
{
    _operationView.hidden = YES;
    _unOperateView.hidden = YES;
    [self dismissProgress];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
    
}


/** 停止跟单的信息提示*/
- (void)reqStopFollowOrderTips
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqStopFollowOrderTips:self orderId:_orderId finishedCallback:@selector(reqStopFollowOrderTipsFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqStopFollowOrderTipsFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *tips = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"tips"]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:tips preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self reqStopFollowOrder];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 停止跟单*/
- (void)reqStopFollowOrder
{
    [self showProgressDefaultText];

}

- (void)reqStopFollowOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        //通知个人首页更新数据
        [self putValueToParamDictionary:FollowOrderDict value:@"1" forKey:@"PersonMainControllerNeedUpdate"];
        
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"已提交停止跟单处理")];
        }
        functionLimit = YES;                //点击了停止跟单就开始限制功能
        _detailEntity.isDone = 1;           //直接赋值1，然后更新页面数据
        /** 更新头部信息*/
        [self.assetHeaderView reloadHeaderViewData:_detailEntity distributeChartData:distributeDataArray];
        [self.userInfoView reloadUserInfoData:_detailEntity isLimitFunction:functionLimit];
        
        [_dataTableView reloadData];
        
        //重新请求一次数据
        [self reqFollowOrderDetail];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqDepositConfig
{
    [[NetWorkManage shareSingleNetWork] reqDepositUSDTConfig:self symbol:@"" targetUid:_detailEntity.userId finishedCallback:@selector(reqDepositConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqDepositConfigFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.configEntity = [[[TradeConfigInfoEntity alloc] initWithJson:dataDic] autorelease];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 追加金额*/
- (void)reqFollowOrderAppendBalance
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqFollowOrderAppendBalance:self orderId:_orderId balance:_appendBalance finishedCallback:@selector(reqFollowOrderAppendBalanceFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderAppendBalanceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"追加金额成功")];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 修改设置提示*/
- (void)reqFollowOrderUpdateOptionsTip
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqFollowOrderUpdateOptionTips:self orderId:_orderId stopWin:_stopWin stopLoss:_stopLoss finishedCallback:@selector(reqFollowOrderUpdateOptionsTipFinished:) failedCallback:nil];
}

- (void)reqFollowOrderUpdateOptionsTipFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *msg = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self reqFollowOrderUpdateOptions];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            [self reqFollowOrderUpdateOptions];
        }

    }
    
}

/** 修改设置*/
- (void)reqFollowOrderUpdateOptions
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqFollowOrderUpdateOptions:self orderId:_orderId maxFollowBalance:_perMaxBalance stopWin:_stopWin stopLoss:_stopLoss finishedCallback:@selector(reqFollowOrderUpdateOptionsFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderUpdateOptionsFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
            [self reqFollowOrderDetail];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"修改成功")];
        }
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


#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.userInfoView.frame.size.height;
    }else if(section == 1){
        return self.holdCoinHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.userInfoView;
    }else if(section == 1){
        return self.holdCoinHeaderView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1){
        return [holdCoinArr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HoldCoinEntity *entity = [holdCoinArr objectAtIndex:indexPath.row];
    if(isHiddenMinHold && entity.hide){         //如果是需要隐藏小额币种，并且该币种属于小额币种
        return 0.0;
    }else{
        return self.followCoinCellHeight;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *followCoinCellIdentifier = @"FODFollowCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:followCoinCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FODFollowCoinCell" owner:nil options:nil] lastObject];
    }
    UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *holdAmountLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *profitLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *costPriceLabel = (UILabel *)[cell viewWithTag:103];
    
    HoldCoinEntity *coinEntity = [holdCoinArr objectAtIndex:indexPath.row];
    symbolLabel.text = coinEntity.symbol;
    holdAmountLabel.text = coinEntity.amount;
    profitLabel.text = coinEntity.profit;
    costPriceLabel.text = coinEntity.costPrice;
    profitLabel.text = [NSString stringWithFormat:@"%@",[TradeUtil stringByAppendingPlusSymbolString:coinEntity.profit]];
    profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:coinEntity.profit.doubleValue];
    
    return cell;
    

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == _dataTableView){
        CGPoint point = _dataTableView.contentOffset;
        if(point.y <= 0){
            [_backgroundIV setFrame:CGRectMake(_backgroundIV.bounds.origin.x, _backgroundIV.bounds.origin.y, _backgroundIV.frame.size.width, NAVIGATION_BAR_HEIGHT - point.y)];
        }else{
            if(_backgroundIV.frame.size.height != NAVIGATION_BAR_HEIGHT){
               [_backgroundIV setFrame:CGRectMake(_backgroundIV.bounds.origin.x, _backgroundIV.bounds.origin.y, _backgroundIV.frame.size.width, NAVIGATION_BAR_HEIGHT)];
            }
            
        }
    }
}

#pragma mark - FODAssetHeaderView delegate
/** 跟单明细*/
- (void)assetHeaderViewFollowOrderDetailButtonDidSelected
{
    [self putValueToParamDictionary:FollowOrderDict value:_orderId forKey:@"FollowOrderTradeInfoOrderId"];
    [self pageToViewControllerForName:@"FollowOrderTradeInfoController"];
}

- (void)assetHeaderViewQuestionInfoDidSelected
{
    CGRect frame = self.questionInfoView.frame;
    frame.size.width = SCREEN_WIDTH - 40;
    [self.questionInfoView setFrame:frame];
    UILabel *contentLabel = (UILabel *)[self.questionInfoView viewWithTag:101];
    contentLabel.text = NSLocalizedStringForKey(@"已扣除跟单分成部分");
    [self lew_presentPopupView:self.questionInfoView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];

}

#pragma mark - FODUserInfoView delegate
- (void)userInfoViewFollowOrderSettingDidSelected
{
    FODFollowOrderSettingView *settingView = [[[NSBundle mainBundle] loadNibNamed:@"FODFollowOrderSettingView" owner:nil options:nil] lastObject];
    settingView.delegate = self;
    [settingView updateSettingViewData:_detailEntity usdtRate:_configEntity.usdtRate];
    [settingView showSettingViewWithAnimationInView:self.view];
}

- (void)userInfoViewUserHeadLogoDidSelected:(NSString *)userId
{
    [self putValueToParamDictionary:ProCoinBaseDict value:userId forKey:@"PersonalMainTargetUid"];
    [self pageToViewControllerForName:@"PersonalMainController"];
}

#pragma mark - FODModifyInfoView delegate
- (void)modifyInfoViewCommintDidSelectedWithBalance:(NSString *)balance modifyInfoView:(FODModifyInfoView *)view
{
    self.appendBalance = balance;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"说明" message:[NSString stringWithFormat:NSLocalizedStringForKey(@"是否追加%@USDT的跟单金额"),balance] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [view dismissModifyViewWithAnimation];
        [self reqFollowOrderAppendBalance];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)modifyInfoViewShowErrorMsg:(NSString *)msg
{
    [self showToastCenter:msg];
}

#pragma mark - FODFollowOrderSettingView delegate
- (void)settingViewCommitButtonDidSelectedWithAmount:(NSString *)amount stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss settingView:(FODFollowOrderSettingView *)settingView
{
    self.perMaxBalance = amount;
    self.stopWin = stopWin;
    self.stopLoss = stopLoss;
    [self reqFollowOrderUpdateOptionsTip];
    [settingView dismissSettingViewWithAnimation];
}
- (void)settingViewShowErrorMsg:(NSString *)msg
{
    [self showToastCenter:msg];
}


@end
