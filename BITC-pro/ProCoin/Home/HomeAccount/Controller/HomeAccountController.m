//
//  HomeAccountController.m
//  Cropyme
//
//  Created by Hay on 2019/5/5.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "HomeAccountController.h"
#import "AccountInfoView.h"
#import "CommonUtil.h"
#import "NetWorkManage+Home.h"
#import "NetWorkManage+FollowOrder.h"
#import "TradeUtil.h"
#import "AccountAssetsEntity.h"
#import "RZWebImageView.h"
#import "MHShareViewController.h"
#import "NetWorkManage+Share.h"
#import <YNPageViewController.h>
#import "TJRBaseTitleView.h"
#import "PCSegmentDigitalVC.h"
#import "PCSegmentStockFuturesVC.h"
#import "PCSegmentFollowOrderVC.h"
#import "PCSegmentBalanceVC.h"
#import "PCMultiNumSettingView.h"
#import "NetWorkManage+ExtractCoin.h"


@interface HomeAccountController ()<AccountInfoViewDelegate,YNPageViewControllerDelegate,YNPageViewControllerDataSource,PCSegmentFollowOrderVCDelegate,PCSegmentDigitalVCDelegate,PCSegmentBalanceVCDelegate,PCSegmentStockFuturesVCDelegate,PCMultiNumSettingViewDelegate>
{
    
    BOOL isLightStype;          //statue bar 是否亮风格

    BOOL isReqBaseInfoFinished;             //是否请求完基本数据
    NSTimer *refreshTimer;                  //刷新定时器
    YNPageViewController *mainController;

//    NSLocalizedStringForKey(@"数字货币"),NSLocalizedStringForKey(@"国际期货"),@"余额",@"外汇",@"数字货币跟单",@"国际期货跟单",@"外汇跟单"
    
    PCSegmentDigitalVC *digitalVC;// 数字
    PCSegmentStockFuturesVC *stockFuturesVC;// 国际期货
    PCSegmentStockFuturesVC *fxVC;// 外汇
    PCSegmentFollowOrderVC *followOrderVC;
    PCSegmentFollowOrderVC *digitalFollowOrderVC;// 数字货币跟单
    PCSegmentFollowOrderVC *stockFuturesFollowOrderVC;// 国际期货跟单
    PCSegmentFollowOrderVC *fxFollowOrderVC;// 外汇跟单
    PCSegmentBalanceVC *balanceVC;// 余额
    
    NSMutableArray *digitalHoldCoinArr;         //数字货币开仓数据
    NSMutableArray *stockFuturesHoldCoinArr;    //股指期货开仓数据
    NSMutableArray *fxHoldCoinArr;    //外汇数据
    NSMutableArray *followDigitalHoldArr;       //跟单数字货币开仓数据
    NSMutableArray *followStockFuturesHoldArr;  //跟单国际期货开仓数据
    NSMutableArray *followFxArr;  //跟单外汇开仓数据
    NSMutableArray *coinRecordArr;              //充提币记录
    
    CGRect backgroundIVOriginRect;          //背景原始rect
}
/** 数据变量*/
@property (retain, nonatomic) NSArray *segmentArrayVC;              //分段控制器
@property (retain, nonatomic) NSArray *segmentArrayTitle;           //分段标题
@property (retain, nonatomic) AccountAssetsEntity *assetsEntity;    //总资产数据

/// 数字货币资产
@property (retain, nonatomic) PCAccountModel *digitalAcountEntity;

/// 股指期货资产
@property (retain, nonatomic) PCAccountModel *stockFuturesAccountEntity;

/// 外汇
@property (retain, nonatomic) PCAccountModel *fxAccountEntity;

/// 跟单数字货币资产
@property (retain, nonatomic) PCAccountModel *followDigitalAccountEntity;

///  跟单国际期货资产
@property (retain, nonatomic) PCAccountModel *followStockFuturesAccountEntity;

/// 跟单外汇期货资产
@property (retain, nonatomic) PCAccountModel *followFxAccountEntity;

/// 余额账户
@property (retain, nonatomic) PCAccountModel *balanceAccountEntity;

@property (retain, nonatomic) PCHomeUserFollowOrderInfoModel *userFollowEntity;     //大v信息
@property (assign, nonatomic) NSInteger openFollow;                 //是否已开通跟单
@property (copy, nonatomic) NSString *minMarketBalance;             //最小金额值，用来显示问号的说明
@property (copy, nonatomic) NSString *shareUrl;                     //分享链接

/** UI*/
@property (retain, nonatomic) IBOutlet TJRBaseTitleView *navigationBar;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundIV;               //背景图片
@property (retain, nonatomic) AccountInfoView *infoHeaderView;                  //顶部账户信息页面

@end

@implementation HomeAccountController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return isLightStype ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isLightStype = YES;
    isReqBaseInfoFinished = NO;
    
    digitalHoldCoinArr = [[NSMutableArray alloc] init];
    fxHoldCoinArr = [[NSMutableArray alloc] init];
    stockFuturesHoldCoinArr = [[NSMutableArray alloc] init];
    followDigitalHoldArr = [[NSMutableArray alloc] init];
    followStockFuturesHoldArr = [[NSMutableArray alloc] init];
    followFxArr = [[NSMutableArray alloc] init];
    coinRecordArr = [[NSMutableArray alloc] init];
    
    _navigationBar.alpha = 0.0;         //一开始先隐藏一下
    backgroundIVOriginRect = CGRectMake(0.0, 0.0, SCREEN_WIDTH, self.infoHeaderView.frame.size.height);
    [_backgroundIV setFrame:backgroundIVOriginRect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //如果登陆了才进行获取数据操作
    
    if(checkIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){
        [self startRefreshTimer];
        [self reqHomeAccountInfo];
    }
    
    [self reqCoinOperationRecord];      //请求充值记录
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self closeRefreshTimer];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(mainController == nil){
        [self setupMainController];
    }
}

- (void)dealloc
{
    [_digitalAcountEntity release];
    [_stockFuturesAccountEntity release];
    [_followDigitalAccountEntity release];
    [_followStockFuturesAccountEntity release];
    [_balanceAccountEntity release];
    [_userFollowEntity release];
    [mainController release];
    [stockFuturesVC release];
    [followOrderVC release];
    [digitalVC release];
    [balanceVC release];
    [digitalHoldCoinArr release];
    [stockFuturesHoldCoinArr release];
    [followDigitalHoldArr release];
    [followStockFuturesHoldArr release];
    [coinRecordArr release];
    [_segmentArrayVC release];
    [_segmentArrayTitle release];
    [_minMarketBalance release];
    [_shareUrl release];
    [_assetsEntity release];
    [_infoHeaderView release];
    [_navigationBar release];
    [_backgroundIV release];
    [super dealloc];
}

#pragma mark - 懒加载
- (AccountInfoView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"AccountInfoView" owner:nil options:nil] lastObject] retain];
        _infoHeaderView.delegate = self;
    }
    return _infoHeaderView;
}

- (NSArray *)segmentArrayVC
{
    if(!_segmentArrayVC){
        digitalVC = [[PCSegmentDigitalVC alloc] init];// 数字
        stockFuturesVC = [[PCSegmentStockFuturesVC alloc] init];// 国际期货
        fxVC = [[PCSegmentStockFuturesVC alloc] init];// 外汇
        followOrderVC = [[PCSegmentFollowOrderVC alloc] init];
        digitalFollowOrderVC = [[PCSegmentFollowOrderVC alloc] init];// 数字货币跟单
        stockFuturesFollowOrderVC = [[PCSegmentFollowOrderVC alloc] init];// 国际期货跟单
        fxFollowOrderVC = [[PCSegmentFollowOrderVC alloc] init];// 外汇跟单
        balanceVC = [[PCSegmentBalanceVC alloc] init];
        
        digitalVC.delegate = self;
        stockFuturesVC.delegate = self;
        fxVC.delegate = self;
        
        fxFollowOrderVC.delegate = self;
        followOrderVC.delegate = self;
        digitalFollowOrderVC.delegate = self;
        stockFuturesFollowOrderVC.delegate = self;
        stockFuturesFollowOrderVC.delegate = self;
        balanceVC.delegate = self;
        
        _segmentArrayVC = [[NSArray arrayWithObjects:balanceVC, digitalVC,stockFuturesVC, fxVC, digitalFollowOrderVC, stockFuturesFollowOrderVC, fxFollowOrderVC,nil] retain];
        //_segmentArrayVC = [[NSArray arrayWithObjects:digitalVC,stockFuturesVC,followOrderVC,balanceVC,nil] retain];
    }
    return _segmentArrayVC;
}

- (NSArray *)segmentArrayTitle
{
    if(!_segmentArrayTitle){
        _segmentArrayTitle = [[NSArray arrayWithObjects:NSLocalizedStringForKey(@"余额"),NSLocalizedStringForKey(@"数字货币"),NSLocalizedStringForKey(@"国际期货"),NSLocalizedStringForKey(@"外汇"),NSLocalizedStringForKey(@"数字货币跟单"),NSLocalizedStringForKey(@"国际期货跟单"),NSLocalizedStringForKey(@"外汇跟单"), nil] retain];
    }
    return _segmentArrayTitle;
}

#pragma mark - 设置main Controller
- (void)setupMainController
{
    UIButton *button_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_1 setFrame:CGRectMake(0.0, 0.0, 0, 44)];
    UIButton *button_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_2 setFrame:CGRectMake(0.0, 0.0, 0, 44)];
    
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionTopPause;
    configration.showTabbar = YES;
    configration.showNavigation = NO;
    configration.scrollMenu = YES;
    configration.aligmentModeCenter = NO;
    configration.lineWidthEqualFontWidth = YES;
    configration.lineColor = RGBA(97, 117, 174, 1.0);
    configration.showBottomLine = YES;
    configration.bottomLineBgColor = [UIColor clearColor];
    configration.bottomLineHeight = 1;
    configration.buttonArray = @[button_1,button_2];
    configration.headerViewCouldScale = YES;
    configration.headerViewScaleMode = YNPageHeaderViewScaleModeTop;
    configration.itemFont = [UIFont systemFontOfSize:14.0f];
    configration.selectedItemFont = [UIFont systemFontOfSize:14.0f];
    /// 设置悬浮停顿偏移量
    configration.suspenOffsetY = NAVIGATION_BAR_HEIGHT;
    //    configration.itemFont = [UIFont systemFontOfSize:14];
    //    configration.selectedItemFont = [UIFont systemFontOfSize:16];
    configration.normalItemColor = RGBA(61, 58, 80, 0.4);
    configration.selectedItemColor = RGBA(97, 117, 174, 1.0);
    
    //    configration.lineLeftAndRightMargin = 36;
    
    mainController = [[YNPageViewController pageViewControllerWithControllers:self.segmentArrayVC
                                                                  titles:self.segmentArrayTitle
                                                                  config:configration] retain];
    
    mainController.delegate = self;
    mainController.dataSource = self;
    
    mainController.headerView = self.infoHeaderView;
    mainController.view.clipsToBounds = YES;
    mainController.view.backgroundColor =  [UIColor clearColor];
    mainController.bgScrollView.backgroundColor = [UIColor clearColor];

    
    mainController.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [mainController addSelfToParentViewController:self];
    [self.view sendSubviewToBack:mainController.view];
    [self.view sendSubviewToBack:_backgroundIV];
    
}

#pragma mark - 按钮点击事件
//- (void)shareButtonPressed:(id)sender
//{
//    MHShareViewController *shareViewController = [[[MHShareViewController alloc] init] autorelease];
//    if(checkIsStringWithAnyText(_shareUrl)){
//        [shareViewController controllerShowInController:self.tabBarController withShareUrl:self.shareUrl];
//    }else{
//        [shareViewController controllerShowInController:self.tabBarController withShareUrl:@""];
//    }
//
//}

#pragma mark - 请求数据
- (void)reqHomeAccountInfo
{
    [[NetWorkManage shareSingleNetWork] reqHomeAccountInfo:self finishedCallback:@selector(reqHomeAccountInfoFinished:) failedCallback:@selector(reqHomeAccountInfoFailed:)];
}

- (void)reqHomeAccountInfoFinished:(NSDictionary *)json
{
    [self dismissProgress];

    if([self checkJsonIsSuccess:json]){
        isReqBaseInfoFinished = YES;
        NSDictionary *dataDic = [json objectForKey:@"data"];
        /** 数字货币资产*/
        NSDictionary *digitalDic = [dataDic objectForKey:@"digitalAccount"];         //数字货币资产
        self.digitalAcountEntity = [[[PCAccountModel alloc] initWithJson:digitalDic] autorelease];
        [digitalHoldCoinArr removeAllObjects];
        NSArray *digitalOpenList = [digitalDic objectForKey:@"openList"];
        for(NSDictionary *dic in digitalOpenList){
            PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
            [digitalHoldCoinArr addObject:entity];
        }
        [digitalVC reloadDigitalAccountInfo:self.digitalAcountEntity accountHoldData:digitalHoldCoinArr];
        
        /** 国际期货资产*/
        NSDictionary *stockFuturesDic = [dataDic objectForKey:@"stockAccount"];
        self.stockFuturesAccountEntity = [[[PCAccountModel alloc] initWithJson:stockFuturesDic] autorelease];
        self.stockFuturesAccountEntity.type = 1;
        NSArray *stockOpenList = [stockFuturesDic objectForKey:@"openList"];
        [stockFuturesHoldCoinArr removeAllObjects];
        for(NSDictionary *dic in stockOpenList){
            PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
            [stockFuturesHoldCoinArr addObject:entity];
        }
        [stockFuturesVC reloadStockFuturesAccountInfo:self.stockFuturesAccountEntity accountHoldData:stockFuturesHoldCoinArr];
        
        /** 外汇*/
        NSDictionary *fxDic = [dataDic objectForKey:@"fxAccount"];
        self.fxAccountEntity = [[[PCAccountModel alloc] initWithJson:fxDic] autorelease];
        self.fxAccountEntity.type = 2;
        NSArray *fxList = [fxDic objectForKey:@"openList"];
        [fxHoldCoinArr removeAllObjects];
        for(NSDictionary *dic in fxList){
            PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
            [fxHoldCoinArr addObject:entity];
        }
        [fxVC reloadStockFuturesAccountInfo:self.fxAccountEntity accountHoldData:fxHoldCoinArr];
        
        
        /** 跟单资产*/
        // 数字
        /// 1国际期货 2外汇 3数字
        NSDictionary *followDigitalDic = [dataDic objectForKey:@"followDigitalAccount"];
        // 外汇
        NSDictionary *followFxDic = [dataDic objectForKey:@"followFxAccount"];
        NSDictionary *followStockFuturesDic = [dataDic objectForKey:@"followStockAccount"];
        self.followDigitalAccountEntity = [[[PCAccountModel alloc] initWithJson:followDigitalDic] autorelease];
        self.followDigitalAccountEntity.type = 3;
        self.followFxAccountEntity = [[[PCAccountModel alloc] initWithJson:followFxDic] autorelease];
        self.followFxAccountEntity.type = 2;
        self.followStockFuturesAccountEntity = [[[PCAccountModel alloc] initWithJson:followStockFuturesDic] autorelease];
        self.followStockFuturesAccountEntity.type = 1;
        
        NSArray *followDigitalOpenList = [followDigitalDic objectForKey:@"openList"];
        [followDigitalHoldArr removeAllObjects];
        for(NSDictionary *dic in followDigitalOpenList){
            PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
            [followDigitalHoldArr addObject:entity];
        }
        
        NSArray *followFxList = [followFxDic objectForKey:@"openList"];
        [followFxArr removeAllObjects];
        for(NSDictionary *dic in followFxList){
            PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
            [followFxArr addObject:entity];
        }
        
        NSArray *followStockFuturesOpenList = [followStockFuturesDic objectForKey:@"openList"];
        [followStockFuturesHoldArr removeAllObjects];
        for(NSDictionary *dic in followStockFuturesOpenList){
            PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
            [followStockFuturesHoldArr addObject:entity];
        }
        
        PCHomeUserFollowOrderInfoModel *followDigitalDv = [[PCHomeUserFollowOrderInfoModel alloc] initWithJson:[dataDic objectForKey:@"followDigitalDv"]];
        
        [digitalFollowOrderVC reloadFollowOrderAccountDigitalInfo:self.followDigitalAccountEntity stockFuturesInfo:self.followStockFuturesAccountEntity accountDigitalHoldData:followDigitalHoldArr acountStockFuturesHoldData:followStockFuturesHoldArr userFollowInfo:followDigitalDv];
        
        PCHomeUserFollowOrderInfoModel *followStockDv = [[PCHomeUserFollowOrderInfoModel alloc] initWithJson:[dataDic objectForKey:@"followStockDv"]];

        
        [stockFuturesFollowOrderVC reloadFollowOrderAccountDigitalInfo:self.followStockFuturesAccountEntity stockFuturesInfo:self.followStockFuturesAccountEntity accountDigitalHoldData:followDigitalHoldArr acountStockFuturesHoldData:followStockFuturesHoldArr userFollowInfo:followStockDv];
        
        PCHomeUserFollowOrderInfoModel *followFxDv = [[PCHomeUserFollowOrderInfoModel alloc] initWithJson:[dataDic objectForKey:@"followFxDv"]];
        
        [fxFollowOrderVC reloadFollowOrderAccountDigitalInfo:self.followFxAccountEntity stockFuturesInfo:self.followStockFuturesAccountEntity accountDigitalHoldData:followDigitalHoldArr acountStockFuturesHoldData:followStockFuturesHoldArr userFollowInfo:followFxDv];

        
//        PCSegmentFollowOrderVC *digitalFollowOrderVC;// 数字货币跟单
//        PCSegmentFollowOrderVC *stockFuturesFollowOrderVC;// 国际期货跟单
//        PCSegmentFollowOrderVC *fxFollowOrderVC;// 外汇跟单
//        PCSegmentBalanceVC *balanceVC;// 余额
        
        
        /** 余额资产*/
        NSDictionary *balanceDic = [dataDic objectForKey:@"balanceAccount"];
        self.balanceAccountEntity = [[[PCAccountModel alloc] initWithJson:balanceDic] autorelease];
        [balanceVC reloadBalanceAccountInfo:self.balanceAccountEntity];
        
        //更新顶部总资产数据
        self.assetsEntity = [[[AccountAssetsEntity alloc] initWithJson:dataDic] autorelease];
        [self.infoHeaderView reloadAccountInfoViewData:self.assetsEntity];
    }else{
        
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqHomeAccountInfoFailed:(NSDictionary *)json
{
    [self dismissProgress];
}

/** 请求充值记录*/
- (void)reqCoinOperationRecord
{
    [[NetWorkManage shareSingleNetWork] reqCoinOperationRecord:self inOut:@"" pageNo:@"1" finishedCallback:@selector(reqCoinOperationRecordFinished:) failedCallback:nil];
}

- (void)reqCoinOperationRecordFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [coinRecordArr removeAllObjects];
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        for(NSDictionary *dic in dataArr){
            PCCoinOperationRecordModel *entity = [[[PCCoinOperationRecordModel alloc] initWithJson:dic] autorelease];
            [coinRecordArr addObject:entity];
        }
        [balanceVC reloadBalanceRecordData:coinRecordArr];
        
    }
}

/** 解除绑定跟单*/
- (void)reqUnBindFollowOrder
{
    if(checkIsStringWithAnyText(self.userFollowEntity.dvUid)){
        [[NetWorkManage shareSingleNetWork] reqStopFollowOrder:self dvUid:self.self.userFollowEntity.dvUid finishedCallback:@selector(reqUnBindFollowOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
    }
    
}

- (void)reqUnBindFollowOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"解除绑定成功");
        }
        [self showToastCenter:msg];
        /** 立即请求一次数据*/
        [self reqHomeAccountInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 请求更新跟单是否开启*/
- (void)reqUpdateFollowOrderOpen:(BOOL)isOpen
{
    [[NetWorkManage shareSingleNetWork] reqUpdateFollowOrderOpen:self isOpen:isOpen finishedCallback:@selector(reqUpdateFollowOrderOpenFinished:) failedCallback:@selector(reqUpdateFollowOrderOpenFailed:)];
}

- (void)reqUpdateFollowOrderOpenFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        /** 立即更新数据*/
        [self reqHomeAccountInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:@"请求开启/关闭跟单数据错误"];
    }
}

- (void)reqUpdateFollowOrderOpenFailed:(NSDictionary *)json
{
    [self showToastCenter:@"请求开启/关闭跟单失败，请检查网路"];
}

/** 请求更新倍数*/
- (void)reqUpdateFollowOrderMultiNum:(NSString *)multiNum
{
    [[NetWorkManage shareSingleNetWork] reqUpdateFollowOrderMultiNum:self multiple:multiNum finishedCallback:@selector(reqUpdateFollowOrderMultiNumFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqUpdateFollowOrderMultiNumFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [json objectForKey:@"msg"];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        [self showToastCenter:msg];
        /** 立即更新数据*/
        [self reqHomeAccountInfo];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index
{
    id baseVC = pageViewController.controllersM[index];
    if([baseVC isKindOfClass:[PCSegmentFollowOrderVC class]]){
        PCSegmentFollowOrderVC *vc = baseVC;
        return [vc followOrderTableView];
    }else if([baseVC isKindOfClass:[PCSegmentDigitalVC class]]){
        PCSegmentDigitalVC *vc = baseVC;
        return [vc digitalCoinTableView];
    }else if([baseVC isKindOfClass:[PCSegmentStockFuturesVC class]]){
        PCSegmentStockFuturesVC *vc = baseVC;
        return [vc dataTableView];
    }else if([baseVC isKindOfClass:[PCSegmentBalanceVC class]]){
        PCSegmentBalanceVC *vc = baseVC;
        return [vc dataTableView];
    }
    return nil;
}

#pragma mark - YNPageViewControllerDelegate
- (void)pageViewController:(YNPageViewController *)pageViewController contentOffsetY:(CGFloat)contentOffset progress:(CGFloat)progress
{
    if(progress >= 0.7){
        if(isLightStype){
            isLightStype = NO;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }else{
        if(!isLightStype){
            isLightStype = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
    _navigationBar.alpha = progress;
    CGRect frame = backgroundIVOriginRect;
    frame.size.height = backgroundIVOriginRect.size.height - contentOffset;
    _backgroundIV.frame =  frame;
}


#pragma mark - account info view delegate
- (void)accountChargeCoinButtonPressed
{
    [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ChargeCoinSymbol"];
    [self pageToViewControllerForName:@"ChargeCoinController"];
}

- (void)accountExtractCoinButtonPressed
{
    [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ExtractCoinSymbol"];
    [self pageToViewControllerForName:@"ExtractCoinController"];
}

- (void)accountTransferCoinButtonPressed
{
    [self pageToViewControllerForName:@"PCTransferCoinController"];
}

- (void)accountP2pCoinButtonPressed
{
    [self putValueToParamDictionary:P2PDict value:self.balanceAccountEntity.holdAmount  forKey:@"holdAmount"];
    [self pageToViewControllerForName:@"P2PMainController"];
}

#pragma mark - PCSegmentDigitalVC delegate
- (void)digitalCoinTableViewDidSelectedCellWithIndexPath:(NSIndexPath *)indexPath
{
    PCBaseHoldCoinModel *entity = [digitalHoldCoinArr objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:entity.orderId forKey:@"TransactionDetailOrderId"];
    [self pageToViewControllerForName:@"PCTransactionDetailController"];
}

- (void)digitalRiskQuestionButtonDidPressed
{
    NSString *localRiskRateDesc = [[NSUserDefaults standardUserDefaults] objectForKey:HomeRiskRateDescLocalKey];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:localRiskRateDesc preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - PCSegmentStockFuturesVC delegate
- (void)stockFuturesTableViewDidSelectedCellWithIndexPath:(PCBaseHoldCoinModel *)model
{
    [self putValueToParamDictionary:ProCoinBaseDict value:model.orderId forKey:@"TransactionDetailOrderId"];
    [self pageToViewControllerForName:@"PCTransactionDetailController"];
}

- (void)stockFuturesRiskQuestionButtonDidPressed
{
    NSString *localRiskRateDesc = [[NSUserDefaults standardUserDefaults] objectForKey:HomeRiskRateDescLocalKey];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:localRiskRateDesc preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - PCSegmentFollowOrder delegate
- (void)followOrderViewOpenFollowSwitchValueChanged:(BOOL)isOn
{
    [self reqUpdateFollowOrderOpen:isOn];
}

- (void)followOrderViewMultiNumButtonDidPressed
{
    PCMultiNumSettingView *settingView = [[[PCMultiNumSettingView alloc] init] autorelease];
    settingView.delegate = self;
    settingView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [settingView showMultiNumViewInController:self.tabBarController];
}

- (void)followOrderViewBindOperationButtonDidPressed:(PCHomeUserFollowOrderInfoModel *)model{
    if(model == nil){
        return;
    }
    if(checkIsStringWithAnyText(model.dvUid) && ![model.dvUid isEqualToString:@"0"]){   //已绑定
        
        [self putValueToParamDictionary:ProCoinBaseDict value:model.dvUid forKey:@"PersonalMainTargetUid"];
        [self pageToViewControllerForName:@"PersonalMainController"];
    }else{  //未绑定则提示
        [self pageToViewControllerForName:@"HomeBigVController"];
    }
}

- (void)followOrderViewDidSelctedHoldDataWithOrderId:(NSString *)orderId
{
    [self putValueToParamDictionary:ProCoinBaseDict value:orderId forKey:@"TransactionDetailOrderId"];
    [self pageToViewControllerForName:@"PCTransactionDetailController"];
}

- (void)followOrderViewRiskQuestionButtonDidPressed
{
    NSString *localRiskRateDesc = [[NSUserDefaults standardUserDefaults] objectForKey:HomeRiskRateDescLocalKey];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:localRiskRateDesc preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - PCSegmentBalanceVC delegate
- (void)balanceCoinOperationRecordDidSelectedWithIndexPath:(NSIndexPath *)indexPath
{
    PCCoinOperationRecordModel *entity = [coinRecordArr objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:entity forKey:@"PCCoinOperationDetailEntity"];
    [self pageToViewControllerForName:@"PCCoinOperationDetailController"];
}

- (void)balanceCoinAllRecordButtonPressed
{
    [self pageToViewControllerForName:@"PCCoinOperationRecordController"];
}

#pragma mark - PCMultiNumSettingView delegate
- (void)multiNumSettingViewCommitData:(PCMultiNumSettingView *)viewController multiNum:(NSString *)multiNum
{
    if(!checkIsStringWithAnyText(multiNum)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入倍数")];
        return;
    }
    if([multiNum integerValue] <= 0){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入大于0的倍数")];
        return;
    }
    [viewController dismissMultiNumView];
    [self showProgressDefaultText];
    [self reqUpdateFollowOrderMultiNum:multiNum];
}

#pragma mark - 开启定时器
- (void)startRefreshTimer
{
    if(refreshTimer == nil){
        refreshTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(reqHomeAccountInfo) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:refreshTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)closeRefreshTimer
{
    if(refreshTimer && refreshTimer.isValid){
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}
@end
