//
//  SegmentLeverageVC.h
//  BYY
//
//  Created by Hay on 2019/12/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "PCAccountModel.h"
#import "YNPageTableView.h"
#import "PCBaseHoldCoinModel.h"

@protocol PCSegmentStockFuturesVCDelegate <NSObject>

- (void)stockFuturesTableViewDidSelectedCellWithIndexPath:(PCBaseHoldCoinModel *)model;
- (void)stockFuturesRiskQuestionButtonDidPressed;

@optional


@end

@interface PCSegmentStockFuturesVC : TJRBaseViewController

@property (assign, nonatomic) id<PCSegmentStockFuturesVCDelegate> delegate;

@property (nonatomic,retain) IBOutlet YNPageTableView *dataTableView;

/** 更新数据*/
- (void)reloadStockFuturesAccountInfo:(PCAccountModel *)infoEntity accountHoldData:(NSArray *)dataArr;


@end


