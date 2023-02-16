//
//  MHBaseLineChartView.m
//  Cropyme
//
//  Created by Hay on 2019/8/31.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "MHBaseLineChartView.h"
#import "TradeUtil.h"
#import "CommonUtil.h"

@interface MHBaseLineChartView()
{
    
    NSMutableArray *chartPointArr;              //折线每个点坐标的数组集合
    UIView *chartView;
    /** 图标上下左右间距*/
    CGFloat chartViewLeftMargin;
    CGFloat chartViewRightMargin;
    CGFloat chartViewTopMargin;
    CGFloat chartViewBottomMargin;
    
    NSInteger yAxisPart;            //y轴的等份
    CGFloat yMaxAxisValue;          //Y轴最大值
    CGFloat yMinAxisValue;          //Y轴最大值
    
    CGFloat yValueTextMaxWidth;     //y轴文字的最长宽度
}

@property (assign, nonatomic) NSInteger yAxisValueDecimals;             //y轴数据小数位数

@end


@implementation MHBaseLineChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initialLineChartView];
    }
    return self;
}

- (void)dealloc
{
    [chartPointArr release];
    [_xAxisDataArr release];
    [_yAxisDataArr release];
    [chartView release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [[chartView.layer sublayers] makeObjectsPerformSelector:@selector(removeAllAnimations)];
    [[chartView.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    

    if([self.yAxisDataArr count] == 0 || [self.xAxisDataArr count] == 0){
        return;
    }
    
    [self dealWithAcquireData];
    [self drawBackgroundLine];
    [self drawYAxisText];
    [self drawXAxisText];
    [self drawChartPoint];

    
}

- (void)reloadAndShowLineChart
{
    [self setNeedsDisplay];
}

#pragma mark - 赋值
- (void)setXAxisDataArr:(NSArray *)xAxisDataArr
{
    if(_xAxisDataArr != nil){
        [_xAxisDataArr release];
        _xAxisDataArr = nil;
    }
    _xAxisDataArr = [xAxisDataArr copy];
}

- (void)setYAxisDataArr:(NSArray *)yAxisDataArr
{
    if(_yAxisDataArr != nil){
        [_yAxisDataArr release];
        _yAxisDataArr = nil;
    }
    _yAxisDataArr = [yAxisDataArr copy];
}

#pragma mark - 初始化
- (void)initialLineChartView
{
    chartPointArr = [[NSMutableArray alloc] init];
    self.yAxisValueDecimals = 0;
    chartViewLeftMargin = 10;
    chartViewTopMargin = 20;
    chartViewRightMargin = 5;
    chartViewBottomMargin = 25;
    chartView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    chartView.backgroundColor = [UIColor clearColor];
    
    yAxisPart = 7;
    
    [self addSubview:chartView];
    
}

#pragma mark - 处理数据
- (void)dealWithAcquireData
{
    yMaxAxisValue = CGFLOAT_MIN;
    yMinAxisValue = CGFLOAT_MAX;
    for(int i = 0 ; i < [_yAxisDataArr count]; i++){
        CGFloat value = [[NSDecimalNumber decimalNumberWithString:[_yAxisDataArr objectAtIndex:i]] doubleValue];
        if(yMaxAxisValue < value){
            yMaxAxisValue = value;
        }
        
        if(yMinAxisValue > value){
            yMinAxisValue = value;
        }
    }
    if(yMaxAxisValue == yMinAxisValue){
        yMinAxisValue = yMaxAxisValue * 0.5;
    }
    
    /** 获得小数位数*/
    self.yAxisValueDecimals = [TradeUtil decimalBitByStringValue:[_yAxisDataArr firstObject]];
    /** 计算y轴文字最长宽度*/
    yValueTextMaxWidth = CGFLOAT_MIN;
    CGFloat perYAxisValue = [[TradeUtil stringRoundDownFloatValue:((yMaxAxisValue - yMinAxisValue) / (CGFloat)(yAxisPart - 1)) dotBits:self.yAxisValueDecimals] doubleValue];
    for(int i = 0; i < yAxisPart; i++){
        NSString *string = [TradeUtil stringRoundDownFloatValue:(yMaxAxisValue - i * perYAxisValue) dotBits:self.yAxisValueDecimals];
        CGSize size = [CommonUtil getPerfectSizeByText:string andFontSize:10.0f andWidth:1000];
        if(yValueTextMaxWidth < size.width){
            yValueTextMaxWidth = size.width;
        }
    }
    
    
}

#pragma mark -  画辅助线
- (void)drawBackgroundLine
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth =  0.5;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    UIColor *strokeColor = RGBA(247, 247, 247, 1.0);
    [strokeColor set];
    CGFloat perPartHeight = (chartView.frame.size.height - chartViewTopMargin - chartViewBottomMargin) / (CGFloat)(yAxisPart - 1);
    for(int i = 0; i < yAxisPart; i++){
        [path moveToPoint:CGPointMake(chartViewLeftMargin + yValueTextMaxWidth, chartViewTopMargin + i * perPartHeight)];
        [path addLineToPoint:CGPointMake(chartView.frame.size.width - chartViewBottomMargin,chartViewTopMargin + i * perPartHeight)];
        [path stroke];
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [chartView.layer addSublayer:shapeLayer];
    
}

#pragma mark - 画y轴文字
- (void)drawYAxisText
{
    NSDictionary *dictAttributesCN = @{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:RGBA(61, 58, 80, 0.4)};
    CGFloat perYAxisValue = [[TradeUtil stringRoundDownFloatValue:((yMaxAxisValue - yMinAxisValue) / (CGFloat)(yAxisPart - 1)) dotBits:self.yAxisValueDecimals] doubleValue];
    CGFloat perPartHeight = (chartView.frame.size.height - chartViewTopMargin - chartViewBottomMargin) / (CGFloat)(yAxisPart - 1);
    for(int i = 0; i < yAxisPart; i++){
        NSString *string = [TradeUtil stringRoundDownFloatValue:(yMaxAxisValue - i * perYAxisValue) dotBits:self.yAxisValueDecimals];
        CGSize size = [CommonUtil getPerfectSizeByText:string andFontSize:10.0f andWidth:1000];
        [string drawAtPoint:CGPointMake(chartViewLeftMargin, chartViewTopMargin + i * perPartHeight - size.height / 2.0f) withAttributes:dictAttributesCN];
    }
    
}

#pragma mark - 画x轴文字
- (void)drawXAxisText
{
    NSDictionary *dictAttributesCN = @{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:RGBA(61, 58, 80, 0.6)};
    CGFloat xDataTextOriginY = chartView.frame.size.height - chartViewBottomMargin + 9;
    if([_xAxisDataArr count] == 1){
        NSString *string = [_xAxisDataArr lastObject];
        [string drawAtPoint:CGPointMake(chartViewLeftMargin + 3, xDataTextOriginY) withAttributes:dictAttributesCN];
    }else{
        for(int i = 0; i < 2; i++){
            if(i == 0 ){
                NSString *string = [_xAxisDataArr objectAtIndex:i];
                [string drawAtPoint:CGPointMake(chartViewLeftMargin + 3, xDataTextOriginY) withAttributes:dictAttributesCN];
            }else if(i == [_xAxisDataArr count] - 1){
                NSString *string = [_xAxisDataArr objectAtIndex:i];
                 CGSize size = [CommonUtil getPerfectSizeByText:string andFontSize:10.0f andWidth:1000];
                [string drawAtPoint:CGPointMake(chartView.frame.size.width - chartViewRightMargin - size.width, xDataTextOriginY) withAttributes:dictAttributesCN];
            }
        }
    }
}

#pragma mark - 画点
- (void)drawChartPoint
{
    CGFloat perXAxisWidth = (chartView.frame.size.width - chartViewLeftMargin - chartViewRightMargin) / (CGFloat)([_yAxisDataArr count] - 1);
    CGFloat yAxisValueGap = yMaxAxisValue - yMinAxisValue;
    CGFloat yAxisTotalHeight = chartView.frame.size.height - chartViewTopMargin - chartViewBottomMargin;
    //计算每个点的坐标
    [chartPointArr removeAllObjects];
    for(int i = 0 ; i < [_yAxisDataArr count]; i++){
        CGFloat yValue  = [[_yAxisDataArr objectAtIndex:i] doubleValue];
        CGFloat percentage = (CGFloat)(yValue - yMinAxisValue) / yAxisValueGap;
        CGFloat height = yAxisTotalHeight * percentage;
        CGPoint point = CGPointMake(chartViewLeftMargin + perXAxisWidth * i, chartView.frame.size.height - chartViewBottomMargin - height);
        NSValue *pointValue = [NSValue valueWithCGPoint:point];
        [chartPointArr addObject:pointValue];
    }
    
    /** 额外添加一个开头和结束来画3元贝塞尔曲线*/
    NSInteger count = [_yAxisDataArr count] + 1;
    CGPoint tempFirstPoint =  [[chartPointArr firstObject] CGPointValue];
    [chartPointArr insertObject:[NSValue valueWithCGPoint:CGPointMake(chartViewLeftMargin - perXAxisWidth, tempFirstPoint.y)] atIndex:0];
    CGPoint tempLastPoint = [[chartPointArr lastObject] CGPointValue];
    [chartPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(chartViewLeftMargin + perXAxisWidth * count, tempLastPoint.y)]];
    
    
    if([chartPointArr count] <= 3){         //如果只有3个数据，证明只有1个点，这时候无需进行绘画
        return;
    }
    
    //取得起点
    UIBezierPath *beizer = [UIBezierPath bezierPath];
    
    
    //添加线
    for (int i = 0;i < [chartPointArr count] - 3;i++ )
    {
        CGPoint p1 = [[chartPointArr objectAtIndex:i] CGPointValue];
        CGPoint p2 = [[chartPointArr objectAtIndex:i+1] CGPointValue];
        CGPoint p3 = [[chartPointArr objectAtIndex:i+2] CGPointValue];
        CGPoint p4 = [[chartPointArr objectAtIndex:i+3] CGPointValue];
        if(i == 0){
            [beizer moveToPoint:p2];
        }
        [self getControlPointx0:p1.x andy0:p1.y x1:p2.x andy1:p2.y x2:p3.x andy2:p3.y x3:p4.x andy3:p4.y bezierPath:beizer];
    }
    
    //显示线
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = beizer.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor colorWithRed:255/255.0 green:143/255.0  blue:1/255.0  alpha:1].CGColor;
    shapeLayer.lineWidth = 1;
    [chartView.layer addSublayer:shapeLayer];
    
    //设置动画
    CABasicAnimation *anmi = [CABasicAnimation animation];
    anmi.keyPath = @"strokeEnd";
    anmi.fromValue = [NSNumber numberWithFloat:0];
    anmi.toValue = [NSNumber numberWithFloat:1.0f];
    anmi.duration =2.0f;
    anmi.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi.autoreverses = NO;
    [shapeLayer addAnimation:anmi forKey:@"stroke"];
    
    
    //遮罩层相关
    UIBezierPath *bezier1 = [UIBezierPath bezierPath];
    bezier1.lineCapStyle = kCGLineCapRound;
    bezier1.lineJoinStyle = kCGLineJoinMiter;
    CGPoint p1 = [[chartPointArr objectAtIndex:1] CGPointValue];       //因为为了计算平滑的贝塞尔曲线，在点数组前后各增加了一个对比值，但无实际用途，所以获取坐标应该从索引1开始
    [bezier1 moveToPoint:p1];
    CGPoint lastPoint;
    for (int i = 0;i<chartPointArr.count - 3;i++ )
    {
        CGPoint p1 = [[chartPointArr objectAtIndex:i] CGPointValue];
        CGPoint p2 = [[chartPointArr objectAtIndex:i+1] CGPointValue];
        CGPoint p3 = [[chartPointArr objectAtIndex:i+2] CGPointValue];
        CGPoint p4 = [[chartPointArr objectAtIndex:i+3] CGPointValue];
        
        [self getControlPointx0:p1.x andy0:p1.y x1:p2.x andy1:p2.y x2:p3.x andy2:p3.y x3:p4.x andy3:p4.y bezierPath:bezier1];

        
    }
    //获取最后一个点的X值
    lastPoint = [[chartPointArr objectAtIndex:chartPointArr.count - 2] CGPointValue];//因为为了计算平滑的贝塞尔曲线，在点数组前后各增加了一个对比值，但无实际用途，所以获取坐标应该倒数第二个
    CGFloat lastPointX = lastPoint.x;
    CGPoint lastPointX1 = CGPointMake(lastPointX,chartView.frame.size.height - chartViewBottomMargin);
    [bezier1 addLineToPoint:lastPointX1];
    //回到原点
    [bezier1 addLineToPoint:CGPointMake(p1.x, chartView.frame.size.height - chartViewBottomMargin)];
    [bezier1 addLineToPoint:p1];
    
    CAShapeLayer *shadeLayer = [CAShapeLayer layer];
    shadeLayer.path = bezier1.CGPath;
    shadeLayer.fillColor = [UIColor colorWithRed:255/255.0 green:143/255.0  blue:1/255.0  alpha:1].CGColor;
    [chartView.layer addSublayer:shadeLayer];
    
    
    //渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, 0, chartView.bounds.size.height - chartViewBottomMargin);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.cornerRadius = 5;
    gradientLayer.masksToBounds = YES;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:143/255.0  blue:1/255.0  alpha:0.6].CGColor,(__bridge id)[UIColor colorWithRed:255/255.0 green:143/255.0  blue:1/255.0  alpha:0.2].CGColor];
    gradientLayer.locations = @[@(0.5f)];
    
    CALayer *baseLayer = [CALayer layer];
    [baseLayer addSublayer:gradientLayer];
    [baseLayer setMask:shadeLayer];
    [chartView.layer addSublayer:baseLayer];
    
    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds";
    anmi1.duration = 2.0f;
    anmi1.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 2*lastPoint.x, chartView.bounds.size.height - chartViewBottomMargin)];
    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi1.fillMode = kCAFillModeForwards;
    anmi1.autoreverses = NO;
    anmi1.removedOnCompletion = NO;
    [gradientLayer addAnimation:anmi1 forKey:@"bounds"];
    
}

/** 画贝塞尔点*/
- (void)getControlPointx0:(CGFloat)x0 andy0:(CGFloat)y0
                       x1:(CGFloat)x1 andy1:(CGFloat)y1
                       x2:(CGFloat)x2 andy2:(CGFloat)y2
                       x3:(CGFloat)x3 andy3:(CGFloat)y3
                  bezierPath:(UIBezierPath *)bezierPath
{
    CGFloat smooth_value =0.6;
    CGFloat ctrl1_x;
    CGFloat ctrl1_y;
    CGFloat ctrl2_x;
    CGFloat ctrl2_y;
    CGFloat xc1 = (x0 + x1) /2.0;
    CGFloat yc1 = (y0 + y1) /2.0;
    CGFloat xc2 = (x1 + x2) /2.0;
    CGFloat yc2 = (y1 + y2) /2.0;
    CGFloat xc3 = (x2 + x3) /2.0;
    CGFloat yc3 = (y2 + y3) /2.0;
    CGFloat len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
    CGFloat len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
    CGFloat len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
    CGFloat k1 = len1 / (len1 + len2);
    CGFloat k2 = len2 / (len2 + len3);
    CGFloat xm1 = xc1 + (xc2 - xc1) * k1;
    CGFloat ym1 = yc1 + (yc2 - yc1) * k1;
    CGFloat xm2 = xc2 + (xc3 - xc2) * k2;
    CGFloat ym2 = yc2 + (yc3 - yc2) * k2;
    ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
    ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
    ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
    ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
    [bezierPath addCurveToPoint:CGPointMake(x2, y2) controlPoint1:CGPointMake(ctrl1_x, ctrl1_y) controlPoint2:CGPointMake(ctrl2_x, ctrl2_y)];
}

@end
