//
//  CMShareTimeView.h
//  Cropyme
//
//  Created by Hay on 2019/6/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseView.h"
#import "CoinQuotationDataEntity.h"
#import "CMShareTimeBaseData.h"

@interface CMShareTimeView : TJRBaseView

/** 是否存在历史数据*/
@property (assign, nonatomic) BOOL isHasHitory;

/** 行情图占整个view高度的比例,默认为4*/
@property (assign, nonatomic) NSInteger mainViewHeightRatio;
/** 成交量占整个view高度的比例，默认为1*/
@property (assign, nonatomic) NSInteger volumeViewHeightRatio;
/** 分时图从左到右分成多少等份，默认为5*/
@property (assign, nonatomic) NSInteger totalColumn;


/** 设置背景颜色*/
@property (retain, nonatomic) UIColor *shareTimeViewBackground;


/** 增加总体行情数据*/
- (void)addShareTimeViewHistoryData:(NSString *)historyData;
/** 增加一条行情数据*/
- (void)addOneShareTimeViewData:(CoinQuotationDataEntity *)dataEntity;

@end


