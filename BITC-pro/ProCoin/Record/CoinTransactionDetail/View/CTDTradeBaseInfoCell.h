//
//  CTDTradeBaseInfoCell.h
//  Cropyme
//
//  Created by Hay on 2019/5/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinTradeOrderEntity.h"

@interface CTDTradeBaseInfoCell : UITableViewCell

- (void)reloadBaseInfoCellData:(CoinTradeOrderEntity *)orderEntity;

@end


