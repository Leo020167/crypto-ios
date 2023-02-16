//
//  BalanceInfoHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "BalanceInfoHeaderView.h"
#import "VBPieChart.h"

@interface BalanceInfoHeaderView()

@property (retain, nonatomic) VBPieChart *pieChart;                         //饼状图
@property (retain, nonatomic) IBOutlet UIView *contentView; //内容view
@property (retain, nonatomic) IBOutlet UIView *tipsView;    //提示view


@end

@implementation BalanceInfoHeaderView

- (void)dealloc
{
    [_pieChart release];
    [_contentView release];
    [_tipsView release];
    [super dealloc];
}


- (void)reloadInfoHeaderViewWithUsableBalanceRate:(NSString *)usableBalanceRate usedBalanceRate:(NSString *)usedBalanceRate
{
    /** 画饼状图*/
    if(_pieChart == nil){
        self.pieChart = [[[VBPieChart alloc] init] autorelease];
        [self.contentView addSubview:_pieChart];
        
        [_pieChart setFrame:CGRectMake(20, 20, _contentView.frame.size.width - 40 , _contentView.frame.size.height - 40)];
        [_pieChart setEnableStrokeColor:YES];
        [_pieChart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_pieChart.layer setShadowRadius:3];
        [_pieChart.layer setShadowColor:[UIColor clearColor].CGColor];
        [_pieChart.layer setShadowOpacity:0.7];
        [_pieChart setHoleRadiusPrecent:0.6];
        _pieChart.length = M_PI*2;
        _pieChart.startAngle = 0;
        
    }
    NSMutableArray *dataValue = [NSMutableArray array];
    [dataValue addObject:@{@"name":NSLocalizedStringForKey(@"可用"), @"value":usableBalanceRate, @"color":RGBA(253, 205, 42, 1.0)}];
    [dataValue addObject:@{@"name":NSLocalizedStringForKey(@"已用"), @"value":usedBalanceRate, @"color":RGBA(240, 114, 52, 1.0)}];
    [_pieChart setChartValues:dataValue animation:YES options:VBPieChartAnimationFanAll];
    
    
    /** 增加饼状图简介信息*/
    [_tipsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(int i = 0; i < 2; i++){
        UIView *view = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"FODPieInfoView" owner:nil options:nil] lastObject];
        [view setFrame:CGRectMake(7.5, 85 + i * (view.frame.size.height + 3), self.tipsView.frame.size.width - 15, view.frame.size.height)];
        UIView *iconView = (UIView *)[view viewWithTag:100];
        UILabel *titleLabel = (UILabel *)[view viewWithTag:101];
        UIColor *color = nil;
        if(i == 0){
            color = RGBA(253, 205, 42, 1.0);
            titleLabel.text = [NSString stringWithFormat:@"%@  %@%%",NSLocalizedStringForKey(@"可用"),usableBalanceRate];
        }else{
            color = RGBA(240, 114, 52, 1.0);
            titleLabel.text = [NSString stringWithFormat:@"%@  %@%%",NSLocalizedStringForKey(@"已用"),usedBalanceRate];
        }
        
        [iconView setBackgroundColor:color];
        [self.tipsView addSubview:view];
        
    }
}
@end
