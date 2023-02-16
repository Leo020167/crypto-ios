//
//  HomeMainHeaderView.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeMainQuotationsCell.h"
#import "SDCycleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeMainHeaderView : UIView

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic, strong) NSMutableArray *bannerArray;

@property (nonatomic, strong) NSMutableArray *quoteArray;

@property (nonatomic, strong) NSMutableArray *announceDataArr;

/// 公告
@property (nonatomic, copy) void(^announceViewActionBlock)(void);

/// 行情
@property (nonatomic, copy) void(^quotationsDataBlock)(HomeQuoteModel * _Nonnull model);

@property (nonatomic, copy) void(^clickActionBlock)(NSUInteger type);


@end

NS_ASSUME_NONNULL_END
