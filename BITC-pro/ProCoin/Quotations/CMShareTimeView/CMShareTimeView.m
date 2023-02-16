//
//  CMShareTimeView.m
//  Cropyme
//
//  Created by Hay on 2019/6/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CMShareTimeView.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"
#import "CMShareTimeBaseData.h"
#import "TradeUtil.h"
#import "VeDateUtil.h"
#import "QuotationPanGestureRecognizer.h"

@interface CMShareTimeView()<UIGestureRecognizerDelegate>
{
    CGFloat numDecimalBit;              //数字小数位数
    CGFloat topMargin;                  //顶部可以留一点空隙，让行情图更好看,同时留出写文字的空间
    CGFloat bottomMargin;               //保留底部一些空间，在上面写时间文字
    NSInteger perGridWidth;             //每一个单元格的宽度
    NSInteger perGridHeight;            //每一个单元格的高度
    CGFloat textHeight;                 //文字的高度
    
    CGFloat yAxisMaxValue;              //y轴最大值
    CGFloat yAxisMinValue;              //y轴最小值
    
    CGFloat maxTradeVolume;             //最大成交量
    CGFloat minTradeVolume;             //最小成交量
    
    NSInteger initViewMinuteCount;             //初始化页面显示的分钟数，会比最大显示分钟数少1格
    NSInteger totalMinuteCount;                //整屏幕最大显示的分钟数
    
    NSMutableArray *showDataArray;      //显示行情数据数组
    
    BOOL isArcViewExist;                //呼吸原点是否存在
    UIView *arcTopView;                 //呼吸原点顶部view
    UIView *arcFloorView;               //呼吸原点底部view
    
    CGFloat backgroundLineWidth;        //背景线条宽度
    
    CGPoint dragBeginPoint;             //开始滑动瞬间的坐标
    CGPoint dragEndPoint;               //结束滑动瞬间的坐标
    
    CGFloat currentZoomScale;           //当前缩放比例   1
    CGFloat perScaleFactor;             //每次缩放因子   0.2
    CGFloat maxZoomScale;               //最大缩放比例   2
    CGFloat minZoomScale;               //最小缩放比例  0.2
    CGFloat lastZoomScale;              //最后一次手势增加缩小的比例
    
    BOOL isNeedLongPressPoint;          //是否需要画长按点
    CGPoint longPressPoint;             //长按手指坐标
    CGFloat longPressVerticalLineWidth; //长按坐标竖线宽度
    
    NSRange showDataRange;              //显示行情数据的range
}

/** 每格所占有的分钟数,默认为10分钟*/
@property (assign, nonatomic) NSInteger eachGirdMinutes;
/** 每一分钟的距离间隔*/
@property (assign, nonatomic) CGFloat perDotXDistance;
/** 主页面行情图的占比 + 副页面成交量的占比*/
@property (assign, nonatomic) NSInteger viewTotalHeightRatio;
/** 分时行情数据,时间作为key,数据作为value,字典类型*/
@property (retain, nonatomic) NSMutableDictionary *shareTimeDataDic;

/** 显示当前价格按钮*/
@property (retain, nonatomic) UIButton *currentPriceButton;

/** 显示长按点的价格*/
@property (retain, nonatomic) UILabel *longPressPriceLabel;
/** 显示长按点的时间*/
@property (retain, nonatomic) UILabel *longPressTimeLabel;

@end

@implementation CMShareTimeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initShareTimeView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initShareTimeView];
    }
    return self;
}

- (void)dealloc
{
    [arcFloorView.layer removeAnimationForKey:@"animationGroup"];
    [showDataArray release];
    [arcTopView release];
    [arcFloorView release];
    [_shareTimeViewBackground release];
    [_shareTimeDataDic release];
    [_currentPriceButton release];
    [_longPressPriceLabel release];
    [_longPressTimeLabel release];
    [super dealloc];
}

#pragma mark - 初始化
- (void)initShareTimeView
{
    _isHasHitory = NO;
    isNeedLongPressPoint = NO;
    
    topMargin = 30;
    bottomMargin = 20;
    textHeight = 15;
    
    
    backgroundLineWidth = 1;
    
    longPressVerticalLineWidth = 6;
    perScaleFactor = 0.2;
    currentZoomScale = 0.2;
    maxZoomScale = 2;
    minZoomScale = 0.2;
    
    self.shareTimeViewBackground = RGBA(15, 24, 38, 1.0);
    self.mainViewHeightRatio = 4;
    self.volumeViewHeightRatio = 1;
    self.viewTotalHeightRatio = self.mainViewHeightRatio + self.volumeViewHeightRatio;
    self.totalColumn = 5;

    showDataArray = [[NSMutableArray alloc] init];
    self.shareTimeDataDic = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self resetBaseDrawCondition];      //设置画行情的基本条件
    
    //创建闪烁白色圆点
    CGFloat areViewRadius = 1.5;
    CGFloat areViewDiameter = areViewRadius * 2;
    arcFloorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, areViewDiameter, areViewDiameter)];
    [CommonUtil viewMasksToBounds:arcFloorView cornerRadius:areViewRadius borderColor:nil];
    arcFloorView.backgroundColor = RGBA(220, 220, 220, 1);
    arcTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, areViewDiameter, areViewDiameter)];
    [CommonUtil viewMasksToBounds:arcTopView cornerRadius:areViewRadius borderColor:nil];
    arcTopView.backgroundColor = [UIColor whiteColor];
    //创建按钮
    self.currentPriceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _currentPriceButton.titleLabel.font = [UIFont systemFontOfSize:9];
    [_currentPriceButton setTitleColor:RGBA(255, 255, 255, 0.5) forState:UIControlStateNormal];
    _currentPriceButton.layer.cornerRadius = 9.0f;
    _currentPriceButton.layer.masksToBounds = YES;
    _currentPriceButton.layer.borderWidth = 1.0;
    _currentPriceButton.layer.borderColor = RGBA(240, 140, 66, 0.7).CGColor;
    [_currentPriceButton setBackgroundColor:RGBA(49, 46, 65, 1.0)];
    [_currentPriceButton addTarget:self action:@selector(currentPriceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    
    
    [self addPanGestureRecognizer];         //添加滑动手势,主要用于拖动k线
    [self addLongPressGestureRecognizer];   //添加长按手势，主要用于查看某个分时点的信息
    [self addPinchGestureRecognizer];       //添加缩放手势，主要用于放大缩小分时图
    [self startArcViewAnimation];
}

#pragma mark - draw rect
- (void)drawRect:(CGRect)rect
{
    //高度减去30，,再减20为可让底部可以流出空间写时间
    CGFloat totalHeight = self.frame.size.height - topMargin - bottomMargin;
    perGridWidth = self.frame.size.width / _totalColumn;            //每一个单元格宽度
    perGridHeight = totalHeight / (CGFloat)_viewTotalHeightRatio;            //每一个单元格高度
    self.perDotXDistance = (CGFloat)(self.frame.size.width / (_eachGirdMinutes * _totalColumn));         //x轴的每格间距
    //初始化画布,重设背景
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, _shareTimeViewBackground.CGColor);
    CGContextFillRect(context, rect);
    //画出背景辅助线条
    [self drawBackgroundLine:context];
    
    if([_shareTimeDataDic.allKeys count] <= 0){         //没数据则不画
        return;
    }
    //文字
    [self drawLineText:context];
    //画点
    [self drawShareTimePoint:context];
    //填充颜色
    [self fillShareTimeColor:context];
    //画成交量
    [self drawVolumeChart:context];
    //画当前价辅助线
    if(!isArcViewExist){        //当呼吸原点不存在的时候，才需要画当前价辅助虚线
        [self drawAssistantDashline:context];
    }else{
        [_currentPriceButton removeFromSuperview];
    }
    if(isNeedLongPressPoint){
        [self drawLongPressPointInfo:context];
    }else{
        [_longPressPriceLabel removeFromSuperview];
        [_longPressTimeLabel removeFromSuperview];
    }
}

#pragma mark - -------------------------------- 重新获取基本的显示条件 ------------------------
- (void)resetBaseDrawCondition
{
    NSInteger currentMinuteCount = 0;                    //当前显示的分钟总数
    self.eachGirdMinutes = 10 / currentZoomScale;
    if(isArcViewExist){
        currentMinuteCount = (_eachGirdMinutes * _totalColumn + 1) * showDataRange.length / totalMinuteCount;
        if([_shareTimeDataDic.allKeys count] >= currentMinuteCount){
            showDataRange = NSMakeRange([_shareTimeDataDic.allKeys count] - currentMinuteCount, currentMinuteCount);
        }else{
            showDataRange = NSMakeRange(0, [_shareTimeDataDic.allKeys count]);
        }
    }else{
        currentMinuteCount = _eachGirdMinutes * _totalColumn + 1;
        if(showDataRange.location + currentMinuteCount <= [_shareTimeDataDic.allKeys count]){
            showDataRange = NSMakeRange(showDataRange.location, currentMinuteCount);
        }else{
            if(currentMinuteCount > [_shareTimeDataDic.allKeys count]){
                showDataRange = NSMakeRange(0, [_shareTimeDataDic.allKeys count]);
            }else{
                showDataRange = NSMakeRange([_shareTimeDataDic.allKeys count] - currentMinuteCount, currentMinuteCount);
            }
        }
    }
    initViewMinuteCount = (_eachGirdMinutes * _totalColumn) - _eachGirdMinutes * 1 + 1;        //最新行情默认会最后一格不显示,所以减去后面一格的分钟数,分钟数要加上开始的那一个
    totalMinuteCount = _eachGirdMinutes * _totalColumn + 1;                                    //分钟数要加上开始的那一个
    longPressVerticalLineWidth = 6 * currentZoomScale;                                         //长按手势线条的宽度
}


#pragma mark - -------------------------------- 数据处理 ------------------------------------
/** 增加总体行情数据*/
- (void)addShareTimeViewHistoryData:(NSString *)historyData
{
    //解析数据，
    if (TTIsStringWithAnyText(historyData)) {
        _isHasHitory = YES;
        [_shareTimeDataDic removeAllObjects];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+),([0-9]*[.]??[0-9]*),([0-9]*[.]??[0-9]*);" options:0 error:nil];
        NSArray *matches = [regex matchesInString:historyData options:0 range:NSMakeRange(0, historyData.length)];
        for (NSTextCheckingResult *m in matches) {
            //            timeString = [content substringWithRange:[m rangeAtIndex:1]];
            CMShareTimeBaseData *std = [[[CMShareTimeBaseData alloc] init] autorelease];
            std.time = [VeDateUtil formatterDate:[historyData substringWithRange:[m rangeAtIndex:1]] inStytle:nil outStytle:@"yyyyMMddHHmmss" isTimestamp:YES];
            std.last = [historyData substringWithRange:[m rangeAtIndex:2]];
            std.currentVolume = [historyData substringWithRange:[m rangeAtIndex:3]];
            [_shareTimeDataDic setObject:std forKey:std.time];
            numDecimalBit = [TradeUtil decimalBitByStringValue:std.last];           //观察后台返回的数据，来定义一共显示多少位小数
        }
        if([_shareTimeDataDic.allKeys count] >= initViewMinuteCount){               //是否超出数据
            showDataRange = NSMakeRange([_shareTimeDataDic.allKeys count] - initViewMinuteCount, initViewMinuteCount);
        }else{
            showDataRange = NSMakeRange(0, [_shareTimeDataDic.allKeys count]);
        }
        [self acquireShowDataArray];
        [self setNeedsDisplay];
    }
}

/**  增加一条行情*/
- (void)addOneShareTimeViewData:(CoinQuotationDataEntity *)dataEntity
{
    //    [_shareTimeDataArr addObject:dataEntity];
    if(dataEntity == nil || !_isHasHitory){
        return;
    }
//    if([dataEntity.last doubleValue] > yAxisMaxValue){
//        yAxisMaxValue = [dataEntity.last doubleValue];
//    }else if([dataEntity.last doubleValue] < yAxisMinValue){
//        yAxisMinValue = [dataEntity.last doubleValue];
//    }
    CMShareTimeBaseData *std = [[[CMShareTimeBaseData alloc] init] autorelease];
    std.time = [VeDateUtil formatterDate:dataEntity.timeStamp inStytle:nil outStytle:@"yyyyMMddHHmmss" isTimestamp:YES];
    std.last = dataEntity.last;
    std.currentVolume = [NSString stringWithFormat:@"%@",@(dataEntity.amount)];
    if(checkIsStringWithAnyText(std.time)){
        [_shareTimeDataDic setObject:std forKey:std.time];
    }
    
    if(isArcViewExist){         //如果呼吸原点存在的话，则直接获取固定的最新，不存在的话就按照之前设置好的
        if([_shareTimeDataDic.allKeys count] >= initViewMinuteCount){
            showDataRange = NSMakeRange([_shareTimeDataDic.allKeys count] - showDataRange.length, showDataRange.length);
        }else{
            showDataRange = NSMakeRange(0, [_shareTimeDataDic.allKeys count]);
        }
 
    }
    [self acquireShowDataArray];
    [self setNeedsDisplay];
}

/** 获取可视数据*/
- (void)acquireShowDataArray
{
    /** 更新显示行情的数据并获取最大最小值*/
    yAxisMaxValue = CGFLOAT_MIN;
    yAxisMinValue = CGFLOAT_MAX;
    minTradeVolume = CGFLOAT_MAX;
    maxTradeVolume = CGFLOAT_MIN;
    [showDataArray removeAllObjects];
    NSArray *keysArray = [[_shareTimeDataDic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if([keysArray count] >= initViewMinuteCount){     //
        for(NSInteger i = showDataRange.location; i < (showDataRange.location + showDataRange.length); i++){
            if(i >= [keysArray count]){         //保证传入的i不会超过索引
                return;
            }
            NSString *key = [keysArray objectAtIndex:i];
            CMShareTimeBaseData *std = [_shareTimeDataDic objectForKey:key];
            if([std.last doubleValue] > yAxisMaxValue){
                yAxisMaxValue = [std.last doubleValue];
            }
            if([std.last doubleValue] < yAxisMinValue){
                yAxisMinValue = [std.last doubleValue];
            }
            
            if([std.currentVolume floatValue] < minTradeVolume){
                minTradeVolume = [std.currentVolume floatValue];
            }
            if([std.currentVolume floatValue] > maxTradeVolume){
                maxTradeVolume = [std.currentVolume floatValue];
            }
            
            [showDataArray addObject:std];
        }
    }else{
        for(NSInteger i = 0; i < [keysArray count];i++){
            NSString *key = [keysArray objectAtIndex:i];
            CMShareTimeBaseData *std = [_shareTimeDataDic objectForKey:key];
            if([std.last doubleValue] > yAxisMaxValue){
                yAxisMaxValue = [std.last doubleValue];
            }
            if([std.last doubleValue] < yAxisMinValue){
                yAxisMinValue = [std.last doubleValue];
            }
            
            if([std.currentVolume floatValue] < minTradeVolume){
                minTradeVolume = [std.currentVolume floatValue];
            }
            if([std.currentVolume floatValue] > maxTradeVolume){
                maxTradeVolume = [std.currentVolume floatValue];
            }
            
            [showDataArray addObject:std];
        }
    }
    if(yAxisMaxValue == yAxisMinValue){
        yAxisMaxValue = yAxisMinValue * 1.5;
    }
}


#pragma mark - 画出背景线条
- (void)drawBackgroundLine:(CGContextRef)context
{
    
    //画横线
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, RGBA(220, 220, 220, 0.1).CGColor);
    CGContextSetLineWidth(context, backgroundLineWidth);
    for(int i = 0; i <= _viewTotalHeightRatio; i++){
        if(i == 0){
            CGContextMoveToPoint(context, 0.0, topMargin);
            CGContextAddLineToPoint(context, self.frame.size.width, topMargin);
            CGContextStrokePath(context);
        }else if(i == _viewTotalHeightRatio){
            CGContextMoveToPoint(context, 0.0, self.frame.size.height - bottomMargin);
            CGContextAddLineToPoint(context, self.frame.size.width,self.frame.size.height - bottomMargin);
            CGContextStrokePath(context);
        }else{
            CGContextMoveToPoint(context, 0.0, topMargin + i * perGridHeight);
            CGContextAddLineToPoint(context, self.frame.size.width, topMargin + i * perGridHeight);
            CGContextStrokePath(context);
        }
        
    }
    //画竖线，从做到右开始画，第一和最后一条不画
    for(int i = 0; i <= _totalColumn; i++){
        if(i == 0 || i == _totalColumn){
            continue;
        }
        CGContextMoveToPoint(context, 0.0 + (i * perGridWidth), 0.0);
        CGContextAddLineToPoint(context, 0.0 + (i * perGridWidth), self.frame.size.height - bottomMargin);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);

}

#pragma mark - 画坐标文字
- (void)drawLineText:(CGContextRef)context
{
    //x轴坐标文字
    CGContextSaveGState(context);
    NSMutableArray *xAxisArray = [NSMutableArray array];
    for(NSInteger i = 0; i < [showDataArray count]; i = i + _eachGirdMinutes){
        CMShareTimeBaseData *std = [showDataArray objectAtIndex:i];
        [xAxisArray addObject:[VeDateUtil formatterDate:std.time inStytle:@"yyyyMMddHHmmss" outStytle:@"HH:mm"]];
    }
    for(int i = 0; i < [xAxisArray count]; i++){
        NSString *timeStr = xAxisArray[i];
        UIColor *textColor = RGBA(255, 255, 255, 0.6);
        UIFont *font = [UIFont systemFontOfSize:10.0f];
        CGSize stringSize = [CommonUtil getPerfectSizeByText:timeStr andFontSize:10.0f andWidth:1000];
        [timeStr drawAtPoint:CGPointMake((0.0 + perGridWidth * i) - (stringSize.width / 2.0f), self.frame.size.height - bottomMargin) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    }
    
    //y轴坐标文字
    CGFloat perYPart = (CGFloat)((yAxisMaxValue - yAxisMinValue) / _mainViewHeightRatio);
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f",@(numDecimalBit)];
    NSArray *yAxisArray = @[
                            [NSString stringWithFormat:formatString,yAxisMaxValue],
                            [NSString stringWithFormat:formatString,(yAxisMaxValue - perYPart)],
                            [NSString stringWithFormat:formatString,(yAxisMaxValue - perYPart - perYPart)],
                            [NSString stringWithFormat:formatString,(yAxisMinValue + perYPart)],
                            [NSString stringWithFormat:formatString,yAxisMinValue]
                            ];
    for(int i = 0; i < [yAxisArray count]; i++){
        NSString *timeStr = yAxisArray[i];
        UIColor *textColor = RGBA(255, 255, 255, 0.6);
        UIFont *font = [UIFont systemFontOfSize:10.0f];
        CGSize stringSize = [CommonUtil getPerfectSizeByText:timeStr andFontSize:10.0f andWidth:1000];
        [timeStr drawAtPoint:CGPointMake(self.frame.size.width - stringSize.width, topMargin + perGridHeight * i - textHeight) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    }
    CGContextRestoreGState(context);
    
}

#pragma mark - 画行情点
- (void)drawShareTimePoint:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, RGBA(240, 140, 66, 0.7).CGColor);
    CGContextSetLineWidth(context, 1);
    CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - perGridHeight * (CGFloat)_volumeViewHeightRatio - bottomMargin - topMargin);    //行情图的高度
    
    NSMutableArray *dataPointArr = [NSMutableArray array];
    //获得点坐标数组
    for(int i = 0; i < [showDataArray count]; i++){
        CMShareTimeBaseData *baseData = [showDataArray objectAtIndex:i];
        CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - yAxisMinValue) / (CGFloat)(yAxisMaxValue - yAxisMinValue));
        CGFloat pointY = topMargin + mainViewHeight - (CGFloat)(mainViewHeight * lastPercentage);
        if(i == 0){
            [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(0.0, pointY)]];
        }else{
            if(i == [showDataArray count] - 1){             //最后一个点的时候添加一个白色动画原点
                [self changeArcViewCenter:CGPointMake(_perDotXDistance * i, pointY)];
            }
            [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(0.0 + _perDotXDistance * i, pointY)]];
        }
    }
    
    /** 额外添加一个开头和结束来画3元贝塞尔曲线*/
    [dataPointArr insertObject:[NSValue valueWithCGPoint:CGPointMake(0.0, topMargin + mainViewHeight / 2.0f)] atIndex:0];
    [dataPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(_perDotXDistance * [showDataArray count], topMargin + mainViewHeight / 2.0f)]];
    
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
    
//    for(int i = 0; i < [showDataArray count]; i++){
//        CMShareTimeBaseData *baseData = [showDataArray objectAtIndex:i];
//        CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - yAxisMinValue) / (CGFloat)(yAxisMaxValue - yAxisMinValue));
//        CGFloat pointY = topMargin + mainViewHeight - (CGFloat)(mainViewHeight * lastPercentage);
//        if(i == 0){
//            CGContextMoveToPoint(context, 0.0, pointY);
//        }else{
//            if(i == [showDataArray count] - 1){             //最后一个点的时候添加一个白色动画原点
//                [self changeArcViewCenter:CGPointMake(_perDotXDistance * i, pointY)];
//            }
//            CGContextAddLineToPoint(context,0.0 + _perDotXDistance * i, pointY);
//        }
//    }
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

/** 画贝塞尔点*/
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

#pragma mark - 画当前价辅助虚线
- (void)drawAssistantDashline:(CGContextRef)context
{
    CGContextSaveGState(context);
    NSArray *keysArray = [[_shareTimeDataDic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    CMShareTimeBaseData *std = [_shareTimeDataDic objectForKey:[keysArray lastObject]];
    CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - perGridHeight * _volumeViewHeightRatio - bottomMargin - topMargin);    //行情图的高度
    CGFloat lastPercentage = (CGFloat)(([std.last doubleValue] - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue));
    CGFloat pointY = 0.0;
    if(lastPercentage <= 0){                //在当前值比最小值还要小的时候，一直在底部
        pointY = topMargin + mainViewHeight;
    }else if(lastPercentage >= 1){          //在当前值比最大值还要大的时候，一直在顶部
        pointY = topMargin;
    }else{                                  //在当前最大值和最小值之间的时候，正常找位置
        pointY = topMargin + mainViewHeight - mainViewHeight * lastPercentage;
    }
    
    CGContextSetStrokeColorWithColor(context, RGBA(230, 230, 230, 0.7).CGColor);
    CGContextSetLineWidth(context, 1);
    CGFloat lengths[] = {5,5};
    CGContextMoveToPoint(context,0.0,pointY);
    CGContextAddLineToPoint(context,self.frame.size.width,pointY);
    CGContextSetLineDash(context, 0, lengths,2);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    //添加按钮
    CGSize constraint = CGSizeMake(20000.0f, 18);
    CGSize size = [std.last boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]} context:nil].size;
    [_currentPriceButton setFrame:CGRectMake(perGridWidth * (_totalColumn - 1) - (size.width + 16)/2.0f, pointY - 18/2 , size.width + 16, 18)];
    [_currentPriceButton setTitle:[NSString stringWithFormat:@"%@→",std.last] forState:UIControlStateNormal];
    [self addSubview:_currentPriceButton];
    
}

#pragma mark - 填充颜色
- (void)fillShareTimeColor:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, 0.0, topMargin + perGridHeight * _mainViewHeightRatio);                                //x轴的每格间距
    CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - perGridHeight * _volumeViewHeightRatio - bottomMargin - topMargin);     //行情图的高度
    for(int i = 0; i < [showDataArray count]; i++){
        CMShareTimeBaseData *baseData = [showDataArray objectAtIndex:i];
        CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue));
        CGFloat pointY = topMargin + mainViewHeight - mainViewHeight * lastPercentage;
        CGContextAddLineToPoint(context, 0.0 + _perDotXDistance * i, pointY);
    }
    CGContextAddLineToPoint(context,_perDotXDistance * ([showDataArray count] - 1),topMargin + perGridHeight * _mainViewHeightRatio);
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
    CGContextDrawLinearGradient(context, gradient, CGPointMake(_perDotXDistance * ([showDataArray count] - 1), topMargin), CGPointMake(_perDotXDistance * ([showDataArray count] - 1), topMargin + perGridHeight * _mainViewHeightRatio), kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
}

#pragma mark - 画长按手势点的信息图
- (void)drawLongPressPointInfo:(CGContextRef)context
{
    //画线
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 0.0, longPressPoint.y - 0.5);
    CGContextAddLineToPoint(context, self.frame.size.width, longPressPoint.y - 0.5);
    CGContextStrokePath(context);
    //画点

    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, longPressPoint.x, longPressPoint.y);
    CGContextAddArc(context, longPressPoint.x, longPressPoint.y, 3, 0, 2 *M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    
    //画渐变竖线
    CGContextMoveToPoint(context, longPressPoint.x - longPressVerticalLineWidth / 2.0f, 0.0);                                //x轴的每格间距
    CGContextAddLineToPoint(context,longPressPoint.x + longPressVerticalLineWidth / 2.0f,0.0);
    CGContextAddLineToPoint(context,longPressPoint.x + longPressVerticalLineWidth / 2.0f, self.frame.size.height);
    CGContextAddLineToPoint(context,longPressPoint.x - longPressVerticalLineWidth/ 2.0f, self.frame.size.height);
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
    CGContextDrawLinearGradient(context, gradient, CGPointMake(longPressPoint.x + 3,0.0), CGPointMake(longPressPoint.x + 3, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    [_longPressPriceLabel removeFromSuperview];
    [_longPressTimeLabel removeFromSuperview];
    NSInteger index = longPressPoint.x / _perDotXDistance;
    //添加文字
    CGSize constraint = CGSizeMake(20000.0f, 20);
    CMShareTimeBaseData *baseData = [showDataArray objectAtIndex:index];
    CGSize lastSize = [baseData.last boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]} context:nil].size;
    if(longPressPoint.x >= self.frame.size.width / 2.0f){          //手在右边，则文字放在左边
        _longPressPriceLabel.frame = CGRectMake(0.0, longPressPoint.y - 10, lastSize.width + 10, 20);
    }else{
        _longPressPriceLabel.frame = CGRectMake(self.frame.size.width - (lastSize.width + 10), longPressPoint.y - 10, lastSize.width + 10, 20);
    }
    _longPressPriceLabel.text = baseData.last;
    [self addSubview:_longPressPriceLabel];
    
    CGSize timeSize = [[VeDateUtil formatterDate:baseData.time inStytle:@"yyyyMMddHHmmss" outStytle:@"HH:mm"] boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]} context:nil].size;
    _longPressTimeLabel.frame = CGRectMake(longPressPoint.x - (timeSize.width + 10)/2.0f, self.frame.size.height - 20, timeSize.width + 10, 20);
    _longPressTimeLabel.text = [VeDateUtil formatterDate:baseData.time inStytle:@"yyyyMMddHHmmss" outStytle:@"HH:mm"];
    [self addSubview:_longPressTimeLabel];
    
}


#pragma mark - ----------------------白色点--------------------------------
/** 改变圆点的中点*/
- (void)changeArcViewCenter:(CGPoint)center
{
    if(isArcViewExist){
        if(showDataRange.location + showDataRange.length < [_shareTimeDataDic.allKeys count]){ //当原点数据的索引小于所有数据的总数时,证明最后一个数据已超出屏幕，原点只会跟着所有数据的最后一点，所以原点要消失
            [self stopArcViewAnimation];
        }else{
            arcTopView.center = center;
            arcFloorView.center = center;
        }
    }else{
        if(showDataRange.location + showDataRange.length >= [_shareTimeDataDic.allKeys count]){
            arcTopView.center = center;
            arcFloorView.center = center;
            
            [self startArcViewAnimation];
        }
    }
}

/** 开始圆点的动画*/
- (void)startArcViewAnimation
{
    [self stopArcViewAnimation];
    
    if (arcTopView.center.x >= self.frame.size.width) return;
    
    isArcViewExist = YES;
    
    [self addSubview:arcFloorView];
    [self addSubview:arcTopView];
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:5];

    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];

    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 2.0f;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.removedOnCompletion = NO;
    animationGroup.animations = @[opacityAnimation, scaleAnimation];
    
    // 将上述两个动画编组
    [arcFloorView.layer addAnimation:animationGroup forKey:@"animationGroup"];
}

/** 结束圆点的动画*/
- (void)stopArcViewAnimation
{
    // 去掉key动画
    [arcFloorView.layer removeAnimationForKey:@"animationGroup"];
    // 去掉所有动画
    //    [areFloorView.layer removeAllAnimations];
    
    [arcFloorView removeFromSuperview];
    [arcTopView removeFromSuperview];
    isArcViewExist = NO;
}

#pragma mark - 画成交量图
- (void)drawVolumeChart:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGFloat volumeLineWidth = _perDotXDistance;
    CGContextSetStrokeColorWithColor(context, RGBA(240, 140, 55, 1.0).CGColor);
    CGContextSetLineWidth(context, volumeLineWidth);
    CGFloat actualVolumeHeight = (CGFloat)((self.frame.size.height - perGridHeight * _mainViewHeightRatio - bottomMargin - topMargin - backgroundLineWidth)); //成交量图的高度
    CGFloat volumeHeight = actualVolumeHeight - 20;                                                         //减少多20为了不顶到上面，同时方便加一些数字
    for(int i = 0; i < [showDataArray count]; i++){
        CMShareTimeBaseData *baseData = [showDataArray objectAtIndex:i];
        CGFloat volumePercentage = (CGFloat)(([baseData.currentVolume doubleValue] - minTradeVolume) / (maxTradeVolume - minTradeVolume));
        CGFloat pointY = topMargin + perGridHeight * _mainViewHeightRatio + (actualVolumeHeight - volumeHeight * volumePercentage);
        if(pointY >= self.frame.size.height - bottomMargin - backgroundLineWidth - 2)
            pointY = self.frame.size.height - bottomMargin - backgroundLineWidth - 2;
        CGContextMoveToPoint(context, 0.0 + (i * _perDotXDistance) , self.frame.size.height - bottomMargin - backgroundLineWidth);
        CGContextAddLineToPoint(context, 0.0 + (i * _perDotXDistance) , pointY);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);

}

#pragma mark - 添加手势
/** 滑动手势*/
- (void)addPanGestureRecognizer
{
    QuotationPanGestureRecognizer *pan = [[[QuotationPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)] autorelease];
    pan.maximumNumberOfTouches = 1;
    pan.direction = QuotationPanGestureRecognizerHorizontal;
    [self addGestureRecognizer:pan];
}


- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        dragBeginPoint = [recognizer locationInView:self];
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        dragEndPoint = [recognizer locationInView:self];
        CGFloat panDistance = dragEndPoint.x - dragBeginPoint.x;
        if(fabs(panDistance)  > _perDotXDistance){         //如果拉动的距离超过了一分钟线的距离，则需要作出相应操作
            NSInteger addDotCount = fabs(panDistance) / _perDotXDistance;             //需要增加N个点
            if(panDistance > 0){            //手势向右移动
                NSInteger location = showDataRange.location;
                if((location - addDotCount) < 0  ){                //超过整体数据的范围
                    return;
                }
                if([_shareTimeDataDic.allKeys count] - (showDataRange.location + 1) + 1 <= totalMinuteCount){       //不超过显示的最大分钟数据范围内
                    showDataRange = NSMakeRange(showDataRange.location - addDotCount, showDataRange.length + addDotCount);
                }else{
                    showDataRange = NSMakeRange(showDataRange.location - addDotCount, totalMinuteCount);
                }
                
                [self acquireShowDataArray];
                [self setNeedsDisplay];
            }else{                          //手势向左移动
                NSInteger location = showDataRange.location;
                NSInteger dataCount = [_shareTimeDataDic.allKeys count];
                if(dataCount - (location + addDotCount + 1) + 1 < initViewMinuteCount){                //超过整体数据的范围
                    return;
                }
                
                if(dataCount - (location + addDotCount + 1) + 1 >= totalMinuteCount){
                    showDataRange = NSMakeRange(location + addDotCount, totalMinuteCount);
                }else{
                    showDataRange = NSMakeRange(location + addDotCount, dataCount - (location + addDotCount + 1) + 1);
                }
                [self acquireShowDataArray];
                [self setNeedsDisplay];
            }
            dragBeginPoint = dragEndPoint;
        }
        

    }

}

/** 长按手势*/
- (void)addLongPressGestureRecognizer
{
    UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)] autorelease];
    longPressRecognizer.numberOfTouchesRequired = 1;
    longPressRecognizer.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPressRecognizer];
}


- (void)longPressRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint movePoint = [recognizer locationInView:self];
    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged){
        
        NSInteger index = floor((movePoint.x / _perDotXDistance));
        CGFloat distance = fabs((_perDotXDistance * index - movePoint.x));
        if(distance > (_perDotXDistance / 2.0f)){
            index += 1;
        }else{
            index = index;
        }
        if(index >= [showDataArray count]){
            return;
        }
        
        isNeedLongPressPoint = YES;
        CGFloat pointX = index *_perDotXDistance;
        CMShareTimeBaseData *baseData = [showDataArray objectAtIndex:index];
        CGFloat mainViewHeight = (CGFloat)(self.frame.size.height - perGridHeight * _volumeViewHeightRatio - bottomMargin - topMargin);    //行情图的高度
        CGFloat lastPercentage = (CGFloat)(([baseData.last doubleValue] - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue));
        CGFloat pointY = topMargin + mainViewHeight - mainViewHeight * lastPercentage;
        
        longPressPoint = CGPointMake(pointX, pointY);
        
        [self setNeedsDisplay];
        
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        isNeedLongPressPoint = NO;
        [self setNeedsDisplay];
    }
}

/** 缩放手势*/
- (void)addPinchGestureRecognizer
{
    UIPinchGestureRecognizer *pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)] autorelease];
    [self addGestureRecognizer:pinchRecognizer];
}

- (void)pinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat zoomSize = recognizer.scale;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        lastZoomScale = recognizer.scale;
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        CGFloat scaleDistance = fabs(zoomSize - lastZoomScale);
        if(scaleDistance > 0.2){            //满足放大缩小区间
            NSInteger scalePercentage = floor(scaleDistance / 0.2);         //比例
            if(zoomSize > lastZoomScale){           //放大
                currentZoomScale = currentZoomScale + scalePercentage * perScaleFactor;
                if(currentZoomScale > maxZoomScale){
                    currentZoomScale = maxZoomScale;
                }
            }else{                                  //缩小
                currentZoomScale = currentZoomScale - scalePercentage * perScaleFactor;
                if(currentZoomScale < minZoomScale){
                    currentZoomScale = minZoomScale;
                }
            }
            lastZoomScale = zoomSize;
            
            [self resetBaseDrawCondition];
            [self acquireShowDataArray];
            [self setNeedsDisplay];
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){

    }
    

   
//    lastZoome = zoomSize;
    
}

#pragma mark - 按钮事件
- (void)currentPriceButtonPressed:(UIButton *)sender
{
    if([_shareTimeDataDic.allKeys count] >= initViewMinuteCount){
        showDataRange = NSMakeRange([_shareTimeDataDic.allKeys count] - initViewMinuteCount, initViewMinuteCount);
    }else{
        showDataRange = NSMakeRange(0, [_shareTimeDataDic.allKeys count]);
    }
    [self acquireShowDataArray];
    [self setNeedsDisplay];
}

@end
