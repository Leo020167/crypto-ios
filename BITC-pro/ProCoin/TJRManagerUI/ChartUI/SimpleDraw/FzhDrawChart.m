//
//  FzhDrawChart.m
//  DrawPicture
//
//  Created by fuzheng on 16/12/02.
//  Copyright © 2016年 fuzheng. All rights reserved.
//

#import "FzhDrawChart.h"
#import "CommonUtil.h"

#define margin      30
#define leftMargin  50
#define BottomMargin 30
#define topMargin  30
#define rightMargin 50

// 颜色RGB
#define zzColor(r, g, b)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define zzColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// 随机色
#define zzRandomColor  zzColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@implementation FzhDrawChart

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.zzWidth = frame.size.width;
        self.zzHeight = frame.size.height;
    }
    return self;
}



//画坐标轴
- (void)drawZuoBiaoXi:(NSArray *)x_itemArr
{
//    CAShapeLayer *layer = [CAShapeLayer layer];
//
//    UIBezierPath *path = [UIBezierPath bezierPath];

    //坐标轴原点
//    CGPoint rPoint = CGPointMake(1.3*margin, self.zzHeight-margin);
    
//    //画y轴
//    [path moveToPoint:rPoint];
//    [path addLineToPoint:CGPointMake(1.3*margin, margin)];
    
//    //画y轴的箭头
//    [path moveToPoint:CGPointMake(1.3*margin, margin)];
//    [path addLineToPoint:CGPointMake(1.3*margin-5, margin+5)];
//    [path moveToPoint:CGPointMake(1.3*margin, margin)];
//    [path addLineToPoint:CGPointMake(1.3*margin+5, margin+5)];

//    //画x轴
//    [path moveToPoint:rPoint];
//    [path addLineToPoint:CGPointMake(self.zzWidth-0.8*margin, self.zzHeight-margin)];
    
//    //画x轴的箭头
//    [path moveToPoint:CGPointMake(self.zzWidth-0.8*margin, self.zzHeight-margin)];
//    [path addLineToPoint:CGPointMake(self.zzWidth-0.8*margin-5, self.zzHeight-margin-5)];
//    [path moveToPoint:CGPointMake(self.zzWidth-0.8*margin, self.zzHeight-margin)];
//    [path addLineToPoint:CGPointMake(self.zzWidth-0.8*margin-5, self.zzHeight-margin+5)];
    
    //画x轴上的标度
//    for (int i=0; i<x_itemArr.count; i++) {
//
//        [path moveToPoint:CGPointMake(1.3*margin+(self.zzWidth-2*margin)/(x_itemArr.count+1)*(i+1), self.zzHeight-margin)];
//        [path addLineToPoint:CGPointMake(1.3*margin+(self.zzWidth-2*margin)/(x_itemArr.count+1)*(i+1), self.zzHeight-margin-3)];
//    }
    
//    //画y轴上的标度
//    for (int i=0; i<10; i++) {
//        [path moveToPoint:CGPointMake(1.3*margin, margin+(self.zzHeight-2*margin)/7*(i+1))];
//        [path addLineToPoint:CGPointMake(1.3*margin+3, margin+(self.zzHeight-2*margin)/7*(i+1))];
//    }
    
//    layer.path = path.CGPath;
//    layer.fillColor = [UIColor clearColor].CGColor;
//    layer.strokeColor = [UIColor whiteColor].CGColor;
//    layer.lineWidth = 2.0;
//    [self.layer addSublayer:layer];
    //计算y轴数值的最大值
//    NSInteger maxY =
//    
//    NSInteger maxYNum = 7;              //Y轴只有7个刻度
//    //给y轴加标注
//    for (int i=0; i < maxYNum; i++) {
//        CGFloat yLHeight = (self.zzHeight-2*margin)/11 <= 20 ? (self.zzHeight-2*margin)/11 : 20;
//        CGFloat yLWidth = yLHeight*2 >= 25 ? 25 : yLHeight*2;
//        CGFloat size = (self.zzHeight-2*margin)/11 <= 20 ? 7 : 12;
//        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(1.3*margin-yLWidth-5, margin+(self.zzHeight-2*margin)/11*(10-i+0.5), yLWidth, yLHeight)];
//        lab.text = [NSString stringWithFormat:@"%d", 10*i];
//        lab.textColor = [UIColor blackColor];
////        lab.adjustsFontSizeToFitWidth = YES;
//        lab.font = [UIFont boldSystemFontOfSize:size];
//        lab.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:lab];
//    }
}

//画柱状图
- (void)drawZhuZhuangTu:(NSArray *)x_itemArr and:(NSArray *)y_itemArr andPrice:(NSArray *)y_priceArr
{
    [self initDrawView];
    
    //建立坐标轴
//    [self drawZuoBiaoXi:x_itemArr];
    
    CGFloat maxHeight = self.zzHeight- BottomMargin - topMargin;
    CGFloat maxWidth = self.zzWidth - leftMargin - rightMargin;
    
    //给Y轴加标注
    NSInteger maxNum = [[y_itemArr objectAtIndex:0] integerValue];          //Y轴最大数量
    for(id temp in y_itemArr){
        NSInteger num = [temp integerValue];
        if(maxNum < num){
            maxNum = num;
        }
    }
    NSInteger totalGradu = 7;
    CGFloat yPerHeight = maxHeight/(totalGradu - 1);
    
    
    NSInteger perGraduateNum = (maxNum/100/(totalGradu - 1)) * 100 +  (maxNum/100%(totalGradu - 1)) * 100;            //获得每个刻度的数值
    
    //画左边Y轴数据
    for (NSInteger i=0; i < totalGradu; i++) {
        CGSize size = [CommonUtil getPerfectLabelTextWidth:[NSString stringWithFormat:@"%@",@(perGraduateNum * (totalGradu - 1))] andFontSize:10.0f andHeight:21];
        CGFloat maxLabWidth = size.width;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin-maxLabWidth-5, self.zzHeight- BottomMargin - yPerHeight*i - 6, maxLabWidth, 12)];
        lab.text = [NSString stringWithFormat:@"%@", @(perGraduateNum * i)];
        lab.textColor = [UIColor whiteColor];
//        lab.adjustsFontSizeToFitWidth = YES;
        lab.font = [UIFont systemFontOfSize:10.0f];
        lab.textAlignment = NSTextAlignmentRight;
        [self addSubview:lab];
    }
    
    
    //画柱状图
    CGFloat columnPercent = 0.0;            //柱形图占平均分配的宽度的占比
    if(x_itemArr.count < 3){            //避免只有一个或者2个数据时，柱形图宽度过大
        columnPercent = 0.3;
    }else{
        columnPercent = 0.7;
    }
    for (int i=0; i<x_itemArr.count; i++) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(maxWidth / x_itemArr.count * (i + (1 - columnPercent)/2.0f) + leftMargin,
                                                self.zzHeight - BottomMargin - maxHeight *([y_itemArr[i] integerValue] / (CGFloat)(perGraduateNum * (totalGradu - 1))),
                                                maxWidth / x_itemArr.count * columnPercent,
                                                maxHeight *([y_itemArr[i] integerValue] / (CGFloat)(perGraduateNum * (totalGradu - 1))))];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.fillColor = RGBA(255, 68, 68, 1.0).CGColor;
        layer.strokeColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:layer];
    }
    
    
    
    //给x轴加标注
    
    for (int i=0; i<x_itemArr.count; i++) {

       
        CGFloat xLWidth = maxWidth / x_itemArr.count * 0.8f;
        CGFloat xLCenter = maxWidth / x_itemArr.count * (i + (1 - columnPercent)/2.0f) +  (maxWidth / x_itemArr.count * columnPercent)/2.0f + leftMargin;
                                                                                      
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(xLCenter - xLWidth/2.0f, self.zzHeight - BottomMargin + 5, xLWidth, 16)];
        lab.text = x_itemArr[i];
        lab.font = [UIFont systemFontOfSize:10.0f];
        lab.textColor = [UIColor whiteColor];
        lab.adjustsFontSizeToFitWidth = YES;
        lab.minimumScaleFactor = 0.5;
        //        lab.font = [UIFont boldSystemFontOfSize:10];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
    }
//    [self addXBiaoZhu:x_itemArr];
    
    
    //================折线图==========
    CGFloat maxPrice = [[y_priceArr objectAtIndex:0] floatValue];          //Y轴最大价格数量
    for(id temp in y_priceArr){
        CGFloat num = [temp floatValue];
        if(maxPrice < num){
            maxPrice = num;
        }
    }
    CGFloat perPriceNum = [[NSString stringWithFormat:@"%.2f",ceilf(maxPrice) / (CGFloat)(totalGradu - 1)] floatValue];
    for (NSInteger i = 0; i < totalGradu; i++) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(self.zzWidth - rightMargin, self.zzHeight- BottomMargin - yPerHeight*i - 6, rightMargin, 12)];
        lab.text = [NSString stringWithFormat:@"%.2f", perPriceNum * i];
        lab.textColor = [UIColor whiteColor];
        //        lab.adjustsFontSizeToFitWidth = YES;
        lab.font = [UIFont systemFontOfSize:10.0f];
        lab.textAlignment = NSTextAlignmentLeft;
        [self addSubview:lab];
    }
    
    CGFloat startPointX = maxWidth / x_itemArr.count * ((1 - columnPercent)/2.0f) +  (maxWidth / x_itemArr.count * columnPercent)/2.0f + leftMargin;
    CGFloat startPointY = self.zzHeight - BottomMargin - maxHeight *([y_priceArr[0] floatValue] / (CGFloat)(perPriceNum * (totalGradu - 1)));
    CGPoint startPoint = CGPointMake(startPointX, startPointY);
    CGPoint endPoint;
    
    for (int i=0; i<y_priceArr.count; i++) {
        CGFloat endPointX = maxWidth / x_itemArr.count * (i + (1 - columnPercent)/2.0f) +  (maxWidth / x_itemArr.count * columnPercent)/2.0f + leftMargin;
        CGFloat endPointY = self.zzHeight - BottomMargin - maxHeight *([y_priceArr[i] floatValue] / (CGFloat)(perPriceNum * (totalGradu - 1)));
        
        endPoint = CGPointMake(endPointX, endPointY);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path addArcWithCenter:endPoint radius:1.5 startAngle:0 endAngle:2*M_PI clockwise:YES];
        [path addLineToPoint:endPoint];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.fillColor = RGBA(220, 220, 220, 1.0).CGColor;
        layer.strokeColor = RGBA(220, 220, 220, 1.0).CGColor;
        layer.lineWidth = 1.0;
        [self.layer addSublayer:layer];
        
        //        CAShapeLayer *layer1 = [CAShapeLayer layer];
        //        layer1.frame = CGRectMake(endPoint.x, endPoint.y, 5, 5);
        //        layer1.backgroundColor = [UIColor blackColor].CGColor;
        //        [self.layer addSublayer:layer1];
        
        
        
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(endPointX - 25, endPointY + 5, 50, 12)];
        lab.text = [NSString stringWithFormat:@"%.2f", [y_priceArr[i] floatValue]];
        lab.textColor = [UIColor whiteColor];
        //        lab.adjustsFontSizeToFitWidth = YES;
        lab.font = [UIFont systemFontOfSize:10.0f];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
        
        startPoint = endPoint;
        
    }
    
    
}

//画饼形图
- (void)drawBingZhuangTu:(NSArray *)x_itemArr and:(NSArray *)y_itemArr
{
    [self initDrawView];
    
    CGPoint yPoint = CGPointMake(self.zzWidth/2, self.zzHeight/2);
    CGFloat startAngle = 0;
    CGFloat endAngle;
    float r = (self.zzHeight -  2*margin) / 2;
    
    //求和
    float sum=0;
    for (NSString *str in y_itemArr) {
        
        sum += [str floatValue];
    }
    
    for (int i=0; i<x_itemArr.count; i++) {
        
        //求每一个的占比
        float zhanbi = [y_itemArr[i] floatValue]/sum;
        
        endAngle = startAngle + zhanbi*2*M_PI;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:yPoint radius:r startAngle:startAngle endAngle:endAngle clockwise:YES];
        [path addLineToPoint:yPoint];
        [path closePath];
        
        CGFloat bLWidth = 80;
        if( i == 0){
            bLWidth = 120;
        }
        CGFloat lab_x = yPoint.x + (r + bLWidth/2) * cos((startAngle + (endAngle - startAngle)/2)) - bLWidth/2;
        CGFloat lab_y = yPoint.y + (r + bLWidth*3/9) * sin((startAngle + (endAngle - startAngle)/2)) - bLWidth*3/9;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(lab_x, lab_y, bLWidth, bLWidth*3/4)];
        lab.text = [NSString stringWithFormat:@"%@\n%.2f%@",x_itemArr[i],zhanbi*100,@"%"];
        lab.textColor = [UIColor whiteColor];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:12.0f];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
        
        layer.path = path.CGPath;
        if(i == 0){
            layer.fillColor = RGBA(255, 149, 149, 1.0).CGColor;
        }else if(i == 1){
            layer.fillColor = RGBA(255, 69, 69, 1.0).CGColor;
        }else{
            layer.fillColor = RGBA(255, 209, 209, 1.0).CGColor;
        }
        
        layer.strokeColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:layer];

        startAngle = endAngle;
    }
}

//画折线图
- (void)drawZheXianTu:(NSArray *)x_itemArr and:(NSArray *)y_itemArr
{
    [self initDrawView];
    
    [self drawZuoBiaoXi:x_itemArr];
    
    CGPoint startPoint = CGPointMake(1.3*margin+(self.zzWidth-2*margin)/(x_itemArr.count+1), self.zzHeight-margin-(self.zzHeight-2*margin)/11*[y_itemArr[0] floatValue]/10);
    CGPoint endPoint;
    
    for (int i=0; i<x_itemArr.count; i++) {
    
        endPoint = CGPointMake(1.3*margin+(self.zzWidth-2*margin)/(x_itemArr.count+1)*(i+1), self.zzHeight-margin-(self.zzHeight-2*margin)/11*[y_itemArr[i] floatValue]/10);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path addArcWithCenter:endPoint radius:1.5 startAngle:0 endAngle:2*M_PI clockwise:YES];
        [path addLineToPoint:endPoint];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.strokeColor = [UIColor redColor].CGColor;
        layer.lineWidth = 1.0;
        [self.layer addSublayer:layer];
        
//        CAShapeLayer *layer1 = [CAShapeLayer layer];
//        layer1.frame = CGRectMake(endPoint.x, endPoint.y, 5, 5);
//        layer1.backgroundColor = [UIColor blackColor].CGColor;
//        [self.layer addSublayer:layer1];
        
        //绘制虚线
        [self drawXuxian:endPoint];
        
        startPoint = endPoint;
    }
    
    //给x轴加标注
    [self addXBiaoZhu:x_itemArr];
}

-(void)addXBiaoZhu:(NSArray *)x_itemArr
{
    for (int i=0; i<x_itemArr.count; i++) {
        CGFloat xLWidth = ((self.zzWidth-2*margin)/(x_itemArr.count+1)) <= 25 ? ((self.zzWidth-2*margin)/(x_itemArr.count+1)) : 25;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(1.3*margin+(self.zzWidth-2*margin)/(x_itemArr.count+1)*(i+1)-xLWidth/2, self.zzHeight-margin, xLWidth, 20)];
        lab.text = x_itemArr[i];
        lab.textColor = [UIColor blackColor];
        lab.adjustsFontSizeToFitWidth = YES;
        //        lab.font = [UIFont boldSystemFontOfSize:10];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
    }
}

//绘制虚线
- (void)drawXuxian:(CGPoint)point
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    [shapeLayer setStrokeColor:[UIColor blackColor].CGColor];

    [shapeLayer setLineWidth:1];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //设置虚线的线宽及间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil]];
    
    //创建虚线绘制路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    //设置y轴方向的虚线
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    CGPathAddLineToPoint(path, NULL, point.x, self.zzHeight-margin);

    //设置x轴方向的虚线
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    CGPathAddLineToPoint(path, NULL, 1.3*margin, point.y);
    
    //设置虚线绘制路径
    [shapeLayer setPath:path];
    CGPathRelease(path);
   
    [self.layer addSublayer:shapeLayer];
}

- (void)initDrawView
{
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}

@end
