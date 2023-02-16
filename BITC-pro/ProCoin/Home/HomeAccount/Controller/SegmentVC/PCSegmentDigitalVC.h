//
//  SegmentHoldCoinVC.h
//  Cropyme
//
//  Created by Hay on 2019/7/20.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "PCAccountModel.h"
#import "PCBaseHoldCoinModel.h"
#import "YNPageTableView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PCSegmentDigitalVCDelegate <NSObject>

@optional

- (void)digitalCoinTableViewDidSelectedCellWithIndexPath:(NSIndexPath *)indexPath;
- (void)digitalRiskQuestionButtonDidPressed;

@end

@interface PCSegmentDigitalVC : TJRBaseViewController

@property (assign, nonatomic) id<PCSegmentDigitalVCDelegate> delegate;

@property (retain, nonatomic) IBOutlet YNPageTableView *digitalCoinTableView;

/** 更新数据*/
- (void)reloadDigitalAccountInfo:(PCAccountModel *)accountEntity accountHoldData:(NSArray *)dataArr;



@end

NS_ASSUME_NONNULL_END
