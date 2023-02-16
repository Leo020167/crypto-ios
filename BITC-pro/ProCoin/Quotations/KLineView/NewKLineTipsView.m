//
//  NewKLineTipsView.m
//  ProCoin
//
//  Created by Hay on 2020/5/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NewKLineTipsView.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"
#import "TradeUtil.h"

@interface NewKLineTipsView()
{
    NSArray *titleDataArr;
}
@end

@implementation NewKLineTipsView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialTipsView];
    }
    return self;
}

- (void)dealloc
{
    [titleDataArr release];
    [super dealloc];
}


#pragma mark - 初始化
- (void)initialTipsView
{
    self.backgroundColor = RGBA(19, 30, 47, 0.9);
    titleDataArr = [[NSArray alloc] initWithObjects:NSLocalizedStringForKey(@"时间"),NSLocalizedStringForKey(@"开"),NSLocalizedStringForKey(@"高"),NSLocalizedStringForKey(@"低"),NSLocalizedStringForKey(@"收"),NSLocalizedStringForKey(@"涨跌额"),NSLocalizedStringForKey(@"涨跌幅"),NSLocalizedStringForKey(@"成交量"), nil];
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    CGSize size = [[titleDataArr firstObject] sizeWithAttributes:@{NSFontAttributeName:font}];
    for(int i = 0; i < [titleDataArr count] ; i++){
        //标题
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(3.0, 3.0 +  i * (3.0 + size.height) , 35, size.height)] autorelease];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = font;
        titleLabel.text = [titleDataArr objectAtIndex:i];
        titleLabel.minimumScaleFactor = 0.5;
        [self addSubview:titleLabel];
        //内容
        UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 98, 3.0 + i * (3.0 + size.height), 95, size.height)] autorelease];
        contentLabel.tag = 1000 + i;
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.font = font;
        contentLabel.adjustsFontSizeToFitWidth = YES;
        contentLabel.minimumScaleFactor = 0.5;
        [self addSubview:contentLabel];
        
    }
    CGRect frame = self.frame;
    frame.size.height = 5.0 +  [titleDataArr count] * (3.0 + size.height) + 5.0;
    self.frame = frame;
    self.layer.cornerRadius = 3.0;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = RGBA(255, 255, 255, 1.0).CGColor;

}

#pragma mark - 显示数据
- (void)reloadDataWithData:(KLine *)kLineData withPriceDecimals:(NSInteger)priceDecimals
{
    UILabel *timeLabel = (UILabel *)[self viewWithTag:1000];
    UILabel *openLabel = (UILabel *)[self viewWithTag:1001];
    UILabel *highLabel = (UILabel *)[self viewWithTag:1002];
    UILabel *lowLabel = (UILabel *)[self viewWithTag:1003];
    UILabel *lastLabel = (UILabel *)[self viewWithTag:1004];
    UILabel *changeBalanceLabel = (UILabel *)[self viewWithTag:1005];
    UILabel *changeRateLabel = (UILabel *)[self viewWithTag:1006];
    UILabel *volumeLabel = (UILabel *)[self viewWithTag:1007];
    

    timeLabel.text = [VeDateUtil formatterDate:kLineData.stocktime inStytle:@"yyyyMMddHHmm" outStytle:@"yyyy-MM-dd HH:mm"];
    openLabel.text = [CommonUtil newFloat:kLineData.todayopen withNumber:priceDecimals];
    highLabel.text = [CommonUtil newFloat:kLineData.maximum withNumber:priceDecimals];
    lowLabel.text = [CommonUtil newFloat:kLineData.minimum withNumber:priceDecimals];
    lastLabel.text = [CommonUtil newFloat:kLineData.realprice withNumber:priceDecimals];
    changeBalanceLabel.text = [CommonUtil newFloat:kLineData.amt withNumber:priceDecimals];
    changeBalanceLabel.textColor = [TradeUtil textColorWithQuotationNumber:kLineData.rate];
    changeRateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:[CommonUtil newFloat:kLineData.rate withNumber:2]]];
    changeRateLabel.textColor = [TradeUtil textColorWithQuotationNumber:kLineData.rate];
    volumeLabel.text = [NSString stringWithFormat:@"%@",@(kLineData.volume)];

}

@end
