//
//  CoinQuotationsDetailController.m
//  Cropyme
//
//  Created by Hay on 2019/5/16.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TYQuotationsDetailController.h"
#import "CoinQuotationsTradeDataCell.h"
#import <YNPageViewController.h>
#import "QuotationSocket.h"
#import "CoinTradeGearEntity.h"
#import "CommonUtil.h"
#import "TYQuotationDetailDataView.h"
#import "CMShareTimeBaseData.h"
#import "VedateUtil.h"
#import "NetWorkManage+Trade.h"
#import "TYCoinQuotationsSegmentGearController.h"
#import "TYCoinQuotationSegmentDealController.h"
#import "PCQuotationDealModel.h"
#import "NetWorkManage+Quotation.h"


@interface TYQuotationsDetailController ()<CoinQuotationDataViewDelegate,YNPageViewControllerDelegate,YNPageViewControllerDataSource>
{
    BOOL isOptional;            //是否添加自选
    BOOL isReqOptionalFinished; //是否请求自选完成
    BOOL isLeverage;            //是否杠杆数据
    NSTimer *quotationRequestTimer;
    NSMutableArray *buysGearData;
    NSMutableArray *sellsGearData;
    NSMutableArray *dealDataArr;
    CGFloat coinInfoDefaultHeight;
    CoinQuotationButtonType quotationButtonType;           //当前按钮类型
    
    YNPageViewController *mainController;
    TYCoinQuotationsSegmentGearController *gearVC;
    TYCoinQuotationSegmentDealController *dealVC;
    BOOL isSpecialShareTimeView;            //是否特殊分时图行情，股指期货的跟数字货币的不一样，所以为特殊分时行情
}
@property (copy ,nonatomic) NSString *symbol;                   //交易对
@property (copy, nonatomic) NSString *originSymbol;             //币种

@property (retain, nonatomic) TYQuotationDetailDataView *quotationView;             //行情页面
@property (retain, nonatomic) NSArray *segmentArrayVC;              //分段控制器
@property (retain, nonatomic) NSArray *segmentArrayTitle;           //分段标题


@property (retain, nonatomic) IBOutlet UILabel *navSecondTitleLabel;

@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *followSymbolButton;    //添加自选按钮
@property (retain, nonatomic) IBOutlet UIView *operationView;       //买入卖出view
@property (retain, nonatomic) IBOutlet UIButton *buyButton;         //买入按钮
@property (retain, nonatomic) IBOutlet UIButton *sellButton;        //卖出按钮

/// 行情类型（1为新币）
@property (nonatomic, copy) NSString *coinType;

/// 1 分时  2 1分
@property (nonatomic, assign) NSInteger dataType;

@end

@implementation TYQuotationsDetailController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isOptional = NO;
    isReqOptionalFinished = NO;
    isLeverage = NO;
    isSpecialShareTimeView = NO;
    self.dataType = 1;

    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailSymbol"]){
        self.symbol = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailSymbol"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailSymbol"];
    }
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailCoinType"]){
        self.coinType = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailCoinType"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailCoinType"];
    }
    
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailOriginSymbol"]){
        self.originSymbol = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailOriginSymbol"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationsDetailOriginSymbol"];
    }
    
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationDetailMarketType"]){
        NSString *marketType = [NSString stringWithFormat:@"%@",[self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationDetailMarketType"]];
        if([marketType isEqualToString:PCAccountStockType]){
            isSpecialShareTimeView = YES;
        }
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinQuotationDetailMarketType"];
    }

    _navigationTitleLabel.text = self.symbol;
    
    if (!self.symbol.length) {
        self.symbol = @"BTC";
    }
    
    buysGearData = [[NSMutableArray alloc] init];
    sellsGearData = [[NSMutableArray alloc] init];
    dealDataArr = [[NSMutableArray alloc] init];

    _buyButton.frame = CGRectMake(30, 5, 150, 40);
    _sellButton.frame = CGRectMake(SCREEN_WIDTH - 30 - 150, 5, 150, 40);
    _buyButton.backgroundColor = QuotationGreenColor;
    _sellButton.backgroundColor = QuotationRedColor;
    
    CoinQuotationButtonType cacheButtonType = (CoinQuotationButtonType)[[[NSUserDefaults standardUserDefaults] objectForKey:CoinQuotationDetailButtonOptionsKey] integerValue];
    quotationButtonType = cacheButtonType;

    [self reqCoinIsFollow];         //判断是否添加自选股
    
    [_buyButton setTitle:NSLocalizedStringForKey(@"买入") forState:0];
    [_sellButton setTitle:NSLocalizedStringForKey(@"卖出") forState:0];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDidConnectedToServer:self selector:@selector(socketDidConnectedToServer)];
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDisconnectedToServer:self selector:@selector(socketDidDisconnected)];
    self.dataType = 2;
    if(quotationButtonType == CoinQuotationButtonType_ShareTime){
        self.dataType = 1;
        [self.quotationView setShareTimeViewHasHistory:NO];         //重新获取历史数据
        [self reqShareTimeHistoryData];
    }else if(quotationButtonType == CoinQuotationButtonType_FiveDaysShareTime){
        [self req5DayShareTimeData];
    }else{
        [self reqQuotationKLineData:@"0"];
    }
    [self reqQuotationRealData];
    [self startQuotationsTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self closeQuotationsTimer];
    [[QuotationSocket shareQuotationSocket] cancelAllNotifcationOfSocket:self];
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
    [mainController release];
    [gearVC release];
    [dealVC release];
    [_symbol release];
    [_originSymbol release];
    [buysGearData release];
    [sellsGearData release];
    [dealDataArr release];
    [_quotationView release];
    [_segmentArrayVC release];
    [_segmentArrayTitle release];
    [_navigationTitleLabel release];
    [_buyButton release];
    [_sellButton release];
    [_operationView release];
    [_followSymbolButton release];
    [_navSecondTitleLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (TYQuotationDetailDataView *)quotationView
{
    if(!_quotationView){
        _quotationView = (TYQuotationDetailDataView *)[[[[NSBundle mainBundle] loadNibNamed:@"TYQuotationDetailDataView" owner:nil options:nil] lastObject] retain];
        _quotationView.isStockFuturesShareTime = isSpecialShareTimeView;
        _quotationView.delegate = self;
    }
    return _quotationView;
}


- (NSArray *)segmentArrayVC
{
    if(!_segmentArrayVC){
        gearVC = [[TYCoinQuotationsSegmentGearController alloc] init];
        dealVC = [[TYCoinQuotationSegmentDealController alloc] init];
        _segmentArrayVC = [[NSArray arrayWithObjects:gearVC,dealVC,nil] retain];
    }
    return _segmentArrayVC;
}

- (NSArray *)segmentArrayTitle
{
    if(!_segmentArrayTitle){
        _segmentArrayTitle = [[NSArray arrayWithObjects:NSLocalizedStringForKey(@"深度"),NSLocalizedStringForKey(@"成交"),nil] retain];
    }
    return _segmentArrayTitle;
}

#pragma mark - 设置main Controller
- (void)setupMainController
{
    
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionTopPause;
    configration.showNavigation = YES;
    configration.showTabbar = NO;
    configration.scrollMenu = NO;
    configration.aligmentModeCenter = NO;
    configration.lineWidthEqualFontWidth = YES;
    configration.lineColor = RGBA(255, 143, 1, 1.0);
    configration.bottomLineHeight = 1;
    configration.headerViewCouldScale = YES;
    configration.headerViewScaleMode = YNPageHeaderViewScaleModeTop;
    configration.itemFont = [UIFont systemFontOfSize:13.0f];
    configration.selectedItemFont = [UIFont systemFontOfSize:13.0f];
//    configration.itemMargin = 30;
    configration.cutOutHeight = self.operationView.frame.size.height + IPHONEX_BOTTOM_HEIGHT;
    //    configration.itemFont = [UIFont systemFontOfSize:14];
    //    configration.selectedItemFont = [UIFont systemFontOfSize:16];
    configration.normalItemColor = RGBA(255, 255, 255, 0.4);
    configration.selectedItemColor = RGBA(255, 143, 1, 1.0);
    configration.scrollViewBackgroundColor = RGBA(19, 30, 49, 1.0);
    
    //    configration.lineLeftAndRightMargin = 36;
    
    mainController = [[YNPageViewController pageViewControllerWithControllers:self.segmentArrayVC
                                                                       titles:self.segmentArrayTitle
                                                                       config:configration] retain];
    
    mainController.delegate = self;
    mainController.dataSource = self;
    
    self.quotationView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, self.quotationView.frame.size.height);
    mainController.headerView = self.quotationView;
    mainController.view.clipsToBounds = YES;
    mainController.view.backgroundColor = RGBA(19, 30, 49, 1.0);
    mainController.bgScrollView.backgroundColor = RGBA(19, 30, 49, 1.0);
    

    mainController.view.frame = CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - self.operationView.frame.size.height - IPHONEX_BOTTOM_HEIGHT);
    [mainController addSelfToParentViewController:self];
    [self.view sendSubviewToBack:mainController.view];
}




#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/**添加自选 */
- (IBAction)followSymbolButtonPressed:(id)sender
{
    if(![ROOTCONTROLLER getLoginStatus]){           //未登录不允许操作
        return;
    }
    if(!isReqOptionalFinished)      //未对数据请求完成，不进行操作
        return;
    if(_followSymbolButton.isSelected){     //已关注
        [self reqCancelCoinFolllow];
    }else{          //未关注
        [self reqAddCoinFollow];
    }
}

/** 全屏*/
- (IBAction)fullScreenButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(_symbol)){
        [self putValueToParamDictionary:ProCoinBaseDict value:_symbol forKey:@"CoinQuotationsLandScapeSymbol"];
        if(isSpecialShareTimeView){
            [self putValueToParamDictionary:ProCoinBaseDict value:PCAccountStockType forKey:@"CoinQuotationsLandScapeMarketType"];
        }
        
        [self performSelector:@selector(pagePresentModalLandscapeViewControllerForName:) withObject:@"CoinQuotationsLandScapeController" afterDelay:0.25];
    }
    
}

- (IBAction)buyButtonPressed:(id)sender
{
    if(![ROOTCONTROLLER getLoginStatus]){
        return;
    }
    if(isLeverage){         //杠杆
        [self putValueToParamDictionary:ProCoinBaseDict value:@"1" forKey:@"LeverageTransactionBuySell"];
        [self putValueToParamDictionary:ProCoinBaseDict value:_symbol forKey:@"LeverageTransactionSymbol"];
        [self putValueToParamDictionary:ProCoinBaseDict value:_originSymbol forKey:@"LeverageTransactionOriginSymbol"];
        [self pageToViewControllerForName:@"LeverageTransactionVC"];
    }else{
        [self putValueToParamDictionary:CoinTradeDic value:self.coinType.intValue == 1 ? @"1" : @"0" forKey:@"CoinTransactionIsNewCoin"];
        [self putValueToParamDictionary:CoinTradeDic value:_symbol forKey:@"CoinTransactionSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:_originSymbol forKey:@"CoinTransactionOriginSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:@"1" forKey:@"CoinTransactionBuySell"];
        [self pageToViewControllerForName:@"TYCoinTransactionController"];
    }
    
}

- (IBAction)sellButtonPressed:(id)sender
{
    if(![ROOTCONTROLLER getLoginStatus]){
        return;
    }
    
    if(isLeverage){     //杠杆
        [self putValueToParamDictionary:ProCoinBaseDict value:@"-1" forKey:@"LeverageTransactionBuySell"];
        [self putValueToParamDictionary:ProCoinBaseDict value:_symbol forKey:@"LeverageTransactionSymbol"];
        [self putValueToParamDictionary:ProCoinBaseDict value:_originSymbol forKey:@"LeverageTransactionOriginSymbol"];
        [self pageToViewControllerForName:@"LeverageTransactionVC"];
    }else{
        [self putValueToParamDictionary:CoinTradeDic value:self.coinType.intValue == 1 ? @"1" : @"0" forKey:@"CoinTransactionIsNewCoin"];
        [self putValueToParamDictionary:CoinTradeDic value:_symbol forKey:@"CoinTransactionSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:_originSymbol forKey:@"CoinTransactionOriginSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:@"-1" forKey:@"CoinTransactionBuySell"];
        //[self pageToViewControllerForName:@"CoinTransactionController"];
        [self pageToViewControllerForName:@"TYCoinTransactionController"];
    }
    
}

#pragma mark - socket
- (void)socketDidConnectedToServer
{
    if(quotationButtonType == CoinQuotationButtonType_ShareTime){
        [self.quotationView setShareTimeViewHasHistory:NO];         //重新获取历史数据
        [self reqShareTimeHistoryData];
    }else if(quotationButtonType == CoinQuotationButtonType_FiveDaysShareTime){
        [self req5DayShareTimeData];
    }else{
        [self reqQuotationKLineData:@"0"];
    }
    [self reqQuotationRealData];
    [self startQuotationsTimer];
}

- (void)socketDidDisconnected
{
    [self closeQuotationsTimer];
}

/** 分时行情历史数据*/
- (void)reqShareTimeHistoryData
{
    [[NetWorkManage shareSingleNetWork] reqShareTimeHistoryData:self symbol:_symbol timestamp:@"0" pageSize:[NSString stringWithFormat:@"%@",@(PCShareTimeHistoryTotalDataCount)] finishedCallback:@selector(reqShareTimeHistoryDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqShareTimeHistoryDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *quoteDic = [dataDic objectForKey:_symbol];
        TJRBaseEntity *basePraser = [[[TJRBaseEntity alloc] init] autorelease];
        NSString *yesterdayClose = [NSString stringWithFormat:@"%@",[basePraser stringParser:@"yesClose" json:quoteDic]];
        NSString *historyKey = [NSString stringWithFormat:@"min_%@", self.symbol];
        if ([dataDic.allKeys containsObject:historyKey]) {
            NSString *content = dataDic[historyKey];
            [self.quotationView shareTimeViewAddHistoryData:content yesterdayClose:yesterdayClose];
        }
        [self reqQuotationRealData];
    }
}

- (void)req5DayShareTimeData
{
    [[NetWorkManage shareSingleNetWork] reqFiveDayShareTimeData:self symbol:_symbol finishedCallback:@selector(req5DayShareTimeDataFinished:) failedCallback:@selector(req5DayShareTimeDataFailed:)];
}

- (void)req5DayShareTimeDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *historyKey = [NSString stringWithFormat:@"min_%@", self.symbol];
        if ([dataDic.allKeys containsObject:historyKey]) {
            NSString *content = dataDic[historyKey];
            [self.quotationView fiveDayShareTimeViewAddData:content];
        }
    }
}

- (void)req5DayShareTimeDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
}

/** 请求实时数据*/
- (void)reqQuotationRealData
{
    NSString *kLineType = @"";
    if(quotationButtonType == CoinQuotationButtonType_ShareTime){
        kLineType = PCQuotationKLineTypeShareTime;
    }else if(quotationButtonType == CoinQuotationButtonType_FifteenKLine){
        kLineType = PCQuotationKLineTypeMin15;
    }else if(quotationButtonType == CoinQuotationButtonType_OneHourKLine){
        kLineType = PCQuotationKLineTypeHour1;
    }else if(quotationButtonType == CoinQuotationButtonType_OneMinKLine){
        kLineType = PCQuotationKLineTypeMin5;
    }else if(quotationButtonType == CoinQuotationButtonType_DayKLine){
        kLineType = PCQuotationKLineTypeDay;
    }else if(quotationButtonType == CoinQuotationButtonType_WeekKLine){
        kLineType = PCQuotationKLineTypeWeek;
    }
    [[NetWorkManage shareSingleNetWork] reqQuotationRealData:self symbol:_symbol depth:[NSString stringWithFormat:@"%@",@(TradeDataCellTotalGearCount)] klineType:kLineType finishedCallback:@selector(reqQuotationRealDataFinished:) failedCallback:nil];
}

- (void)reqQuotationRealDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *quoteDic = [dataDic objectForKey:_symbol];
        NSArray *buysArr = [quoteDic objectForKey:@"buys"];
        NSArray *sellsArr = [quoteDic objectForKey:@"sells"];
        NSArray *dealArr = [quoteDic objectForKey:@"dealList"];
        [buysGearData removeAllObjects];
        if([buysArr isKindOfClass:[NSArray class]]){
            for(NSDictionary *buyDic in buysArr){
                CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:buyDic] autorelease];
                [buysGearData addObject:gearEntity];
            }
        }
        [sellsGearData removeAllObjects];
        if([sellsArr isKindOfClass:[NSArray class]]){
            for(NSDictionary *sellDic in sellsArr){
                CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:sellDic] autorelease];
                [sellsGearData addObject:gearEntity];
            }
        }
        [dealDataArr removeAllObjects];
        if([dealArr isKindOfClass:[NSArray class]]){
            for(NSDictionary *dealDic in dealArr){
                PCQuotationDealModel *dealEntity = [[[PCQuotationDealModel alloc] initWithJson:dealDic] autorelease];
                [dealDataArr addObject:dealEntity];
            }
        }
        CoinQuotationDataEntity *dataEntity = [[[CoinQuotationDataEntity alloc] initWithJson:quoteDic] autorelease];        //展示头部行情数据对象
        _navSecondTitleLabel.text = dataEntity.name;
        [self.quotationView reloadQuotationData:dataEntity];
        [gearVC reloadControllerWithBuyDataArr:buysGearData sellDataArr:sellsGearData];
        [dealVC reloadDealData:dealDataArr];

        NSString *klineType = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"klineType"]];
        NSDictionary *minDic = [dataDic objectForKey:@"lastKline"];
        CoinQuotationDataEntity *currentDataEntity = [[[CoinQuotationDataEntity alloc] initWithJson:minDic] autorelease];   //分时图当时数据
        //获取分时行情历史数据
        if([klineType isEqualToString:PCQuotationKLineTypeShareTime] && self.dataType == 1){      //行情的分时并且点击的tag还是分时的时候才操作，否则舍弃
            if(quotationButtonType == CoinQuotationButtonType_ShareTime){
                if([self.quotationView isShareTimeViewHasHistory]){         //有历史数据
                    [self.quotationView shareTimeViewAddOneQuotationData:currentDataEntity];
                }
            }
        }else{              //属于k线的实时快照
//            [self reqQuotationKLineData:@"0"];
//            NSString *currentKLineType = @"";               //当前选项
//            if(quotationButtonType == CoinQuotationButtonType_FifteenKLine){
//                   currentKLineType = PCQuotationKLineTypeMin15;
//               }else if(quotationButtonType == CoinQuotationButtonType_OneHourKLine){
//                   currentKLineType = PCQuotationKLineTypeHour1;
//               }else if(quotationButtonType == CoinQuotationButtonType_FourHourKLine){
//                   currentKLineType = PCQuotationKLineTypeHour4;
//               }else if(quotationButtonType == CoinQuotationButtonType_DayKLine){
//                   currentKLineType = PCQuotationKLineTypeDay;
//               }else if(quotationButtonType == CoinQuotationButtonType_WeekKLine){
//                   currentKLineType = PCQuotationKLineTypeWeek;
//               }else if(quotationButtonType == CoinQuotationButtonType_OneMinKLine){
//                   currentKLineType = PCQuotationKLineTypeMin1;
//               }
//            if([klineType isEqualToString:currentKLineType]){
//                [self.quotationView kLineViewAddData:currentDataEntity];
//            }
//            [self reqQuotationKLineData:0];
        }
        
    }
}

/** 请求K线数据*/
- (void)reqQuotationKLineData:(NSString *)timestamp
{
    NSString *kLineType = @"";
    if(quotationButtonType == CoinQuotationButtonType_FifteenKLine){
        kLineType = PCQuotationKLineTypeMin15;
    }else if(quotationButtonType == CoinQuotationButtonType_OneHourKLine){
        kLineType = PCQuotationKLineTypeHour1;
    }else if(quotationButtonType == CoinQuotationButtonType_OneMinKLine){
        kLineType = PCQuotationKLineTypeMin5;
    }else if(quotationButtonType == CoinQuotationButtonType_DayKLine){
        kLineType = PCQuotationKLineTypeDay;
    }else if(quotationButtonType == CoinQuotationButtonType_WeekKLine){
        kLineType = PCQuotationKLineTypeWeek;
    }
    if(checkIsStringWithAnyText(kLineType)){
        NSLog(@"kiline : %@", kLineType);
        [[NetWorkManage shareSingleNetWork] reqQuotationKLineData:self symbol:_symbol timestamp:timestamp pageSize:@"" kLineType:kLineType type:@"h" finishedCallback:@selector(reqQuotationKLineDataFinished:) failedCallback:@selector(reqKlineFailed:)];
    }
}

- (void)reqQuotationKLineDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *klineType = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"klineType"]];
        NSString *currentKLineType = @"";               //当前选项更新的数据
        if(quotationButtonType == CoinQuotationButtonType_FifteenKLine){
               currentKLineType = PCQuotationKLineTypeMin15;
           }else if(quotationButtonType == CoinQuotationButtonType_OneHourKLine){
               currentKLineType = PCQuotationKLineTypeHour1;
           }else if(quotationButtonType == CoinQuotationButtonType_OneMinKLine){
               currentKLineType = PCQuotationKLineTypeMin5;
           }else if(quotationButtonType == CoinQuotationButtonType_DayKLine){
               currentKLineType = PCQuotationKLineTypeDay;
           }else if(quotationButtonType == CoinQuotationButtonType_WeekKLine){
               currentKLineType = PCQuotationKLineTypeWeek;
           }
        if([klineType isEqualToString:currentKLineType]){
            [self.quotationView kLineViewReloadData:dataDic];
        }
    }
}

- (void)reqKlineFailed:(NSDictionary *)json{
    [QMUITips showError:NSLocalizedStringForKey(@"请求失败")];
}

//- (void)refreshQuotationsDataForTimer
//{
//    if(checkIsStringWithAnyText(_symbol)){
//        [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationRealWithSymbol:_symbol depth:TradeDataCellTotalGearCount] withTag:QuotationSocketRealTimeDataTag];
//    }
//}

///** 请求历史行情数据*/
//- (void)refreshQuotationHistoryData
//{
//    [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationShareTimeWithSymbol:_symbol pageSize:ShareTimeDataCount] withTag:QuotationSocketShareTimeHistoryTag];
//}
//
///** 请求K线数据*/
//- (void)refreshQuotationKLineDataWithTimestamp:(NSString *)timestamp
//{
//    if(quotationButtonType == CoinQuotationButtonType_FifteenKLine){
//        [self showProgressDefaultText];
//        [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationKLineFifteenMinutesWithSymbol:_symbol timestamp:timestamp type:@"v"] withTag:QuotationSocketFifteenMinutesTag];
//    }else if(quotationButtonType == CoinQuotationButtonType_OneHourKLine){
//        [self showProgressDefaultText];
//        [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationKLineOneHourWithSymbol:_symbol timestamp:timestamp type:@"v"] withTag:QuotationSocketOneHourTag];
//    }else if(quotationButtonType == CoinQuotationButtonType_DayKLine){
//        [self showProgressDefaultText];
//        [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationKLineOneDayWithSymbol:_symbol timestamp:timestamp type:@"v"] withTag:QuotationSocketOneDayTag];
//    }else if(quotationButtonType == CoinQuotationButtonType_WeekKLine){
//        [self showProgressDefaultText];
//        [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationKLineWeekWithSymbol:_symbol timestamp:timestamp type:@"v"] withTag:QuotationSocketOneWeekTag];
//    }else if(quotationButtonType == CoinQuotationButtonType_FourHourKLine){
//        [self showProgressDefaultText];
//        [[QuotationSocket shareQuotationSocket] sendMsgToServer:[QuotationSocketManager sendCoinQuotationKLineFourHourWithSymbol:_symbol timestamp:timestamp type:@"v"] withTag:QuotationSocketOneWeekTag];
//    }
//
//}

///** 行情数据回调*/
//- (void)socketDidReadDataWithNotification:(NSNotification *)notification
//{
//    [self dismissProgress];
//    NSDictionary *infoDic = notification.userInfo;
//    NSDictionary *json = [infoDic objectForKey:MHSocketJsonKey];
//    QuotationSocketTag tag = (QuotationSocketTag)[[infoDic objectForKey:MHSocketTagKey] longValue];
//    switch (tag) {
//        case QuotationSocketRealTimeDataTag:                //实时数据
//        {
//            
//            
//            NSDictionary *quoteDic = [json objectForKey:_symbol];
//            NSArray *buysArr = [quoteDic objectForKey:@"buys"];
//            NSArray *sellsArr = [quoteDic objectForKey:@"sells"];
//            NSArray *dealArr = [quoteDic objectForKey:@"dealList"];
//            [buysGearData removeAllObjects];
//            if([buysArr isKindOfClass:[NSArray class]]){
//                for(NSDictionary *buyDic in buysArr){
//                    CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:buyDic] autorelease];
//                    [buysGearData addObject:gearEntity];
//                }
//            }
//            [sellsGearData removeAllObjects];
//            if([sellsArr isKindOfClass:[NSArray class]]){
//                for(NSDictionary *sellDic in sellsArr){
//                    CoinTradeGearEntity *gearEntity = [[[CoinTradeGearEntity alloc] initWithJson:sellDic] autorelease];
//                    [sellsGearData addObject:gearEntity];
//                }
//            }
//            [dealDataArr removeAllObjects];
//            if([dealArr isKindOfClass:[NSArray class]]){
//                for(NSDictionary *dealDic in dealArr){
//                    PCQuotationDealModel *dealEntity = [[[PCQuotationDealModel alloc] initWithJson:dealDic] autorelease];
//                    [dealDataArr addObject:dealEntity];
//                }
//            }
//            CoinQuotationDataEntity *dataEntity = [[[CoinQuotationDataEntity alloc] initWithJson:quoteDic] autorelease];        //展示头部行情数据对象
//            [self.quotationView reloadQuotationData:dataEntity];
//            [gearVC reloadControllerWithBuyDataArr:buysGearData sellDataArr:sellsGearData];
//            [dealVC reloadDealData:dealDataArr];
//            
//            NSDictionary *minDic = [json objectForKey:[NSString stringWithFormat:@"min_%@",_symbol]];
//            CoinQuotationDataEntity *currentDataEntity = [[[CoinQuotationDataEntity alloc] initWithJson:minDic] autorelease];   //分时图当时数据
//            //获取分时行情历史数据
//            if([self.quotationView isShareTimeViewHasHistory]){         //有历史数据
//                [self.quotationView shareTimeViewAddOneQuotationData:currentDataEntity];
//            }else{
//                [self refreshQuotationHistoryData];
//            }
//        }
//            break;
//        case QuotationSocketShareTimeHistoryTag:
//        {
//            NSString *historyKey = [NSString stringWithFormat:@"min_%@", self.symbol];
//            if ([json.allKeys containsObject:historyKey]) {
//                NSString *content = json[historyKey];
//                [self.quotationView shareTimeViewAddHistoryData:content];
//            }
//        }
//            break;
//        case QuotationSocketFifteenMinutesTag:
//        case QuotationSocketOneHourTag:
//        case QuotationSocketFourHourTag:
//        case QuotationSocketOneDayTag:
//        case QuotationSocketOneWeekTag:
//            
//            [self.quotationView kLineViewReloadData:json];
//            break;
//            
//        default:
//            break;
//    }
//}


- (void)reqCoinIsFollow
{
    [[NetWorkManage shareSingleNetWork] reqCoinIsFollow:self symbol:self.symbol finishedCallback:@selector(reqCoinIsFollowFinished:) failedCallback:@selector(reqCoinIsFollowFailed:)];
}

- (void)reqCoinIsFollowFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        isReqOptionalFinished = YES;
        TJRBaseEntity *jsonParser = [[[TJRBaseEntity alloc] init] autorelease];
        NSDictionary *dataDic = [json objectForKey:@"data"];
        isOptional = [jsonParser boolParser:@"isOptional" json:dataDic];
        if(isOptional){ //已添加自选股
            _followSymbolButton.selected = YES;
        }else{//未添加自选股
            _followSymbolButton.selected = NO;
        }
    }
}

- (void)reqCoinIsFollowFailed:(NSDictionary *)json
{
}

/** 添加自选 */
- (void)reqAddCoinFollow
{
    [[NetWorkManage shareSingleNetWork] reqAddCoinFollow:self symbol:_symbol finishedCallback:@selector(reqAddCoinFollowFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqAddCoinFollowFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = @"添加成功";
        }
        [self showToastCenter:msg];
        _followSymbolButton.selected = YES;
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 删除自选 */
- (void)reqCancelCoinFolllow
{
    [[NetWorkManage shareSingleNetWork] reqCancelCoinFollow:self symbol:_symbol finishedCallback:@selector(reqCancelCoinFolllowFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCancelCoinFolllowFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"Deleted Successfully");
        }
        [self showToastCenter:msg];
        _followSymbolButton.selected = NO;
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}



#pragma mark - 开启关闭定时器
- (void)startQuotationsTimer
{
    [self closeQuotationsTimer];
    quotationRequestTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getMainData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:quotationRequestTimer forMode:NSRunLoopCommonModes];
}

- (void)getMainData{
    [self reqQuotationRealData];
    [self reqQuotationKLineData:@"0"];
}

- (void)closeQuotationsTimer
{
    if(quotationRequestTimer && [quotationRequestTimer isValid]){
        [quotationRequestTimer invalidate];
        quotationRequestTimer = nil;
    }
}

#pragma mark - CoinQuotationDataView delegate
- (void)coinQuotationDataViewQuotationTypeDidChanged:(CoinQuotationButtonType)type dataType:(NSInteger)dataType
{
    quotationButtonType = type;
    self.dataType = dataType;
    if(type == CoinQuotationButtonType_ShareTime){
        [self.quotationView setShareTimeViewHasHistory:NO];         //重新获取历史数据
        [self reqShareTimeHistoryData];
    }else if(type == CoinQuotationButtonType_FiveDaysShareTime){
        [self req5DayShareTimeData];
    }else{
        [self reqQuotationKLineData:@"0"];
    }
}

- (void)coinQuotationDataViewKLineNeedMoreData:(NSString *)timestamp
{
    [self reqQuotationKLineData:timestamp];
}


#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index
{
    id baseVC = pageViewController.controllersM[index];
    if([baseVC isKindOfClass:[TYCoinQuotationsSegmentGearController class]]){
        TYCoinQuotationsSegmentGearController *vc = baseVC;
        return [vc gearTableView];
    }else if([baseVC isKindOfClass:[TYCoinQuotationSegmentDealController class]]){
        TYCoinQuotationSegmentDealController *vc = baseVC;
        return [vc dealTableView];
    }
    return nil;
}

#pragma mark - YNPageViewControllerDelegate
- (void)pageViewController:(YNPageViewController *)pageViewController contentOffsetY:(CGFloat)contentOffset progress:(CGFloat)progress
{
    
}


@end
