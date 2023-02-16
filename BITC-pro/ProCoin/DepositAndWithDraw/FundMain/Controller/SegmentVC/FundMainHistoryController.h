//
//  FundMainHistoryController.h
//  Cropyme
//
//  Created by Hay on 2019/7/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "RZRefreshTableView.h"
#import "CashTradeOrderEntity.h"

@protocol FundMainHistoryControllerDelegate <NSObject>

@optional
- (void)historyControllerTableViewDidSelectedWithEntity:(CashTradeOrderEntity *_Nonnull)entity;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FundMainHistoryController : TJRBaseViewController

@property (assign, nonatomic) id<FundMainHistoryControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet RZRefreshTableView *historyTableView;

/** 请求历史记录*/
- (void)reqCashCoinTransactionFirstPageHistoryRecord;
@end

NS_ASSUME_NONNULL_END
