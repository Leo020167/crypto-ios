//
//  LeverageDetailOpenInfoCell.h
//  BYY
//
//  Created by Hay on 2019/12/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeverageTradeDetailModel.h"

@protocol LeverageDetailOpenInfoCellDelegate <NSObject>

@optional
- (void)openInfoCellAddBondBalanceDidPressed;

@end


@interface LeverageDetailOpenInfoCell : UITableViewCell

@property (assign, nonatomic) id<LeverageDetailOpenInfoCellDelegate> delegate;

- (void)reloadOpenInfoData:(LeverageTradeDetailModel *)model;

@end


