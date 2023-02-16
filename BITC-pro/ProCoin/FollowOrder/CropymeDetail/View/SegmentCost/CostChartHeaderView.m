
//
//  CostChartHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/8/13.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CostChartHeaderView.h"
#import "CostChartView.h"

@interface CostChartHeaderView()

@property (retain, nonatomic) IBOutlet CostChartView *chartView;
@property (retain, nonatomic) IBOutlet UILabel *totalAmountLabel;       //总数量
@property (retain, nonatomic) IBOutlet UILabel *avgPirceLabel;          //平均成本
@property (retain, nonatomic) IBOutlet UILabel *profitRateLabel;        //盈利比例

@end

@implementation CostChartHeaderView

- (void)dealloc
{
    [_chartView release];
    [_totalAmountLabel release];
    [_avgPirceLabel release];
    [_profitRateLabel release];
    [super dealloc];
}


- (void)reloadChartHeaderViewWithCostEntity:(CDCostBaseEntity *)costEntity chartDataArr:(NSArray *)chartDataArr
{
    _totalAmountLabel.text = [NSString stringWithFormat:@"%@：%@ %@", NSLocalizedStringForKey(@"总数量"), costEntity.totalAmount,costEntity.symbol];
    _avgPirceLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringForKey(@"平均成本价"), costEntity.avgCostPrice];
    _profitRateLabel.text = [NSString stringWithFormat:@"%@：%@%%", NSLocalizedStringForKey(@"盈利比例"), costEntity.profitRate];
    
    [_chartView reloadChartViewWithDataArr:chartDataArr currentPrice:costEntity.price];
}

@end
