//
//  BuyBackMainChartView.h
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BuyBackMainChartViewDelegate <NSObject>

@optional
- (void)buyBackMainChartViewBuyBackButtonDidSelected;
- (void)buyBackMainChartViewTradeButtonDidSelected;

@end



@interface BuyBackMainChartView : UIView

@property (assign, nonatomic) id<BuyBackMainChartViewDelegate> delegate;


- (void)reloadChartView:(NSArray *)dataArr;

@end

