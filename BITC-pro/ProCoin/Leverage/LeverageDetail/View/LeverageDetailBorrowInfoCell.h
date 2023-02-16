//
//  LeverageDetailBorrowInfoCell.h
//  BYY
//
//  Created by Hay on 2019/12/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeverageTradeDetailModel.h"

@protocol LeverageDetailBorrowInfoCellDelegate <NSObject>

@optional

- (void)borrowInfoCellInterestTipsButtonPressed;

- (void)borrowInfoCellStopWinLossRateButtonPressed;

@end



@interface LeverageDetailBorrowInfoCell : UITableViewCell

@property (assign, nonatomic) id<LeverageDetailBorrowInfoCellDelegate> delegate;

- (void)reloadBorrowInfoData:(LeverageTradeDetailModel *)model;

@end


