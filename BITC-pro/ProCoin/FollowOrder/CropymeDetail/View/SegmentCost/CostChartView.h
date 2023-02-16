//
//  CostChartView.h
//  Cropyme
//
//  Created by Hay on 2019/8/13.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 跟单用户成本正态分布图*/

@interface CostChartView : UIView

/** 更新画图*/
- (void)reloadChartViewWithDataArr:(NSArray *)dataArr currentPrice:(NSString *)currentPirce;

@end


