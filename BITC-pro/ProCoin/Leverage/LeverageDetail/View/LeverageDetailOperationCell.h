//
//  LeverageDdetailOperationCell.h
//  BYY
//
//  Created by Hay on 2020/1/1.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeverageTradeDetailModel.h"

@protocol LeverageDetailOperationCellDeleagte <NSObject>

@optional
- (void)operationCellCloseButtonPressed;
- (void)operationCellQuotationInfoButtonPressed;

@end


@interface LeverageDetailOperationCell : UITableViewCell

@property (assign, nonatomic) id<LeverageDetailOperationCellDeleagte> delegate;

- (void)reloadOpetationCellData:(LeverageTradeDetailModel *)model;


@end

