//
//  KLineViewAndNetData.h
//  TJRtaojinroad
//
//  Created by 影孤清 on 13-10-21.
//  Copyright (c) 2013年 淘金路. All rights reserved.
//

#import "NewKLineView.h"
#import "CoinQuotationDataEntity.h"

#define klineNum 250

@protocol KLineViewAndNetDataDelegate <NSObject>

@optional
- (void)kLineViewNeedLoadMoreData:(NSString *)timestamp;


@end

@interface KLineViewAndNetData : NewKLineView
{
    NSInteger _klineCycle;
    NSInteger _klineNumber;
    NSUInteger pastMaxNumber;
}

@property (assign, nonatomic) id<KLineViewAndNetDataDelegate> kLineDelegate;

@property (assign, nonatomic) BOOL notClearDrawForHttp;/* 不清空所画的K线(默认为NO 即清空) */
@property (assign, nonatomic) BOOL notDrawAfterHttpFinish;/* 网络数据成功,不直接画(默认为NO) */

#pragma mark - 清除画布
- (void)cleanDraw;

#pragma mark - 更新K线数据
- (void)reloadKLineData:(NSDictionary *)json kLineType:(KLineDataType)kLineType;
- (void)addKLineData:(CoinQuotationDataEntity *)data kLineType:(KLineDataType)kLineType;

@end
