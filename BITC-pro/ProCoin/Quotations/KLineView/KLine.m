//
//  KLine.m
//  Http
//
//  Created by  on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KLine.h"
#import "VeDateUtil.h"

@implementation KLineUserOpp

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self && json) {
        self.type = [self intParser:@"type" json:json];	/* type=1代表做多，type=-1代表做空,type=0代表平仓 */
        self.face = [self intParser:@"face" json:json];
        self.b1s2 = [self intParser:@"b1s2" json:json];	/* 1代表买，2代表卖 */
        self.score = [self floatParser:@"score" json:json];// 收益率
    }
    return self;
}

@end

@implementation KLine

- (void)dealloc {
	TT_RELEASE_SAFELY(_fullcode);
	TT_RELEASE_SAFELY(_stockname);
	TT_RELEASE_SAFELY(_stocktime);
    [_timestamp release];
    [_todayOpenString release];
	[super dealloc];
}

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self && json) {
        self.maximum = [self floatParser:@"zgcj" json:json];
        self.minimum = [self floatParser:@"zdcj" json:json];
        self.realprice = [self doubleParser:@"zjcj" json:json];
        self.todayopen = [self floatParser:@"jrkp" json:json];
        self.bar = [self floatParser:@"bar" json:json];
        self.dea = [self floatParser:@"dea" json:json];
        self.dif = [self floatParser:@"dif" json:json];
        self.ema12 = [self floatParser:@"ema12" json:json];
        self.ema26 = [self floatParser:@"ema26" json:json];
        self.kdjd = [self floatParser:@"kdjd" json:json];
        self.kdjj = [self floatParser:@"kdjj" json:json];
        self.kdjk = [self floatParser:@"kdjk" json:json];
        self.m10 = [self floatParser:@"m10" json:json];
        self.m20 = [self floatParser:@"m20" json:json];
        self.m5 = [self floatParser:@"m5" json:json];
        self.vm10 = [self doubleParser:@"vm10" json:json];
        self.vm5 = [self doubleParser:@"vm5" json:json];
        self.rate = [self floatParser:@"rate" json:json];
        self.amt = [self floatParser:@"amt" json:json];
        self.amount = [self doubleParser:@"cjje" json:json];
        self.stockdate = [self intParser:@"date" json:json];
        self.volume = [self longlongParser:@"cjsl" json:json];
        self.yesterday = [self floatParser:@"zrsp" json:json];
        if ([self jsonHasKey:@"fullcode" json:json]) self.fullcode = [self stringParser:@"fullcode" json:json];
        else if ([self jsonHasKey:@"fdm" json:json]) self.fullcode = [self stringParser:@"fdm" json:json];
        
        if ([self jsonHasKey:@"amount" json:json]) self.amount = [self doubleParser:@"amount" json:json];
        else if ([self jsonHasKey:@"cjje" json:json]) self.amount = [self doubleParser:@"cjje" json:json];
        
        if ([self jsonHasKey:@"maximum" json:json]) self.maximum = [self floatParser:@"maximum" json:json];
        else if ([self jsonHasKey:@"zgcj" json:json]) self.maximum = [self floatParser:@"zgcj" json:json];
        
        if ([self jsonHasKey:@"minimum" json:json]) self.minimum = [self floatParser:@"minimum" json:json];
        else if ([self jsonHasKey:@"zdcj" json:json]) self.minimum = [self floatParser:@"zdcj" json:json];
        
        if ([self jsonHasKey:@"realprice" json:json]) self.realprice = [self floatParser:@"realprice" json:json];
        else if ([self jsonHasKey:@"zjcj" json:json]) self.realprice = [self floatParser:@"zjcj" json:json];
        
        if ([self jsonHasKey:@"stockdate" json:json]) self.stockdate = [self intParser:@"stockdate" json:json];
        else if ([self jsonHasKey:@"date" json:json]) self.stockdate = [self intParser:@"date" json:json];
        
        if ([self jsonHasKey:@"stockname" json:json]) self.stockname = [self stringParser:@"stockname" json:json];
        else if ([self jsonHasKey:@"jc" json:json]) self.stockname = [self stringParser:@"jc" json:json];
        
        if ([self jsonHasKey:@"stocktime" json:json]) self.stocktime = [self stringParser:@"stocktime" json:json];
        else if ([self jsonHasKey:@"time" json:json]) {
            self.stocktime = [self stringParser:@"time" json:json];
            NSString *time = [VeDateUtil dateFormatterWithyyyyMMddHHmmToMMddHHmm:self.stocktime];
            if (time && time.length == 8) {
                self.stockdate = [time intValue];
            }
        }
        
        if ([self jsonHasKey:@"todayopen" json:json]) self.todayopen = [self floatParser:@"todayopen" json:json];
        else if ([self jsonHasKey:@"jrkp" json:json]) self.todayopen = [self floatParser:@"jrkp" json:json];
        
        if ([self jsonHasKey:@"volume" json:json]) self.volume = [self longlongParser:@"volume" json:json];
        else if ([self jsonHasKey:@"cjsl" json:json]) self.volume = [self longlongParser:@"cjsl" json:json];
        
        if ([self jsonHasKey:@"yesterday" json:json]) self.yesterday = [self floatParser:@"yesterday" json:json];
        else if ([self jsonHasKey:@"zrsp" json:json]) self.yesterday = [self floatParser:@"zrsp" json:json];
    }
    return self;
}

/**
 *  和以前的数据的Key有点不同,所以开这个方法,其他地方不用
 *
 *  @param json <#json description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithJsonOther:(NSDictionary *)json {
    self = [super init];
    if (self && json) {
        self.bar = [self floatParser:@"bar" json:json];
        self.dea = [self floatParser:@"dea" json:json];
        self.dif = [self floatParser:@"dif" json:json];
        self.ema12 = [self floatParser:@"ema12" json:json];
        self.ema26 = [self floatParser:@"ema26" json:json];
        self.kdjd = [self floatParser:@"kdjd" json:json];
        self.kdjj = [self floatParser:@"kdjj" json:json];
        self.kdjk = [self floatParser:@"kdjk" json:json];
        self.m10 = [self floatParser:@"m10" json:json];
        self.m20 = [self floatParser:@"m20" json:json];
        self.m5 = [self floatParser:@"m5" json:json];
        self.vm10 = [self doubleParser:@"vm10" json:json];
        self.vm5 = [self doubleParser:@"vm5" json:json];
        self.rate = [self floatParser:@"rate" json:json];
        self.amt = [self floatParser:@"amt" json:json];
        
        if ([self jsonHasKey:@"symbol" json:json]) self.fullcode = [self stringParser:@"symbol" json:json];
        else if ([self jsonHasKey:@"fdm" json:json]) self.fullcode = [self stringParser:@"fdm" json:json];
        
        if ([self jsonHasKey:@"amount" json:json]) self.amount = [self doubleParser:@"amount" json:json];
        else if ([self jsonHasKey:@"cjje" json:json]) self.amount = [self doubleParser:@"cjje" json:json];
        
        if ([self jsonHasKey:@"maximum" json:json]) self.maximum = [self floatParser:@"maximum" json:json];
        else if ([self jsonHasKey:@"zgcj" json:json]) self.maximum = [self floatParser:@"zgcj" json:json];
        
        if ([self jsonHasKey:@"minimum" json:json]) self.minimum = [self floatParser:@"minimum" json:json];
        else if ([self jsonHasKey:@"zdcj" json:json]) self.minimum = [self floatParser:@"zdcj" json:json];
        
        if ([self jsonHasKey:@"realprice" json:json]) self.realprice = [self floatParser:@"realprice" json:json];
        else if ([self jsonHasKey:@"zjcj" json:json]) self.realprice = [self floatParser:@"zjcj" json:json];
        
        if ([self jsonHasKey:@"stockdate" json:json]) self.stockdate = [self integerParser:@"stockdate" json:json];
        else if ([self jsonHasKey:@"date" json:json]) self.stockdate = [self integerParser:@"date" json:json];
        
        if ([self jsonHasKey:@"stockname" json:json]) self.stockname = [self stringParser:@"stockname" json:json];
        else if ([self jsonHasKey:@"jc" json:json]) self.stockname = [self stringParser:@"jc" json:json];
        
        if ([self jsonHasKey:@"stocktime" json:json]) self.stocktime = [self stringParser:@"stocktime" json:json];
        else if ([self jsonHasKey:@"time" json:json]) {
            self.stocktime = [self stringParser:@"time" json:json];
            NSString *time = [VeDateUtil dateFormatterWithyyyyMMddHHmmToMMddHHmm:self.stocktime];
            if (time && time.length == 8) {
                self.stockdate = [time intValue];
            }
        }
        
        if ([self jsonHasKey:@"todayopen" json:json]) self.todayopen = [self floatParser:@"todayopen" json:json];
        else if ([self jsonHasKey:@"jrkp" json:json]) self.todayopen = [self floatParser:@"jrkp" json:json];
        
        if([self jsonHasKey:@"todayopen" json:json]){
            self.todayOpenString = [self stringParser:@"todayopen" json:json];
        }
        
        if ([self jsonHasKey:@"volume" json:json]) self.volume = [self longlongParser:@"volume" json:json];
        else if ([self jsonHasKey:@"cjsl" json:json]) self.volume = [self longlongParser:@"cjsl" json:json];
        
        if ([self jsonHasKey:@"yesterday" json:json]) self.yesterday = [self floatParser:@"yesterday" json:json];
        else if ([self jsonHasKey:@"zrsp" json:json]) self.yesterday = [self floatParser:@"zrsp" json:json];
    }
    return self;
}


- (void)createOneUserOpp:(NSDictionary *)dic {
    if (dic && dic.count > 0 && self.stockdate > 0) {
        NSString *key = [NSString stringWithFormat:@"%@",@(self.stockdate)];
        KLineUserOpp *item = dic[key];
        if (item) {
            self.b1s2 = item.b1s2;
            self.score = item.score;
            self.face = item.face;
            self.type = item.type;
        }
    }
}

/**
 *  专为圈子里的K线
 *
 *  @param json json description
 *  @param jrkp 开盘偏移值
 *  @param zgcj 最高偏移值
 *  @param zdcj 最低偏移值
 *  @param zjcj 收盘偏移值
 *
 *  @return return value description
 */
- (instancetype)initWithJson:(NSDictionary *)json jrkp:(CGFloat)jrkp zgcj:(CGFloat)zgcj zdcj:(CGFloat)zdcj zjcj:(CGFloat)zjcj {
    self = [self initWithJson:json];
    if (self) {
        self.maximum += zgcj;
        self.minimum += zdcj;
        self.realprice += zjcj;
        self.todayopen += jrkp;
    }
    return self;
}

/**
 *    将初始的MACD和KDJ参数赋到对应K线里
 *    @param item MACD和KDJ参数
 */
- (void)createKDJAndMacd:(KLine *)item {
	if (!item || (self.stockdate != item.stockdate)) return;

	self.kdjk = item.kdjk;
	self.kdjd = item.kdjd;
	self.kdjj = item.kdjj;
	self.ema12 = item.ema12;
	self.ema26 = item.ema26;
	self.bar = item.bar;
	self.dif = item.dif;
	self.dea = item.dea;
	self.isHasIndex = YES;
}

- (NSComparisonResult)compareKeysByDes:(id)otherObject {
	if ([self stockdate] < [otherObject stockdate]) {
		return NSOrderedDescending;
	} else if ([self stockdate] > [otherObject stockdate]) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (NSComparisonResult)compareKeysByAsc:(id)otherObject {
	if ([[self stocktime] integerValue] > [[otherObject stocktime] integerValue]) {
		return NSOrderedDescending;
	} else if ([[self stocktime] integerValue] < [[otherObject stocktime] integerValue]) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (NSComparisonResult)compareIndexByDes:(KLine *)otherObject {
	if ([self index] < [otherObject index]) {
		return NSOrderedDescending;
	} else if ([self index] > [otherObject index]) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (NSComparisonResult)compareIndexByAsc:(KLine *)otherObject {
	if ([self index] > [otherObject index]) {
		return NSOrderedDescending;
	} else if ([self index] < [otherObject index]) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (id)copyWithZone:(NSZone *)zone {
	KLine *copy = [[KLine allocWithZone:zone] init];

	copy->_amount = _amount;
	copy->_index = _index;
	copy->_bar = _bar;
	copy->_dea = _dea;
	copy->_dif = _dif;
	copy->_ema12 = _ema12;
	copy->_ema26 = _ema26;
	copy->_fullcode = [_fullcode copy];
	copy->_kdjd = _kdjd;
	copy->_kdjj = _kdjj;
	copy->_kdjk = _kdjk;
	copy->_m10 = _m10;
	copy->_m20 = _m20;
	copy->_m5 = _m5;
	copy->_maximum = _maximum;
	copy->_minimum = _minimum;
	copy->_realprice = _realprice;
	copy->_shtTime = _shtTime;
	copy->_shtDay = _shtDay;
	copy->_stockdate = _stockdate;
	copy->_stockname = [_stockname copy];
	copy->_stocktime = [_stocktime copy];
	copy->_todayopen = _todayopen;
	copy->_vm20 = _vm20;
	copy->_vm10 = _vm10;
	copy->_vm5 = _vm5;
	copy->_volume = _volume;
	copy->_yesterday = _yesterday;
	copy->_rate = _rate;
	copy->_amt = _amt;
	copy->_type = _type;
	copy->_face = _face;
	copy->_b1s2 = _b1s2;
	copy->_score = _score;
	return copy;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return [self copyWithZone:zone];
}
//- (id)mutableCopyWithZone:(NSZone *)zone {
//	KLine *copy = NSCopyObject(self, 0, zone);
//
//    copy->_amount = [_amount copy];
//    copy->_index = _index;
//	copy->_bar = _bar;
//	copy->_dea = _dea;
//	copy->_dif = _dif;
//	copy->_ema12 = _ema12;
//	copy->_ema26 = _ema26;
//	copy->_fullcode = [_fullcode copy];
//	copy->_kdjd = _kdjd;
//	copy->_kdjj = _kdjj;
//	copy->_kdjk = _kdjk;
//	copy->_m10 = _m10;
//	copy->_m20 = _m20;
//	copy->_m5 = _m5;
//	copy->_maximum = _maximum;
//	copy->_minimum = _minimum;
//	copy->_realprice = _realprice;
//	copy->_stockdate = _stockdate;
//	copy->_stockname = [_stockname copy];
//	copy->_stocktime = [_stocktime copy];
//	copy->_todayopen = _todayopen;
//	copy->_vm10 = _vm10;
//	copy->_vm5 = _vm5;
//	copy->_volume = _volume;
//	copy->_yesterday = _yesterday;
//	copy->_rate = _rate;
//	copy->_amt = _amt;
//	copy->_type = _type;
//	copy->_face = _face;
//	copy->_b1s2 = _b1s2;
//	copy->_score = _score;
//	return copy;
//}

@end

