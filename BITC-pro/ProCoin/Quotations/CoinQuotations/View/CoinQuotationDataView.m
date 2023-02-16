//
//  CoinQuotationDataView.m
//  Cropyme
//
//  Created by Hay on 2019/6/25.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CoinQuotationDataView.h"
#import "CMShareTimeView.h"
#import "KLineViewAndNetData.h"
#import "TradeUtil.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"
#import "CMStockFuturesShareTimeView.h"
#import "CMFiveDayShareTimeView.h"

@interface CoinQuotationDataView()<KLineViewDelegate,KLineViewAndNetDataDelegate>
{
    CoinQuotationButtonType buttonType;        //按钮类型
    NSInteger priceDecimalsDot;         //价格小数位数
}

@property (copy, nonatomic) NSString *symbol;

@property (retain, nonatomic) IBOutlet UIImageView *huobiLogo;              //货币logo
@property (retain, nonatomic) IBOutlet UILabel *currencyLabel;
@property (retain, nonatomic) IBOutlet UILabel *lastPriceLabel;             //最新价
@property (retain, nonatomic) IBOutlet UILabel *openMarketStrLabel;
@property (retain, nonatomic) IBOutlet UILabel *lastPriceCNYLabel;          //最新价描述
@property (retain, nonatomic) IBOutlet UILabel *rateLabel;                  //涨跌
@property (retain, nonatomic) IBOutlet UILabel *highPriceLabel;             //最高价
@property (retain, nonatomic) IBOutlet UILabel *lowPriceLabel;              //最低价
@property (retain, nonatomic) IBOutlet UILabel *tolAmountLabel;             //24H成交量
@property (retain, nonatomic) IBOutlet UIButton *shareTimeButton;           //分时按钮
@property (retain, nonatomic) IBOutlet CMFiveDayShareTimeView *fiveDayShareTimeView;    //5日分时图
@property (retain, nonatomic) IBOutlet UIButton *fiveDaysShareTimeButton;   //5日分时
@property (retain, nonatomic) IBOutlet UIButton *fifteenMinutesKLineButton; //15分钟K线
@property (retain, nonatomic) IBOutlet UIButton *oneHourKLineButton;        //1小时K线
@property (retain, nonatomic) IBOutlet UIButton *oneMinKLineButton;       //1分钟K线
@property (retain, nonatomic) IBOutlet UIButton *dayKLineButton;            //日K按钮
@property (retain, nonatomic) IBOutlet UIButton *weekKLineButton;           //周K按钮
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *indicateIVLayoutConstraintLeading;       //指示图片的leading layout
@property (retain, nonatomic) IBOutlet CMShareTimeView *shareTimeView;            //分时图
@property (retain, nonatomic) IBOutlet CMStockFuturesShareTimeView *stockFuturesShareTimeView;      //股指期货特殊分时图
/** K Line*/
@property (retain, nonatomic) IBOutlet UIView *kLineSuperView;
@property (retain, nonatomic) IBOutlet KLineViewAndNetData *kLineView;      //K线图
@property (retain, nonatomic) IBOutlet UILabel *ma5Label;
@property (retain, nonatomic) IBOutlet UILabel *ma10Label;
@property (retain, nonatomic) IBOutlet UILabel *ma20Label;


@end

@implementation CoinQuotationDataView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initCoinQuotationDataView];
}

- (void)initCoinQuotationDataView
{
    self.isStockFuturesShareTime = NO;
    _kLineView.delegate = self;
    _kLineView.kLineDelegate = self;
    _kLineView.canRightPullAddMore = YES;
    priceDecimalsDot = 0;
    buttonType = (CoinQuotationButtonType)[[[NSUserDefaults standardUserDefaults] objectForKey:QuotationDetailButtonOptionsKey] integerValue];      //缓存值
    if(buttonType == CoinQuotationButtonType_ShareTime){
        _shareTimeView.hidden = NO;
        _stockFuturesShareTimeView.hidden = NO;
        _fiveDayShareTimeView.hidden = YES;
        _kLineSuperView.hidden = YES;
        _shareTimeButton.selected = YES;
        _indicateIVLayoutConstraintLeading.constant = _shareTimeButton.frame.origin.x;
    }
//    else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
//        _shareTimeView.hidden = YES;
//        _stockFuturesShareTimeView.hidden = YES;
//        _fiveDayShareTimeView.hidden = NO;
//        _kLineSuperView.hidden = YES;
//
//        _fiveDaysShareTimeButton.selected = YES;
//        _indicateIVLayoutConstraintLeading.constant = _fiveDaysShareTimeButton.frame.origin.x;
//    }
    else{
        _shareTimeView.hidden = YES;
        _stockFuturesShareTimeView.hidden = YES;
        _fiveDayShareTimeView.hidden = YES;
        _kLineSuperView.hidden = NO;
        
        if(buttonType == CoinQuotationButtonType_OneMinKLine){
            _oneMinKLineButton.selected = YES;
            _indicateIVLayoutConstraintLeading.constant = _oneMinKLineButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_FifteenKLine){
            _fifteenMinutesKLineButton.selected = YES;
            _indicateIVLayoutConstraintLeading.constant = _fifteenMinutesKLineButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_OneHourKLine){
            _oneHourKLineButton.selected = YES;
            _indicateIVLayoutConstraintLeading.constant = _oneHourKLineButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_DayKLine){
            _dayKLineButton.selected = YES;
            _indicateIVLayoutConstraintLeading.constant = _dayKLineButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_WeekKLine){
            _weekKLineButton.selected = YES;
            _indicateIVLayoutConstraintLeading.constant = _weekKLineButton.frame.origin.x;
        }else if(buttonType == CoinQuotationButtonType_FiveDaysShareTime){
            _fiveDaysShareTimeButton.selected = YES;
            _indicateIVLayoutConstraintLeading.constant = _fiveDaysShareTimeButton.frame.origin.x;
        }
    }
}

- (void)dealloc
{
    [_symbol release];
    [_lastPriceLabel release];
    [_lastPriceCNYLabel release];
    [_rateLabel release];
    [_shareTimeButton release];
    [_shareTimeView release];
    [_oneHourKLineButton release];
    [_kLineView release];
    [_dayKLineButton release];
    [_weekKLineButton release];
    [_indicateIVLayoutConstraintLeading release];
    [_ma5Label release];
    [_ma10Label release];
    [_ma20Label release];
    [_kLineSuperView release];
    [_highPriceLabel release];
    [_lowPriceLabel release];
    [_tolAmountLabel release];
    [_oneMinKLineButton release];
    [_huobiLogo release];
    [_fifteenMinutesKLineButton release];
    [_stockFuturesShareTimeView release];
    [_fiveDayShareTimeView release];
    [_fiveDaysShareTimeButton release];
    [_openMarketStrLabel release];
    [_currencyLabel release];
    [super dealloc];
}

- (void)setIsStockFuturesShareTime:(BOOL)isStockFuturesShareTime
{
    _isStockFuturesShareTime = isStockFuturesShareTime;
    if(_isStockFuturesShareTime){
        
        if(buttonType == CoinQuotationButtonType_ShareTime){
            _shareTimeView.hidden = YES;
            _stockFuturesShareTimeView.hidden = NO;
        }
        
    }else{
        if(buttonType == CoinQuotationButtonType_ShareTime){
            _shareTimeView.hidden = NO;
            _stockFuturesShareTimeView.hidden = YES;
        }
        
    }
}

- (void)reloadQuotationData:(CoinQuotationDataEntity *)dataEntity
{
    self.symbol = dataEntity.symbol;
    if(checkIsStringWithAnyText(dataEntity.tip)){
        _huobiLogo.hidden = NO;
    }else{
        _huobiLogo.hidden = YES;
    }
    priceDecimalsDot = dataEntity.priceDecimals;
    _lastPriceLabel.text = dataEntity.last;
    _lastPriceLabel.textColor = [TradeUtil textColorWithQuotationNumber:[dataEntity.rate doubleValue]];
    _rateLabel.textColor = [TradeUtil textColorWithQuotationNumber:[dataEntity.rate doubleValue]];;
    _lastPriceCNYLabel.textColor = [TradeUtil textColorWithQuotationNumber:[dataEntity.rate doubleValue]];
    _openMarketStrLabel.hidden = !TTIsStringWithAnyText(dataEntity.openMarketStr);
    _openMarketStrLabel.text = [NSString stringWithFormat:@" %@ ",dataEntity.openMarketStr];
    _currencyLabel.text = dataEntity.currency;
    _lastPriceCNYLabel.text = dataEntity.amt;
    _rateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:dataEntity.rate]];
    _highPriceLabel.text = dataEntity.highString;
    _lowPriceLabel.text = dataEntity.lowString;
    _tolAmountLabel.text = dataEntity.amountString;
}

- (void)setShareTimeViewHasHistory:(BOOL)hasHistory
{
    if(_isStockFuturesShareTime){
        _stockFuturesShareTimeView.isHasHitory = hasHistory;
    }else{
        _shareTimeView.isHasHitory = hasHistory;
    }
    
}

/** 分时是否有历史数据*/
- (BOOL)isShareTimeViewHasHistory
{
    if(_isStockFuturesShareTime){
        return _stockFuturesShareTimeView.isHasHitory;
    }else{
        return _shareTimeView.isHasHitory;
    }
    
}

/** 增加分时历史数据*/
- (void)shareTimeViewAddHistoryData:(NSString *)historyData yesterdayClose:(NSString *)yesterdayClose
{
    if(_isStockFuturesShareTime){
        if(!_stockFuturesShareTimeView.hidden){
            [_stockFuturesShareTimeView addShareTimeViewHistoryData:historyData yesterdayClose:yesterdayClose];
        }
    }else{
        if(!_shareTimeView.hidden){         //shareTimeView不隐藏的前提下才会对其操作
            [_shareTimeView addShareTimeViewHistoryData:historyData];
        }
    }
    
    
}

/** 增加一个分时数据*/
- (void)shareTimeViewAddOneQuotationData:(CoinQuotationDataEntity *)dataEntity
{
    if(_isStockFuturesShareTime){
        if(!_stockFuturesShareTimeView.hidden){
            [_stockFuturesShareTimeView addOneShareTimeViewData:dataEntity];
        }
    }else{
        if(!_shareTimeView.hidden){         //shareTimeView不隐藏的前提下才会对其操作
            [_shareTimeView addOneShareTimeViewData:dataEntity];
        }
    }
    
    
}

/** 增加5日分时数据*/
- (void)fiveDayShareTimeViewAddData:(NSString *)dataStr
{
    if(_fiveDayShareTimeView.hidden == NO){
        [_fiveDayShareTimeView addFiveDayShareTimeViewHistoryData:dataStr];
    }
}



#pragma mark - 按钮点击事件
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
        _indicateIVLayoutConstraintLeading.constant = targetButton.frame.origin.x;
        [self layoutIfNeeded];
    }];
    if(targetButton == _shareTimeButton){
        if(_isStockFuturesShareTime){
            _stockFuturesShareTimeView.hidden = NO;
        }else{
            _shareTimeView.hidden = NO;
        }
        _fiveDayShareTimeView.hidden = YES;
        _kLineSuperView.hidden = YES;
        _fiveDaysShareTimeButton.selected = NO;
        _fifteenMinutesKLineButton.selected = NO;
        _dayKLineButton.selected = NO;
        _weekKLineButton.selected = NO;
        _oneHourKLineButton.selected = NO;
        _oneMinKLineButton.selected = NO;
        buttonType = CoinQuotationButtonType_ShareTime;
    }
//    else if(targetButton == _fiveDaysShareTimeButton){
//        if(_isStockFuturesShareTime){
//            _stockFuturesShareTimeView.hidden = YES;
//        }else{
//            _shareTimeView.hidden = YES;
//        }
//        _fiveDayShareTimeView.hidden = NO;
//        _kLineSuperView.hidden = YES;
//
//        _shareTimeButton.selected = NO;
//        _fifteenMinutesKLineButton.selected = NO;
//        _dayKLineButton.selected = NO;
//        _weekKLineButton.selected = NO;
//        _oneHourKLineButton.selected = NO;
//        _oneMinKLineButton.selected = NO;
//        buttonType = CoinQuotationButtonType_FiveDaysShareTime;
//    }
    else{
        if(_isStockFuturesShareTime){
            _stockFuturesShareTimeView.hidden = YES;
        }else{
            _shareTimeView.hidden = YES;
        }
        _fiveDayShareTimeView.hidden = YES;
        _kLineSuperView.hidden = NO;
        
        _shareTimeButton.selected = NO;

        
        [_kLineView cleanDraw];
        if(targetButton == _fiveDaysShareTimeButton){
            _dayKLineButton.selected = NO;
            _weekKLineButton.selected = NO;
            _oneHourKLineButton.selected = NO;
            _oneMinKLineButton.selected = NO;
            _fifteenMinutesKLineButton.selected = NO;
            buttonType = CoinQuotationButtonType_FiveDaysShareTime;
        }else if(targetButton == _fifteenMinutesKLineButton){
            _dayKLineButton.selected = NO;
            _weekKLineButton.selected = NO;
            _oneHourKLineButton.selected = NO;
            _oneMinKLineButton.selected = NO;
            _fiveDaysShareTimeButton.selected = NO;
            buttonType = CoinQuotationButtonType_FifteenKLine;
        }else if(targetButton == _dayKLineButton){
            _weekKLineButton.selected = NO;
            _oneHourKLineButton.selected = NO;
            _oneMinKLineButton.selected = NO;
            _fifteenMinutesKLineButton.selected = NO;
            _fiveDaysShareTimeButton.selected = NO;
            buttonType = CoinQuotationButtonType_DayKLine;
        }else if(targetButton == _weekKLineButton){
            _dayKLineButton.selected = NO;
            _oneHourKLineButton.selected = NO;
            _oneMinKLineButton.selected = NO;
            _fifteenMinutesKLineButton.selected = NO;
            _fiveDaysShareTimeButton.selected = NO;
            buttonType = CoinQuotationButtonType_WeekKLine;
        }else if(targetButton == _oneHourKLineButton){
            _dayKLineButton.selected = NO;
            _weekKLineButton.selected = NO;
            _oneMinKLineButton.selected = NO;
            _fifteenMinutesKLineButton.selected = NO;
            _fiveDaysShareTimeButton.selected = NO;
            buttonType = CoinQuotationButtonType_OneHourKLine;
        }else{
            _dayKLineButton.selected = NO;
            _weekKLineButton.selected = NO;
            _oneHourKLineButton.selected = NO;
            _fifteenMinutesKLineButton.selected = NO;
            _fiveDaysShareTimeButton.selected = NO;
            buttonType = CoinQuotationButtonType_OneMinKLine;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:buttonType] forKey:QuotationDetailButtonOptionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _ma5Label.text = @"---";
    _ma10Label.text = @"---";
    _ma20Label.text = @"---";
    if([_delegate respondsToSelector:@selector(coinQuotationDataViewQuotationTypeDidChanged:)]){
        [_delegate coinQuotationDataViewQuotationTypeDidChanged:buttonType];
    }
}

#pragma mark - K线
/** 更新K线数据*/
- (void)kLineViewReloadData:(NSDictionary *)json
{
//    [_kLineView cleanDraw];
    if(_fifteenMinutesKLineButton.isSelected){
        [_kLineView reloadKLineData:json kLineType:KLineData15Minute];
    }else if(_dayKLineButton.isSelected){
        [_kLineView reloadKLineData:json kLineType:KLineDataDay];
    }else if(_weekKLineButton.isSelected){
        [_kLineView reloadKLineData:json kLineType:KLineDataWeek];
    }else if(_oneHourKLineButton.isSelected){
        [_kLineView reloadKLineData:json kLineType:KLineData60Minute];
    }else if(_fiveDaysShareTimeButton.isSelected){
        [_kLineView reloadKLineData:json kLineType:KLineData5Minute];
    }else{
        [_kLineView reloadKLineData:json kLineType:KLineData1Minute];
    }
    
}

//- (void)kLineViewAddData:(CoinQuotationDataEntity *)currentData
//{
//    if(_fifteenMinutesKLineButton.isSelected){
//        [_kLineView addKLineData:currentData kLineType:KLineData15Minute];
//    }else if(_dayKLineButton.isSelected){
//        [_kLineView addKLineData:currentData kLineType:KLineDataDay];
//    }else if(_weekKLineButton.isSelected){
//        [_kLineView addKLineData:currentData kLineType:KLineDataWeek];
//    }else if(_oneHourKLineButton.isSelected){
//        [_kLineView addKLineData:currentData kLineType:KLineData60Minute];
//    }else{
//        [_kLineView addKLineData:currentData kLineType:KLineData240Minute];
//    }
//}

#pragma mark - NewKLineView delegate
- (void)kLineShowData:(KLine *)kLine VolumeType:(NSInteger)type isEnd:(BOOL)isEnd
{
//    _kLineInfoView.hidden = isEnd;
//
//    _infoKLineTimeLabel.text = [NSString stringWithFormat:@"时间：%@",[VeDateUtil formatterDate:kLine.stocktime inStytle:@"yyyyMMddHHmm" outStytle:@"yyyy-MM-dd HH:mm"]];
//    _infoKLineOpenLabel.text = [NSString stringWithFormat:@"开：%@",[TradeUtil stringRoundDownFloatValue:kLine.todayopen dotBits:priceDecimalsDot]];
//    _infoKLineCloseLabel.text = [NSString stringWithFormat:@"收：%@",[TradeUtil stringRoundDownFloatValue:kLine.realprice dotBits:priceDecimalsDot]];
//    _infoKLineHighestLabel.text = [NSString stringWithFormat:@"高：%@",[TradeUtil stringRoundDownFloatValue:kLine.maximum dotBits:priceDecimalsDot]];
//    _infoKLineLowestLabel.text = [NSString stringWithFormat:@"低：%@",[TradeUtil stringRoundDownFloatValue:kLine.minimum dotBits:priceDecimalsDot]];
//    _infoKLineVolumeLabel.text = [NSString stringWithFormat:@"成交量：%@",[TradeUtil stringByFormatKWithNumber:kLine.volume]];
    _ma5Label.text = [NSString stringWithFormat:@"MA5：%@",[TradeUtil stringRoundDownFloatValue:kLine.m5 dotBits:priceDecimalsDot]];
    _ma10Label.text = [NSString stringWithFormat:@"MA10：%@",[TradeUtil stringRoundDownFloatValue:kLine.m10 dotBits:priceDecimalsDot]];
    _ma20Label.text = [NSString stringWithFormat:@"MA30：%@",[TradeUtil stringRoundDownFloatValue:kLine.m30 dotBits:priceDecimalsDot]];

}

- (void)kLineViewNeedLoadMoreData:(NSString *)timestamp
{
    if([_delegate respondsToSelector:@selector(coinQuotationDataViewKLineNeedMoreData:)]){
        [_delegate coinQuotationDataViewKLineNeedMoreData:timestamp];
    }
}

@end
