//
//  NewKLineView.m
//  TJRtaojinroad
//
//  Created by 影孤清 on 13-10-21.
//  Copyright (c) 2013年 淘金路. All rights reserved.
//

#import "NewKLineView.h"
#import "VeDateUtil.h"
#import "MBProgressHUD.h"
#import "StockExRights.h"
#import "TradeUtil.h"

NSString *const KLineMaxValue = @"klineMaxValue";
NSString *const KLineMinValue = @"klineMinValue";
NSString *const VolumeMaxValue = @"volumeMaxValue";
NSString *const KDJMax = @"kdjMax";
NSString *const KDJMin = @"kdjMin";
NSString *const MACDMax = @"macdMax";
NSString *const MACDMin = @"macdMin";

const double N12 = 2.0f / 13.0f;
const double N13 = 11.0f / 13.0f;
const double N26 = 2.0f / 27.0f;
const double N27 = 25.0f / 27.0f;
const double P13 = 1.0f / 3.0f;
const double P23 = 2.0f / 3.0f;

@interface NewKLineView()


@end

@implementation NewKLineView
@synthesize netKLineArray;
@synthesize restorationArray;
@synthesize volumeTextFont;
@synthesize showRange;
@synthesize defaultShowRange;
@synthesize candlesWidth;
@synthesize cycle;
@synthesize kLineViewDrawKLineHeight = klineHeight;
@synthesize kLineViewDrawTextHeight = volumeTextHeight;
@synthesize kLineViewDrawVolumeHeight = volumeHeight;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    kLineTipsView = [[NewKLineTipsView alloc] initWithFrame:CGRectMake(5.0, 10, 135, 0.0)];
    kLineTipsView.hidden = YES;
    [self addSubview:kLineTipsView];
    klineDataAscSel = @selector(compareKeysByAsc:);
    klineDataDescSel = @selector(compareKeysByDes:);
    self.kLineViewBackgroundColor = RGBA(15, 24, 38, 1.0);
    netKLineArray = [[NSMutableArray alloc] init];
    restorationArray = [NSMutableArray new];
    coordinateArray = [[NSMutableArray alloc] init];
    resultArray = [[NSMutableArray alloc] init];
    stockExRightsArray = [NSMutableArray new];
    _kLineViewTextPadding = 3;
    cycle = KLineDataDay;
    defaultCandleWidth = 4;
    candlesWidth = defaultCandleWidth;
    spacing = candlesWidth / 2.0f;
    _minCandlesWidth = 1;
    _maxCandlesWidth = 20;
    self.isCanClickVolume = YES;
    self.isCanShowWhiteLine = YES;
    self.isCanMoveKLineView = YES;
    self.isShouldReturnKLineData = YES;
    self.isDrawVolumeText = YES;
    self.isCanPinch = YES;
    pinchIsLicit = YES;
    longIsLicit = YES;
    panIsLicit = YES;
    volumeTextHeight = 1;
    _decimalPlaces = 2;
    _isCalculationRate = YES;
    _isShowDate = YES;
    self.isStockExRights = YES;
    self.maxKLineNumber = 250;
    self.isFillRed = YES;
    _lacunae = UIEdgeInsetsMake(0, 0, 0, 10);
    self.showType = KLineShowNormal;
    [self frameChange];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self frameChange];
}

- (void)setDelegate:(id<KLineViewDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        _delegateFlags.kLineShowData = [delegate respondsToSelector:@selector(kLineShowData:VolumeType:isEnd:)];
        _delegateFlags.klineHttpStart = [delegate respondsToSelector:@selector(klineHttpStart)];
        _delegateFlags.klineHttpEnd = [delegate respondsToSelector:@selector(klineHttpEnd)];
        _delegateFlags.klineHttpError = [delegate respondsToSelector:@selector(klineHttpError)];
        _delegateFlags.klineShowToast = [delegate respondsToSelector:@selector(klineShowToast:)];
        _delegateFlags.klineArenaShowRealprice = [delegate respondsToSelector:@selector(klineArenaShowRealprice:withYesterday:index:)];
        _delegateFlags.kLineTouch = [delegate respondsToSelector:@selector(kLineTouch:isShowLine:)];
    } else {
        _delegateFlags.kLineShowData = 0;
        _delegateFlags.klineHttpStart = 0;
        _delegateFlags.klineHttpEnd = 0;
        _delegateFlags.klineHttpError = 0;
        _delegateFlags.klineShowToast = 0;
        _delegateFlags.klineArenaShowRealprice = 0;
        _delegateFlags.kLineTouch = 0;
    }
}

/**
 *  设置K线的显示类型
 *
 *  @param showType 显示类型
 */
- (void)setShowType:(KLineShowType)showType {
    _showType = showType;
    
    switch (showType) {
        case KLineShowWhite:
            [self releaseColor];
            normalColor = [QuotationBlueColor retain];
            redColor = [QuotationRedColor retain];
            greenColor = [QuotationGreenColor retain];
            blueColor = [QuotationBlueColor retain];
            purpleColor = [QuotationPurpleColor retain];
            yellowColor = [QuotationYellowColor retain];
            lineColor = [RGBA(220, 220, 220, 0.1) retain];
            midValueColor = [[UIColor whiteColor] retain];
            break;
            
        case KLineShowBlack:
            [self releaseColor];
            normalColor = [[UIColor whiteColor] retain];
            redColor = [QuotationRedColor retain];
            greenColor = [QuotationGreenColor retain];
            blueColor = [RGBA(67, 191, 175, 1) retain];
            purpleColor = [RGBA(233, 69, 219, 1) retain];
            yellowColor = [RGBA(255, 244, 116, 1) retain];
            lineColor = [RGBA(50, 50, 50, 1) retain];
            midValueColor = [[UIColor whiteColor] retain];
            break;
            
        default:
            break;
    }
}

- (void)releaseColor {
    RELEASE(lineColor);
    RELEASE(midValueColor);
    RELEASE(redColor);
    RELEASE(greenColor);
    RELEASE(yellowColor);
    RELEASE(normalColor);
    RELEASE(purpleColor);
}

/**
 *    重置K线宽度
 */
- (void)candleReset {
    spacing = defaultSpacing;
    self.candlesWidth = defaultCandleWidth;	// 里面有重置showRange和candleNumber
}

/* 是否可以缩放K线,默认为YES,可缩放 */
- (void)setIsCanPinch:(BOOL)isCanPinch {
    _isCanPinch = isCanPinch;
    
    if (isCanPinch) {
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
        [self addGestureRecognizer:pinchGesture];
    } else if (pinchGesture) {
        [self removeGestureRecognizer:pinchGesture];
    }
}

- (void)setIsCanMoveKLineView:(BOOL)isCanMoveKLineView {
    _isCanMoveKLineView = isCanMoveKLineView;
    
    if (isCanMoveKLineView) {
        panGesture = [[QuotationPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches = 1;
        panGesture.direction = QuotationPanGestureRecognizerHorizontal;
        [self addGestureRecognizer:panGesture];
    } else if (panGesture) {
        [self removeGestureRecognizer:panGesture];
    }
}

- (void)setIsCanShowWhiteLine:(BOOL)isCanShowWhiteLine {
    _isCanShowWhiteLine = isCanShowWhiteLine;
    
    if (isCanShowWhiteLine) {
        longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        longGesture.allowableMovement = 0;
        longGesture.minimumPressDuration = 0.3;
        [self addGestureRecognizer:longGesture];
    } else if (longGesture) {
        [self removeGestureRecognizer:longGesture];
    }
}

- (void)setIsCanClickVolume:(BOOL)isCanClickVolume {
    _isCanClickVolume = isCanClickVolume;
    
    if (isCanClickVolume) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGesture];
    } else if (tapGesture) {
        [self removeGestureRecognizer:tapGesture];
    }
}

- (void)setMaxForKLineShow:(NSInteger)maxForKLineShow {
    _maxForKLineShow = maxForKLineShow;
    candlesWidth = 2.0f * (CHART_WIDTH - _lacunae.right - _lacunae.left) / (3.0f * maxForKLineShow - 1);
    spacing = (CHART_WIDTH - _lacunae.right - _lacunae.left - maxForKLineShow * candlesWidth) / (maxForKLineShow - 1);
//    spacing = candlesWidth / 2.0f;
    defaultCandleWidth = candlesWidth;
    defaultSpacing = spacing;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self frameChange];
}

- (void)setVolumeTextFont:(UIFont *)font {
    RELEASE(volumeTextFont);
    
    if (font) {
        volumeTextFont = [font retain];
    } else {
        volumeTextHeight = -1;
    }
    [self frameChange];
}

- (void)setIsShowLine:(BOOL)isShowLine {
    _isShowLine = isShowLine;
    [self calculateLinePosition:0];
    [self delegateForShowKLineWithPoint:YES];
}

- (void)setPullNormalText:(NSString *)normalText showText:(NSString *)showText loadText:(NSString *)loadText {
    RELEASE(pullShowText);
    RELEASE(pullNormalText);
    RELEASE(pullLoadingText);
    pullShowText = [showText copy];
    pullNormalText = [normalText copy];
    pullLoadingText = [loadText copy];
    CGFloat width = [CommonUtil getPerfectSizeByText:NSLocalizedStringForKey(@"正") andFontSize:15 andWidth:1000].width;
    rightPullMaxX = width*2;
}

- (void)setVolumeType:(KLineIndexType)volumeType {
    _volumeType = volumeType;
    
    switch (volumeType) {
        case KLineIndexTypeVOL:	/* 成交量 */
            [btnParameter setTitle:NSLocalizedStringForKey(@"成交量") forState:UIControlStateNormal];
            break;
            
        case KLineIndexTypeMACD:	/* MACD */
            [btnParameter setTitle:@"MACD" forState:UIControlStateNormal];
            break;
            
        case KLineIndexTypeKDJ:	/* KDJ */
            [btnParameter setTitle:@"KDJ" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

/**
 *   设置当前是否是显示除权数据
 *   @param isStockExRights
 */
- (void)setIsStockExRights:(BOOL)isStockExRights {
    if (_isStockExRights == isStockExRights) return;
    
    _isStockExRights = isStockExRights;
    stockArray = isStockExRights ? netKLineArray : restorationArray;
    [self calculationRestoration:!isStockExRights];
}

/**
 *  设置K线和成交量中间的空白距离
 *
 *  @param volumeBlankHeight 距离
 */
- (void)setVolumeBlankHeight:(CGFloat)volumeBlankHeight {
    _volumeBlankHeight = volumeBlankHeight;
    NSInteger drawHeight = CHART_HEIGHT - volumeTextHeight - _lacunae.top - _lacunae.bottom;
    klineHeight = (int)((CGFloat)drawHeight * 3 / 5);
    volumeHeight = drawHeight - klineHeight - volumeBlankHeight;
    volumeDrawY = klineHeight + volumeTextHeight + volumeBlankHeight + _lacunae.top;
    
    if (volumeBlankHeight > 20) {
        CGRect frame = btnParameter.frame;
        frame.origin.x = 10;
        frame.origin.y = klineHeight + volumeBlankHeight - 5.0f;
        btnParameter.frame = frame;
        btnParameter.userInteractionEnabled = YES;
    } else {
        CGRect frame = btnParameter.frame;
        frame.origin.y = CHART_HEIGHT - CGRectGetHeight(frame) - 5;
        frame.origin.x = CHART_WIDTH - CGRectGetWidth(frame) - 5;
        btnParameter.frame = frame;
        btnParameter.userInteractionEnabled = NO;
    }
}

/**
 *  @brief  上下左右留白距离
 *
 *  @param lacunae  * 距离
 *
 */ 
- (void)setLacunae:(UIEdgeInsets)lacunae {
    _lacunae = lacunae;
    [self frameChange];
}

- (void)frameChange {
    CHART_WIDTH = self.frame.size.width;
    CHART_HEIGHT = self.frame.size.height;
    klineDrawWidth = CHART_WIDTH - _lacunae.right - _lacunae.left;
    
    if (!volumeTextFont) {
        volumeTextFont = [[UIFont systemFontOfSize:13] retain];
    }
    
    if (volumeTextHeight <= 0) {
        volumeTextHeight = 0;
    } else {
        volumeTextHeight = volumeTextFont.lineHeight + _kLineViewTextPadding * 2;// [@"总:123456" sizeWithFont:volumeTextFont].height;
    }
    
    if (_isOnlyDrawKLine) {
        klineHeight = CHART_HEIGHT - _lacunae.top - _lacunae.bottom;
        volumeHeight = 0;
        volumeDrawY = klineHeight;
    } else {
        NSInteger drawHeight = CHART_HEIGHT - volumeTextHeight - _lacunae.top - _lacunae.bottom;
        klineHeight = (int)((CGFloat)drawHeight * 6 / 8);
        volumeHeight = drawHeight - klineHeight - _volumeBlankHeight;
        volumeDrawY = klineHeight + volumeTextHeight + _volumeBlankHeight + _lacunae.top;
    }
    candlesNumber = (klineDrawWidth + spacing) / (candlesWidth + spacing);
    showRange = NSMakeRange(0, candlesNumber);
    defaultShowRange = showRange;
    CGRect frame = btnParameter.frame;
    
    if (_volumeBlankHeight > 20) {
        frame.origin.x = 10;
        frame.origin.y = klineHeight + volumeTextHeight + (_volumeBlankHeight - 20) / 2.0f;
    } else {
        frame.origin.y = CHART_HEIGHT - CGRectGetHeight(frame) - 5;
        frame.origin.x = CHART_WIDTH - CGRectGetWidth(frame) - 5;
    }
    btnParameter.frame = frame;
    int num = (int)((klineDrawWidth + spacing) / (candlesWidth + spacing));
    spacing = (klineDrawWidth - num * candlesWidth) / (num - 1);
    defaultSpacing = spacing;
}

- (void)setIsDrawVolumeText:(BOOL)isDrawVolumeText {
    if (_isDrawVolumeText != isDrawVolumeText) {
        _isDrawVolumeText = isDrawVolumeText;
        
        if (!isDrawVolumeText) volumeTextHeight = -1;
        [self frameChange];
        [self setNeedsDisplay];
    }
}

- (void)setIsOnlyDrawKLine:(BOOL)isOnlyDrawKLine {
    _isOnlyDrawKLine = isOnlyDrawKLine;
    klineHeight = CHART_HEIGHT - _lacunae.top - _lacunae.bottom;
    volumeHeight = 0;
    volumeDrawY = klineHeight;
}

#pragma mark - 成交量上的类型按钮
- (void)setIsShowKLineParameters:(BOOL)isShowKLineParameters {
    _isShowKLineParameters = isShowKLineParameters;
    
    if (isShowKLineParameters) {
        RELEASE(btnParameter);
        btnParameter = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        btnParameter.titleLabel.adjustsFontSizeToFitWidth = YES;
        CGRect frame;
        
        if (_volumeBlankHeight > 20) {
            frame.origin.x = 10;
            frame.origin.y = klineHeight + volumeTextHeight + (_volumeBlankHeight - 20) / 2.0f;
            btnParameter.userInteractionEnabled = YES;
        } else {
            frame.origin.y = CHART_HEIGHT - 50;
            frame.origin.x = CHART_WIDTH - 25;
            btnParameter.userInteractionEnabled = NO;
        }
        frame.size.width = 45;
        frame.size.height = 20;
        btnParameter.frame = frame;
        [btnParameter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnParameter setBackgroundImage:[CommonUtil createImageWithColor:RGBA(0, 161, 242, 1) withViewForSize:btnParameter] forState:UIControlStateNormal];
        btnParameter.titleLabel.font = [UIFont systemFontOfSize:12];
        self.volumeType = KLineIndexTypeVOL;
        [CommonUtil viewMasksToBounds:btnParameter cornerRadius:3 borderColor:nil];
        btnParameter.userInteractionEnabled = NO;
        [btnParameter addTarget:self action:@selector(volumeShowTypeChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnParameter];
    } else if (btnParameter) {
        [btnParameter removeFromSuperview];
        RELEASE(btnParameter);
    }
}

/**
 *   记录股票的除权数据
 *   @param exArray
 */
- (void)addStockExRights:(NSArray *)exArray {
    [stockExRightsArray removeAllObjects];
    
    if (!exArray || (exArray.count == 0)) return;
    
    [stockExRightsArray addObjectsFromArray:exArray];
}

- (void)dealloc {
    RELEASE(pullShowText);
    RELEASE(pullNormalText);
    RELEASE(pullLoadingText);
    [self releaseColor];
    RELEASE(_kLineViewBackgroundColor);
    RELEASE(btnParameter);
    RELEASE(pinchGesture);
    RELEASE(longGesture);
    RELEASE(panGesture);
    RELEASE(tapGesture);
    RELEASE(leftPriceImage);
    [restorationArray removeAllObjects];
    RELEASE(restorationArray);
    RELEASE(stockExRightsArray);
    RELEASE(progressHUD);
    RELEASE(_fullcode);
    RELEASE(volumeTextFont);
    [netKLineArray removeAllObjects];
    RELEASE(netKLineArray);
    [resultArray release];
    [coordinateArray release];
    [kLineTipsView release];
    [super dealloc];
}

- (void)setCandlesWidth:(CGFloat)cw {
    candlesWidth = cw;
    defaultCandleWidth = cw;
    candlesNumber = (klineDrawWidth + spacing) / (candlesWidth + spacing);
    defaultShowRange = NSMakeRange(0, candlesNumber);
}

#pragma mark - 捏合事件处理
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        lastScale = 1;
        CGPoint firstPoint = [recognizer locationOfTouch:0 inView:self];
        CGPoint secondPoint = [recognizer locationOfTouch:1 inView:self];
        pinchIsLicit = [self calculateTouchArea:firstPoint secondPoint:secondPoint] == KLineTouchAreaKLine;
        [self delegateForKLineTouch:YES];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (!pinchIsLicit) return;	/* 捏合不合法时,不操作 */
        
        CGFloat scale = (recognizer.scale - lastScale) / 2.0f + 1;
        lastScale = recognizer.scale;
        
        if ((scale == 1) || ((candlesWidth <= _minCandlesWidth) && (scale < 1)) || ((candlesWidth >= _maxCandlesWidth) && (scale > 1))) {
            return;
        }
        NSUInteger location = showRange.location;
        NSUInteger length = showRange.length;
        candlesWidth *= scale;
        candlesWidth = MAX(_minCandlesWidth, candlesWidth);
        candlesWidth = MIN(_maxCandlesWidth, candlesWidth);
        spacing = candlesWidth / 2.0f;
        candlesNumber = floor((klineDrawWidth + spacing) / (candlesWidth + spacing));
        spacing = (klineDrawWidth - candlesNumber * candlesWidth) / (candlesNumber - 1);
        NSUInteger count = MIN(stockArray.count, _maxKLineNumber);
        candlesNumber = MIN(count, candlesNumber);
        NSUInteger l;
        if(location + length < candlesNumber){
            l = location + candlesNumber - length;
        }else{
            l = location + length - candlesNumber;
        }
        NSUInteger _startLocation = 0;
        if (_maxKLineNumber < stockArray.count) {
            _startLocation = MAX(stockArray.count - _maxKLineNumber, 0);
        }
        showRange.location = l < _startLocation ? _startLocation : l;
        showRange.length = candlesNumber;
        NSInteger differenceCount = stockArray.count - _maxKLineNumber - 1;
        differenceCount = MAX(differenceCount, 0);
        showRange.location = MAX(showRange.location, differenceCount);
        [self calculationShowArray];
    } else {
        pinchIsLicit = YES;
        lastScale = 1.0f;
        [self delegateForKLineTouch:NO];
    }
}

#pragma mark - 白线滑动事件处理
- (void)longPressGesture:(UILongPressGestureRecognizer *)recognizer {
    downPoint = [recognizer locationInView:self];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            longIsLicit = [self calculateTouchArea:downPoint secondPoint:CGPointZero] == KLineTouchAreaKLine;
            _isShowLine = longIsLicit;
            [self delegateForKLineTouch:longIsLicit];
            //不能break,因为出现白线的时候就要显示数据
        case UIGestureRecognizerStateChanged:
        {
            if (!longIsLicit) return;	/* 长按位置不合法时,不操作 */
            
            [self calculateLinePosition:downPoint.x];
            [self delegateForShowKLineWithPoint:NO];
            break;
        }
            
        default:
            _isShowLine = NO;
            longIsLicit = YES;
            [self setNeedsDisplay];
            [self delegateForShowKLineWithPoint:YES];
            [self delegateForKLineTouch:NO];
            break;
    }
}

#pragma mark - K线拖动事件处理
- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        startLocation = showRange.location;
        downPoint = [recognizer locationInView:self];
        [self delegateForKLineTouch:YES];
        panIsLicit = [self calculateTouchArea:downPoint secondPoint:CGPointZero] == KLineTouchAreaKLine;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (!panIsLicit) return;//不合法时.不操作
        
        CGPoint movePoint = [recognizer locationInView:self];
        int moveNum = floor((movePoint.x - downPoint.x) / (candlesWidth + spacing));
        
        NSUInteger count = stockArray.count;
        NSUInteger minCount = MIN(stockArray.count, _maxKLineNumber);
        NSInteger differenceCount = stockArray.count - _maxKLineNumber - 1;
        differenceCount = MAX(differenceCount, 0);
        
        if ((moveNum < 0) && (offsetX != 0)) {	/* 右拖加载更多时,向左滑动超过初始位置 */
            offsetX = 0;
            [self setNeedsDisplay];
        } else if (moveNum > 0) {/* 向右滑 */
            if ((showRange.location == differenceCount) && _canRightPullAddMore) {//右拖加载更多
                if (startLocation != differenceCount) return;
                offsetX = movePoint.x - downPoint.x;
                if (offsetX > rightPullMaxX) {
//                    downPoint.x += rightPullMaxX - offsetX;
                    offsetX = rightPullMaxX;
                }
                rightPullType = offsetX < rightPullMaxX*3/5.0f ? 1 : 2;
                [self setNeedsDisplay];
                return;
            } else {//向右拖动
                if ((showRange.location > differenceCount) && (candlesNumber < minCount)) {
                    NSInteger location = showRange.location - moveNum;
                    if (location < differenceCount) {
                        showRange.location = differenceCount;
                    } else {
                        showRange.location = location;
                    }
                    [self calculationShowArray:showRange];
                }
            }
        } else if (moveNum < 0) {/* 向左滑 */
            if (showRange.location + showRange.length < count) {
                if (showRange.location - moveNum + showRange.length < count) {
                    showRange.location -= moveNum;
                } else {
                    showRange.location = count - showRange.length;
                }
                [self calculationShowArray:showRange];
            }
        }
        
        if (moveNum != 0) downPoint = movePoint;
    } else {
//        panGesture.isEnd = false;
        if (rightPullType == 2) {
            rightPullType = 3;
            KLine *k = [stockArray firstObject];
            
            if (offsetX >= rightPullMaxX/2.0f) {
                offsetX = rightPullMaxX;
                [self setNeedsDisplay];
            }
            [self leftPullAddMoreData:k];
        } else if (offsetX != 0) {
            rightPullType = 0;
            offsetX = 0;
            [self setNeedsDisplay];
        }
        [self delegateForKLineTouch:NO];
    }
}

- (void)leftPullAddMoreData:(KLine *)lastDate {}

- (void)hideLeftPull {
    rightPullType = 0;
    
    if (offsetX != 0) {
        offsetX = 0;
        [self setNeedsDisplay];
    }
}

#pragma mark - 成功量点击事件处理
- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if (!_isCanClickVolume) {/* 不可切换成交量时,不操作 */
        return;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [recognizer locationInView:self];
        
        if ([self calculateTouchArea:point secondPoint:CGPointZero] == KLineTouchAreaVolume) {
            [self volumeShowTypeChange];
        }
    }
}

- (void)volumeShowTypeChange {
    self.volumeType = ++_volumeType % 3;
    [self calculationCoordinate];
    [self delegateForShowKLineWithPoint:YES];
}

#pragma mark - 判断手指点击位置(如果只有一个手指,secondPoint就为CGPointZero)
- (KLineViewTouchArea)calculateTouchArea:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint {
    CGPoint point = CGPointZero;
    
    if (CGPointEqualToPoint(secondPoint, CGPointZero)) {/* 第二个为0 */
        point = firstPoint;
    } else {
        point = firstPoint.y < secondPoint.y ? firstPoint : secondPoint;
    }
    
    if (point.y <= klineHeight) {
        return KLineTouchAreaKLine;
    } else if (point.y <= volumeDrawY) {
        return KLineTouchAreaVolumeText;
    } else {
        return KLineTouchAreaVolume;
    }
}

#pragma mark - 计算白线所在坐标
- (void)calculateLinePosition:(CGFloat)pointX {
    if (coordinateArray.count == 0) {
        _isShowLine = NO;
        return;
    }
    
    if (_isShowLine) {
        NSUInteger count = coordinateArray.count;
        NSUInteger n = (pointX - spacing) / (candlesWidth + spacing);
        
        if (n >= count) n = count - 1;
        KLineCoordinate *lineK = [coordinateArray objectAtIndex:n];
        
        if (n + 1 < count) {
            KLineCoordinate *tempK = [coordinateArray objectAtIndex:n + 1];
            
            if (fabs(pointX - tempK.coordinateX) < fabs(pointX - lineK.coordinateX)) {
                n++;
                lineK = tempK;
            }
        }
        lPosition = lineK.index;
        linePointX = lineK.coordinateX;
        linePointY = lineK.coordinateY;
    } else {
        lPosition = stockArray.count - 1;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - 生成要显示的K线数据Array
- (void)createNetKLArray:(NSArray *)array {
    if (!array) return;
    
    candlesNumber = (klineDrawWidth + spacing) / (candlesWidth + spacing);
    if (array != netKLineArray) {
        [netKLineArray removeAllObjects];
        [netKLineArray addObjectsFromArray:array];
    }
    NSUInteger min = MIN(netKLineArray.count, _maxKLineNumber);
    showRange.length = MIN(candlesNumber, min);
    [self createKLineArrayFromNetKLineArray];
}

- (void)createKLineArrayFromNetKLineArray {
    if (netKLineArray.count == 0) return;
    
//    self.fullcode = nil;
//    KLine *kl =  [netKLineArray firstObject];
//    
//    if (!TTIsStringWithAnyText(_fullcode) && kl && TTIsStringWithAnyText(kl.fullcode)) {
//        self.fullcode = kl.fullcode;
//        _decimalPlaces = [CommonUtil quotationKeepDecimalPlacesWithFullcode:_fullcode];
//    }
}

/**
 *    计算涨跌幅
 *    @param array
 */
- (void)calculationRate:(NSMutableArray *)array {
    KLine *pastKLine = nil;
    if (!klineDataAscSel) klineDataAscSel = @selector(compareKeysByAsc:);
    [array sortUsingSelector:klineDataAscSel];	/* 排序 */
    
    if (array == netKLineArray) {
        KLine *k = [netKLineArray lastObject];
        
        if (k && (k.index + 1 != netKLineArray.count)) {
            NSUInteger index = 0;
            
            for (KLine *kk in netKLineArray) {
                kk.index = index;
                index++;
            }
        }
    }
    [self resetMValue];
    NSInteger index = 0;
    NSMutableArray *nineDayArray = [NSMutableArray new];
    
    for (KLine *kline in array) {
        if (pastKLine != nil) {
            if (pastKLine.realprice == 0) {
                kline.rate = 0;
                kline.amt = 0;
            } else {
                if ((kline.realprice == 0) || (kline.todayopen == 0)) {
                    kline.realprice = pastKLine.realprice;
                    kline.maximum = pastKLine.realprice;
                    kline.minimum = pastKLine.realprice;
                    kline.todayopen = pastKLine.realprice;
                    kline.m5 = pastKLine.m5;
                    kline.m10 = pastKLine.m10;
                    kline.m20 = pastKLine.m20;
                    kline.m30 = pastKLine.m30;
                    kline.volume = 0;
                    kline.vm5 = pastKLine.vm5;
                    kline.vm10 = pastKLine.vm10;
                } else {
                    kline.amt = kline.realprice - pastKLine.realprice;
                    kline.rate = kline.amt * 100 / pastKLine.realprice;
                }
                kline.yesterday = pastKLine.realprice;
            }
        }
        [self calculationRestorationMValue:kline index:index array:array];	/* 计算M5,M10,M20,VM5,VM10 */
        
        if (!kline.isHasIndex) {
            double max, min;
            [self calculationMACD:kline pastKLine:pastKLine];
            [self getNineDayMax:&max min:&min array:nineDayArray kLine:kline];
            [self calculationKDJ:kline pastKLine:pastKLine H9:max L9:min];
            kline.isHasIndex = YES;
        }
        pastKLine = kline;
        index++;
    }
    
    [nineDayArray removeAllObjects];
    RELEASE(nineDayArray);
}

/**
 *    计算MACD
 *    @param kL
 *    @param pK
 */
- (void)calculationMACD:(KLine *)kL pastKLine:(KLine *)pK {
    if (!pK) {	/* 不存在上一支时 */
        kL.ema12 = kL.realprice;
        kL.ema26 = kL.realprice;
        return;
    }
    double ema12 = N12 * kL.realprice + N13 * pK.ema12;
    double ema26 = N26 * kL.realprice + N27 * pK.ema26;
    double dif = ema12 - ema26;
    double dea = 0.2 * dif + 0.8 * pK.dea;
    double bar = 2 * (dif - dea);
    kL.ema12 = ema12;
    kL.ema26 = ema26;
    kL.dif = dif;
    kL.dea = dea;
    kL.bar = bar;
}

/**
 *    计算KDJ
 *    @param kL 当前K线
 *    @param pK 上一根K线
 *    @param H9 9天内最高价
 *    @param L9 9天内最低价
 */
- (void)calculationKDJ:(KLine *)kL pastKLine:(KLine *)pK H9:(double)H9 L9:(double)L9 {
    double rsv = 0;
    double k;
    double d;
    double j;
    
    if (!pK) {	/* 不存在上一支时 */
        if (kL.maximum == kL.minimum) {
            rsv = 50;
        } else {
            rsv = (kL.realprice - kL.minimum) / (kL.maximum - kL.minimum) * 100;
        }
        k = rsv;
        d = rsv;
        j = rsv;
    } else {
        if (H9 != L9) {
            rsv = (kL.realprice - L9) / (H9 - L9) * 100;
        } else {
            rsv = 50;
        }
        k = P23 * pK.kdjk + P13 * rsv;
        d = P23 * pK.kdjd + P13 * k;
        j = 3 * k - 2 * d;
    }
    kL.kdjk = k;
    kL.kdjd = d;
    kL.kdjj = j;
}

/**
 *    获取九天内的最大最小值
 *    @param max
 *    @param min
 *    @param array
 */
- (void)getNineDayMax:(double *)max min:(double *)min array:(NSMutableArray *)array kLine:(KLine *)kLine {
    if (!array) return;
    
    [array addObject:kLine];
    
    if (array.count > 9) {
        [array removeObjectAtIndex:0];
    }
    
    CGFloat l = 9999;
    CGFloat h = 0.0f;
    
    for (KLine *k in array) {
        h = MAX(k.maximum, h);
        l = MIN(k.minimum, l);
    }
    
    *max = h;
    *min = l;
}

#pragma mark - 计算坐标
- (void)calculationCoordinate {
    if ((resultArray == nil) || (resultArray.count <= 0)) return;
    
    isClearDrawRect = NO;
    [coordinateArray removeAllObjects];
    spanX = candlesWidth + spacing;
    float coordinateX = candlesWidth / 2.0f + 0.05 + _lacunae.left;	/* 起始一个K线的位置(最左) */

    
    NSDictionary *dic = [self getMaxAndMinWithArray:resultArray];
    
    if (!dic) return;
    
    klineMaxValue = [[dic objectForKey:KLineMaxValue] doubleValue];
    klineMinValue = [[dic objectForKey:KLineMinValue] doubleValue];
    klineSpanY = (double)(klineMaxValue - klineMinValue) / (double)klineHeight;
    
    
    if (_volumeType == KLineIndexTypeVOL) {
        volumeMaxValue = [[dic objectForKey:VolumeMaxValue] floatValue];
        volumeSpanY = volumeMaxValue / volumeHeight;/* 成交量 */
    } else if (_volumeType == KLineIndexTypeMACD) {
        macdMax = [[dic objectForKey:MACDMax] floatValue];
        macdMin = [[dic objectForKey:MACDMin] floatValue];
        macdSpanY = (macdMax - macdMin) / volumeHeight;	/* MACD */
    } else if (_volumeType == KLineIndexTypeKDJ) {
        kdjMax = [[dic objectForKey:KDJMax] floatValue];
        kdjMin = [[dic objectForKey:KDJMin] floatValue];
        kdjSpanY = (kdjMax - kdjMin) / volumeHeight;/* KDJ */
    }
    
    for (KLine *kl in resultArray) {
        KLineCoordinate *coordinate = [[KLineCoordinate alloc] init];
        coordinate.index = kl.index;
        coordinate.coordinateX = coordinateX;	/* X坐标 */
        coordinate.coordinateY =((CGFloat)(klineMaxValue - kl.realprice) / (klineMaxValue - klineMinValue)) * klineHeight;
        [coordinate setAmt:kl.realprice today:kl.todayopen];/* 收盘价与开盘价涨跌 */
        coordinate.maximum = [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.maximum] + _lacunae.top;/* 最大值 */
        coordinate.minimum = [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.minimum] + _lacunae.top;/* 最小值 */
        coordinate.todayopen = [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.todayopen] + _lacunae.top;/* 开盘 */
        coordinate.realprice = [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.realprice] + _lacunae.top;/* 收盘 */
        coordinate.M5 = kl.m5 > 0 ? [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.m5] + _lacunae.top : -1;	/* M5 */
        coordinate.M10 = kl.m10 > 0 ? [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.m10] + _lacunae.top : -1;	/* M10 */
        coordinate.M20 = kl.m20 > 0 ? [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.m20] + _lacunae.top : -1;	/* M20 */
        coordinate.M30 = kl.m30 > 0 ? [CommonUtil getCharPixelY:klineMaxValue spanY:klineSpanY value:kl.m30] + _lacunae.top : -1;    /* M30 */
        coordinate.rate =  kl.rate;
        
        if (_volumeType == KLineIndexTypeVOL) {
            coordinate.volume = [CommonUtil getVolumeY:volumeMaxValue spanY:volumeSpanY value:kl.volume] + volumeDrawY;	/* Volume */
            coordinate.VM5 = [CommonUtil getCharPixelY:volumeMaxValue spanY:volumeSpanY value:kl.vm5] + volumeDrawY;/* M5 */
            coordinate.VM10 = [CommonUtil getCharPixelY:volumeMaxValue spanY:volumeSpanY value:kl.vm10] + volumeDrawY;	/* M10 */
            if (kl.vm20 > 0) {
                coordinate.VM20 = [CommonUtil getCharPixelY:volumeMaxValue spanY:volumeSpanY value:kl.vm20] + volumeDrawY;	/* M20 */
            } else {
                coordinate.VM20 = CHART_HEIGHT;
            }
        } else if (_volumeType == KLineIndexTypeMACD) {
            coordinate.dif = [CommonUtil getCharPixelYCanNegative:macdMax spanY:macdSpanY value:kl.dif] + volumeDrawY;	/* dif */
            coordinate.dea = [CommonUtil getCharPixelYCanNegative:macdMax spanY:macdSpanY value:kl.dea] + volumeDrawY;	/* dea */
            coordinate.bar = [CommonUtil getCharPixelYCanNegative:macdMax spanY:macdSpanY value:kl.bar] + volumeDrawY;	/* bar */
        } else if (_volumeType == KLineIndexTypeKDJ) {
            coordinate.KDJK = [CommonUtil getCharPixelY:kdjMax spanY:kdjSpanY value:kl.kdjk] + volumeDrawY;	/* K */
            coordinate.KDJD = [CommonUtil getCharPixelY:kdjMax spanY:kdjSpanY value:kl.kdjd] + volumeDrawY;	/* D */
            coordinate.KDJJ = [CommonUtil getCharPixelYCanNegative:kdjMax spanY:kdjSpanY value:kl.kdjj] + volumeDrawY;	/* J */
        }
        coordinate.stockdate = kl.stockdate;
        coordinate.stockTime = kl.stocktime;
        coordinate.shtDay = kl.shtDay;
        coordinate.shtTime = kl.shtTime;
        coordinate.b1s2 = kl.b1s2;
        coordinate.face = kl.face;
        [coordinateArray addObject:coordinate];	/* 将转换后的结果缓存 */
        coordinateX += spanX;	/* X坐标自增到下一条位置 */
        [coordinate release];
    }
    
    [self setNeedsDisplay];	/* 回调画图 */
}

#pragma mark - 计算最大最小值
- (NSDictionary *)getMaxAndMinWithArray:(NSArray *)array {
    if (!array || (array.count == 0)) return nil;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    BOOL isInitialization = YES;
    
    CGFloat _klineMaxValue = 0;
    CGFloat _klineMinValue = 999999;
    CGFloat _volumeMaxValue;
    CGFloat _kdjMax;
    CGFloat _kdjMin;
    CGFloat _macdMax;
    CGFloat _macdMin;
    
    for (KLine *kl in array) {
        if (isInitialization) {	/* 第一次赋值 */
            _klineMaxValue = kl.maximum;
            _klineMaxValue = fmax(_klineMaxValue, kl.m5);
            _klineMaxValue = fmax(_klineMaxValue, kl.m10);
            _klineMaxValue = fmax(_klineMaxValue, kl.m20);
            _klineMaxValue = fmax(_klineMaxValue, kl.m30);
            _klineMinValue = kl.minimum;
            
            if (kl.m5 > 0) _klineMinValue = fmin(_klineMinValue, kl.m5);
            
            if (kl.m10 > 0) _klineMinValue = fmin(_klineMinValue, kl.m10);
            
            if (kl.m20 > 0) _klineMinValue = fmin(_klineMinValue, kl.m20);
            
            if (kl.m30 > 0) _klineMinValue = fmin(_klineMinValue, kl.m30);
            
            if (_volumeType == KLineIndexTypeVOL) {
                _volumeMaxValue = fmaxl(kl.vm5, kl.vm10);
                _volumeMaxValue = fmaxl(_volumeMaxValue, kl.volume);
                _volumeMaxValue = fmaxl(_volumeMaxValue, kl.vm20);
            } else if (_volumeType == KLineIndexTypeMACD) {
                _macdMax = fmaxf(kl.dif, kl.dea);
                _macdMax = fmaxf(_macdMax, kl.bar);
                _macdMin = fmaxf(kl.dif, kl.dea);
                _macdMin = fmaxf(_macdMin, kl.bar);
            } else if (_volumeType == KLineIndexTypeKDJ) {
                _kdjMax = fmaxf(kl.kdjk, kl.kdjd);
                _kdjMax = fmaxf(_kdjMax, kl.kdjj);
                _kdjMin = fminf(kl.kdjk, kl.kdjd);
                _kdjMin = fminf(_kdjMin, kl.kdjj);
            }
            isInitialization = !(_klineMaxValue > 0 && _klineMinValue > 0);
        } else {// 计算最大最小值
            _klineMaxValue = fmax(_klineMaxValue, kl.maximum);
            _klineMaxValue = fmax(_klineMaxValue, kl.m5);
            _klineMaxValue = fmax(_klineMaxValue, kl.m10);
            _klineMaxValue = fmax(_klineMaxValue, kl.m20);
            _klineMaxValue = fmax(_klineMaxValue, kl.m30);
            
            if (kl.minimum > 0) _klineMinValue = fmin(_klineMinValue, kl.minimum);
            
            if (kl.m5 > 0) _klineMinValue = fmin(_klineMinValue, kl.m5);
            
            if (kl.m10 > 0) _klineMinValue = fmin(_klineMinValue, kl.m10);
            
            if (kl.m20 > 0) _klineMinValue = fmin(_klineMinValue, kl.m20);
            
            if (kl.m30 > 0) _klineMinValue = fmin(_klineMinValue, kl.m30);
            
            if (_volumeType == KLineIndexTypeVOL) {
                _volumeMaxValue = fmaxl(_volumeMaxValue, kl.volume);
                _volumeMaxValue = fmaxl(_volumeMaxValue, kl.vm5);
                _volumeMaxValue = fmaxl(_volumeMaxValue, kl.vm10);
                _volumeMaxValue = fmaxl(_volumeMaxValue, kl.vm20);
            } else if (_volumeType == KLineIndexTypeMACD) {
                _macdMax = fmaxf(_macdMax, kl.dif);
                _macdMax = fmaxf(_macdMax, kl.dea);
                _macdMax = fmaxf(_macdMax, kl.bar);
                _macdMin = fminf(_macdMin, kl.dif);
                _macdMin = fminf(_macdMin, kl.dea);
                _macdMin = fminf(_macdMin, kl.bar);
                _macdMax = fmaxf(_macdMax, fabs(_macdMin));
                _macdMin = -_macdMax;
            } else if (_volumeType == KLineIndexTypeKDJ) {
                _kdjMax = fmaxf(_kdjMax, kl.kdjk);
                _kdjMax = fmaxf(_kdjMax, kl.kdjd);
                _kdjMax = fmaxf(_kdjMax, kl.kdjj);
                _kdjMin = fminf(_kdjMin, kl.kdjk);
                _kdjMin = fminf(_kdjMin, kl.kdjd);
                _kdjMin = fminf(_kdjMin, kl.kdjj);
            }
        }
    }
    
    if ((_klineMaxValue == _klineMinValue) && (_klineMinValue > 0)) {/* 最大值和最小值相同时,就上调10% */
        CGFloat temp = _klineMaxValue / 10.0;
        _klineMaxValue += temp;
        _klineMinValue -= temp;
    }
    [dic setObject:[NSNumber numberWithFloat:_klineMaxValue] forKey:KLineMaxValue];
    [dic setObject:[NSNumber numberWithFloat:_klineMinValue] forKey:KLineMinValue];
    [dic setObject:[NSNumber numberWithFloat:_volumeMaxValue] forKey:VolumeMaxValue];
    [dic setObject:[NSNumber numberWithFloat:_kdjMax] forKey:KDJMax];
    [dic setObject:[NSNumber numberWithFloat:_kdjMin] forKey:KDJMin];
    [dic setObject:[NSNumber numberWithFloat:_macdMax] forKey:MACDMax];
    [dic setObject:[NSNumber numberWithFloat:_macdMin] forKey:MACDMin];
    return dic;
}

#pragma mark - 计算当前屏幕显示的K线

/**
 *    计算当前屏幕显示的K线,显示最新的那条
 */
- (void)calculationShowArrayAndShowNew {
    if (showRange.length > stockArray.count) {
        showRange.length = stockArray.count;
    } else if (showRange.length < stockArray.count) {
        showRange.length = MIN(stockArray.count, candlesNumber);
    }
    showRange.location = stockArray.count - showRange.length;
    [self calculationShowArray:showRange];
}

/**
 *    计算当前屏幕显示的K线,不用隐藏一部分K线就调用这个
 */
- (void)calculationShowArray {
    if (showRange.length > stockArray.count) {
        showRange.length = stockArray.count;
    } else if (showRange.length < stockArray.count) {
        showRange.length = MIN(stockArray.count, candlesNumber);
    }
    [self calculationShowArray:showRange];
}

/**
 *   @method 计算当前屏幕显示的K线
 *   (特殊情况下使用,比如要显示的K线不是拿到的所有K线数据-K线角斗场)
 *   @param range 显示K线的区间
 */
- (void)calculationShowArray:(NSRange)range {
    [resultArray removeAllObjects];
    NSUInteger count = stockArray.count;
    
    if ((stockArray != nil) && (count > 0)) {
        if (range.length > _maxKLineNumber) range.length = _maxKLineNumber;
        if ((range.location + range.length > count)) range.location = count - range.length;
        [resultArray addObjectsFromArray:[stockArray subarrayWithRange:range]];
        if (!klineDataAscSel) klineDataAscSel = @selector(compareKeysByAsc:);
        [resultArray sortUsingSelector:klineDataAscSel];
        [self delegateForShowKLineWithPoint:YES];
        [self calculationCoordinate];
    }
}

#pragma mark - 返回白线所在位置的K线数据,没白线则为最新的一根K线数据
- (void)delegateForShowKLineWithPoint:(BOOL)isEnd {
    if (_delegateFlags.kLineShowData) {
        if (_isShouldReturnKLineData || _isShowLine) {
            KLine *showKLine = nil;
            
            if (_isShowLine) {
                showKLine = lPosition < stockArray.count ?[stockArray objectAtIndex:lPosition] : nil;
            } else {
                showKLine = [stockArray lastObject];
            }
            [_delegate kLineShowData:showKLine VolumeType:_volumeType isEnd:isEnd];
        }
    }
}

- (void)delegateForKLineTouch:(BOOL)isTouch {
    if (_delegateFlags.kLineTouch) {
        [_delegate kLineTouch:isTouch isShowLine:_isShowLine];
    }
}

#pragma mark - 计算复权后的具体数据

/**
 *    计算复权数据
 *    @param isRestoration  YES是计算复权,NO为除权数据
 */
- (void)calculationRestoration:(BOOL)isRestoration {
    if (isRestoration) {
        KLine *netK = [netKLineArray firstObject];
        KLine *restorationK = [restorationArray firstObject];
        
        // 如果存在复权数据,则取出来
        if (restorationK && [restorationK.fullcode isEqualToString:netK.fullcode]) {
            [self createKLineArrayFromNetKLineArray];
            [self calculationShowArray];
            return;
        }
        
        [restorationArray removeAllObjects];
        if (!klineDataDescSel) klineDataDescSel = @selector(compareKeysByDes:);
        [stockExRightsArray sortUsingSelector:klineDataDescSel];/* 排序 */
        KLine *pastKL = nil;
        NSMutableArray *nineDayArray = [NSMutableArray new];
        [self resetMValue];
        NSInteger index = 0;
        
        for (KLine *line in netKLineArray) {
            KLine *kk = [line copy];
            [restorationArray addObject:kk];
            for (StockExRights *stockEx in stockExRightsArray) {
                NSInteger success = 0;
                
                if ((cycle == KLineDataMonth) && ((int)(kk.stockdate / 100) == (int)(stockEx.stockDate / 100)) && (kk.stockdate % 100 != 1)) {
                    /* 月线的日期是最后一天的日期,如果是1号除权,那么不做复权操作,其他只计算部分复权数据,收盘和最小不用计算 */
                    success = 2;
                } else if ((cycle == KLineDataWeek) && [self twoDateInSameWeekWithStockDate:kk.stockdate exRightsDate:stockEx.stockDate]) {
                    /* 周线的日期是最后一天的日期,所以周线时,要判断K线日期和除权日期是否在同一周内,如果周一除权,那么不做复权操作(周一当不在同一周内操作)
                     *  其他只计算部分复权数据,收盘和最小不用计算 */
                    success = 2;
                } else if (kk.stockdate < stockEx.stockDate) {
                    success = 1;	/* 计算所有值的复权数据 */
                } else if (cycle == KLineDataDay) {
                    success = 0;	//不计算复权数据
                }
                //                else if (kk.stockdate == stockEx.stockDate) {
                // 周线时,k线日期和除权时期相同时,复权就出现数据错误
                //					success = 2;	/* 计算部分复权数据,收盘和最小不用计算 */
                //				}
                
                if (success > 0) {
                    CGFloat max = kk.maximum;
                    CGFloat open = kk.todayopen;
                    kk.maximum = [self calculationDataWithStockExrights:stockEx price:kk.maximum];
                    kk.todayopen = [self calculationDataWithStockExrights:stockEx price:kk.todayopen];
                    
                    if (success != 2) {		/* 计算部分复权数据,收盘和最小不用计算 */
                        kk.realprice = [self calculationDataWithStockExrights:stockEx price:kk.realprice];
                        kk.minimum = [self calculationDataWithStockExrights:stockEx price:kk.minimum];
                    }
                    if (kk.maximum < kk.minimum) {
                        kk.maximum = max;
                        kk.todayopen = open;
                    }
                } else {
                    break;
                }
            }
            
            if (pastKL) {
                if (pastKL.realprice > 0) {
                    kk.amt = kk.realprice - pastKL.realprice;
                    kk.rate = kk.amt / pastKL.realprice * 100;
                } else {
                    kk.amt = 0;
                    pastKL.rate = 0;
                }
            }
            /* 计算当前的M5,M10,M20,M30,VM5,VM10 */
            [self calculationRestorationMValue:kk index:index array:restorationArray];
            double max, min;
            [self calculationMACD:kk pastKLine:pastKL];
            [self getNineDayMax:&max min:&min array:nineDayArray kLine:kk];
            [self calculationKDJ:kk pastKLine:pastKL H9:max L9:min];
            pastKL = kk;
            index++;
            RELEASE(kk);
        }
        
        RELEASE(nineDayArray);
    }
    [self createKLineArrayFromNetKLineArray];
    [self calculationShowArray];
}

#pragma mark - 计算复权后的价格
- (CGFloat)calculationDataWithStockExrights:(StockExRights *)stockEx price:(CGFloat)price {
    if (!stockEx) return price;
    
    /* 复权后价格=((复权前价格-分红)/(1+送股比例(每10送就除10)) + 配价*配价×配股比例(每10就除10))/(1+配股比例(每10配就除10)) */
    return ((price - stockEx.fenHong * 0.1f) / (1 + stockEx.songGu * 0.1f) + stockEx.peiJia * stockEx.peiGu * 0.1f) / (1 + stockEx.peiGu * 0.1f);
}

#pragma mark - 计算复权后的M5,M10,M20,M30
- (void)resetMValue {
    sumM5     = 0;
    sumM10    = 0;
    sumM20    = 0;
    sumM30    = 0;
    firstM5   = 0;
    firstM10  = 0;
    firstM20  = 0;
    firstM30  = 0;
    sumVM5    = 0;
    sumVM10   = 0;
    firstVM5  = 0;
    firstVM10 = 0;
}

/**
 *	计算复权后的M5,M10,M20,VM5,VM10(从小往大算)
 */
- (void)calculationRestorationMValue:(KLine *)kl index:(NSInteger)index array:(NSArray *)array {
    KLine *firstKL;
    
    sumM5 += kl.realprice;
    sumM10 += kl.realprice;
    sumM20 += kl.realprice;
    sumM30 += kl.realprice;
    sumVM5 += kl.volume;
    sumVM10 += kl.volume;
    
    if (index >= 4) {
        if (index > 4) {
            sumM5 -= firstM5;
            sumVM5 -= firstVM5;
        }
        
        kl.m5 = sumM5 / 5;
        kl.vm5 = sumVM5 / 5;
        firstKL = [array objectAtIndex:index - 4];
        firstM5 = firstKL.realprice;
        firstVM5 = firstKL.volume;
    }
    
    if (index >= 9) {
        if (index > 9) {
            sumM10 -= firstM10;
            sumVM10 -= firstVM10;
        }
        
        kl.m10 = sumM10 / 10;
        kl.vm10 = sumVM10 / 10;
        firstKL = [array objectAtIndex:index - 9];
        firstM10 = firstKL.realprice;
        firstVM10 = firstKL.volume;
    }
    
    if (index >= 19) {
        if (index > 19) {
            sumM20 -= firstM20;
        }
        
        kl.m20 = sumM20 / 20;
        firstKL = [array objectAtIndex:index - 19];
        firstM20 = firstKL.realprice;
    }
    
    if(index >= 29){
        if (index > 29) {
            sumM30 -= firstM30;
        }
        
        kl.m30 = sumM30 / 30;
        firstKL = [array objectAtIndex:index - 29];
        firstM30 = firstKL.realprice;
    }
}

#pragma mark - 两个日期是否在同一周内

/**
 *	两个日期是否在同一周内
 *	@param firstDate
 *	@param secondDate
 *	@returns
 */
- (BOOL)twoDateInSameWeekWithStockDate:(NSInteger)stockDate exRightsDate:(NSInteger)exRightsDate {
    if (exRightsDate > stockDate) return false;
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMdd"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *start;
    NSDate *first = [dateformat dateFromString:[NSString stringWithFormat:@"%@", @(stockDate)]];
    NSTimeInterval extends;
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *second = [dateformat dateFromString:[NSString stringWithFormat:@"%@", @(exRightsDate)]];
    
    BOOL success = [cal rangeOfUnit:NSWeekCalendarUnit startDate:&start interval:&extends forDate:second];
    
    if (!success) return NO;
    
    NSTimeInterval dateInSecs = [first timeIntervalSinceReferenceDate];
    NSTimeInterval dayStartInSecs = [start timeIntervalSinceReferenceDate];
    RELEASE(dateformat);
    BOOL same = dateInSecs > dayStartInSecs && dateInSecs < (dayStartInSecs + extends);
    
    if (same && ([self getWeekDayWithDate:exRightsDate] == 1)) {
        same = NO;
    }
    return same;
}

/**
 *    获取一个日期是星期几
 *    @param date
 *    @returns 返回0-6(0为星期天,1为星期一,类推)
 */
- (NSInteger)getWeekDayWithDate:(NSInteger)date {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc] init];
    
    [dateformat setDateFormat:@"yyyyMMdd"];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"GMT"];
    
    [calendar setTimeZone:timezone];
    NSDate *fromeDate = [dateformat dateFromString:[NSString stringWithFormat:@"%@",@(date)]];
    RELEASE(dateformat);
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:fromeDate];
    return [comps weekday];
}

#pragma mark - 清除画布
- (void)cleanDraw {
    [self resetMValue];
    _isShowLine = NO;
    _isStockExRights = YES;
    isClearDrawRect = YES;
    [restorationArray removeAllObjects];
    [netKLineArray removeAllObjects];
    [coordinateArray removeAllObjects];
    [self candleReset];
    [self setNeedsDisplay];
}

#pragma mark - 画图总方法
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);	/* 清除画布 */
    CGContextSetStrokeColorWithColor(context, _kLineViewBackgroundColor.CGColor);
    CGContextSetFillColorWithColor(context, _kLineViewBackgroundColor.CGColor);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    [self drawBackgroundLine:context];	/* 画成交量背景线 */
    
    if (isClearDrawRect) return [self drawVolumeTextWithVolumeType:_volumeType isClean:YES context:context];
    
    
    KLineCoordinate *pastKc = nil;
    int index = 1;
    
    CGContextSaveGState(context);
    
    switch (_volumeType) {
        case 0:	/* 成交量 */
            
            if (candlesWidth < KLineCandlesMinWidth) {	/* 蜡烛的宽度太小时 */
                for (KLineCoordinate *kc in coordinateArray) {
                    [self drawCandlesOnlyLine:kc pastKLineCoordinate:pastKc context:context];
                    
                    if (!_isOnlyDrawKLine) [self drawVolumeOnlyLine:kc pastKLineCoordinate:pastKc context:context];
                    pastKc = kc;
                }
            } else {
                for (KLineCoordinate *kc in coordinateArray) {
                    [self drawCandles:kc context:context kLineIndex:index];
                    [self drawM:kc pastKLineCoordinate:pastKc context:context];
                    
                    if (!_isOnlyDrawKLine) [self drawVolume:kc pastKLineCoordinate:pastKc context:context];
                    pastKc = kc;
                    index++;
                }
            }
            
            break;
            
        case 1:	/* MACD */
            
            if (candlesWidth < KLineCandlesMinWidth) {	/* 蜡烛的宽度太小时 */
                for (KLineCoordinate *kc in coordinateArray) {
                    [self drawCandlesOnlyLine:kc pastKLineCoordinate:pastKc context:context];
                    
                    if (!_isOnlyDrawKLine) [self drawMACD:kc pastKLineCoordinate:pastKc context:context];
                    pastKc = kc;
                }
            } else {
                for (KLineCoordinate *kc in coordinateArray) {
                    [self drawCandles:kc context:context kLineIndex:index];
                    [self drawM:kc pastKLineCoordinate:pastKc context:context];
                    
                    if (!_isOnlyDrawKLine) [self drawMACD:kc pastKLineCoordinate:pastKc context:context];
                    pastKc = kc;
                    index++;
                }
            }
            
            break;
            
        case 2:	/* KDJ */
            
            if (candlesWidth < KLineCandlesMinWidth) {	/* 蜡烛的宽度太小时 */
                for (KLineCoordinate *kc in coordinateArray) {
                    [self drawCandlesOnlyLine:kc pastKLineCoordinate:pastKc context:context];
                    
                    if (!_isOnlyDrawKLine) [self drawKDJ:kc pastKLineCoordinate:pastKc context:context];
                    pastKc = kc;
                }
            } else {
                for (KLineCoordinate *kc in coordinateArray) {
                    [self drawCandles:kc context:context kLineIndex:index];
                    [self drawM:kc pastKLineCoordinate:pastKc context:context];
                    
                    if (!_isOnlyDrawKLine) [self drawKDJ:kc pastKLineCoordinate:pastKc context:context];
                    pastKc = kc;
                    index++;
                }
            }
            break;
    }
    
    CGContextRestoreGState(context);
    
    [self drawKLineTextMaxAndMin:context];    /* 画K线的最大最小值 */
    
    if (!_isOnlyDrawKLine) [self drawVolumeTextWithVolumeType:_volumeType isClean:NO context:context];
    
    if (_isShowLine){
        [self drawWhiteLine:context];    /* 画竖白线 */
    } else{
        if(!kLineTipsView.hidden){
            kLineTipsView.hidden = YES;
        }
    }
    
    if (self.isShowDate) [self drawLeftAndRightDate:context];/* 画成交量里 左边和右边的日期 */
    
    if (rightPullType > 0) [self drawRightPullAddMoreText:context];	/* 画右拖加载更多的文字 */
}

#pragma mark - 画背景虚线
- (void)drawBackgroundLine:(CGContextRef)context {
    CGContextSaveGState(context);
    double step = (double)klineHeight / 4;
    double volStep = (double)volumeHeight / 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [lineColor setStroke];	// RGBA(80, 80, 80, 1)
    [path setLineWidth:0.3];
    [path moveToPoint:CGPointMake(offsetX, 0)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, 0)];
    
    [path moveToPoint:CGPointMake(offsetX, 4 * step)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, 4 * step)];
    
    [path moveToPoint:CGPointMake(offsetX, volumeDrawY)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, volumeDrawY)];
    [path stroke];
    
    path = [UIBezierPath bezierPath];
    [path setLineWidth:0.5];
    [lineColor setStroke];
    [path moveToPoint:CGPointMake(offsetX, 1 * step)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, 1 * step)];
    
    [path moveToPoint:CGPointMake(offsetX, 2 * step)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, 2 * step)];
    
    [path moveToPoint:CGPointMake(offsetX, 3 * step)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, 3 * step)];
    
    if (self.volumeBlankHeight > 0) {
        [path moveToPoint:CGPointMake(offsetX, klineHeight + volumeTextHeight)];
        [path addLineToPoint:CGPointMake(CHART_WIDTH, klineHeight + volumeTextHeight)];
    }
    
    [path moveToPoint:CGPointMake(offsetX, volumeDrawY + volStep)];
    [path addLineToPoint:CGPointMake(CHART_WIDTH, volumeDrawY + volStep)];
    [path stroke];
    CGContextRestoreGState(context);
}

#pragma mark - 画K线的最大最小值
- (void)drawKLineTextMaxAndMin:(CGContextRef)context {
    CGContextSaveGState(context);
    float sizeFont = 12.0;
    
    NSString *maxString = [CommonUtil newFloat:klineMaxValue withNumber:_decimalPlaces];
    UIColor *color = [TradeUtil textColorWithQuotationNumber:1.0];;	// 最大值颜色
    UIFont *font = [UIFont systemFontOfSize:sizeFont];
    
    [maxString drawAtPoint:CGPointMake(2 + offsetX, 2) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    
    color = midValueColor;	// 平均值颜色
    NSString *midString = [CommonUtil newFloat:(klineMaxValue + klineMinValue) / 2 withNumber:_decimalPlaces];
    CGSize stringSize = [CommonUtil getPerfectSizeByText:midString andFontSize:sizeFont andWidth:1000];
    [midString drawAtPoint:CGPointMake(2 + offsetX, (klineHeight - stringSize.height) / 2.0f) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    
    color = [TradeUtil textColorWithQuotationNumber:-1.0];;// 最小值颜色
    NSString *minString = [CommonUtil newFloat:klineMinValue withNumber:_decimalPlaces];
    stringSize = [CommonUtil getPerfectSizeByText:minString andFontSize:sizeFont andWidth:1000];
    [minString drawAtPoint:CGPointMake(2 + offsetX, klineHeight - stringSize.height) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    CGContextRestoreGState(context);
}

#pragma mark - 画左边和右边的日期
- (void)drawLeftAndRightDate:(CGContextRef)context {
//    if (_isShowLine) return;
//    NSString *date = nil;
//
//    CGContextSaveGState(context);
//    float sizeFont = 12.0;
//    UIColor *color = RGBA(178, 178, 178, 1);/* 日期颜色 */
//    UIFont *font = [UIFont systemFontOfSize:sizeFont];
//    if (!coordinateArray || (coordinateArray.count == 0)) return;
//
//    KLineCoordinate *leftKl = nil;
//    KLineCoordinate *rightKl = nil;
//    leftKl = [coordinateArray firstObject];
//    rightKl = [coordinateArray lastObject];
//
//    if (leftKl == rightKl) rightKl = nil;
//
//    if (!leftKl) {
//        date = nil;
//    } else if (cycle < KLineDataDay) {
//        date = [VeDateUtil dateFormatterWithyyyyMMddHHmmToMM_dd_HH_mm:leftKl.stockTime];/* 分钟线时显示日期为01-01 15:14 */
//    } else {
//        date = [VeDateUtil getStringIntToDate:leftKl.stockdate stytle:@"-" keepHead:YES];
//    }
//
//    CGSize leftStringSize, rightStringSize;
//
//    if (TTIsStringWithAnyText(date)) {    // 最左边的日期
//        [date drawAtPoint:CGPointMake(1.0 + offsetX, volumeDrawY) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
//    }
//
//    date = nil;
//
//    if (!rightKl) {
//        date = nil;
//    } else if (cycle < KLineDataDay) {
//        date = [VeDateUtil dateFormatterWithyyyyMMddHHmmToMM_dd_HH_mm:rightKl.stockTime];    // 分钟线时显示日期为01-01 15:14
//    } else {
//        date = [VeDateUtil getStringIntToDate:rightKl.stockdate stytle:@"-" keepHead:YES];
//    }
//
//    if (TTIsStringWithAnyText(date)) {    // 最右边的日期
//        rightStringSize = [CommonUtil getPerfectSizeByText:date andFontSize:sizeFont andWidth:1000];
//        float x = rightKl.coordinateX - rightStringSize.width / 2.0f;
//
//        if (x + rightStringSize.width > CHART_WIDTH) {
//            x = CHART_WIDTH - rightStringSize.width;
//        } else if (x < leftStringSize.width + 2) {
//            x = leftStringSize.width + 2;
//        }
//        [date drawAtPoint:CGPointMake(x, volumeDrawY) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
//    }
//    CGContextRestoreGState(context);
}

#pragma mark 画蜡烛图
- (void)drawCandles:(KLineCoordinate *)kc context:(CGContextRef)context kLineIndex:(NSInteger)kLineIndex {	/* amt 收盘价等于开盘价时为0 收盘价大于开盘价为正 反之为负 */
    
    if (kc.amt > 0) {/* 收盘价大于开盘价 */
        CGContextSetStrokeColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:1.0] CGColor]);
        CGContextSetFillColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:1.0] CGColor]);
        CGContextMoveToPoint(context, kc.coordinateX + offsetX, kc.maximum);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.realprice);
        CGContextStrokePath(context);
        
        if (fabs(kc.todayopen - kc.realprice) > 1) {
            if (_isFillRed) {
                CGContextFillRect(context, CGRectMake((float)(kc.coordinateX + offsetX - candlesWidth / 2), (float)kc.realprice, candlesWidth, fabs(kc.todayopen - kc.realprice)));
                CGContextFillPath(context);
            } else {
                CGContextStrokeRect(context, CGRectMake((float)(kc.coordinateX + offsetX - candlesWidth / 2), (float)kc.realprice, candlesWidth, fabs(kc.todayopen - kc.realprice)));
            }
        } else {/* 开盘价和收盘价差值太小,画不成矩形,所以画条直线 */
            CGContextMoveToPoint(context, (kc.coordinateX + offsetX - candlesWidth / 2), (float)kc.realprice);
            CGContextAddLineToPoint(context, (float)(kc.coordinateX + offsetX + candlesWidth / 2), (float)kc.realprice);
        }
        
        if (kc.minimum > kc.todayopen) {/* 最小比开盘大才画 */
            CGContextMoveToPoint(context, kc.coordinateX + offsetX, kc.todayopen);
            CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.minimum);
        }
        CGContextStrokePath(context);
    } else if (kc.amt < 0) {/* 收盘价小于开盘价 */
        CGContextSetStrokeColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:-1.0] CGColor]);
        CGContextSetFillColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:-1.0] CGColor]);
        CGContextMoveToPoint(context, kc.coordinateX + offsetX, kc.maximum);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.todayopen);
        CGContextStrokePath(context);
        
        if (fabs(kc.todayopen - kc.realprice) > 1) {
            CGContextFillRect(context, CGRectMake((float)(kc.coordinateX + offsetX - candlesWidth / 2), (float)kc.todayopen, candlesWidth, fabs(kc.todayopen - kc.realprice)));
            CGContextFillPath(context);
        } else {/* 开盘价和收盘价差值太小,画不成矩形,所以画条直线 */
            CGContextMoveToPoint(context, (kc.coordinateX + offsetX - candlesWidth / 2), (float)kc.realprice);
            CGContextAddLineToPoint(context, (float)(kc.coordinateX + offsetX + candlesWidth / 2), (float)kc.realprice);
        }
        
        if (kc.minimum > kc.realprice) {/* 最小比收盘大才画 */
            CGContextMoveToPoint(context, kc.coordinateX + offsetX, kc.realprice);
            CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.minimum);
        }
        CGContextStrokePath(context);
    } else {
        CGContextSetStrokeColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:1.0] CGColor]);
        CGContextSetFillColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:1.0] CGColor]);
        CGContextMoveToPoint(context, kc.coordinateX + offsetX, kc.maximum);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.minimum);
        CGContextMoveToPoint(context, (kc.coordinateX + offsetX - candlesWidth / 2), (float)kc.realprice);
        CGContextAddLineToPoint(context, (float)(kc.coordinateX + offsetX + candlesWidth / 2), (float)kc.realprice);
        CGContextStrokePath(context);
    }
}

#pragma mark - 画蜡烛图,因为宽度太小,所以只把收盘价连起来
- (void)drawCandlesOnlyLine:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context {
    if (pastKc == nil) return;
    
    if ((kc.realprice <= klineHeight) && (pastKc.realprice <= klineHeight) && ((kc.realprice > 0) && (pastKc.realprice > 0))) {	// M5
        CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
        CGContextSetFillColorWithColor(context, [normalColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.realprice);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.realprice);
        CGContextStrokePath(context);
    }
}

#pragma mark - 画均线
- (void)drawM:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context {
    if (pastKc == nil) return;
    
    if ((kc.M5 <= klineHeight) && (pastKc.M5 <= klineHeight) && ((kc.M5 > 0) && (pastKc.M5 > 0))) {	// M5
        CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
        CGContextSetFillColorWithColor(context, [normalColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.M5);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.M5);
        CGContextStrokePath(context);
    }
    
    if ((kc.M10 <= klineHeight) && (pastKc.M10 <= klineHeight) && ((kc.M10 > 0) && (pastKc.M10 > 0))) {	// M10
        CGContextSetStrokeColorWithColor(context, [yellowColor CGColor]);
        CGContextSetFillColorWithColor(context, [yellowColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.M10);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.M10);
        CGContextStrokePath(context);
    }
    
//    if ((kc.M20 <= klineHeight) && (pastKc.M20 <= klineHeight) && ((kc.M20 > 0) && (pastKc.M20 > 0))) {    // M20
//        CGContextSetStrokeColorWithColor(context, [purpleColor CGColor]);
//        CGContextSetFillColorWithColor(context, [purpleColor CGColor]);
//        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.M20);
//        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.M20);
//        CGContextStrokePath(context);
//    }
    
    if ((kc.M30 <= klineHeight) && (pastKc.M30 <= klineHeight) && ((kc.M30 > 0) && (pastKc.M30 > 0))) {    // M30
        CGContextSetStrokeColorWithColor(context, [purpleColor CGColor]);
        CGContextSetFillColorWithColor(context, [purpleColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.M30);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.M30);
        CGContextStrokePath(context);
    }
}

#pragma mark - 画成交量
- (void)drawVolume:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context {
    if (pastKc != nil) {
        if ((kc.VM5 < volumeHeight + volumeDrawY) && (pastKc.VM5 < volumeHeight + volumeDrawY)) {	// VM5
            CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
            CGContextSetFillColorWithColor(context, [normalColor CGColor]);
            CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.VM5);
            CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.VM5);
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextStrokePath(context);
        }
        
        if ((kc.VM10 < volumeHeight + volumeDrawY) && (pastKc.VM10 < volumeHeight + volumeDrawY)) {	// VM10
            CGContextSetStrokeColorWithColor(context, [yellowColor CGColor]);
            CGContextSetFillColorWithColor(context, [yellowColor CGColor]);
            CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.VM10);
            CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.VM10);
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextStrokePath(context);
        }
    }
    
    if (kc.amt < 0) {// 开盘价大于收盘价
        CGContextSetFillColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:-1.0] CGColor]);
        CGContextFillRect(context, CGRectMake((float)(kc.coordinateX + offsetX - candlesWidth / 2), kc.volume, candlesWidth, CHART_HEIGHT));
        CGContextFillPath(context);
    } else {
        CGContextSetStrokeColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:1.0] CGColor]);
        CGContextSetFillColorWithColor(context, [[TradeUtil textColorWithQuotationNumber:1.0] CGColor]);
        
        if (_isFillRed) {
            CGContextFillRect(context, CGRectMake((float)(kc.coordinateX + offsetX - candlesWidth / 2), kc.volume, candlesWidth, CHART_HEIGHT));
            CGContextFillPath(context);
        } else {
            CGContextStrokeRect(context, CGRectMake((float)(kc.coordinateX + offsetX - candlesWidth / 2), kc.volume, candlesWidth, CHART_HEIGHT));
            CGContextStrokePath(context);
        }
    }
}

#pragma mark - 画成交量,因为宽度太小,所以直接连起来
- (void)drawVolumeOnlyLine:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context {
    if (pastKc != nil) {
        if ((kc.volume < volumeHeight + volumeDrawY) && (pastKc.volume < volumeHeight + volumeDrawY)) {	// VM5
            CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
            CGContextSetFillColorWithColor(context, [normalColor CGColor]);
            CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.volume);
            CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.volume);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

#pragma mark - MACD
- (void)drawMACD:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context {
    if (pastKc != nil) {
        /* dif */
        CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
        CGContextSetFillColorWithColor(context, [normalColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.dif);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.dif);
        CGContextDrawPath(context, kCGPathFillStroke);
        /* dea */
        CGContextSetStrokeColorWithColor(context, [yellowColor CGColor]);
        CGContextSetFillColorWithColor(context, [yellowColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.dea);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.dea);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    /* bar */
    if (kc.bar <= (float)volumeHeight / 2 + volumeDrawY) {
        CGContextSetStrokeColorWithColor(context, [redColor CGColor]);
        CGContextSetFillColorWithColor(context, [redColor CGColor]);
    } else {
        CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
        CGContextSetFillColorWithColor(context, [normalColor CGColor]);
    }
    
    CGContextMoveToPoint(context, kc.coordinateX + offsetX, kc.bar);
    CGContextAddLineToPoint(context, kc.coordinateX + offsetX, (float)volumeHeight / 2 + volumeDrawY);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - KDJ
- (void)drawKDJ:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context {
    if (pastKc != nil) {
        /* K */
        CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
        CGContextSetFillColorWithColor(context, [normalColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.KDJK);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.KDJK);
        CGContextDrawPath(context, kCGPathFillStroke);
        /* D */
        CGContextSetStrokeColorWithColor(context, [yellowColor CGColor]);
        CGContextSetFillColorWithColor(context, [yellowColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.KDJD);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.KDJD);
        CGContextDrawPath(context, kCGPathFillStroke);
        /* J */
        CGContextSetStrokeColorWithColor(context, [purpleColor CGColor]);
        CGContextSetFillColorWithColor(context, [purpleColor CGColor]);
        CGContextMoveToPoint(context, pastKc.coordinateX + offsetX, pastKc.KDJJ);
        CGContextAddLineToPoint(context, kc.coordinateX + offsetX, kc.KDJJ);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

#pragma mark - 画竖白线
- (void)drawWhiteLine:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1.0);
    linePointY = MAX(1, linePointY);
    linePointY = MIN(klineHeight, linePointY);
    CGFloat width = [self drawLeftPriceWithPoint:CGPointMake(linePointX, linePointY) context:context];
    CGContextSetStrokeColorWithColor(context, [normalColor CGColor]);
    
    CGContextMoveToPoint(context, linePointX, 0);	/* K线上的竖线 */
    CGContextAddLineToPoint(context, linePointX, klineHeight);
    
    /* k线上的横线 */
    if (downPoint.x < width + 10) {
        CGContextMoveToPoint(context, 0, linePointY);
        CGContextAddLineToPoint(context, CHART_WIDTH - width + 2, linePointY);
    } else {
        CGContextMoveToPoint(context, width - 2, linePointY);
        CGContextAddLineToPoint(context, CHART_WIDTH, linePointY);
    }
    
    CGContextMoveToPoint(context, linePointX, volumeDrawY);	/* 成交量上的竖线 */
    CGContextAddLineToPoint(context, linePointX, CHART_HEIGHT);
    CGContextStrokePath(context);
    
    //画竖线中间的日期
    float sizeFont = 12.0;
    UIColor *color = RGBA(178, 178, 178, 1);/* 日期颜色 */
    UIFont *font = [UIFont systemFontOfSize:sizeFont];
    NSString *date = nil;
    if (stockArray.count > lPosition) {
        KLine *k = [stockArray objectAtIndex:lPosition];
        
        if (cycle < KLineDataDay) {
            date = [VeDateUtil dateFormatterWithyyyyMMddHHmmToMM_dd_HH_mm:k.stocktime];	// 分钟线时显示日期为01-01 15:14
        } else {
            date = [VeDateUtil getStringIntToDate:k.stockdate stytle:@"-" keepHead:YES];
        }
        
        CGSize dateStringSize;
        
        if (TTIsStringWithAnyText(date)) {
            dateStringSize = [CommonUtil getPerfectSizeByText:date andFontSize:sizeFont andWidth:1000];
            CGFloat dateX = linePointX - dateStringSize.width / 2.0f;
            
            if (CHART_WIDTH - linePointX < dateStringSize.width / 2.0f) {
                dateX = CHART_WIDTH - dateStringSize.width;
            } else if (dateX < 1.0) {
                dateX = 1.0;
            }
            [date drawAtPoint:CGPointMake(dateX, volumeDrawY) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
            return;
        }
    }
    CGContextRestoreGState(context);
}

- (CGFloat)getLineYWithKLine:(KLine *)k coordinate:(KLineCoordinate *)kc price:(CGFloat *)price y:(CGFloat)y {
    if (!k || !kc) return 0;
    
    y = MAX(y, kc.maximum);
    y = MIN(y, kc.minimum);
    CGFloat lengthYAndMax = fabs(y - kc.maximum);
    CGFloat lengthYAndR = fabs(y - kc.realprice);
    CGFloat lengthYAndT = fabs(y - kc.todayopen);
    CGFloat lengthYAndMin = fabs(y - kc.minimum);
    CGFloat minLength = MIN(lengthYAndMax, lengthYAndR);
    minLength = MIN(minLength, lengthYAndT);
    minLength = MIN(minLength, lengthYAndMin);
    
    if (minLength == lengthYAndMax) {
        y = kc.maximum;
        *price = k.maximum;
    } else if (minLength == lengthYAndR) {
        y = kc.realprice;
        *price = k.realprice;
    } else if (minLength == lengthYAndT) {
        y = kc.todayopen;
        *price = k.todayopen;
    } else if (minLength == lengthYAndMin) {
        y = kc.minimum;
        *price = k.minimum;
    }
    return y;
}

#pragma mark - 画左边的滑动价钱
- (CGFloat)drawLeftPriceWithPoint:(CGPoint)point context:(CGContextRef)context {
    CGFloat y = point.y;
    
    if (y < 0) y = 0;
    
    if (y > klineHeight) y = klineHeight;
//    CGFloat price = klineMaxValue - (klineMaxValue - klineMinValue) / klineHeight * y;
    if([stockArray count] < lPosition)
        return 0;
    KLine *kline = [stockArray objectAtIndex:lPosition];
    
    if(kLineTipsView.hidden){
        kLineTipsView.hidden = NO;
    }
    CGRect frame = kLineTipsView.frame;
    if(point.x > self.frame.size.width / 2.0f){
        frame.origin.x = 5.0;
    }else{
        frame.origin.x = self.frame.size.width - frame.size.width - 5.0;
    }
    kLineTipsView.frame = frame;
    [kLineTipsView reloadDataWithData:kline withPriceDecimals:_decimalPlaces];
    NSString *priceStr = [CommonUtil newFloat:kline.realprice withNumber:_decimalPlaces];
    float sizeFont = 12.0;
    UIColor *color = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:sizeFont];
    CGSize stringSize = [CommonUtil getPerfectSizeByText:priceStr andFontSize:sizeFont andWidth:1000];
    CGSize size = CGSizeMake(stringSize.width + 5, stringSize.height);
    //    NSString *fontName = [UIFont boldSystemFontOfSize:sizeFont].fontName;
    //    UIFont *textFont = [UIFont fontWithName:fontName size:sizeFont];
    
    if (y - size.height / 2.0f < 0) {
        y = 0;
    } else if (y + size.height / 2.0f > klineHeight) {
        y = klineHeight - size.height + 2;
    } else {
        y -= size.height / 2.0f;
    }
    //    if (!leftPriceImage) {
    //        leftPriceImage = [[NewKLineView createRoundedRectImage:RGBA(40, 205, 215, 1) size:size] retain];
    //    }
    CGFloat x = 0;
    
    if (point.x < size.width + 10) {
        x = CHART_WIDTH - size.width;
    }
    CGRect rect = CGRectMake(x, y, size.width, size.height);
    //    [leftPriceImage drawInRect:rect];
    
    CGContextSetFillColorWithColor(context, [RGBA(0, 161, 242, 1) CGColor]);
    CGContextFillRect(context, rect);
    CGContextFillPath(context);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [priceStr drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color,
                                               NSParagraphStyleAttributeName: paragraphStyle}];
    RELEASE(paragraphStyle);
    return size.width;
}

// - (CGFloat)drawLeftPriceWithY:(CGPoint)point price:(CGFloat)price context:(CGContextRef)context {
//    CGFloat x = 0;
//    CGFloat y = point.y;
//    y = MAX(0, y);
//    y = MIN(klineHeight, y);
//	NSString *priceStr = [CommonUtil keeepDecimalPlaces:price decimal:_decimalPlaces];
//	float sizeFont = 12.0;
//	NSString *fontName = [UIFont boldSystemFontOfSize:sizeFont].fontName;
//	UIFont *textFont = [UIFont fontWithName:fontName size:sizeFont];
//	CGSize stringSize = [priceStr sizeWithFont:textFont constrainedToSize:CGSizeMake(1000, 15) lineBreakMode:NSLineBreakByTruncatingTail];
//	CGSize size = CGSizeMake(stringSize.width + 5, stringSize.height);
//
//	if (y - size.height / 2.0f < 0) {
//		y = 0;
//	} else if (y + size.height / 2.0f > klineHeight) {
//		y = klineHeight - size.height;
//	} else {
//		y -= size.height / 2.0f;
//	}
//    if (!leftPriceImage) {
//        leftPriceImage = [[NewKLineView createRoundedRectImage:RGBA(40, 205, 215, 1) size:size] retain];
//    }
//    if (point.x < size.width + 10) {
//        x = CHART_WIDTH - size.width;
//    }
//    [leftPriceImage drawInRect:CGRectMake(x, y, size.width, size.height)];
//    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
//    CGContextSelectFont(context, [fontName UTF8String], sizeFont, kCGEncodingMacRoman);
//	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
//	CGContextSetTextDrawingMode(context, kCGTextFill);
//	const char *priceTextChar = [priceStr UTF8String];
//    CGContextShowTextAtPoint(context, x+2, y+4+size.height/2.0f, priceTextChar, strlen(priceTextChar));
//	return size.width;
// }

#pragma mark - 生成左边价格的矩形图片
+ (UIImage *)createRoundedRectImage:(UIColor *)color size:(CGSize)size {
    if (!color) color = [UIColor clearColor];
    int w = size.width;
    int h = size.height;
    NSInteger r = 4;
    UIImage *img = [CommonUtil createImageWithColor:color withSize:size];
    CGImageRef imageRef = img.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ct = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, CGImageGetBitmapInfo(imageRef));
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextBeginPath(ct);
    addRoundedRectToPath(ct, rect, r, r);
    CGContextClosePath(ct);
    CGContextClip(ct);
    CGContextDrawImage(ct, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(ct);
    img = [UIImage imageWithCGImage:imageMasked];
    CGContextRelease(ct);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return img;
}

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;
    
    if ((ovalWidth == 0) || (ovalHeight == 0)) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh / 2.0f);	// Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw / 2.0f, fh, 1);	// Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh / 2.0f, 0.4);	// Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw / 2.0f, 0, 0.7);	// Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh / 2.0f, 1);	// Back to lower right
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - 画成交量上面的文字
- (void)drawVolumeTextWithVolumeType:(KLineIndexType)type isClean:(BOOL)isClean context:(CGContextRef)context {
    if (!self.isDrawVolumeText) return;
    
    CGContextSaveGState(context);
    NSString *firstString = nil;
    NSString *secondString = nil;
    NSString *thirdString = nil;
    UIColor *firstColor, *secondColor, *thirdColor;
    
    KLine *data = nil;
    
    if (!isClean) {
        if (_isShowLine) {
            if (lPosition < stockArray.count) data = [stockArray objectAtIndex:lPosition];
        } else {
            data = [stockArray lastObject];
        }
    }
    
    if (!data) {
        firstString = [NSString stringWithFormat:@"%@:----", NSLocalizedStringForKey(@"总")];
        secondString = @"M5:----";
        thirdString = @"M10:----";
        firstColor = greenColor;
        secondColor = blueColor;
        thirdColor = yellowColor;
    } else {
        switch (type) {
            case KLineIndexTypeVOL:	/* 成交量 */
                firstString = [NSString stringWithFormat:@"%@:%@ ", NSLocalizedStringForKey(@"总"), [TradeUtil stringByFormatKWithNumber:data.volume]];
                secondString = [NSString stringWithFormat:@"M5:%@ ",[TradeUtil stringByFormatKWithNumber:data.vm5]];
                thirdString = [NSString stringWithFormat:@"M10:%@ ",[TradeUtil stringByFormatKWithNumber:data.vm10]];
                firstColor = greenColor;
                secondColor = blueColor;
                thirdColor = yellowColor;
                break;
                
            case KLineIndexTypeMACD:	/* MACD */
                firstString = [NSString stringWithFormat:@"MACD(9,12,26)DIF:%.3f ", data.dif];
                secondString = [NSString stringWithFormat:@"DEA:%.3f ", data.dea];
                thirdString = [NSString stringWithFormat:@"MACD:%.3f", data.bar];
                firstColor = normalColor;
                secondColor = yellowColor;
                thirdColor = [TradeUtil textColorWithQuotationNumber:data.bar];
                break;
                
            case KLineIndexTypeKDJ:	/* KDJ */
                firstString = [NSString stringWithFormat:@"KDJ(9,3,3) K:%.3f ", data.kdjk];
                secondString = [NSString stringWithFormat:@"D:%.3f ", data.kdjd];
                thirdString = [NSString stringWithFormat:@"J:%.3f", data.kdjj];
                firstColor = normalColor;
                secondColor = yellowColor;
                thirdColor = purpleColor;
                break;
        }
    }
    
    if (!self.volumeTextFont) self.volumeTextFont = [UIFont systemFontOfSize:13];
    CGSize firstSize = [CommonUtil getPerfectSizeByText:firstString andFontSize:self.volumeTextFont.pointSize andWidth:1000];
    CGSize secondSize = [CommonUtil getPerfectSizeByText:secondString andFontSize:self.volumeTextFont.pointSize andWidth:1000];
    [firstString drawAtPoint:CGPointMake(offsetX + 2 , klineHeight + _kLineViewTextPadding) withAttributes:@{NSFontAttributeName:self.volumeTextFont, NSForegroundColorAttributeName:firstColor}];
    [secondString drawAtPoint:CGPointMake(offsetX + 4 + firstSize.width, klineHeight + _kLineViewTextPadding) withAttributes:@{NSFontAttributeName:self.volumeTextFont, NSForegroundColorAttributeName:secondColor}];
    [thirdString drawAtPoint:CGPointMake(offsetX + 6 + firstSize.width + secondSize.width, klineHeight + _kLineViewTextPadding) withAttributes:@{NSFontAttributeName:self.volumeTextFont, NSForegroundColorAttributeName:thirdColor}];
    
    CGContextRestoreGState(context);
}

#pragma mark - 画右拖加载更多的文字
- (void)drawRightPullAddMoreText:(CGContextRef)context {
    NSString *text = nil;
    UIColor *color = nil;
    if (rightPullType == 1) {
        color = HexColorA(0x808080, 1);
        text = pullNormalText;
    } else if (rightPullType == 2) {
        color = HexColorA(0x00a1f2, 1);
        text = pullShowText;
    } else if (rightPullType == 3) {
        color = HexColorA(0x00a1f2, 1);
        text = pullLoadingText;
    } else {
        return;
    }
    CGContextSaveGState(context);
    CGSize stringSize = [CommonUtil getPerfectSizeByText:@"正" andFontSize:15 andWidth:1000];
    CGFloat x = offsetX - stringSize.width *5 /4.0f;
    NSRange range;
    CGFloat y = (klineHeight - text.length*stringSize.height)/2.0f;
    NSUInteger length = text.length;
    for(int i = 0; i < length; i ++){
        range = [text rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *s = [text substringWithRange:NSMakeRange(i, 1)];
        [s drawAtPoint:CGPointMake(x, y) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:color}];
        y += stringSize.height;
    }
    CGContextRestoreGState(context);
}

/**
 *  解析K线数据(从字符串中用正则表达式解析)
 *
 *  @param klineData <#klineData description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)parserKLineArray:(NSString *)klineData {
    @try {
        if (TTIsStringWithAnyText(klineData)) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{8,12}),([-]??[0-9]*[.]??[0-9E-]*),([-]??[0-9]*[.]??[0-9E-]*),([-]??[0-9]*[.]??[0-9E-]*),([-]??[0-9]*[.]??[0-9E-]*),([-]??[0-9]*[.]??[0-9E-]*);" options:0 error:nil];
            NSArray *matches = [regex matchesInString:klineData options:0 range:NSMakeRange(0, klineData.length)];
            /* 1日期,2开盘,3最高,4最低,5收盘(最近成交),6成交量  */
            /* 1日期,2开盘,3最高,4最低,5收盘(最近成交),6成交量
             20140605,35.8,36.19,33.42,36.07,6704694;
             */
            NSMutableArray *array = [NSMutableArray array];
            for (NSTextCheckingResult *m in matches) {
                KLine *k = [KLine new];
                NSString *dateString = [klineData substringWithRange:[m rangeAtIndex:1]];
                k.timestamp = dateString;
                if (TTIsStringWithAnyText(dateString)) {
                        k.stocktime = [VeDateUtil formatterDate:dateString inStytle:nil outStytle:@"yyyyMMddHHmm" isTimestamp:YES];
                        k.stockdate = [[VeDateUtil formatterDate:dateString inStytle:nil outStytle:@"yyyyMMdd" isTimestamp:YES] integerValue];
                }
                k.todayopen = [[klineData substringWithRange:[m rangeAtIndex:2]] doubleValue];
                k.todayOpenString = [NSString stringWithFormat:@"%@",[klineData substringWithRange:[m rangeAtIndex:2]]];
                k.maximum = [[klineData substringWithRange:[m rangeAtIndex:3]] doubleValue];
                k.minimum = [[klineData substringWithRange:[m rangeAtIndex:4]] doubleValue];
                k.realprice = [[klineData substringWithRange:[m rangeAtIndex:5]] doubleValue];
                k.volume = [[klineData substringWithRange:[m rangeAtIndex:6]] doubleValue];
                [array addObject:k];
                RELEASE(k);
            }
            return array;
        }
    }
    @catch(NSException *exception) {
        NSLog(@"解析指数分时线出错：%@", [exception debugDescription]);
    }
    return nil;
}

#pragma mark - 等待圈圈

/**
 *	@brief	显示等待圈圈
 *
 *	@param  text    显示文字
 *  @param details
 */
- (void)showProgress:(NSString *)text detailsText:(NSString *)details {
    if (progressLoging) return;
    
    if (!progressHUD) {
        progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        progressHUD.center = self.center;
        [self addSubview:progressHUD];
    }
    progressHUD.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    progressHUD.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    progressHUD.backgroundRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    progressHUD.mode = MBProgressHUDModeIndeterminate;			// 无文字效果
    progressHUD.labelText = text;
    progressHUD.detailsLabelText = details;
    [progressHUD show:YES];
    progressLoging = true;
    [self bringSubviewToFront:progressHUD];
}

/**
 *	@brief	取消等待圈圈
 */
- (void)dismissProgress {
    if (progressLoging && progressHUD) [progressHUD hide:YES];
    progressLoging = false;
}

@end
