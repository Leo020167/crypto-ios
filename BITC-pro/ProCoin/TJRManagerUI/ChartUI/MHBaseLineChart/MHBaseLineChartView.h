//
//  MHBaseLineChartView.h
//  Cropyme
//
//  Created by Hay on 2019/8/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MHBaseLineChartView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

/** X轴数据*/
@property (copy, nonatomic) NSArray *xAxisDataArr;
/** Y轴数据*/
@property (copy, nonatomic) NSArray *yAxisDataArr;


- (void)reloadAndShowLineChart;

@end


