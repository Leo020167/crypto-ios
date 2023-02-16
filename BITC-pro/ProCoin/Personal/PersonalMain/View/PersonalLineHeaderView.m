//
//  PersonalLineHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/6/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "PersonalLineHeaderView.h"
#import "CMLineCharView.h"
#import "VeDateUtil.h"
#import "TradeUtil.h"

@interface PersonalLineHeaderView()
{
    KindButtonType kindType;
    TimeButtonType timeType;
    NSMutableArray *dataValueArr;           //数据数组

}


@property (retain, nonatomic) IBOutlet UIButton *trendNumButton;            //业绩走势按钮
@property (retain, nonatomic) IBOutlet UIButton *followNumButton;           //跟单人气按钮
@property (retain, nonatomic) IBOutlet UIButton *tradeNumButton;            //交易次数按钮
@property (retain, nonatomic) IBOutlet UIImageView *indicatorIV;            //指示图片
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *indicatorLayoutConstraintLeading; //指示图片的leading约束
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *secondaryIndicatorIVLayoutConstraintLeading;        //次级指示图片的leading约束
@property (retain, nonatomic) IBOutlet UIButton *oneMonthButton;            //一个月按钮
@property (retain, nonatomic) IBOutlet UIButton *threeMonthsButton;         //三个月按钮
@property (retain, nonatomic) IBOutlet UIButton *sixMonthsButton;           //六个月按钮
@property (retain, nonatomic) IBOutlet UIButton *oneYearButton;             //一年按钮

@property (retain, nonatomic) IBOutlet UIView *lineChartView;
@end

@implementation PersonalLineHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    kindType = KindButtonType_Trend;
    timeType = TimeButtonType_OneMonth;
    _trendNumButton.selected = YES;
    _oneMonthButton.selected = YES;
    dataValueArr = [[NSMutableArray alloc] init];
    _secondaryIndicatorIVLayoutConstraintLeading.constant = 0.0 +  (SCREEN_WIDTH / 4.0f - 60)/2.0f; //初始化次级图片指示器位置
}


- (void)dealloc
{
    [dataValueArr release];
    [_trendNumButton release];
    [_followNumButton release];
    [_tradeNumButton release];
    [_oneMonthButton release];
    [_threeMonthsButton release];
    [_sixMonthsButton release];
    [_oneYearButton release];
    [_lineChartView release];
    [_indicatorIV release];
    [_indicatorLayoutConstraintLeading release];
    [_secondaryIndicatorIVLayoutConstraintLeading release];
    [super dealloc];
}


#pragma mark - 按钮点击事件
- (IBAction)kindOptionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.isSelected){
        return;
    }
    targetButton.selected = YES;
    if(targetButton == _trendNumButton){
        _followNumButton.selected = NO;
        _tradeNumButton.selected = NO;
        kindType = KindButtonType_Trend;
    }else if(targetButton == _followNumButton){
        _trendNumButton.selected = NO;
        _tradeNumButton.selected = NO;
        kindType = KindButtonType_Follow;
    }else{
        _trendNumButton.selected = NO;
        _followNumButton.selected = NO;
        kindType = KindButtonType_Trade;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _indicatorLayoutConstraintLeading.constant = targetButton.frame.origin.x + 35;
        [self layoutIfNeeded];
    }];
    if([_delegate respondsToSelector:@selector(lineHeaderViewOptionDidChangedWithKindType:timeType:)]){
        [_delegate lineHeaderViewOptionDidChangedWithKindType:kindType timeType:timeType];
    }
}

- (IBAction)dateOptionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.isSelected){
        return;
    }
    targetButton.selected = YES;
    if(targetButton == _oneMonthButton){
        _threeMonthsButton.selected = NO;
        _sixMonthsButton.selected = NO;
        _oneYearButton.selected = NO;
        timeType = TimeButtonType_OneMonth;
    }else if(targetButton == _threeMonthsButton){
        _oneMonthButton.selected = NO;
        _sixMonthsButton.selected = NO;
        _oneYearButton.selected = NO;
        timeType = TimeButtonType_ThreeMonth;
    }else if(targetButton == _sixMonthsButton){
        _oneMonthButton.selected = NO;
        _threeMonthsButton.selected = NO;
        _oneYearButton.selected = NO;
        timeType = TimeButtonType_SixMonth;
    }else{
        _oneMonthButton.selected = NO;
        _threeMonthsButton.selected = NO;
        _sixMonthsButton.selected = NO;
        timeType = TimeButtonType_OneYear;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _secondaryIndicatorIVLayoutConstraintLeading.constant = targetButton.frame.origin.x +  (targetButton.frame.size.width - 60)/2.0f;
        [self layoutIfNeeded];
    }];
    if([_delegate respondsToSelector:@selector(lineHeaderViewOptionDidChangedWithKindType:timeType:)]){
        [_delegate lineHeaderViewOptionDidChangedWithKindType:kindType timeType:timeType];
    }
}

#pragma mark - 更新数据
- (void)reloadLineHeaderViewData:(NSMutableArray *)dataArr
{
    [dataValueArr removeAllObjects];
    [[_lineChartView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if([dataArr count] <= 0){
        return;
    }
    
    LineDataEntity *dataEntity = [dataArr firstObject];
    LineDataEntity *lastDataEntity = [dataArr lastObject];
    CGFloat maxNum = [dataEntity.num doubleValue];
    CGFloat minNum = [dataEntity.num doubleValue];
    for(int i = 0; i < [dataArr count]; i++){
        LineDataEntity *dataEntity = [dataArr objectAtIndex:i];
        [dataValueArr addObject:dataEntity.num];
        if([dataEntity.num floatValue] > maxNum){
            maxNum = [dataEntity.num doubleValue];
        }
        if([dataEntity.num floatValue] < minNum){
            minNum = [dataEntity.num doubleValue];
        }
    }
    NSInteger row = 6;
    NSInteger distance = maxNum - minNum;
    CGFloat perHeight;
    if(distance == 0){
        perHeight = 1;
    }else{
        perHeight = ceil(((CGFloat)(maxNum - minNum)/(row - 1)));
    }
    //判断minNum是否小数或整数
    NSString *scanString = [NSString stringWithFormat:@"%@",@(minNum)];
    NSScanner* scan = [NSScanner scannerWithString:scanString];
    float val;
    if([scan scanFloat:&val] && [scan isAtEnd]){
        minNum = [[TradeUtil stringRoundDownFloatValue:[scanString floatValue] dotBits:2] doubleValue];
    }else{
        minNum = [[TradeUtil stringRoundDownFloatValue:[scanString floatValue] dotBits:0] doubleValue];
    }
    
    NSArray *yAxisData = @[ [NSString stringWithFormat:@"%@",@(minNum + perHeight * 6)],
                            [NSString stringWithFormat:@"%@",@(minNum + perHeight * 5)],
                            [NSString stringWithFormat:@"%@",@(minNum + perHeight * 4)],
                            [NSString stringWithFormat:@"%@",@(minNum + perHeight * 3)],
                            [NSString stringWithFormat:@"%@",@(minNum + perHeight * 2)],
                            [NSString stringWithFormat:@"%@",@(minNum + perHeight)],
                            [NSString stringWithFormat:@"%@",@(minNum)]];
    
    NSArray *xAxisData = @[[VeDateUtil formatterDate:dataEntity.dayTime inStytle:nil outStytle:@"yyyy-MM-dd" isTimestamp:YES],[VeDateUtil formatterDate:lastDataEntity.dayTime inStytle:nil outStytle:@"yyyy-MM-dd" isTimestamp:YES]];
    
    CMLineCharView *chartView = [[CMLineCharView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _lineChartView.frame.size.height)];
    chartView.backgroundColor = [UIColor whiteColor];
    [_lineChartView addSubview:chartView];
    chartView.dataArrOfY = yAxisData;//Y轴坐标
    chartView.dataArrOfX = xAxisData;//X轴坐标
    chartView.dataArrOfPoint = dataValueArr;
}

@end
