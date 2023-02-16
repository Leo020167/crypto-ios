//
//  LeverageDetailCloseInfoCell.h
//  BYY
//
//  Created by Hay on 2020/1/1.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeverageTradeDetailModel.h"


@interface LeverageDetailCloseInfoCell : UITableViewCell

- (void)reloadCloseInfoData:(LeverageTradeDetailModel *)model;

@end

