//
//  KLineCoordinate.h
//  Http
//
//  Created by  on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLineCoordinate : NSObject 
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) float coordinateX;
@property (nonatomic, assign) CGFloat coordinateY;
@property (nonatomic, assign) float maximum;
@property (nonatomic, assign) float minimum;
@property (nonatomic, assign) float realprice;
@property (nonatomic, assign) NSUInteger stockdate;
@property (nonatomic, assign) float todayopen;
@property (nonatomic, assign) float amt;// 收盘价与开盘价的差值(收盘价大于开盘价为1,相等为0,收盘价小于开盘价为-1)
@property (nonatomic, assign) float rate;
@property (nonatomic, assign) float yesterday;
@property (nonatomic, assign) float M5;
@property (nonatomic, assign) float M10;
@property (nonatomic, assign) float M20;
@property (nonatomic, assign) float M30;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float VM5;
@property (nonatomic, assign) float VM10;
@property (nonatomic, assign) float VM20;
@property (nonatomic, assign) float KDJK;
@property (nonatomic, assign) float KDJD;
@property (nonatomic, assign) float KDJJ;
@property (nonatomic, assign) float dif;
@property (nonatomic, assign) float dea;
@property (nonatomic, copy) NSString *stockTime;
@property (nonatomic, assign) float bar;
@property (nonatomic, assign) int b1s2;//1代表买，2代表卖
@property (nonatomic, assign) int face;
@property (nonatomic, assign) NSUInteger shtTime;// 零点以来的分钟数
@property (nonatomic, assign) NSUInteger shtDay;// 表示日期MMDD，比如223就表示2月23号

- (void)setAmt:(double)price today:(double)today;
- (NSComparisonResult)compareKeysByDes:(id)otherObject;
- (NSComparisonResult)compareKeysByAsc:(id)otherObject;

@end
