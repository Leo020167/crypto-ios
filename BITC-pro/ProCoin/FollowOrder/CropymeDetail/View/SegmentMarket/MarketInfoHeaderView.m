//
//  MarketInfoHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/8/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "MarketInfoHeaderView.h"
#import "VBPieChart.h"
#import "FollowOrderDistributeChartEntity.h"

@interface MarketInfoHeaderView()
{
    
}
@property (copy, nonatomic) NSArray *dataArray;         //数据数组
@property (copy, nonatomic) NSArray *colorArray;        //颜色数组
@property (retain, nonatomic) VBPieChart *pieChart;                         //饼状图
@property (retain, nonatomic) IBOutlet UILabel *totalMarketLabel;           //总市值
@property (retain, nonatomic) IBOutlet UILabel *totalMarketCNYLabel;        //总市值人民币显示
@property (retain, nonatomic) IBOutlet UIView *contentView;     //内容view
@property (retain, nonatomic) IBOutlet UIView *tipsView;        //信息简介view

@end;

@implementation MarketInfoHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.colorArray = [NSArray arrayWithObjects:
                       RGBA(243, 132, 45, 1.0),RGBA(100, 127, 198, 1.0),RGBA(234, 241, 160, 1), RGBA(231, 215, 160, 1),
                       RGBA(100, 189, 163, 1.0),RGBA(99, 186, 213, 1.0),RGBA(172, 206, 225, 1.0),RGBA(171, 191, 94, 1), RGBA(249, 183, 194, 1.0),nil];
}


- (void)dealloc
{
    [_dataArray release];
    [_colorArray release];
    [_pieChart release];
    [_contentView release];
    [_tipsView release];
    [_totalMarketLabel release];
    [_totalMarketCNYLabel release];
    [super dealloc];
}

- (void)reloadInfoHeaderViewData:(NSArray *)chartArray totalMarket:(NSString *)totalMarket totalMarketCNY:(NSString *)totalMarketCNY
{
    _totalMarketLabel.text = [NSString stringWithFormat:@"%@:%@ USDT", NSLocalizedStringForKey(@"总市值"), totalMarket];
    _totalMarketCNYLabel.text = totalMarketCNY;
    /** 画饼状图*/
    self.dataArray = [NSArray arrayWithArray:chartArray];
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
    for(int i = 0; i < [_dataArray count]; i++){
        FollowOrderDistributeChartEntity *chartEntity = [_dataArray objectAtIndex:i];
        UIColor *color = nil;
        if(i >= [_colorArray count]){
            color = [_colorArray lastObject];
        }else{
            color = [_colorArray objectAtIndex:i];
        }
        [dataValue addObject:@{@"name":chartEntity.symbol, @"value":chartEntity.rate, @"color":color}];
    }
    
    [_pieChart setChartValues:dataValue animation:YES options:VBPieChartAnimationFanAll];
    
    
    /** 增加饼状图简介信息*/
    [_tipsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(int i = 0; i < [_dataArray count]; i++){
        FollowOrderDistributeChartEntity *chartEntity = (FollowOrderDistributeChartEntity *)[_dataArray objectAtIndex:i];
        UIView *view = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"FODPieInfoView" owner:nil options:nil] lastObject];
        [view setFrame:CGRectMake(7.5, 85 + i * (view.frame.size.height + 3), self.tipsView.frame.size.width - 15, view.frame.size.height)];
        UIView *iconView = (UIView *)[view viewWithTag:100];
        UILabel *titleLabel = (UILabel *)[view viewWithTag:101];
        UIColor *color = nil;
        if(i >= [_colorArray count] ){
            color = [_colorArray lastObject];
        }else{
            color = [_colorArray objectAtIndex:i];
        }
        [iconView setBackgroundColor:color];
        titleLabel.text = [NSString stringWithFormat:@"%@  %@%%",chartEntity.symbol,chartEntity.rate];
        
        [self.tipsView addSubview:view];
        
    }
}

@end
