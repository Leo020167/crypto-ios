//
//  FODAssetHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/5/30.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FODAssetHeaderView.h"
#import "TradeUtil.h"
#import "VBPieChart.h"

@interface FODAssetHeaderView()
{
    
}

@property (retain, nonatomic) NSArray *colorArray;         //颜色数组

@property (retain, nonatomic) VBPieChart *pieChart;                         //饼状图
@property (retain, nonatomic) NSArray *chartDataArray;                      //图形数据

@property (retain, nonatomic) IBOutlet UILabel *profitLabel;                //累计盈亏
@property (retain, nonatomic) IBOutlet UILabel *tolBalanceLabel;            //跟单总投入
@property (retain, nonatomic) IBOutlet UILabel *balanceLabel;               //余额


@property (retain, nonatomic) IBOutlet UIView *chartContentView;            //图表内容视图
@property (retain, nonatomic) IBOutlet UIView *chartInfoView;               //图标描述视图




@end

@implementation FODAssetHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.colorArray = [NSArray arrayWithObjects:
                       RGBA(247, 247, 247, 1.0),RGBA(243, 132, 45, 1.0),RGBA(100, 127, 198, 1.0),RGBA(234, 241, 160, 1), RGBA(231, 215, 160, 1),
                       RGBA(100, 189, 163, 1.0),RGBA(99, 186, 213, 1.0),RGBA(172, 206, 225, 1.0),RGBA(171, 191, 94, 1), RGBA(249, 183, 194, 1.0),nil];
}



- (void)dealloc
{
    [_colorArray release];
    [_pieChart release];
    [_chartDataArray release];
    [_profitLabel release];
    [_tolBalanceLabel release];
    [_balanceLabel release];
    [_chartContentView release];
    [_chartInfoView release];
    [super dealloc];
}

#pragma mark - 更新页面数据
- (void)reloadHeaderViewData:(FollowOrderDetailEntity *)entity distributeChartData:(NSArray *)chartData;
{

    /** 画饼状图*/
    self.chartDataArray = chartData;
    if(_pieChart == nil){
        self.pieChart = [[[VBPieChart alloc] init] autorelease];
        [self.chartContentView addSubview:_pieChart];
        
        [_pieChart setFrame:CGRectMake(20, 20, _chartContentView.frame.size.width - 40 , _chartContentView.frame.size.height - 40)];
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
    for(int i = 0; i < [chartData count]; i++){
        FollowOrderDistributeChartEntity *chartEntity = [chartData objectAtIndex:i];
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
    [_chartInfoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(int i = 0; i < [chartData count]; i++){
        FollowOrderDistributeChartEntity *chartEntity = [chartData objectAtIndex:i];
        UIView *view = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"FODPieInfoView" owner:nil options:nil] lastObject];
        [view setFrame:CGRectMake(7.5, 85 + i * (view.frame.size.height + 3), self.chartInfoView.frame.size.width - 15, view.frame.size.height)];
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

        [self.chartInfoView addSubview:view];

    }
    
    /** 对控件进行赋值*/
    _profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:entity.profitCash];
    _profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[entity.profitCash doubleValue]];
    _tolBalanceLabel.text = entity.tolBalance;
    _balanceLabel.text = entity.balance;

    
}

#pragma mark - 按钮点击事件

- (IBAction)followOrderDetailButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(assetHeaderViewFollowOrderDetailButtonDidSelected)]){
        [_delegate assetHeaderViewFollowOrderDetailButtonDidSelected];
    }
}

- (IBAction)questionButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(assetHeaderViewQuestionInfoDidSelected)]){
        [_delegate assetHeaderViewQuestionInfoDidSelected];
    }
}
@end
