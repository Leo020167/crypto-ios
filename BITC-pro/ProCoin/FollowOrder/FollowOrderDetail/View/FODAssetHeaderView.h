//
//  FODAssetHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/5/30.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowOrderDetailEntity.h"
#import "FollowOrderDistributeChartEntity.h"
#import "TradeUtil.h"
#import "CommonUtil.h"

@protocol FODAssetHeaderViewDelegate <NSObject>

@optional
- (void)assetHeaderViewFollowOrderDetailButtonDidSelected;
- (void)assetHeaderViewQuestionInfoDidSelected;

@end

@interface FODAssetHeaderView : UIView

@property (assign, nonatomic) id<FODAssetHeaderViewDelegate> delegate;

/** 更新页面数据*/
- (void)reloadHeaderViewData:(FollowOrderDetailEntity *)entity distributeChartData:(NSArray *)chartData;

@end


