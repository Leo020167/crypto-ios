//
//  KLine.h
//  Http
//
//  Created by  on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"

@interface KLineUserOpp : TJRBaseEntity
@property (nonatomic, assign) int type;	/* type=1代表做多，type=-1代表做空,type=0代表平仓 */
@property (nonatomic, assign) int face;
@property (nonatomic, assign) int b1s2;	/* 1代表买，2代表卖 */
@property (nonatomic, assign) CGFloat score;// 收益率
@end

@class CircleGameKLineBoxUserEntity;
@interface KLine : TJRBaseEntity <NSCopying, NSMutableCopying>

@property (nonatomic, assign) CGFloat amount;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) CGFloat bar;
@property (nonatomic, assign) CGFloat dea;
@property (nonatomic, assign) CGFloat dif;
@property (nonatomic, assign) CGFloat ema12;
@property (nonatomic, assign) CGFloat ema26;
@property (nonatomic, copy) NSString *fullcode;
@property (nonatomic, assign) CGFloat kdjd;
@property (nonatomic, assign) CGFloat kdjj;
@property (nonatomic, assign) CGFloat kdjk;
@property (nonatomic, assign) CGFloat m10;
@property (nonatomic, assign) CGFloat m20;
@property (nonatomic, assign) CGFloat m30;
@property (nonatomic, assign) CGFloat m5;
@property (nonatomic, assign) CGFloat maximum;
@property (nonatomic, assign) CGFloat minimum;
@property (nonatomic, assign) CGFloat realprice;
@property (nonatomic, assign) NSUInteger stockdate;
@property (nonatomic, assign) NSUInteger shtTime;// 零点以来的分钟数
@property (nonatomic, assign) NSUInteger shtDay;// 表示日期MMDD，比如223就表示2月23号
@property (nonatomic, copy) NSString *stockname;
@property (nonatomic, copy) NSString *stocktime;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, assign) CGFloat todayopen;
@property (nonatomic, copy) NSString *todayOpenString;
@property (nonatomic, assign) CGFloat vm10;
@property (nonatomic, assign) CGFloat vm5;
@property (nonatomic, assign) CGFloat vm20;
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) CGFloat yesterday;
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) CGFloat amt;
@property (nonatomic, assign) int type;	/* type=1代表做多，type=-1代表做空,type=0代表平仓 */
@property (nonatomic, assign) int face;
@property (nonatomic, assign) int b1s2;	/* 1代表买，2代表卖 */
@property (nonatomic, assign) CGFloat score;// 收益率
@property (nonatomic, assign) BOOL isHasIndex;	/* 是否有参数指标 */
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
- (instancetype)initWithJson:(NSDictionary *)json jrkp:(CGFloat)jrkp zgcj:(CGFloat)zgcj zdcj:(CGFloat)zdcj zjcj:(CGFloat)zjcj;
/**
 *  和以前的数据的Key有点不同,所以开这个方法,其他地方不用
 *
 *  @param json <#json description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithJsonOther:(NSDictionary *)json;
- (void)createOneUserOpp:(NSDictionary *)dic;
/**
 *    将初始的MACD和KDJ参数赋到对应K线里
 *    @param item MACD和KDJ参数
 */
- (void)createKDJAndMacd:(KLine *)item;

- (NSComparisonResult)compareKeysByDes:(id)otherObject;
- (NSComparisonResult)compareKeysByAsc:(id)otherObject;
- (NSComparisonResult)compareIndexByDes:(KLine *)otherObject;
- (NSComparisonResult)compareIndexByAsc:(KLine *)otherObject;

@end

