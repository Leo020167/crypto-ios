//
//  NewKLineView.h
//  TJRtaojinroad
//
//  Created by 影孤清 on 13-10-21.
//  Copyright (c) 2013年 淘金路. All rights reserved.
//

#import "TJRBaseView.h"
#import "KLine.h"
#import "KLineCoordinate.h"
#import "CommonUtil.h"
#import <CoreText/CoreText.h>
#import "QuotationPanGestureRecognizer.h"
#import "NewKLineTipsView.h"

//#define minNumber			 1
#define KLineCandlesMinWidth 0.5

#define RedColor	RGBA(222, 59, 3, 1)
#define GreenColor	RGBA(50, 177, 108, 1)
#define BlueColor	RGBA(89, 189, 228, 1)
#define YellowColor	RGBA(255, 247, 153, 1)
#define PurpleColor	RGBA(143, 130, 188, 1)
#define WhiteColor	RGBA(255, 255, 255, 1)

extern NSString *const KLineMaxValue;
extern NSString *const KLineMinValue;
extern NSString *const VolumeMaxValue;
extern NSString *const KDJMax;
extern NSString *const KDJMin;
extern NSString *const MACDMax;
extern NSString *const MACDMin;

typedef enum {
	KLineTouchAreaKLine,
	KLineTouchAreaVolume,
	KLineTouchAreaVolumeText,
	KLineTouchAreaOut
} KLineViewTouchArea;

typedef NS_ENUM (NSInteger, KLineShowType) {/* K线显示类型 */
    KLineShowNormal = 0,
    KLineShowWhite = 0,/* 背景白色 */
    KLineShowBlack = 1,/* 背景黑色 */
};

typedef NS_ENUM(NSInteger,KLineIndexType) {//K线指标类型
    KLineIndexTypeVOL = 0,//成交量
    KLineIndexTypeMACD = 1,//MACD
    KLineIndexTypeKDJ = 2,//KDJ
};

@protocol KLineViewDelegate <NSObject>
@optional

/**
 *   @method 显示白线所在位置的数据
 *   @param type 成交量的类型
 */
- (void)kLineShowData:(KLine *)kLine VolumeType:(NSInteger)type isEnd:(BOOL)isEnd;

- (void)klineHttpStart;
- (void)klineHttpEnd;
- (void)klineHttpError;
- (void)klineShowToast:(NSString *)toast;

- (void)klineArenaShowRealprice:(float)realprice withYesterday:(float)yesterday index:(NSUInteger)index;

- (void)kLineTouch:(BOOL)isTouch isShowLine:(BOOL)isShowLine;	/* 这个暂时不用 */

@end

@class MBProgressHUD;
@interface NewKLineView : TJRBaseView<UIGestureRecognizerDelegate> {
    NewKLineTipsView *kLineTipsView;
    NSMutableArray *netKLineArray;
	NSMutableArray *restorationArray;	/* 记录复权后数据 */
	NSMutableArray *stockArray;	/* 不创建,只是用来指向netKLineArray或restorationArray */
	NSMutableArray *resultArray;
	NSMutableArray *coordinateArray;
	KLineDataType cycle;
	CGFloat volumeDrawY;
	CGFloat klineHeight;
	CGFloat volumeTextHeight;
	CGFloat volumeHeight;
	UIFont *volumeTextFont;
	CGFloat CHART_HEIGHT;
	CGFloat CHART_WIDTH;
	CGFloat klineMaxValue, klineMinValue;
	CGFloat volumeMaxValue;
	CGFloat kdjMax, kdjMin, macdMax, macdMin;
	CGFloat candlesWidth;/* 蜡烛的宽度 */
	double spacing;	/* 蜡烛与蜡烛间的间距 */
//	NSInteger number;
	CGFloat spanX;
	CGFloat klineSpanY;
	CGFloat volumeSpanY;
	CGFloat kdjSpanY;
	CGFloat macdSpanY;
    CGFloat klineDrawWidth;
	NSInteger candlesNumber;//当前蜡烛大小,可以显示的根数
	NSRange showRange;
	CGPoint downPoint;
	NSUInteger lPosition;/* 白线所在具体数据中的位置 */
    CGFloat linePointX;
    CGFloat linePointY;
	NSRange defaultShowRange;
	double restorationCoefficient;	/* 复权系数 */
	BOOL isClearDrawRect;	/* 是否只是清空画布 */
	MBProgressHUD *progressHUD;
	BOOL progressLoging;
	NSMutableArray *stockExRightsArray;	/* 记录股票除权数据 */

	double sumM5;
	double sumM10;
	double sumM20;
    double sumM30;
	double firstM5;
	double firstM10;
	double firstM20;
    double firstM30;
	double sumVM5;
	double sumVM10;
	double firstVM5;
	double firstVM10;

	UIImage *leftPriceImage;
	CGFloat lastScale;
	BOOL pinchIsLicit;	/* 当前的捏合是否合法 */
	BOOL longIsLicit;	/* 当前的长按是否合法 */
	BOOL panIsLicit;/* 当前的拖动是否合法 */

	UIPinchGestureRecognizer *pinchGesture;
	UILongPressGestureRecognizer *longGesture;
	QuotationPanGestureRecognizer *panGesture;
	UITapGestureRecognizer *tapGesture;

	CGFloat offsetX;/* X的偏移量,用来右拉加载更多 */
	BOOL isSaveKLineData;	/* 加载数据时,是否保留上次的数据,默认为NO */
	NSInteger rightPullType;/* 左边右拖加载的状态,0为不显示,1为显示加载数据,2为显示加载中... */
	UIButton *btnParameter;	/* 成交量里显示当前类型 */
    CGFloat defaultCandleWidth;
    CGFloat defaultSpacing;
    UIColor *lineColor;/* 背景线颜色 */
    UIColor *midValueColor;/* 中间价钱的颜色 */
    UIColor *redColor;
    UIColor *greenColor;
    UIColor *yellowColor;
    UIColor *normalColor;/* 反背景颜色,(黑的时候就是白,白的时候就是黑) */
    UIColor *purpleColor;
    UIColor *blueColor;
    NSUInteger startLocation;//记录开始拖动K线时,起始位置,只有在最开始时,才能加载更多
    BOOL canRightPull;//拖动K线时,只有在最开始时,才能加载更多
    CGFloat rightPullMaxX;//右拉加载更多的最大拖动距离
    NSString *pullNormalText;//右拉显示更多时,初始显示文字(如:加载更多数据)
    NSString *pullShowText;//右拉距离足够时,显示可以加载的文字(如:松手加载数据)
    NSString *pullLoadingText;//加载数据中显示文字(如:数据加载中...)
    SEL klineDataAscSel;//K线升序排序方法
    SEL klineDataDescSel;//K线降序排序方法
    
    struct {
        unsigned int kLineShowData : 1;
        unsigned int klineHttpStart : 1;
        unsigned int klineHttpEnd : 1;
        unsigned int klineHttpError : 1;
        unsigned int klineShowToast : 1;
        unsigned int klineArenaShowRealprice : 1;
        unsigned int kLineTouch : 1;
    } _delegateFlags;
}
@property (copy, nonatomic) NSString *fullcode;
@property (assign, nonatomic) IBOutlet id <KLineViewDelegate> delegate;	/* K线回调协议 */
@property (retain, nonatomic) UIColor *kLineViewBackgroundColor;/* 背景颜色,默认为白色 */
@property (assign, nonatomic) NSInteger maxKLineNumber;	/* 可显示的最大K线根数,默认为250 */
@property (retain, nonatomic) UIFont *volumeTextFont;	/* (默认为[UIFont systemOfSize:13]) */
@property (assign, nonatomic) BOOL isShowLine;	/* 当前是否有显示白线 */
@property (assign, nonatomic) BOOL isCanPinch;	/* 是否可以缩放K线,默认为YES,可缩放 */
@property (assign, nonatomic) NSRange showRange;/* 显示K线范围 */
@property (assign, nonatomic) CGFloat candlesWidth;	/* 蜡烛的宽度 */
@property (assign, nonatomic) CGFloat maxCandlesWidth;	/* 蜡烛的最大宽度 */
@property (assign, nonatomic) CGFloat minCandlesWidth;	/* 蜡烛的最小宽度 */
//@property (assign, nonatomic) double spacing;	/* 蜡烛与蜡烛间的间距 */
@property (assign, nonatomic) BOOL isCanShowWhiteLine;	/* 是否可以显示白线(默认为YES) */
@property (assign, nonatomic) BOOL isCanMoveKLineView;	/* 是否可以拖动K线(默认为YES) */
@property (assign, nonatomic) BOOL isCanClickVolume;/* 成交量是否可以点击切换(默认为YES) */
@property (assign, nonatomic) BOOL isShouldReturnKLineData;	/* 是否返回白线位置的K线数据,无白线则是最新的(默认为YES) */
@property (assign, nonatomic) KLineDataType cycle;	/* K线周期 */
@property (assign, nonatomic) BOOL isOnlyDrawKLine;	/* 只画K线不要中间的文字和下面的成交量(默认为NO) */
@property (assign, nonatomic) KLineIndexType volumeType;	/* 显示成交量上的文字类型(0 成交量,1 MACD,2 KDJ) */
@property (assign, nonatomic) NSRange defaultShowRange;	/* 初始化后的可显示K线范围 */
@property (assign, nonatomic) BOOL isDrawVolumeText;/* 是否画成交量上面的文字(默认为YES) */
@property (retain, nonatomic) NSMutableArray *netKLineArray;/* K线数据array(原始数据) */
@property (retain, nonatomic) NSMutableArray *restorationArray;	/*  记录复权后数据 */
@property (assign, readonly, nonatomic) CGFloat kLineViewDrawKLineHeight;	/* 上半部K线的高度 */
@property (assign, readonly, nonatomic) CGFloat kLineViewTextPadding;	/* 中间文字上下padding */
@property (assign, readonly, nonatomic) CGFloat kLineViewDrawTextHeight;	/* 中间文字的高度 */
@property (assign, readonly, nonatomic) CGFloat kLineViewDrawVolumeHeight;/* 下面成交量的高度 */
@property (assign, nonatomic) NSInteger maxForKLineShow;/* 一屏中显示K线的数量,默认是不用设置 */
@property (assign, nonatomic) BOOL isCalculationRate;	/* 是否要计算涨跌幅(默认是YES) */
@property (assign, nonatomic) BOOL isShowDate;	/* 是否显示K线的日期 默认为YES*/
@property (assign, nonatomic) BOOL isStockExRights;	/* 是否是显示除权数据,默认为YES */
@property (assign, nonatomic) BOOL canRightPullAddMore;	/* 是否有 右边加载更多功能,默认为false */
@property (assign, nonatomic) BOOL isShowKLineParameters;	/* 是否显示成交量里的类型,默认为NO */
@property (assign, nonatomic) CGFloat volumeBlankHeight; /* 成交量上的空白高度 */
@property (assign, nonatomic) BOOL isFillRed; /* 阳线(红K线)是否是实心,默认为NO */
@property (assign, nonatomic) UIEdgeInsets lacunae; /* 上下左右留白距离,默认右边留白距离10,其他为0*/
@property (assign, nonatomic) KLineShowType showType;/* K线背景显示颜色,默认为白色 */
@property (nonatomic, assign) NSUInteger decimalPlaces;//保留小数位数


/**
 *  设置右拉加载更多的文字
 *
 *  @param normalText 右拉显示更多时,初始显示文字(如:加载更多数据)
 *  @param showText   右拉距离足够时,显示可以加载的文字(如:松手加载数据)
 *  @param loadText   加载数据中显示文字(如:数据加载中...)
 */
- (void)setPullNormalText:(NSString *)normalText showText:(NSString *)showText loadText:(NSString *)loadText;
/**
 *   记录股票的除权数据
 *   @param exArray
 */
- (void)addStockExRights:(NSArray *)exArray;
#pragma mark -计算涨跌和涨幅
- (void)calculationRate:(NSMutableArray *)array;
#pragma mark - 清除画布
- (void)cleanDraw;
#pragma mark - 计算复权后的具体数据
- (void)calculationRestoration:(BOOL)isRestoration;
#pragma mark - 生成要显示的K线数据Array
- (void)createNetKLArray:(NSArray *)array;
- (void)createKLineArrayFromNetKLineArray;
- (NSDictionary *)getMaxAndMinWithArray:(NSArray *)array;
- (void)leftPullAddMoreData:(KLine *)lastDate;
- (void)hideLeftPull;
- (void)drawCandles:(KLineCoordinate *)kc context:(CGContextRef)context kLineIndex:(NSInteger)kLineIndex;
#pragma mark - 判断手指点击位置(如果只有一个手指,secondPoint就为CGPointZero)
- (KLineViewTouchArea)calculateTouchArea:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint;
/**
	重置K线宽度
 */
- (void)candleReset;
#pragma mark - 计算当前屏幕显示的K线
/**
 *    计算当前屏幕显示的K线,显示最新的那条
 */
- (void)calculationShowArrayAndShowNew;

/**
 *   计算当前屏幕显示的K线,不用隐藏一部分K线就调用这个
 */
- (void)calculationShowArray;

/**
 *   @method 计算当前屏幕显示的K线
 *   @param range 显示K线的区间
 */
- (void)calculationShowArray:(NSRange)range;

/**
 *    生成左边价格的矩形图片
 *    @param color
 *    @param size
 *    @returns
 */
+ (UIImage *)createRoundedRectImage:(UIColor *)color size:(CGSize)size;

/**
 *  解析K线数据(从字符串中用正则表达式解析)
 *
 *  @param klineData <#klineData description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)parserKLineArray:(NSString *)klineData;

/**
 *	@brief	显示等待圈圈
 *
 *	@param  text    显示文字
 *  @param details
 */
- (void)showProgress:(NSString *)text detailsText:(NSString *)details;

/**
 *	@brief	取消等待圈圈
 */
- (void)dismissProgress;
#pragma mark - 画成交量
- (void)drawVolume:(KLineCoordinate *)kc pastKLineCoordinate:(KLineCoordinate *)pastKc context:(CGContextRef)context;
#pragma mark - 画左边的滑动价钱
- (CGFloat)drawLeftPriceWithPoint:(CGPoint)point context:(CGContextRef)context;
@end

