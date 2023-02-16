//
//  SegmentFollowOrderVC.h
//  Cropyme
//
//  Created by Hay on 2019/7/20.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "PCAccountModel.h"
#import "YNPageTableView.h"
#import "PCHomeUserFollowOrderInfoModel.h"
#import "PCBaseHoldCoinModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol PCSegmentFollowOrderVCDelegate <NSObject>

- (void)followOrderViewBindOperationButtonDidPressed:(PCHomeUserFollowOrderInfoModel *)model;
- (void)followOrderViewMultiNumButtonDidPressed;
- (void)followOrderViewOpenFollowSwitchValueChanged:(BOOL)isOn;
- (void)followOrderViewDidSelctedHoldDataWithOrderId:(NSString *)orderId;
- (void)followOrderViewRiskQuestionButtonDidPressed;
@optional


@end

@interface PCSegmentFollowOrderVC : TJRBaseViewController

@property (assign, nonatomic) id<PCSegmentFollowOrderVCDelegate> delegate;

@property (retain, nonatomic) IBOutlet YNPageTableView *followOrderTableView;

/** 更新数据*/
- (void)reloadFollowOrderAccountDigitalInfo:(PCAccountModel *)digitalInfoEntity stockFuturesInfo:(PCAccountModel *)stockFuturesEntity accountDigitalHoldData:(NSArray *)digitalDataArr acountStockFuturesHoldData:(NSArray *)stockFuturesDataArr userFollowInfo:(PCHomeUserFollowOrderInfoModel *)userFollowEntity;

@end

NS_ASSUME_NONNULL_END
