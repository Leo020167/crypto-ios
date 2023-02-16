//
//  BuyBackMainChartView.m
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "BuyBackMainChartView.h"
#import "CMLineCharView.h"
#import "VeDateUtil.h"
#import "TradeUtil.h"
#import "KBTTrendDataEntity.h"
#import "MHBaseLineChartView.h"

@interface BuyBackMainChartView()
{

}
@property (retain, nonatomic) MHBaseLineChartView *lineChartView;

@property (retain, nonatomic) IBOutlet UIView *lineChartContentView;

@end

@implementation BuyBackMainChartView

- (void)awakeFromNib
{
    [super awakeFromNib];

}


- (void)dealloc
{
    [_lineChartView release];
    [_lineChartContentView release];
    [super dealloc];
}

/** 回购按钮点击事件*/
- (IBAction)buyBackButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(buyBackMainChartViewBuyBackButtonDidSelected)]){
        [_delegate buyBackMainChartViewBuyBackButtonDidSelected];
    }
}

/** 交易按钮点击事件*/
- (IBAction)tradeButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(buyBackMainChartViewTradeButtonDidSelected)]){
        [_delegate buyBackMainChartViewTradeButtonDidSelected];
    }
}


- (void)reloadChartView:(NSArray *)dataArr
{
    if([dataArr count] <= 0){
        return;
    }
    if(self.lineChartView == nil){
        self.lineChartView = [[[MHBaseLineChartView alloc] initWithFrame:CGRectMake(10, 0.0, SCREEN_WIDTH - 20, _lineChartContentView.frame.size.height)] autorelease];
        self.lineChartView.backgroundColor = [UIColor clearColor];
        [_lineChartContentView addSubview:self.lineChartView];
    }

    NSMutableArray *yAxisDataArr = [NSMutableArray array];
    NSMutableArray *xAxisDataArr = [NSMutableArray array];
    for(int i = 0; i < [dataArr count]; i++){
        KBTTrendDataEntity *dataEntity = [dataArr objectAtIndex:i];
        [yAxisDataArr addObject:dataEntity.price];
        if(i == 0 || i == [dataArr count] - 1){
            [xAxisDataArr addObject:[VeDateUtil formatterDate:dataEntity.dayTime inStytle:nil outStytle:@"yyyy-MM-dd" isTimestamp:YES]];
        }
    }
    _lineChartView.yAxisDataArr = yAxisDataArr;
    _lineChartView.xAxisDataArr = xAxisDataArr;
    
    [_lineChartView reloadAndShowLineChart];
    

}

@end
