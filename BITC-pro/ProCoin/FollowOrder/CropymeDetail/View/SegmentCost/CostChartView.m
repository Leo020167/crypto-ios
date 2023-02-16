//
//  CostChartView.m
//  Cropyme
//
//  Created by Hay on 2019/8/13.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CostChartView.h"
#import "CostChartEntity.h"
#import "TradeUtil.h"
#import "CommonUtil.h"

@interface CostChartView()
{
    CGFloat yAxisMaxValue;                          //y轴最大数字
    CGFloat yAxisMinValue;                          //y轴最小数字
    CGFloat yAxisPerValue;                          //y轴每一份的值
    NSInteger yAxisDecimals;                        //y轴的小数位数
    NSInteger yAxisDotCount;                        //y轴显示的点共有多少个，默认7个
    CGFloat perYAxisDotHeight;                      //y轴每一个坐标点的高度
    
    CGFloat xAxisMaxValue;                          //x轴最大数字
    
    CGFloat chartViewTopMargin;                 //顶部留白
    CGFloat chartViewBottomMargin;              //底部留白
    CGFloat rightTextAreaWidth;                 //y轴文字区域占的宽度,根据传入的y轴数据，取最长的宽度.开始默认为50
    
    CGFloat drawDataHeight;                    //画数据图的高度
    
    CGFloat backgroundLineWidth;       //背景辅助线宽度
}

@property (copy, nonatomic) NSString *currentPrice;              //当前现价
@property (copy, nonatomic) NSArray *chartDataArr;               //画图数据数组

@end

@implementation CostChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initCostChartView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initCostChartView];
    }
    return self;
}

- (void)dealloc
{
    [_currentPrice release];
    [_chartDataArr release];
    [super dealloc];
}

#pragma mark - 初始化
- (void)initCostChartView
{
    chartViewTopMargin = 15;
    chartViewBottomMargin = 15;
    backgroundLineWidth = 0.5;
    yAxisDotCount = 7;
    rightTextAreaWidth = 50;
    drawDataHeight = self.frame.size.height - chartViewTopMargin - chartViewBottomMargin;
    perYAxisDotHeight = (CGFloat)((self.frame.size.height - chartViewTopMargin - chartViewBottomMargin) / (yAxisDotCount - 1));
}

#pragma mark - 画图
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    if([self.chartDataArr count] <= 0)
        return;
    
    //画背景辅助线
    [self drawBackgroundLine:context];
    //画y轴文字
    [self drawYAxisText];
    //画数据
    [self drawDataLineChart:context];
}

/** 更新画图*/
- (void)reloadChartViewWithDataArr:(NSArray *)dataArr currentPrice:(NSString *)currentPirce
{
    if([dataArr count] == 0){
        return;
    }
    self.currentPrice = currentPirce;
    self.chartDataArr = dataArr;
    //处理数据
    [self processingDataBychartData];
    //重绘
    [self setNeedsDisplay];
}

#pragma mark - 处理数据并计算某些必须值
- (void)processingDataBychartData
{
    yAxisMaxValue = CGFLOAT_MIN;
    yAxisMinValue = CGFLOAT_MAX;
    xAxisMaxValue = CGFLOAT_MIN;
    
    for(int i = 0; i < [_chartDataArr count]; i++){
        CostChartEntity *entity = [_chartDataArr objectAtIndex:i];
        if(yAxisMinValue > [entity.price doubleValue]){
            yAxisMinValue = [entity.price doubleValue];
        }
        
        if(yAxisMaxValue < [entity.price doubleValue]){
            yAxisMaxValue = [entity.price doubleValue];
        }
        
        if(xAxisMaxValue < [entity.amount doubleValue]){
            xAxisMaxValue = [entity.amount doubleValue];
        }
    }
    
    if(yAxisMinValue == yAxisMaxValue){         //如果这两个数字相等，则只有一个数据
        yAxisMaxValue = yAxisMinValue * yAxisDotCount;
    }
    yAxisPerValue = (CGFloat)((yAxisMaxValue - yAxisMinValue) / yAxisDotCount);
    
    /**根据后端返回的数据，随便一个值，得出价格的位数*/
    CostChartEntity *entity = [_chartDataArr firstObject];
    yAxisDecimals = [TradeUtil decimalBitByStringValue:entity.price];
    
    /** 计算y轴区域占的宽度*/
    //为了更好看，会在宽度基础上加5
    rightTextAreaWidth = ((CGSize)[CommonUtil getPerfectSizeByText:[TradeUtil stringRoundDownFloatValue:yAxisMaxValue dotBits:yAxisDecimals] andFontSize:10.0f andWidth:1000]).width + 5;

}


#pragma mark - 画背景辅助线
- (void)drawBackgroundLine:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, RGBA(230, 230, 230, 1).CGColor);
    CGContextSetLineWidth(context, backgroundLineWidth);
    
    for(int i = 0 ; i < yAxisDotCount ; i++){
        CGContextMoveToPoint(context, 0.0, chartViewTopMargin + perYAxisDotHeight * i - backgroundLineWidth/2.0f);
        CGContextAddLineToPoint(context, self.frame.size.width - rightTextAreaWidth, chartViewTopMargin + perYAxisDotHeight * i - backgroundLineWidth/2.0f);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

#pragma mark - 画y轴文字
- (void)drawYAxisText
{
    for(int i = 0; i < yAxisDotCount; i++){
        NSString *textString = @"";
        if(i == 0){
            textString = [TradeUtil stringRoundDownFloatValue:yAxisMaxValue dotBits:yAxisDecimals];

        }else if(i == yAxisDotCount - 1){
            textString = [TradeUtil stringRoundDownFloatValue:yAxisMinValue dotBits:yAxisDecimals];
        }else{
            textString = [TradeUtil stringRoundDownFloatValue:(yAxisMaxValue - i * yAxisPerValue) dotBits:yAxisDecimals];
        }
        
        CGSize stringSize = [CommonUtil getPerfectSizeByText:textString andFontSize:10.0f andWidth:1000];
        [textString drawAtPoint:CGPointMake(self.frame.size.width - stringSize.width, chartViewTopMargin + i * perYAxisDotHeight - stringSize.height/2.0f) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(61, 58, 80, 0.4)}];
        
    }
}

#pragma mark - 画数据
- (void)drawDataLineChart:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGFloat lineWidth = 2;
    CGContextSetLineWidth(context, lineWidth);
    
    CGFloat lineAreaWidth = self.frame.size.width - rightTextAreaWidth;
    for(int i = 0; i < [_chartDataArr count]; i++){
        CostChartEntity *entity = [_chartDataArr objectAtIndex:i];
        CGFloat dataLineChartLength = [entity.amount doubleValue]/xAxisMaxValue * lineAreaWidth;      //数据图的长度
        CGFloat y = (1 - ([entity.price doubleValue] - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue)) * drawDataHeight + chartViewTopMargin;                    //y坐标
        if([entity.price doubleValue] <= [self.currentPrice doubleValue]){          //购买价低于等于现价
            CGContextSetStrokeColorWithColor(context, RGBA(63, 172, 141, 1.0).CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, RGBA(205, 80, 102, 1.0).CGColor);
        }
        CGContextMoveToPoint(context, 0.0, y - lineWidth / 2.0f);
        CGContextAddLineToPoint(context, dataLineChartLength, y - lineWidth / 2.0f);
        CGContextStrokePath(context);
    }
    /** 画现价虚线*/
    CGContextSetStrokeColorWithColor(context, RGBA(240, 140, 55, 1.0).CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat lengths[] = {2,3};
    CGContextSetLineDash(context, 0, lengths,2);
    CGFloat dashY;
    CGSize stringSize = [CommonUtil getPerfectSizeByText:self.currentPrice andFontSize:10.0f andWidth:1000];
    if([self.currentPrice doubleValue] >= yAxisMaxValue){
        dashY = chartViewTopMargin;
        [self.currentPrice drawAtPoint:CGPointMake(lineAreaWidth - stringSize.width, dashY + 5) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(240, 140, 55, 0.8)}];
    }else if([self.currentPrice doubleValue] <= yAxisMinValue){
        dashY = drawDataHeight + chartViewTopMargin;
        [self.currentPrice drawAtPoint:CGPointMake(lineAreaWidth - stringSize.width, dashY - stringSize.height - 5) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(240, 140, 55, 0.8)}];
    }else{
        dashY = (1 - ([self.currentPrice doubleValue] - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue)) * drawDataHeight + chartViewTopMargin;                    //y坐标
        [self.currentPrice drawAtPoint:CGPointMake(lineAreaWidth - stringSize.width, dashY - stringSize.height - 5) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(240, 140, 55, 0.8)}];
    }
    CGContextMoveToPoint(context, 0.0, dashY);
    CGContextAddLineToPoint(context, lineAreaWidth,dashY - lineWidth / 2.0f);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
   
    
    
}
@end
