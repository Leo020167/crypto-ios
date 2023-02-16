//
//  CoinQuotationsTradeDataCell.h
//  Cropyme
//
//  Created by Hay on 2019/9/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TradeDataCellTotalGearCount     20


@interface CoinQuotationsTradeDataCell : UITableViewCell

+ (NSInteger)coinQuotationTradeDataCellShowGearCount;
+ (CGFloat)coinQuotationTradeDataCellHeight;

/** 设置左边买家数据,右边卖家数据*/
- (void)updateBuyTradeData:(NSArray *)buyDataArr sellDataArr:(NSArray *)sellDataArr;

@end


