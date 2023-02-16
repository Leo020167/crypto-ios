//
//  FundMainUndoneController.h
//  Cropyme
//
//  Created by Hay on 2019/7/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "RZRefreshTableView.h"
#import "CashTradeOrderEntity.h"

@protocol FundMainUndoneControllerDelegate <NSObject>

@optional
- (void)undoneControllerTableViewDidSelectedWithEntity:(CashTradeOrderEntity *_Nonnull)entity;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FundMainUndoneController : TJRBaseViewController

@property (assign, nonatomic) id<FundMainUndoneControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet RZRefreshTableView *undoneTableView;


/** 请求未完成记录*/
- (void)reqCashCoinTransactionFirstPageUndoneRecord;


@end

NS_ASSUME_NONNULL_END
