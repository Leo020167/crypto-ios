//
//  SegmentStoreVC.h
//  BYY
//
//  Created by Hay on 2019/12/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "PCAccountModel.h"
#import "YNPageTableView.h"
#import "PCCoinOperationRecordModel.h"

@protocol PCSegmentBalanceVCDelegate <NSObject>

@optional
- (void)balanceCoinAllRecordButtonPressed;
- (void)balanceCoinOperationRecordDidSelectedWithIndexPath:(NSIndexPath *)indexPath;

@end


@interface PCSegmentBalanceVC : TJRBaseViewController

@property (nonatomic, assign) id<PCSegmentBalanceVCDelegate> delegate;

@property (retain, nonatomic) IBOutlet YNPageTableView *dataTableView;

/** 更新数据*/
- (void)reloadBalanceAccountInfo:(PCAccountModel *)balanceInfoEntity;
- (void)reloadBalanceRecordData:(NSArray *)recordDataArr;
@end

