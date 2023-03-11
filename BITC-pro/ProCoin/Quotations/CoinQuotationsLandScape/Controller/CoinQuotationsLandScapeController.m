//
//  CoinQuotationsLandScapeController.m
//  Cropyme
//
//  Created by Hay on 2019/9/3.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinQuotationsLandScapeController.h"
#import "CMShareTimeView.h"
#import "CoinQuotationDataView.h"
#import "QuotationUtil.h"
#import "KLineViewAndNetData.h"
#import "VeDateUtil.h"
#import "TradeUtil.h"
#import "QuotationSocket.h"
#import "NetWorkManage+Quotation.h"
#import "CMStockFuturesShareTimeView.h"
#import "CMFiveDayShareTimeView.h"

@interface CoinQuotationsLandScapeController ()<KLineViewDelegate,KLineViewAndNetDataDelegate>
{
    CoinQuotationButtonType buttonType;
    NSInteger priceDecimalsDot;         //价格小数位数
    NSTimer *quotationRequestTimer;
    BOOL isSpecialShareTimeView;            //是否特殊分时图行情，股指期货的跟数字货币的不一样，所以为特殊分时行情
}

@property (copy, nonatomic) NSString *symbol;

/** UI*/
@property (retain, nonatomic) IBOutlet UIImageView *huobiLogo;              //火币logo
@property (retain, nonatomic) IBOutlet UIImageView *indicatorImageView;     //指示器
@property (retain, nonatomic) IBOutlet UIButton *shareTimeButton;           //分时按钮
@property (retain, nonatomic) IBOutlet UIButton *fiveDaysShareTimeButton;   //5日分时按钮
@property (retain, nonatomic) IBOutlet UIButton *fifteenMinutesButton;      //15分钟按钮
@property (retain, nonatomic) IBOutlet UIButton *oneHourButton;             //1小时按钮
@property (retain, nonatomic) IBOutlet UIButton *oneMinButton;            //1分钟按钮
@property (retain, nonatomic) IBOutlet UIButton *oneDayButton;              //日k按钮
@property (retain, nonatomic) IBOutlet UIButton *oneWeekButton;             //周k按钮
@property (retain, nonatomic) IBOutlet CMShareTimeView *shareTimeView;      //分时图
@property (retain, nonatomic) IBOutlet CMStockFuturesShareTimeView *stockFuturesShareTimeView;  //股指期货行情
@property (retain, nonatomic) IBOutlet CMFiveDayShareTimeView *fiveDaysShareTimeView;           //5日分时
@property (retain, nonatomic) IBOutlet UIView *kLineView;                   //k线图
@property (retain, nonatomic) IBOutlet KLineViewAndNetData *kLineChartView; //k线画图
@property (retain, nonatomic) IBOutlet UILabel *ma5Label;
@property (retain, nonatomic) IBOutlet UILabel *ma10Label;
@property (retain, nonatomic) IBOutlet UILabel *ma20Label;

@property (retain, nonatomic) IBOutlet UILabel *currencyLabel;
@property (retain, nonatomic) IBOutlet UILabel *openMarketStrLabel;
@property (retain, nonatomic) IBOutlet UILabel *symbolLabel;
@property (retain, nonatomic) IBOutlet UILabel *lastPriceLabel;         //最新价
@property (retain, nonatomic) IBOutlet UILabel *lastPriceCNYLabel;      //最新价描述
@property (retain, nonatomic) IBOutlet UILabel *rateLabel;              //涨跌
@property (retain, nonatomic) IBOutlet UILabel *highPriceLabel;         //最高价
@property (retain, nonatomic) IBOutlet UILabel *lowPriceLabel;          //最低价
@property (retain, nonatomic) IBOutlet UILabel *tolAmountLabel;         //24H成交量




@end

@implementation CoinQuotationsLandScapeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    buttonType = CoinQuotationButtonType_ShareTime;
    priceDecimalsDot = 0;
    _kLineChartView.delegate = self;
    _kLineChartView.kLineDelegate = self;
    _kLineChartView.canRightPullAddMore = YES;
    _shareTimeView.hidden = YES;
    _stockFuturesShareTimeView.hidden = YES;
    isSpecialShareTimeView = NO;
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CoinQuotationsLandScapeSymbol"]){
        self.symbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CoinQuotationsLandScapeSymbol"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"CoinQuotationsLandScapeSymbol"];
    }
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CoinQuotationsLandScapeMarketType"]){
        NSString *marketType = [NSString stringWithFormat:@"%@",[self getValueFromModelDictionary:ProCoinBaseDict forKey:@"CoinQuotationsLandScapeMarketType"]];
        if([marketType isEqualToString:PCAccountStockType]){
            isSpecialShareTimeView = NO;    /// 股指改为和数字货币一致
        }
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"CoinQuotationsLandScapeMarketType"];
    }
    
    CoinQuotationButtonType cacheButtonType = (CoinQuotationButtonType)[[[NSUserDefaults standardUserDefaults] objectForKey:QuotationDetailButtonOptionsKey] integerValue];
    buttonType = cacheButtonType;
    CGRect frame = self.indicatorImageView.frame;
    if(buttonType == CoinQuotationButtonType_ShareTime){
        if(isSpecialShareTimeView){
            _stockFuturesShareTimeView.hidden = NO;
        }else{
            _shareTimeView.hidden = NO;
        }
        _fiveDaysShareTimeView.hidden = YES;
        _kLineView.hidden = YES;
        _shareTimeButton.selected = YES;
        frame.origin.x = _shareTimeButton.frame.origin.x;
    }else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
        if(isSpecialShareTimeView){
            _stockFuturesShareTimeView.hidden = YES;
        }else{
            _shareTimeView.hidden = YES;
        }
        _fiveDaysShareTimeView.hidden = NO;
        _kLineView.hidden = YES;
        _fiveDaysShareTimeButton.selected = YES;
        frame.origin.x = _fiveDaysShareTimeButton.frame.origin.x;
    }else{
        if(isSpecialShareTimeView){
            _stockFuturesShareTimeView.hidden = YES;
        }else{
            _shareTimeView.hidden = YES;
        }
        _fiveDaysShareTimeView.hidden = YES;
        _kLineView.hidden = NO;
        if(buttonType == CoinQuotationButtonType_FifteenKLine){
            _fifteenMinutesButton.selected = YES;
            frame.origin.x = _fifteenMinutesButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_OneHourKLine){
            _oneHourButton.selected = YES;
            frame.origin.x = _oneHourButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_OneMinKLine){
            _oneMinButton.selected = YES;
            frame.origin.x = _oneMinButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_DayKLine){
            _oneDayButton.selected = YES;
            frame.origin.x = _oneDayButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_WeekKLine){
            _oneWeekButton.selected = YES;
            frame.origin.x = _oneWeekButton.frame.origin.x;
        }
    }
    _indicatorImageView.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDidConnectedToServer:self selector:@selector(socketDidConnectedToServer)];
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDisconnectedToServer:self selector:@selector(socketDidDisconnected)];

    if(buttonType == CoinQuotationButtonType_ShareTime){
        if(isSpecialShareTimeView){
            self.stockFuturesShareTimeView.isHasHitory = NO;
        }else{
            self.shareTimeView.isHasHitory = NO;         //重新获取历史数据
        }
        
        [self reqShareTimeHistoryData];
    }
//    else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
//        [self req5DayShareTimeData];
//    }
    else{
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

- (void)dealloc
{
    [_currencyLabel release];
    [_openMarketStrLabel release];
    [_symbol release];
    [_indicatorImageView release];
    [_shareTimeButton release];
    [_oneHourButton release];
    [_oneDayButton release];
    [_oneWeekButton release];
    [_shareTimeView release];
    [_kLineView release];
    [_kLineChartView release];
    [_ma5Label release];
    [_ma10Label release];
    [_ma20Label release];
    [_lastPriceLabel release];
    [_lastPriceCNYLabel release];
    [_rateLabel release];
    [_highPriceLabel release];
    [_lowPriceLabel release];
    [_tolAmountLabel release];
    [_symbolLabel release];
    [_oneMinButton release];
    [_huobiLogo release];
    [_fifteenMinutesButton release];
    [_stockFuturesShareTimeView release];
    [_fiveDaysShareTimeView release];
    [_fiveDaysShareTimeButton release];
    [super dealloc];
}

#pragma mark - 按钮点击事件

- (IBAction)closeControllerButtonPressed:(id)sender
{
    [self dismissModalLandscapeViewController];
    [self rotationNavigationControllerToNormal];
}

- (IBAction)quotationTypeButtonPressed:(id)sender
{
    if(!checkIsStringWithAnyText(_symbol)){         //不存在symbol，不让点击
        return;
    }
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.isSelected){
        return;
    }
    targetButton.selected = !targetButton.isSelected;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.indicatorImageView.frame;
        frame.origin.x = targetButton.frame.origin.x;
        _indicatorImageView.frame = frame;
    }];
    if(targetButton == _shareTimeButton){
        if(isSpecialShareTimeView){
            _stockFuturesShareTimeView.hidden = NO;
        }else{
            _shareTimeView.hidden = NO;
        }
        _fiveDaysShareTimeView.hidden = YES;
        _kLineView.hidden = YES;
        _fiveDaysShareTimeButton.selected = NO;
        _fifteenMinutesButton.selected = NO;
        _oneHourButton.selected = NO;
        _oneMinButton.selected = NO;
        _oneDayButton.selected = NO;
        _oneWeekButton.selected = NO;
        buttonType = CoinQuotationButtonType_ShareTime;
    }else if(targetButton == _fiveDaysShareTimeButton){
        if(isSpecialShareTimeView){
            _stockFuturesShareTimeView.hidden = YES;
        }else{
            _shareTimeView.hidden = YES;
        }
        _fiveDaysShareTimeView.hidden = NO;
        _kLineView.hidden = YES;
        
        _shareTimeButton.selected = NO;
        _fifteenMinutesButton.selected = NO;
        _oneHourButton.selected = NO;
        _oneMinButton.selected = NO;
        _oneDayButton.selected = NO;
        _oneWeekButton.selected = NO;
        
        buttonType = CoinQuotationButtonType_FiveDaysShareTime;
    }else{
        if(isSpecialShareTimeView){
            _stockFuturesShareTimeView.hidden = YES;
        }else{
            _shareTimeView.hidden = YES;
        }
        _fiveDaysShareTimeView.hidden = YES;
        _kLineView.hidden = NO;
        _shareTimeButton.selected = NO;
        _fiveDaysShareTimeButton.selected = NO;
        [_kLineChartView cleanDraw];
        if(targetButton == _fifteenMinutesButton){
            _oneHourButton.selected = NO;
            _oneMinButton.selected = NO;
            _oneDayButton.selected = NO;
            _oneWeekButton.selected = NO;
            buttonType = CoinQuotationButtonType_FifteenKLine;
        }else if(targetButton == _oneHourButton){
            _fifteenMinutesButton.selected = NO;
            _oneMinButton.selected = NO;
            _oneDayButton.selected = NO;
            _oneWeekButton.selected = NO;
            buttonType = CoinQuotationButtonType_OneHourKLine;
        }else if(targetButton == _oneMinButton){
            _fifteenMinutesButton.selected = NO;
            _oneHourButton.selected = NO;
            _oneDayButton.selected = NO;
            _oneWeekButton.selected = NO;
            buttonType = CoinQuotationButtonType_OneMinKLine;
        }else if(targetButton == _oneDayButton){
            _fifteenMinutesButton.selected = NO;
            _oneHourButton.selected = NO;
            _oneMinButton.selected = NO;
            _oneWeekButton.selected = NO;
            buttonType = CoinQuotationButtonType_DayKLine;
        }else{
            _fifteenMinutesButton.selected = NO;
            _oneHourButton.selected = NO;
            _oneMinButton.selected = NO;
            _oneDayButton.selected = NO;
            buttonType = CoinQuotationButtonType_WeekKLine;
        }
    }
    _ma5Label.text = @"---";
    _ma10Label.text = @"---";
    _ma20Label.text = @"---";
    
    if(buttonType == CoinQuotationButtonType_ShareTime){
        if(isSpecialShareTimeView){
            self.stockFuturesShareTimeView.isHasHitory = NO;
        }else{
           self.shareTimeView.isHasHitory = NO;         //重新获取历史数据
        }
        
        [self reqShareTimeHistoryData];
    }
//    else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
//        [self req5DayShareTimeData];
//    }
    else{
        [self reqQuotationKLineData:@"0"];
    }

}

#pragma mark - socket
- (void)socketDidConnectedToServer
{
    if(buttonType == CoinQuotationButtonType_ShareTime){
        if(isSpecialShareTimeView){
            self.stockFuturesShareTimeView.isHasHitory = NO;
        }else{
            self.shareTimeView.isHasHitory =  NO;         //重新获取历史数据
        }
        
        [self reqShareTimeHistoryData];
    }
//    else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
//        [self req5DayShareTimeData];
//    }
    else{
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
        NSString *historyKey = [NSString stringWithFormat:@"min_%@", self.symbol];
        NSDictionary *quoteDic = [dataDic objectForKey:_symbol];
        TJRBaseEntity *basePraser = [[[TJRBaseEntity alloc] init] autorelease];
        NSString *yesterdayClose = [NSString stringWithFormat:@"%@",[basePraser stringParser:@"yesClose" json:quoteDic]];
        if ([dataDic.allKeys containsObject:historyKey]) {
            NSString *content = dataDic[historyKey];
            if(isSpecialShareTimeView){
                [self.stockFuturesShareTimeView addShareTimeViewHistoryData:content yesterdayClose:yesterdayClose];
            }else{
                [self.shareTimeView addShareTimeViewHistoryData:content];
            }
            
        }
        [self reqQuotationRealData];
        [self reqQuotationKLineData:@"0"];
    }
}

/** 5日分时*/
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
            [self.fiveDaysShareTimeView addFiveDayShareTimeViewHistoryData:content];
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
    if(buttonType == CoinQuotationButtonType_ShareTime){
        kLineType = PCQuotationKLineTypeShareTime;
    }else if(buttonType == CoinQuotationButtonType_FifteenKLine){
           kLineType = PCQuotationKLineTypeMin15;
    }else if(buttonType == CoinQuotationButtonType_OneHourKLine){
        kLineType = PCQuotationKLineTypeHour1;
    }else if(buttonType == CoinQuotationButtonType_OneMinKLine){
        kLineType = PCQuotationKLineTypeMin1;
    }else if(buttonType == CoinQuotationButtonType_DayKLine){
        kLineType = PCQuotationKLineTypeDay;
    }else if(buttonType == CoinQuotationButtonType_WeekKLine){
        kLineType = PCQuotationKLineTypeWeek;
    }
    [[NetWorkManage shareSingleNetWork] reqQuotationRealData:self symbol:_symbol depth:[NSString stringWithFormat:@"%@",@(0)] klineType:kLineType finishedCallback:@selector(reqQuotationRealDataFinished:) failedCallback:nil];
}

- (void)reqQuotationRealDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *quoteDic = [dataDic objectForKey:_symbol];
        CoinQuotationDataEntity *dataEntity = [[[CoinQuotationDataEntity alloc] initWithJson:quoteDic] autorelease];        //展示头部行情数据对象
        priceDecimalsDot = dataEntity.priceDecimals;
        [self reloadQuotationBaseData:dataEntity];

        NSString *klineType = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"klineType"]];
        NSDictionary *minDic = [dataDic objectForKey:@"lastKline"];
        CoinQuotationDataEntity *currentDataEntity = [[[CoinQuotationDataEntity alloc] initWithJson:minDic] autorelease];   //分时图当时数据
        //获取分时行情历史数据
        if([klineType isEqualToString:PCQuotationKLineTypeShareTime]){      //行情的分时并且点击的tag还是分时的时候才操作，否则舍弃
            if(buttonType == CoinQuotationButtonType_ShareTime){
                if(isSpecialShareTimeView){
                    if(self.stockFuturesShareTimeView.isHasHitory){
                        [self.stockFuturesShareTimeView addOneShareTimeViewData:currentDataEntity];
                    }
                }else{
                    if(self.shareTimeView.isHasHitory){         //有历史数据
                        [self.shareTimeView addOneShareTimeViewData:currentDataEntity];
                    }
                }
                
            }
        }else{              //属于k线的实时快照
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
//               }
//            if([klineType isEqualToString:currentKLineType]){
//                [self.quotationView kLineViewAddData:currentDataEntity];
//            }
        }
        
    }
}

/** 请求K线数据*/
- (void)reqQuotationKLineData:(NSString *)timestamp
{
    NSString *kLineType = @"";
    if(buttonType == CoinQuotationButtonType_FifteenKLine){
        kLineType = PCQuotationKLineTypeMin15;
    }else if(buttonType == CoinQuotationButtonType_OneHourKLine){
        kLineType = PCQuotationKLineTypeHour1;
    }else if(buttonType == CoinQuotationButtonType_OneMinKLine){
        kLineType = PCQuotationKLineTypeMin1;
    }else if(buttonType == CoinQuotationButtonType_DayKLine){
        kLineType = PCQuotationKLineTypeDay;
    }else if(buttonType == CoinQuotationButtonType_WeekKLine){
        kLineType = PCQuotationKLineTypeWeek;
    }else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
        kLineType = PCQuotationKLineTypeMin5;
    }
    
    if(checkIsStringWithAnyText(kLineType)){
        [[NetWorkManage shareSingleNetWork] reqQuotationKLineData:self symbol:_symbol timestamp:timestamp pageSize:@"" kLineType:kLineType type:@"v" finishedCallback:@selector(reqQuotationKLineDataFinished:) failedCallback:nil];
    }
}

- (void)reqQuotationKLineDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *klineType = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"klineType"]];
        NSString *currentKLineType = @"";               //当前选项更新的数据
        if(buttonType == CoinQuotationButtonType_FifteenKLine){
            currentKLineType = PCQuotationKLineTypeMin15;
        }else if(buttonType == CoinQuotationButtonType_OneHourKLine){
            currentKLineType = PCQuotationKLineTypeHour1;
        }else if(buttonType == CoinQuotationButtonType_OneMinKLine){
            currentKLineType = PCQuotationKLineTypeMin1;
        }else if(buttonType == CoinQuotationButtonType_DayKLine){
            currentKLineType = PCQuotationKLineTypeDay;
        }else if(buttonType == CoinQuotationButtonType_WeekKLine){
            currentKLineType = PCQuotationKLineTypeWeek;
        }else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
            currentKLineType = PCQuotationKLineTypeMin5;
        }
        
        if([klineType isEqualToString:currentKLineType]){
            if([currentKLineType isEqualToString:PCQuotationKLineTypeMin15]){
                [self.kLineChartView reloadKLineData:dataDic kLineType:KLineData15Minute];
            }else if([currentKLineType isEqualToString:PCQuotationKLineTypeHour1]){
                [self.kLineChartView reloadKLineData:dataDic kLineType:KLineData60Minute];
            }else if([currentKLineType isEqualToString:PCQuotationKLineTypeMin1]){
                [self.kLineChartView reloadKLineData:dataDic kLineType:KLineData1Minute];
            }else if([currentKLineType isEqualToString:PCQuotationKLineTypeDay]){
                [self.kLineChartView reloadKLineData:dataDic kLineType:KLineDataDay];
            }else if([currentKLineType isEqualToString:PCQuotationKLineTypeWeek]){
                [self.kLineChartView reloadKLineData:dataDic kLineType:KLineDataWeek];
            }else if([currentKLineType isEqualToString:PCQuotationKLineTypeMin5]){
                [self.kLineChartView reloadKLineData:dataDic kLineType:KLineData5Minute];
            }
        }
    }
}

#pragma mark - 顶部数据
- (void)reloadQuotationBaseData:(CoinQuotationDataEntity *)dataEntity
{
    if(checkIsStringWithAnyText(dataEntity.tip)){
        _huobiLogo.hidden = NO;
    }else{
        _huobiLogo.hidden = YES;
    }
    _openMarketStrLabel.hidden = !TTIsStringWithAnyText(dataEntity.openMarketStr);
    _openMarketStrLabel.text = [NSString stringWithFormat:@" %@ ",dataEntity.openMarketStr];
    _currencyLabel.text = dataEntity.currency;
    _symbolLabel.text = self.symbol;
    _lastPriceLabel.text = dataEntity.last;
    _lastPriceLabel.textColor = [TradeUtil textColorWithQuotationNumber:[dataEntity.rate doubleValue]];
    _lastPriceCNYLabel.text = dataEntity.amt;
    _rateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:dataEntity.rate]];
    _rateLabel.textColor = [TradeUtil textColorWithQuotationNumber:[dataEntity.rate doubleValue]];
    _highPriceLabel.text = dataEntity.highString;
    _lowPriceLabel.text = dataEntity.lowString;
    _tolAmountLabel.text = dataEntity.amountString;
}





/** NewKLineView delegate*/
- (void)kLineShowData:(KLine *)kLine VolumeType:(NSInteger)type isEnd:(BOOL)isEnd
{
    _ma5Label.text = [NSString stringWithFormat:@"MA5：%@",[TradeUtil stringRoundDownFloatValue:kLine.m5 dotBits:priceDecimalsDot]];
    _ma10Label.text = [NSString stringWithFormat:@"MA10：%@",[TradeUtil stringRoundDownFloatValue:kLine.m10 dotBits:priceDecimalsDot]];
    _ma20Label.text = [NSString stringWithFormat:@"MA30：%@",[TradeUtil stringRoundDownFloatValue:kLine.m30 dotBits:priceDecimalsDot]];
    
}

#pragma mark - 开启关闭定时器
- (void)startQuotationsTimer
{
    [self closeQuotationsTimer];
    quotationRequestTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(reqQuotationRealData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:quotationRequestTimer forMode:NSRunLoopCommonModes];
}

- (void)closeQuotationsTimer
{
    if(quotationRequestTimer && [quotationRequestTimer isValid]){
        [quotationRequestTimer invalidate];
        quotationRequestTimer = nil;
    }
}

#pragma mark - Kline delegate
- (void)kLineViewNeedLoadMoreData:(NSString *)timestamp
{
    [self reqQuotationKLineData:timestamp];
}

@end
