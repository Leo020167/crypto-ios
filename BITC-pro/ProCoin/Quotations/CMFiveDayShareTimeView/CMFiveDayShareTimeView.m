//
//  CMFiveDayShareTimeView.m
//  ProCoin
//
//  Created by Hay on 2020/4/22.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "CMFiveDayShareTimeView.h"
#import "VeDateUtil.h"
#import "TradeUtil.h"
#import "CommonUtil.h"

@interface CMFiveDayShareTimeView()
{
    NSInteger numDecimalBit;            //价格小数位数
    CGFloat topBlankHeight;             //顶部预留空白高度
    CGFloat bottomBlankHeight;          //底部预留空白高度
    CGFloat backgroundLineWidth;        //背景辅助线的宽度
    
    CGFloat maxPrice;       //最高价
    CGFloat minPrice;       //最低价
    CGFloat midPrice;       //昨日收盘价
    
    NSMutableArray *shareTimeData;          //分数数据数组
    NSMutableArray *dataDateArr;            //日期数组
    NSInteger totalMinutes;         //总共301根数据
    CGFloat perMinuterWidth;        //每分钟占的宽度
    
    BOOL isNeedLongPressPoint;          //是否需要画长按点
    CGPoint longPressPoint;             //长按手指坐标
    
    CGFloat maxTradeVolume;             //最大成交量
    CGFloat minTradeVolume;             //最小成交量
}

/**
  @brief  目前占比暂时按照写死来设计，以后再进行修改
 */
/** 行情图占整个view高度的比例,默认为4*/
@property (assign, nonatomic) NSInteger mainViewHeightRatio;
/** 成交量占整个view高度的比例，默认为1*/
@property (assign, nonatomic) NSInteger volumeViewHeightRatio;
/** 分时图从左到右分成多少等份，默认为5*/
@property (assign, nonatomic) NSInteger totalColumn;
/** 分时图从上到下分成多少等份*/
@property (assign, nonatomic) NSInteger totalRow;

/** 每格的高度*/
@property (assign, nonatomic) CGFloat girdHeight;
/** 每格的宽度*/
@property (assign, nonatomic) CGFloat girdWidth;

/** 辅助线条颜色*/
@property (retain, nonatomic) UIColor *backgroundLineColor;

/** 显示长按点的价格*/
@property (retain, nonatomic) UILabel *longPressPriceLabel;
/** 显示长按点的时间*/
@property (retain, nonatomic) UILabel *longPressTimeLabel;


@end

@implementation CMFiveDayShareTimeView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        [self initShareTimeView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initShareTimeView];
    }
    return self;
}


- (void)dealloc
{
    [shareTimeData release];
    [dataDateArr release];
    [_shareTimeViewBackground release];
    [_backgroundLineColor release];
    [_longPressPriceLabel release];
    [_longPressTimeLabel release];
    [super dealloc];
}

#pragma mark - 初始化
- (void)initShareTimeView
{
    isNeedLongPressPoint = NO;
    shareTimeData = [[NSMutableArray alloc] init];
    dataDateArr = [[NSMutableArray alloc] init];
    totalMinutes = 301;
    topBlankHeight = 30;
    bottomBlankHeight = 20;
    backgroundLineWidth = 1;
    minPrice = 0.0;
    self.shareTimeViewBackground = RGBA(15, 24, 38, 1.0);
    self.mainViewHeightRatio = 4;
    self.volumeViewHeightRatio = 1;
    self.totalColumn = 5;
    self.totalRow = _mainViewHeightRatio + _volumeViewHeightRatio;
    self.backgroundLineColor = RGBA(220, 220, 220, 0.1);
    
    //创建长按点价格
    self.longPressPriceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 20)] autorelease];
    _longPressPriceLabel.layer.masksToBounds = YES;
    _longPressPriceLabel.layer.borderWidth = 1.0;
    _longPressPriceLabel.layer.borderColor = RGBA(255, 255, 255, 1.0).CGColor;
    _longPressPriceLabel.font = [UIFont systemFontOfSize:9];
    _longPressPriceLabel.textAlignment = NSTextAlignmentCenter;
    _longPressPriceLabel.textColor = [UIColor whiteColor];
    _longPressPriceLabel.backgroundColor = RGBA(49, 46, 65, 1.0);
    
    self.longPressTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 20)] autorelease];
    _longPressTimeLabel.layer.masksToBounds = YES;
    _longPressTimeLabel.layer.borderWidth = 1.0;
    _longPressTimeLabel.layer.borderColor = RGBA(255, 255, 255, 1.0).CGColor;
    _longPressTimeLabel.font = [UIFont systemFontOfSize:9];
    _longPressTimeLabel.textAlignment = NSTextAlignmentCenter;
    _longPressTimeLabel.textColor = [UIColor whiteColor];
    _longPressTimeLabel.backgroundColor = RGBA(49, 46, 65, 1.0);
    
    [self addLongPressGestureRecognizer];   //添加长按手势，主要用于查看某个分时点的信息
    
    
    [self setNeedsDisplay];
    
}

#pragma mark - 计算
- (void)calculateViewData
{
    maxPrice = CGFLOAT_MIN;
    minPrice = CGFLOAT_MAX;
    maxTradeVolume = CGFLOAT_MIN;
    minTradeVolume = CGFLOAT_MAX;
    
    
    [dataDateArr removeAllObjects];
    NSString *preDateStr = @"";
    for(int i = 0; i < [shareTimeData count] ; i++){
        CMShareTimeBaseData *std = [shareTimeData objectAtIndex:i];
        if([std.last doubleValue] > maxPrice){
            maxPrice = [std.last doubleValue];
        }
        if([std.last doubleValue] < minPrice){
            minPrice = [std.last doubleValue];
        }
        
        if([std.currentVolume doubleValue] < minTradeVolume){
            minTradeVolume = [std.currentVolume doubleValue];
        }
        if([std.currentVolume doubleValue] > maxTradeVolume){
            maxTradeVolume = [std.currentVolume doubleValue];
        }
        NSString *currentDate = [VeDateUtil formatterDate:std.time inStytle:@"yyyyMMddHHmmss" outStytle:@"yyyyMMdd"];
        if(![currentDate isEqualToString:preDateStr]){
            [dataDateArr addObject:[VeDateUtil formatterDate:std.time inStytle:@"yyyyMMddHHmmss" outStytle:@"MM-dd"]];
            preDateStr = currentDate;
        }
    }
    if(maxPrice == minPrice){
        maxPrice = maxPrice * 1.2;
        minPrice = minPrice * 0.8;
    }
    midPrice = maxPrice - (maxPrice - minPrice)/2.0f;
    
    if(maxTradeVolume == minTradeVolume){
        maxTradeVolume = maxTradeVolume * 1.2;
        minTradeVolume = minTradeVolume * 0.8;
    }
    
    
//    if(fabs(maxPrice - midPrice) > fabs(midPrice - minPrice)){
//        minPrice = midPrice - fabs(maxPrice - midPrice);
//    }else{
//        maxPrice = midPrice + fabs(midPrice - minPrice);
//    }
    
    
}
#pragma mark - 获取数据
/** 增加总体行情数据*/
- (void)addFiveDayShareTimeViewHistoryData:(NSString *)historyData
{
    //解析数据，
    if (TTIsStringWithAnyText(historyData)) {
        _isHasHitory = YES;
        [shareTimeData removeAllObjects];
        NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:250];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+),([0-9]*[.]??[0-9]*),([0-9]*[.]??[0-9]*);" options:0 error:nil];
        NSArray *matches = [regex matchesInString:historyData options:0 range:NSMakeRange(0, historyData.length)];
        for (NSTextCheckingResult *m in matches) {
          //            timeString = [content substringWithRange:[m rangeAtIndex:1]];
            CMShareTimeBaseData *std = [[[CMShareTimeBaseData alloc] init] autorelease];
            std.time = [VeDateUtil formatterDate:[historyData substringWithRange:[m rangeAtIndex:1]] inStytle:nil outStytle:@"yyyyMMddHHmmss" isTimestamp:YES];
            std.last = [historyData substringWithRange:[m rangeAtIndex:2]];
            std.currentVolume = [historyData substringWithRange:[m rangeAtIndex:3]];
            [dataArr addObject:std];
            numDecimalBit = [TradeUtil decimalBitByStringValue:std.last];           //观察后台返回的数据，来定义一共显示多少位小数
        }
        [dataArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if([((CMShareTimeBaseData *)obj1).time integerValue] < [((CMShareTimeBaseData *)obj2).time integerValue]){
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        [shareTimeData addObjectsFromArray:dataArr];
        /** 计算必要的数据*/
        [self calculateViewData];
        [self setNeedsDisplay];
    }
}
 

#pragma mark - 画图
/** 总方法*/
- (void)drawRect:(CGRect)rect
{
    perMinuterWidth = self.frame.size.width / (CGFloat)totalMinutes;
    _girdWidth = self.frame.size.width / (CGFloat)_totalColumn;
    _girdHeight = (self.frame.size.height - topBlankHeight - bottomBlankHeight) / (CGFloat)_totalRow;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, _shareTimeViewBackground.CGColor);
    CGContextFillRect(context, rect);
    
    [self drawBackgroundLine:context];
    
    if([shareTimeData count] == 0)
        return;
    
    [self drawBackgroundLineText:context];
    [self drawShareTimePoint:context];
    [self fillShareTimeColor:context];
    [self drawVolumeChart:context];
    if(isNeedLongPressPoint){
        [self drawLongPressPointInfo:context];
    }else{
        [_longPressPriceLabel removeFromSuperview];
        [_longPressTimeLabel removeFromSuperview];
    }
}

/** 画辅助线*/
- (void)drawBackgroundLine:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    
    //画横线
    CGContextSetLineWidth(context, backgroundLineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    //突出中线
    NSInteger midLineIndex = _mainViewHeightRatio / 2;
    CGFloat lengths[] = {5,5};
    CGContextMoveToPoint(context,0.0,topBlankHeight + midLineIndex * _girdHeight);
    CGContextAddLineToPoint(context, self.frame.size.width, topBlankHeight + midLineIndex * _girdHeight);
    CGContextSetLineDash(context, 0, lengths,2);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, backgroundLineWidth);
    CGContextSetStrokeColorWithColor(context, _backgroundLineColor.CGColor);
    for(int i = 0; i <= _totalRow ; i++){
        if(i == _mainViewHeightRatio / 2){         //中线已经画出,不需要再画
            continue;
        }
        CGContextMoveToPoint(context, 0.0, topBlankHeight + i * _girdHeight);
        CGContextAddLineToPoint(context, self.frame.size.width, topBlankHeight + i * _girdHeight);
        CGContextStrokePath(context);
    }
    
    //画竖线
    for(int i = 0; i <= _totalColumn; i++){
        if(i == 0 || i == _totalColumn)
            continue;
        CGContextMoveToPoint(context, i * _girdWidth, 0.0);
        CGContextAddLineToPoint(context, i * _girdWidth, self.frame.size.height - bottomBlankHeight);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
}

/** 画辅助线的文字*/
- (void)drawBackgroundLineText:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    UIColor *textColor = RGBA(255, 255, 255, 0.6);
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    
    //画价格
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f",@(numDecimalBit)];
    NSString *drawPrice = @"";
    NSArray *priceArr = @[
        [NSString stringWithFormat:formatString,maxPrice],
        [NSString stringWithFormat:formatString,midPrice + (maxPrice - midPrice)/2.0f],
        [NSString stringWithFormat:formatString,midPrice],
        [NSString stringWithFormat:formatString,midPrice - (midPrice - minPrice)/2.0f],
        [NSString stringWithFormat:formatString,minPrice]
    ];
    for(int i = 0; i <= _mainViewHeightRatio; i++){
        drawPrice = [priceArr objectAtIndex:i];
        CGSize stringSize = [CommonUtil getPerfectSizeByText:drawPrice andFontSize:10.0f andWidth:1000];
        [drawPrice drawAtPoint:CGPointMake(self.frame.size.width - stringSize.width, (topBlankHeight + i * _girdHeight) - 15) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    }
    
    //画日期
    for(int i = 0; i < [dataDateArr count];i++){
        NSString *dateStr = [dataDateArr objectAtIndex:i];
        CGSize stringSize = [CommonUtil getPerfectSizeByText:dateStr andFontSize:10.0f andWidth:1000];
        CGFloat x = ((i + 1) * _girdWidth ) - _girdWidth / 2.0f - (stringSize.width / 2.0f);
        [dateStr drawAtPoint:CGPointMake(x, self.frame.size.height - 15) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    }
    
    //画百分比
    CGFloat topPricePercentage = (CGFloat)(maxPrice - midPrice) / midPrice;
    CGFloat halfTopPricePercentage = (CGFloat)topPricePercentage / 2.0f;
    CGFloat bottomPricePercentage = (CGFloat)(minPrice - midPrice) / midPrice;
    CGFloat halfBottomPricePercentage = (CGFloat)bottomPricePercentage / 2.0f;
    NSString *topStr = [NSString stringWithFormat:@"%.2f%%",topPricePercentage * 100];
    NSString *halfTopStr = [NSString stringWithFormat:@"%.2f%%",halfTopPricePercentage * 100];
    NSString *bottomStr = [NSString stringWithFormat:@"%.2f%%",bottomPricePercentage * 100];
    NSString *halfBottomStr = [NSString stringWithFormat:@"%.2f%%",halfBottomPricePercentage * 100];
    
    [topStr drawAtPoint:CGPointMake(0.0, topBlankHeight - 15) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    [halfTopStr drawAtPoint:CGPointMake(0.0, topBlankHeight + _girdHeight - 15) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    [halfBottomStr drawAtPoint:CGPointMake(0.0, topBlankHeight +( _mainViewHeightRatio - 1) * _girdHeight - 15) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    [bottomStr drawAtPoint:CGPointMake(0.0, topBlankHeight + _mainViewHeightRatio * _girdHeight - 15) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    
    
    
    CGContextRestoreGState(context);
}

/** 画行情点*/
- (void)drawShareTimePoint:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, RGBA(240, 140, 66, 0.7).CGColor);
    CGContextSetLineWidth(context, 1);
    CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - _girdHeight * (CGFloat)_volumeViewHeightRatio - bottomBlankHeight - topBlankHeight);    //行情图的高度
    
    //获得点坐标数组
    NSMutableArray *dataPointArr = [NSMutableArray array];
    NSInteger dateIndex = 0;
    NSInteger beginIndex = 0.0;
    
    for(NSInteger i = 0; i < [shareTimeData count]; i++){
        CMShareTimeBaseData *baseData = [shareTimeData objectAtIndex:i];
        if(dateIndex >= [dataDateArr count])
            break;
        NSString *dateStr = [dataDateArr objectAtIndex:dateIndex];
        if([dateStr isEqualToString:[VeDateUtil formatterDate:baseData.time inStytle:@"yyyyMMddHHmmss" outStytle:@"MM-dd"]]){
            CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - minPrice) / (CGFloat)(maxPrice - minPrice));
            CGFloat pointY = topBlankHeight + (mainViewHeight - (CGFloat)(mainViewHeight * lastPercentage));
            [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(0.0 + perMinuterWidth * i, pointY)]];
            if(i == [shareTimeData count] - 1){     //已经最后数据
                /** 额外添加一个开头和结束来画3元贝塞尔曲线*/
                [dataPointArr insertObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)beginIndex * perMinuterWidth, topBlankHeight + mainViewHeight / 2.0f)] atIndex:0];
                [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)i * perMinuterWidth, topBlankHeight + mainViewHeight / 2.0f)]];
                for (NSInteger i = 0; i < [dataPointArr count] - 3; i++) {
                    CGPoint p1 = [[dataPointArr objectAtIndex:i] CGPointValue];
                    CGPoint p2 = [[dataPointArr objectAtIndex:i+1] CGPointValue];
                    CGPoint p3 = [[dataPointArr objectAtIndex:i+2] CGPointValue];
                    CGPoint p4 = [[dataPointArr objectAtIndex:i+3] CGPointValue];
                    if (i == 0) {
                        CGContextMoveToPoint(context, p2.x, p2.y);
                    }
                    [self getControlPointx0:p1.x andy0:p1.y x1:p2.x andy1:p2.y x2:p3.x andy2:p3.y x3:p4.x andy3:p4.y context:context];
                }
                CGContextStrokePath(context);
            }
        }else{
            /** 额外添加一个开头和结束来画3元贝塞尔曲线*/
            [dataPointArr insertObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)beginIndex * perMinuterWidth, topBlankHeight + mainViewHeight / 2.0f)] atIndex:0];
            [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(i - 1) * perMinuterWidth, topBlankHeight + mainViewHeight / 2.0f)]];
            for (NSInteger i = 0; i < [dataPointArr count] - 3; i++) {
                CGPoint p1 = [[dataPointArr objectAtIndex:i] CGPointValue];
                CGPoint p2 = [[dataPointArr objectAtIndex:i+1] CGPointValue];
                CGPoint p3 = [[dataPointArr objectAtIndex:i+2] CGPointValue];
                CGPoint p4 = [[dataPointArr objectAtIndex:i+3] CGPointValue];
                if (i == 0) {
                    CGContextMoveToPoint(context, p2.x, p2.y);
                }
                [self getControlPointx0:p1.x andy0:p1.y x1:p2.x andy1:p2.y x2:p3.x andy2:p3.y x3:p4.x andy3:p4.y context:context];
            }
            CGContextStrokePath(context);
            [dataPointArr removeAllObjects];
            CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - minPrice) / (CGFloat)(maxPrice - minPrice));
            CGFloat pointY = topBlankHeight + (mainViewHeight - (CGFloat)(mainViewHeight * lastPercentage));
            [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(0.0 + perMinuterWidth * i, pointY)]];
            dateIndex++;
            beginIndex = i;
        }
        
    }
    CGContextRestoreGState(context);
}

/**填充颜色*/
- (void)fillShareTimeColor:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, 0.0, topBlankHeight + _girdHeight * _mainViewHeightRatio);                                //x轴的每格间距
    CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - _girdHeight * _volumeViewHeightRatio - bottomBlankHeight - topBlankHeight);     //行情图的高度
    for(NSInteger i = 0; i < [shareTimeData count] ; i++){
        CMShareTimeBaseData *baseData = [shareTimeData objectAtIndex:i];
        CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - minPrice) / (maxPrice - minPrice));
        CGFloat pointY = topBlankHeight + mainViewHeight - mainViewHeight * lastPercentage;
        CGContextAddLineToPoint(context, 0.0 + perMinuterWidth * i, pointY);
    }
    CGContextAddLineToPoint(context,perMinuterWidth * ([shareTimeData count] - 1),topBlankHeight + _girdHeight * _mainViewHeightRatio);
    CGContextClip(context);
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] =
    {
        240/255.0f,140/255.0f,66/255.0f,0.3,
        240/255.0f,140/255.0f,66/255.0f,0.2,
        240/255.0f,140/255.0f,66/255.0f,0.02,
        240/255.0f,140/255.0f,66/255.0f,0.02,
        240/255.0f,140/255.0f,66/255.0f,0.05,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(rgb);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(perMinuterWidth * ([shareTimeData count] - 1), topBlankHeight), CGPointMake(perMinuterWidth * ([shareTimeData count] - 1), topBlankHeight + _girdHeight * _mainViewHeightRatio), kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
}

/** 成交量*/
- (void)drawVolumeChart:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, RGBA(240, 140, 55, 1.0).CGColor);
    CGContextSetLineWidth(context, perMinuterWidth);
    CGFloat actualVolumeHeight = (CGFloat)((self.frame.size.height - _girdHeight * _mainViewHeightRatio - bottomBlankHeight - topBlankHeight)); //成交量图的高度
    CGFloat volumeHeight = actualVolumeHeight - 5;                                                         //减少多5为了不顶到上面，同时方便加一些数字
    for(NSInteger i = 0; i < [shareTimeData count] ; i++){
        CMShareTimeBaseData *baseData = [shareTimeData objectAtIndex:i];
        CGFloat volumePercentage = (CGFloat)(([baseData.currentVolume doubleValue] - minTradeVolume) / (maxTradeVolume - minTradeVolume));
        CGFloat pointY = topBlankHeight + _girdHeight * _mainViewHeightRatio + (actualVolumeHeight - volumeHeight * volumePercentage);
        if(pointY > self.frame.size.height - bottomBlankHeight - backgroundLineWidth){  //不能逆向画成交量
            pointY = self.frame.size.height - bottomBlankHeight - backgroundLineWidth - 1;
        }
        CGContextMoveToPoint(context, 0.0 + i * perMinuterWidth, self.frame.size.height - bottomBlankHeight - backgroundLineWidth);
        CGContextAddLineToPoint(context, 0.0 + i * perMinuterWidth , pointY);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);

}


/** 长按信息*/
- (void)drawLongPressPointInfo:(CGContextRef)context
{
    NSInteger index = floor((longPressPoint.x / perMinuterWidth));
    CGFloat distance = fabs((perMinuterWidth * index - longPressPoint.x));
    if(distance > (perMinuterWidth / 2.0f)){
        index += 1;
    }else{
        index = index;
    }
    if(index >= [shareTimeData count]){
        return;
    }
    CGFloat locationX = index * perMinuterWidth;
    //画线
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 0.0, longPressPoint.y - 0.5);
    CGContextAddLineToPoint(context, self.frame.size.width, longPressPoint.y - 0.5);
    CGContextStrokePath(context);
    //画点

    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, locationX, longPressPoint.y);
    CGContextAddArc(context, locationX, longPressPoint.y, 3, 0, 2 *M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    
    //画渐变竖线
    CGContextMoveToPoint(context, locationX - perMinuterWidth / 2.0f, 0.0);                                //x轴的每格间距
    CGContextAddLineToPoint(context,locationX + perMinuterWidth / 2.0f,0.0);
    CGContextAddLineToPoint(context,locationX + perMinuterWidth / 2.0f, self.frame.size.height);
    CGContextAddLineToPoint(context,locationX - perMinuterWidth/ 2.0f, self.frame.size.height);
    CGContextClip(context);
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] =
    {
        255/255.0f,255/255.0f,255/255.0f,0.05,
        255/255.0f,255/255.0f,255/255.0f,0.1,
        255/255.0f,255/255.0f,255/255.0f,0.3,
        255/255.0f,255/255.0f,255/255.0f,0.1,
        255/255.0f,255/255.0f,255/255.0f,0.05,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(rgb);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(locationX + 3,0.0), CGPointMake(locationX + 3, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    [_longPressPriceLabel removeFromSuperview];
    [_longPressTimeLabel removeFromSuperview];
    
    
    //添加文字
    CGSize constraint = CGSizeMake(20000.0f, 20);
    CMShareTimeBaseData *baseData = [shareTimeData objectAtIndex:index];
    CGSize lastSize = [baseData.last boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]} context:nil].size;
    if(locationX >= self.frame.size.width / 2.0f){          //手在右边，则文字放在左边
        _longPressPriceLabel.frame = CGRectMake(0.0, longPressPoint.y - 10, lastSize.width + 10, 20);
    }else{
        _longPressPriceLabel.frame = CGRectMake(self.frame.size.width - (lastSize.width + 10), longPressPoint.y - 10, lastSize.width + 10, 20);
    }
    _longPressPriceLabel.text = baseData.last;
    [self addSubview:_longPressPriceLabel];
    
    CGSize timeSize = [[VeDateUtil formatterDate:baseData.time inStytle:@"yyyyMMddHHmmss" outStytle:@"HH:mm"] boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]} context:nil].size;
    CGFloat timeX = locationX - (timeSize.width + 10)/2.0f;
    if(timeX <= 0)
        timeX = 0;
    if(timeX + timeSize.width + 10 >= self.frame.size.width)
        timeX = self.frame.size.width - (timeSize.width + 10);
        
    _longPressTimeLabel.frame = CGRectMake(timeX, self.frame.size.height - 20, timeSize.width + 10, 20);
    _longPressTimeLabel.text = [VeDateUtil formatterDate:baseData.time inStytle:@"yyyyMMddHHmmss" outStytle:@"HH:mm"];
    [self addSubview:_longPressTimeLabel];
    
}





#pragma mark - 画贝塞尔点
- (void)getControlPointx0:(CGFloat)x0 andy0:(CGFloat)y0
                       x1:(CGFloat)x1 andy1:(CGFloat)y1
                       x2:(CGFloat)x2 andy2:(CGFloat)y2
                       x3:(CGFloat)x3 andy3:(CGFloat)y3
                     context:(CGContextRef)context
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
    CGContextAddCurveToPoint(context, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, x2, y2);
}

#pragma mark - 手势
- (void)addLongPressGestureRecognizer
{
    UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)] autorelease];
    longPressRecognizer.numberOfTouchesRequired = 1;
    longPressRecognizer.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPressRecognizer];
}

- (void)longPressRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    if([shareTimeData count] == 0)
        return;
    CGPoint movePoint = [recognizer locationInView:self];
    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged){
        
        NSInteger index = floor((movePoint.x / perMinuterWidth));
        CGFloat distance = fabs((perMinuterWidth * index - movePoint.x));
        if(distance > (perMinuterWidth / 2.0f)){
            index += 1;
        }else{
            index = index;
        }
        if(index >= [shareTimeData count]){
            return;
        }
        isNeedLongPressPoint = YES;
        CMShareTimeBaseData *baseData = [shareTimeData objectAtIndex:index];
        CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - _girdHeight * _volumeViewHeightRatio - bottomBlankHeight - topBlankHeight);    //行情图的高度
        CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - minPrice) / (maxPrice - minPrice));
        CGFloat pointY = topBlankHeight + mainViewHeight - mainViewHeight * lastPercentage;
        
        longPressPoint = CGPointMake(movePoint.x, pointY);
        
        [self setNeedsDisplay];
        
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        isNeedLongPressPoint = NO;
        [self setNeedsDisplay];
    }
}




@end
