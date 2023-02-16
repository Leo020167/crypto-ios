//
//  KLineViewAndNetData.m
//  TJRtaojinroad
//
//  Created by 影孤清 on 13-10-21.
//  Copyright (c) 2013年 淘金路. All rights reserved.
//

#import "KLineViewAndNetData.h"
#import "StockExRights.h"
#import "VeDateUtil.h"
#import "TradeUtil.h"

@interface KLineViewAndNetData()
{
    BOOL isKLineEnd;            //是否已经是最后的一批数据了
}

@property (copy, nonatomic) NSString *timestamp;
@end

@implementation KLineViewAndNetData

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self initKlineView];
    }
    return self;
}

- (void)dealloc
{
    [_timestamp release];
    [super dealloc];
}

- (void)initKlineView
{
    isKLineEnd = NO;
}

- (void)cleanDraw
{
    [super cleanDraw];
}

#pragma mark - 更新K线数据
- (void)reloadKLineData:(NSDictionary *)json kLineType:(KLineDataType)kLineType
{
    self.cycle = kLineType;
    [self parserKLineData:json];
}

- (void)addKLineData:(CoinQuotationDataEntity *)data kLineType:(KLineDataType)kLineType
{
    self.cycle = kLineType;
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:netKLineArray];
    if([tempArr count] > 0){
        KLine *entity = [tempArr lastObject];
        if([entity.timestamp isEqualToString:data.timeStamp]){
            KLine *currentEntity = [[KLine alloc] init];
            currentEntity.timestamp = data.timeStamp;
            currentEntity.todayopen = [data.openString doubleValue];
            currentEntity.todayOpenString = data.openString;
            currentEntity.maximum = [data.highString doubleValue];
            currentEntity.minimum = [data.lowString doubleValue];
            currentEntity.realprice = [data.last doubleValue];
            currentEntity.volume = data.amount;
            [tempArr replaceObjectAtIndex:[tempArr count] - 1 withObject:currentEntity];
            [currentEntity release];
            
        }else{
            KLine *currentEntity = [[KLine alloc] init];
            currentEntity.timestamp = data.timeStamp;
            currentEntity.todayopen = [data.openString doubleValue];
            currentEntity.todayOpenString = data.openString;
            currentEntity.maximum = [data.highString doubleValue];
            currentEntity.minimum = [data.lowString doubleValue];
            currentEntity.realprice = [data.last doubleValue];
            currentEntity.volume = data.amount;
            [tempArr addObject:currentEntity];
            [currentEntity release];
        }
    }
    [self cleanDraw];
    [netKLineArray addObjectsFromArray:tempArr];
    self.maxKLineNumber = MIN(pastMaxNumber, netKLineArray.count);
    [self calculationRate:netKLineArray];    /* 计算涨跌和涨幅 */
    [self createKLineArrayFromNetKLineArray];
    [self calculationShowArrayAndShowNew];
    
}

- (void)leftPullAddMoreData:(KLine *)lastDate
{
    isSaveKLineData = YES;
    if(!isKLineEnd){
        if([_kLineDelegate respondsToSelector:@selector(kLineViewNeedLoadMoreData:)]){
            if(checkIsStringWithAnyText(lastDate.timestamp)){
                [_kLineDelegate kLineViewNeedLoadMoreData:lastDate.timestamp];
            }else{
                [_kLineDelegate kLineViewNeedLoadMoreData:@"0"];
            }
        }
    }
}

- (void)parserKLineData:(NSDictionary *)json
{
    if (pastMaxNumber == 0) pastMaxNumber = self.maxKLineNumber;
	NSString *fdm = [json objectForKey:@"fdm"];
	NSString *jc = [json objectForKey:@"jc"];
	NSString *klineString = [json objectForKey:@"kline"];
    TJRBaseEntity *baseParser = [[[TJRBaseEntity alloc] init] autorelease];
    isKLineEnd = [baseParser boolParser:@"isEnd" json:json];
	if (TTIsStringWithAnyText(klineString)) {
		if (!isSaveKLineData) {
			[netKLineArray removeAllObjects];
		}
		NSArray *kArray = [self parserKLineArray:klineString];
		[netKLineArray addObjectsFromArray:kArray];
		self.maxKLineNumber = MAX(pastMaxNumber, netKLineArray.count);
		[netKLineArray sortUsingSelector:@selector(compareKeysByAsc:)];	/* 排序 */
	}
    KLine *tempK = [netKLineArray lastObject];
    self.decimalPlaces = [TradeUtil decimalBitByStringValue:[NSString stringWithFormat:@"%@",tempK.todayOpenString]];

    KLine *k = [[KLine alloc] initWithJsonOther:[json objectForKey:@"oldData"]];
	[netKLineArray makeObjectsPerformSelector:@selector(createKDJAndMacd:) withObject:k];
	RELEASE(k);

	if (TTIsStringWithAnyText(fdm)) {
		[netKLineArray makeObjectsPerformSelector:@selector(setFullcode:) withObject:fdm];
	}

	if (TTIsStringWithAnyText(jc)) {
		[netKLineArray makeObjectsPerformSelector:@selector(setStockname:) withObject:jc];
	}

    NSArray *jsonArray = [json objectForKey:@"exList"];
    NSMutableArray *exList = [NSMutableArray array];
    for (NSDictionary *item in jsonArray) {
        StockExRights *exRights = [[StockExRights alloc] initWithJson:item];
        [exList addObject:exRights];
        RELEASE(exRights);
    }
    
	[self addStockExRights:exList];	/* 保存除权数据 */
	[self calculationRate:netKLineArray];	/* 计算涨跌和涨幅 */
	[self createKLineArrayFromNetKLineArray];

    if (!self.notDrawAfterHttpFinish){
        [self calculationShowArrayAndShowNew];
    }

	isSaveKLineData = NO;
	[super hideLeftPull];
}


@end

