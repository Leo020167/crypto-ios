//
//  HomeLineChartView.m
//  CCLineChart
//
//  Created by CC on 2018/5/6.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CMLineCharView.h"

#define XAxisTextWidth  40
#define LineChartViewTopMargin 25
#define AxisTextColor [UIColor colorWithRed:61/255.0 green:58/255.0  blue:80/255.0  alpha:0.4]
#define HenLineColor [UIColor colorWithRed:230/255.0 green:230/255.0  blue:230/255.0  alpha:1]

@interface CMLineCharView ()

@property (nonatomic, strong) UIView  *contentView;
@property (nonatomic,strong)UIView *lineChartView;
@property (nonatomic,strong)NSMutableArray *pointCenterArr;
@end


@implementation CMLineCharView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        
        [self addLineChartView];
        
        self.pointCenterArr = [NSMutableArray array];   
    }
    return self;
    
}
#pragma mark - 外部赋值
//外部Y坐标轴赋值
-(void)setDataArrOfY:(NSArray *)dataArrOfY
{
    _dataArrOfY = dataArrOfY;
    [self addYAxisViews];
}

//外部X坐标轴赋值
-(void)setDataArrOfX:(NSArray *)dataArrOfX
{
    _dataArrOfX = dataArrOfX;
    [self addXAxisViews];
    [self addLinesView];
}

//点数据
-(void)setDataArrOfPoint:(NSArray *)dataArrOfPoint
{
    _dataArrOfPoint = dataArrOfPoint;
    [self addPointView];
    [self addBezierLine];
}

#pragma mark - UI
- (void)addLineChartView
{
    _lineChartView = [[UIView alloc]initWithFrame:CGRectMake(XAxisTextWidth, LineChartViewTopMargin, _contentView.bounds.size.width - XAxisTextWidth - 15, _contentView.bounds.size.height - LineChartViewTopMargin * 2)];
    _lineChartView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_lineChartView];
}

/** Y轴文字*/
-(void)addYAxisViews
{
    CGFloat height = _lineChartView.bounds.size.height / (_dataArrOfY.count - 1);
    for (int i = 0;i< _dataArrOfY.count ;i++ )
    {
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, height * i - height / 2 + LineChartViewTopMargin, XAxisTextWidth - 5, height)];
        leftLabel.font = [UIFont systemFontOfSize:9];
        leftLabel.textColor = AxisTextColor;
        leftLabel.textAlignment = NSTextAlignmentRight;
        leftLabel.text = _dataArrOfY[i];
        leftLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:leftLabel];
    }
}

/** X轴文字*/
-(void)addXAxisViews
{
//    CGFloat width = _lineChartView.bounds.size.width /( _dataArrOfX.count - 1);
    for (int i = 0;i< _dataArrOfX.count;i++ )
    {
        CGRect labelFrame = CGRectZero;
        if(i == 0){
            CGSize size = [self sizeOfStringWithMaxSize:CGSizeMake(1000, 20) textFont:9.0f aimString:_dataArrOfX[i]];
            labelFrame = CGRectMake(_lineChartView.frame.origin.x, _lineChartView.frame.origin.y + _lineChartView.frame.size.height, size.width, 20);
        }else{
            if(i == (_dataArrOfX.count - 1)){
                CGSize size = [self sizeOfStringWithMaxSize:CGSizeMake(1000, 20) textFont:9.0f aimString:_dataArrOfX[i]];
                labelFrame = CGRectMake(_lineChartView.frame.origin.x + _lineChartView.frame.size.width - size.width, _lineChartView.frame.origin.y + _lineChartView.frame.size.height, size.width, 20);
            }else{
                labelFrame = CGRectZero;
            }
        }
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:labelFrame];
        leftLabel.font = [UIFont systemFontOfSize:9];
        leftLabel.textColor = AxisTextColor;
        leftLabel.text = _dataArrOfX[i];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:leftLabel];
    }
    
}

-(void)addLinesView
{
    CGFloat yLineSpace = _lineChartView.bounds.size.height /( _dataArrOfY.count - 1);
//    CGFloat height = _lineChartView.bounds.size.width /( _dataArrOfX.count - 1);
    //横格
    for (int i = 0;i < _dataArrOfY.count  ;i++ )
    {
        UIView *hengView = [[UIView alloc] initWithFrame:CGRectMake(0, yLineSpace * i,_lineChartView.bounds.size.width , 0.5)];
        hengView.backgroundColor = HenLineColor;
        [_lineChartView addSubview:hengView];
    }
//    //竖格
//    for (int i = 0;i< _dataArrOfX.count - 2 ;i++ )
//    {
//
//        UIView *shuView = [[UIView alloc]initWithFrame:CGRectMake(height * (i + 1), 0, 0.5, _lineChartView.bounds.size.height)];
//        shuView.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0  blue:216/255.0  alpha:1];
//        [_lineChartView addSubview:shuView];
//    }
}

#pragma mark - 点和根据点画贝塞尔曲线
-(void)addPointView
{
    //区域高
    CGFloat height = self.lineChartView.bounds.size.height;
    //y轴最小值
    float arrmin = [_dataArrOfY[_dataArrOfY.count - 1] floatValue];
    //y轴最大值
    float arrmax = [_dataArrOfY[0] floatValue];
    //区域宽
    CGFloat width = self.lineChartView.bounds.size.width;
    //X轴间距
    float Xmargin = 0.0;
    if(_dataArrOfPoint.count <= 1){
        Xmargin = width;
    }else{
        Xmargin = width / (_dataArrOfPoint.count - 1 );
    }
    
    
    for (int i = 0; i<_dataArrOfPoint.count; i++)
    {
        //nowFloat是当前值
        float nowFloat = [_dataArrOfPoint[i] floatValue];
        //点点的x就是(竖着的间距 * i),y坐标就是()
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake((Xmargin)*i - 2 / 2, height - (nowFloat - arrmin)/(arrmax - arrmin) * height - 2 / 2 , 2, 2)];
//        v.backgroundColor = [UIColor blueColor];
//        [_lineChartView addSubview:v];
        
        NSValue *point = [NSValue valueWithCGPoint:v.center];
        [self.pointCenterArr addObject:point];
    }
    
}

-(void)addBezierLine
{
    //取得起点
    CGPoint p1 = [[self.pointCenterArr objectAtIndex:0] CGPointValue];
    UIBezierPath *beizer = [UIBezierPath bezierPath];
    [beizer moveToPoint:p1];
    
    //添加线
    for (int i = 0;i<self.pointCenterArr.count;i++ )
    {
        if (i != 0)
        {
            CGPoint prePoint = [[self.pointCenterArr objectAtIndex:i-1] CGPointValue];
            CGPoint nowPoint = [[self.pointCenterArr objectAtIndex:i] CGPointValue];
            [beizer addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
        }
    }
    //显示线
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = beizer.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor colorWithRed:97/255.0 green:117/255.0  blue:174/255.0  alpha:1].CGColor;
    shapeLayer.lineWidth = 2;
    [_lineChartView.layer addSublayer:shapeLayer];
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
    [bezier1 moveToPoint:p1];
    CGPoint lastPoint;
    for (int i = 0;i<self.pointCenterArr.count;i++ )
    {
        if (i != 0)
        {
            CGPoint prePoint = [[self.pointCenterArr objectAtIndex:i-1] CGPointValue];
            CGPoint nowPoint = [[self.pointCenterArr objectAtIndex:i] CGPointValue];
            [bezier1 addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
            if (i == self.pointCenterArr.count-1)
            {
                lastPoint = nowPoint;
            }
        }
    }
    //获取最后一个点的X值
    CGFloat lastPointX = lastPoint.x;
    CGPoint lastPointX1 = CGPointMake(lastPointX,_lineChartView.bounds.size.height);
    [bezier1 addLineToPoint:lastPointX1];
    //回到原点
    [bezier1 addLineToPoint:CGPointMake(p1.x, _lineChartView.bounds.size.height)];
    [bezier1 addLineToPoint:p1];
    
    CAShapeLayer *shadeLayer = [CAShapeLayer layer];
    shadeLayer.path = bezier1.CGPath;
    shadeLayer.fillColor = [UIColor colorWithRed:97/255.0 green:117/255.0  blue:174/255.0  alpha:1].CGColor;
    [_lineChartView.layer addSublayer:shadeLayer];
    
    
    //渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, 0, _lineChartView.bounds.size.height);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.cornerRadius = 5;
    gradientLayer.masksToBounds = YES;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:97/255.0 green:117/255.0  blue:174/255.0  alpha:0.6].CGColor,(__bridge id)[UIColor colorWithRed:97/255.0 green:117/255.0  blue:174/255.0  alpha:0.2].CGColor];
    gradientLayer.locations = @[@(0.5f)];

    CALayer *baseLayer = [CALayer layer];
    [baseLayer addSublayer:gradientLayer];
    [baseLayer setMask:shadeLayer];
    [_lineChartView.layer addSublayer:baseLayer];

    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds";
    anmi1.duration = 2.0f;
    anmi1.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 2*lastPoint.x, _lineChartView.bounds.size.height)];
    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi1.fillMode = kCAFillModeForwards;
    anmi1.autoreverses = NO;
    anmi1.removedOnCompletion = NO;
    [gradientLayer addAnimation:anmi1 forKey:@"bounds"]; 
}


/**
 *  返回字符串的占用尺寸
 *
 *  @param maxSize   最大尺寸
 *  @param fontSize  字号大小
 *  @param aimString 目标字符串
 *
 *  @return 占用尺寸
 */
- (CGSize)sizeOfStringWithMaxSize:(CGSize)maxSize textFont:(CGFloat)fontSize aimString:(NSString *)aimString
{
    return [[NSString stringWithFormat:@"%@",aimString] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    
}




@end
