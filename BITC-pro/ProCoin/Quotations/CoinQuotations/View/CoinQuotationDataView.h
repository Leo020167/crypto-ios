//
//  CoinQuotationDataView.h
//  Cropyme
//
//  Created by Hay on 2019/6/25.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinQuotationDataEntity.h"
#import "CMShareTimeBaseData.h"
#import "QuotationUtil.h"


@protocol CoinQuotationDataViewDelegate <NSObject>

@optional
- (void)coinQuotationDataViewQuotationTypeDidChanged:(CoinQuotationButtonType)type;
- (void)coinQuotationDataViewKLineNeedMoreData:(NSString *)timestamp;

@end

@interface CoinQuotationDataView : UIView

@property (assign, nonatomic) id<CoinQuotationDataViewDelegate> delegate;

@property (assign, nonatomic) BOOL isStockFuturesShareTime;     //是否为特殊的股指期货分时图，默认为NO,不是

- (void)setShareTimeViewHasHistory:(BOOL)hasHistory;
- (BOOL)isShareTimeViewHasHistory;
/** 增加分时历史数据*/
- (void)shareTimeViewAddHistoryData:(NSString *)historyData yesterdayClose:(NSString *)yesterdayClose;
- (void)shareTimeViewAddOneQuotationData:(CoinQuotationDataEntity *)dataEntity;
/** 增加5日分时数据*/
- (void)fiveDayShareTimeViewAddData:(NSString *)dataStr;

- (void)reloadQuotationData:(CoinQuotationDataEntity *)dataEntity;
//- (void)kLineViewAddData:(CoinQuotationDataEntity *)currentData;

#pragma mark - K线
/** 更新K线数据*/
- (void)kLineViewReloadData:(NSDictionary *)json;


@end


