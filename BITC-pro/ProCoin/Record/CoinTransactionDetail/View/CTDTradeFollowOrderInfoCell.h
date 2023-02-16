//
//  CTDTradeFollowOrderInfoCell.h
//  Cropyme
//
//  Created by Hay on 2019/5/28.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinTradeOrderEntity.h"


@interface CTDTradeFollowOrderInfoCell : UITableViewCell

/** 更新页面信息*/
- (void)reloadOrderInfoCellData:(CoinTradeOrderEntity *)orderEntity;

@end


