//
//  CMFiveDayShareTimeView.h
//  ProCoin
//
//  Created by Hay on 2020/4/22.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinQuotationDataEntity.h"
#import "CMShareTimeBaseData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMFiveDayShareTimeView : UIView

/** 是否存在历史数据*/
@property (assign, nonatomic) BOOL isHasHitory;




/** 设置背景颜色*/
@property (retain, nonatomic) UIColor *shareTimeViewBackground;


/** 增加总体行情数据*/
- (void)addFiveDayShareTimeViewHistoryData:(NSString *)historyData;


@end

NS_ASSUME_NONNULL_END
