//
//  CMStockFuturesShareTimeView.h
//  ProCoin
//
//  Created by Hay on 2020/4/20.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinQuotationDataEntity.h"
#import "CMShareTimeBaseData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMStockFuturesShareTimeView : UIView


/** 是否存在历史数据*/
@property (assign, nonatomic) BOOL isHasHitory;




/** 设置背景颜色*/
@property (retain, nonatomic) UIColor *shareTimeViewBackground;


/** 增加总体行情数据*/
- (void)addShareTimeViewHistoryData:(NSString *)historyData yesterdayClose:(NSString *)yesterdayClose;
/** 增加一条行情数据*/
- (void)addOneShareTimeViewData:(CoinQuotationDataEntity *)dataEntity;


@end

NS_ASSUME_NONNULL_END
